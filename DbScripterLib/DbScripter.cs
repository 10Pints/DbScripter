// using System;
// using System.Collections.Generic;
// using System.Diagnostics.Eventing.Reader;
// using System.IO;
// using System.Linq;
// using System.Runtime.Remoting.Messaging;
using CommonLib;
using CommonLib.Extensions;

using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.HadrModel;
using Microsoft.SqlServer.Management.Sdk.Sfc;
using Microsoft.SqlServer.Management.Smo;

using NLog.Filters;

using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics.Eventing.Reader;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Linq;

using Windows.ApplicationModel.Background;
using Windows.Globalization;

using static Azure.Core.HttpHeader;
using static CommonLib.Logger;
using static CommonLib.Utils;
using static System.Net.Mime.MediaTypeNames;

namespace DbScripterLibNS
{
   public class DbScripter
   {
      public Params P { get; private set;} 
      public StreamWriter? Writer { get; private set; }
      public Database Database { get => database ?? new Database() ; private set => database = value; }
      private Database? database = null;


      // SortedListCollectionBase : SmoCollectionBase
      private Dictionary<SqlTypeEnum, SortedListCollectionBase> DbCollmap = new Dictionary<SqlTypeEnum, SortedListCollectionBase>();

      public Server Server { get; private set; } = new Server();
      public ScriptingOptions ScriptOptions { get; private set; } = new ScriptingOptions();
      public string FileName { get; set; } = "";

      // These properties are info caches for the scripted items
      public Dictionary<SqlTypeEnum, SortedList<string, string>> ExportedItems { get; protected set; } = new Dictionary<SqlTypeEnum, SortedList<string, string>> ();
      
      public SortedList<string, string> BadBin { get; protected set; } = new SortedList<string, string>();
      /*public SortedList<string, string> ExportedDatbases { get; protected set; } = new SortedList<string, string>(new StringCompareNoCase());
      public SortedList<string, string> ExportedSchemas { get; protected set; } = new SortedList<string, string>(new StringCompareNoCase());
      public SortedList<string, string> ExportedTables { get; protected set; } = new SortedList<string, string>(new StringCompareNoCase());
      public SortedList<string, string> ExportedProcedures { get; protected set; } = new SortedList<string, string>(new StringCompareNoCase());
      public SortedList<string, string> ExportedFunctions { get; protected set; } = new SortedList<string, string>(new StringCompareNoCase());
      public SortedList<string, string> ExportedViews { get; protected set; } = new SortedList<string, string>(new StringCompareNoCase());
      public SortedList<string, string> ExportedTableTypes { get; protected set; } = new SortedList<string, string>();
      */
      

      // dependency eval
      public SortedList<string, string> WantedItems { get; protected set; } = new SortedList<string, string>();
      public SortedList<string, string> ConsisderedEntities { get; protected set; } = new SortedList<string, string>();
      public SortedList<string, string> DifferentDatabases { get; protected set; } = new SortedList<string, string>();
      public SortedList<string, string> DuplicateDependencies { get; protected set; } = new();
      public SortedList<string, string> SystemObjects { get; protected set; } = new SortedList<string, string>();
      public SortedList<string, string> UnresolvedEntities { get; protected set; } = new SortedList<string, string>();
      public SortedList<string, string> UnwantedSchemas { get; protected set; } = new SortedList<string, string>();
      public SortedList<string, string> UnwantedTypes { get; protected set; } = new SortedList<string, string>();
      public SortedList<string, string> UnknownEntities { get; protected set; } = new SortedList<string, string>();

      public SortedList<string, string> PrintedItems { get; protected set; } = new SortedList<string, string>();
      //public Dictionary<SqlTypeEnum, List<string> > RequiredItemMap { get; private set; } = new Dictionary<SqlTypeEnum, List<string>>();

      private int _exportedItemCnt = 0;

      public DbScripter()
      {
         P = new Params();
      }

      /// <summary>
      /// Initializes
      /// </summary>
      /// <param name="args"></param>
      /// <param name="msg"></param>
      /// <returns></returns>
      public bool Init(string? configFile, out string msg)
      {
         LogS();
         bool ret = false;

         do
         {
            if (!P.Init(configFile, out msg))
               break;
            //c
            SqlTypeEnum[]? weekendDays = Enum.GetValues<SqlTypeEnum>();
            //ExportedItems  = new Dictionary<SqlTypeEnum, SortedList<string, string>>();

            foreach(var ty in Enum.GetValues<SqlTypeEnum>())
               ExportedItems[ty] = new SortedList<string, string>(new StringCompareNoCase());

            // Create the server object and makes a connection, throws exception otherwise
            if (!InitServer(P.Server ?? "", P.Instance ?? "", out msg))
               break;

            if (!InitDatabase(P.Database, out msg))
               break;

            if (!InitScriptingOptions(out msg))
               break;

            //if (!InitWriter(out msg)) // Do later to avoid test issues with opene files
            //   break;

            ret = true;
         } while(false);

         return LogR(ret);
      }

      /// <summary>
      /// The Main entry point for exporting scripts
      /// Design: EA: Model.Use Case Model.Save a selection of items 1 item per file.Export.Export_ActivityGraph.Export Files Act
      /// 
      /// Preconditions
      ///   Logger init
      ///   Params init
      ///   Database init
      ///   
      /// Postconditions:
      /// POST 01: ret = true and schema objects exported to the named export file
      ///          OR (error AND ret = 0 and suitable error msg)
      /// </summary>
      /// <param name="msg"></param>
      /// <returns></returns>
      public bool Export(out string msg)
      {
         LogS("Main entry point for exporting scripts");

         // Validate Specialise the Options config for this op
         if (!ExportInit(out msg))
            return false;

         StringBuilder sb = new();

         // Script the output file header if a composite file
         ScriptCompositeHdr(sb);

         // Get the Filter Root smo objects Urns from the required filter config
         Dictionary<SqlTypeEnum, List<Urn>>? urn_map = GetFilterUrns();

         // Get all the required root items (or all if not spec)
         HashSet<Urn> rootUrns = GetRootUrns(urn_map);

         // Get the root items and their dependencies items to script.
         /*/ Create the schema dependency walk returns false if no items
         if (!GetItemsToScript(rootUrns, (P.CreateMode == CreateModeEnum.Create || P.CreateMode == CreateModeEnum.Alter), out List<Urn> walk, out msg))
         {
            // This is not an error - if the database has no items to script given the criteria
            // if GetSchemaDependencyWalk() encounters an error then it will throw exception
            // script = "";
            return LogR(true, "the database has no items to script given the criteria");
         }
         */

         // Create a walk of smo items to script in dependency order
         List<Urn> walk = GetDependencyWalk
            (
               rootUrns, 
               (P.CreateMode == CreateModeEnum.Create || P.CreateMode == CreateModeEnum.Alter)
            );

         // Export the required objects in dependency order
         LogN("Stage 2 : export the required objects in dependency order");
         // if ExportSchemas returns false then no items were found to script
         //if (!ExportSchemas(sb, out string script, out msg))
         //   return false; ;
         // Add the use db statement if required
         if (P.ScriptUseDb)
            ScriptUse(sb);

         int i = 0;
         // Script the items to text file and add to the main script
         foreach (Urn urn in walk)
            sb.AppendLine(ScriptItemToFile(++i, urn));

         // Write the script to sql file
         string sql = sb.ToString();
         File.WriteAllText("D:\\Dev\\DbScripter\\DbScripterLibTests\\Scripts\\out.sql", sql);
         sb.Clear();

         // Finally
         return LogR(true);
      }

      private void ScriptCompositeHdr(StringBuilder sb)
      {
         // If a composite file create the output file header
         if (!P.IndividualFiles)
         {
            ScriptLine($"/*", sb);
            ScriptLine($"Parameters:", sb);
            ScriptLine($"{P}*/\r\n\r\n", sb);
         }
      }

      private bool ValidateExportPreconditions(out string msg)
      {
         LogS();
         bool ret = false;

         do
         { 
            if(!IsValid(out msg))
               break;

            // Pre 2: Create type is not alter
            if(P.CreateMode == CreateModeEnum.Error)
            {
               msg = "create mode must be defined";
               break;
            }

            if (Params.Config == null)
            {
               msg = "Params.config not initialzed";
               break;
            }

            //if (!P.IsValid(out msg)) break; // already checked

            if (database == null)
            {
               msg = "E0002: Precondition violation: Database not specified";
               break;
            }

            msg = "";
            ret = true;
         } while(false);

         if(!ret)
            LogE(msg);

         return LogR(ret);
      }

      /// <summary>
      /// This gets all the root urns filtered by the filters
      /// </summary>
      /// <param name="urn_map"></param>
      /// <returns></returns>
      public HashSet<Urn> GetRootUrns(Dictionary<SqlTypeEnum, List<Urn>> urn_map)
      {
         LogS();
         HashSet< Urn>? root_urns = new HashSet<Urn>();

         foreach (SqlTypeEnum e  in Enum.GetValues<SqlTypeEnum>())
            GetUrnsOfType(e, root_urns, urn_map);

         LogL();
         return root_urns;
      }

      /*
      protected void GetAssemblies(HashSet<Urn> root_urns, Dictionary<SqlTypeEnum, List<Urn>> urn_map)
      {
         GetUrnsOfType(SqlTypeEnum.Assembly, root_urns, urn_map);
      }

      private void GetTables(HashSet<Urn> root_urns, Dictionary<SqlTypeEnum, List<Urn>> urn_map)
      {
         GetUrnsOfType(SqlTypeEnum.Table, root_urns, urn_map);
      }

      private void GetViews(HashSet<Urn> root_urns, Dictionary<SqlTypeEnum, List<Urn>> urn_map)
      {
         GetUrnsOfType(SqlTypeEnum.View, root_urns, urn_map);
      }

      private void GetFunctions(HashSet<Urn> root_urns, Dictionary<SqlTypeEnum, List<Urn>> urn_map)
      {
         GetUrnsOfType(SqlTypeEnum.Function, root_urns, urn_map);
      }

      private void StoredProcedures(HashSet<Urn> root_urns, Dictionary<SqlTypeEnum, List<Urn>> urn_map)
      {
         GetUrnsOfType(SqlTypeEnum.StoredProcedure, root_urns, urn_map);
      }
      */

      /// <summary>
      /// Gets the urns of a type
      /// if the corresponding WantAll flag is set then all of that type from the Database
      /// else just the required ones as specifiec in the corresponding required config
      /// </summary>
      /// <param name="type"></param>
      /// <param name="root_urns"></param>
      /// <param name="urn_map"></param>
      protected void GetUrnsOfType(SqlTypeEnum type, HashSet<Urn> root_urns, Dictionary<SqlTypeEnum, List<Urn>> urn_map)
      {
         if (P.WantAll(type))
            foreach (dynamic item in Database.Assemblies)
               root_urns.Add(item.Urn);
         else
            if(urn_map.ContainsKey(type)) // urn_map may not contain all types 
               foreach (var urn in urn_map[type])
                  root_urns.Add(urn);
      }

      /// <summary>
      /// gets the list of filter urns but no databases or Schemas
      /// This list can be used to get dependencies
      /// </summary>
      /// <returns></returns>
      public Dictionary<SqlTypeEnum, List<Urn>> GetFilterUrns()
      {
         Dictionary<SqlTypeEnum, List<Urn>> map = new Dictionary<SqlTypeEnum, List<Urn>>();

         foreach(KeyValuePair<SqlTypeEnum, List<string>> pr 
            in P.RequiredItemMap.Where(pr => (pr.Key != SqlTypeEnum.Database && pr.Key != SqlTypeEnum.Schema
         )))
            map[pr.Key] = GetFilterUrns(pr.Key, DbCollmap[pr.Key]);

         return map;
      }

      /// <summary>
      /// Return the required urns for the list of filter names
      /// 
      /// </summary>
      /// <param name="list"></param>
      /// <returns></returns>
      public List<Urn> GetFilterUrns(SqlTypeEnum type, dynamic db_coll )
      {
         List<string> required_list = P.RequiredItemMap[type];
         List<Urn> list = new List<Urn>();
         SqlSmoObject? obj;

         // For each required itme:
         foreach (var q_name in required_list)
         {
            if(q_name == "*") // wild card
               continue;

            var urnStr = CreateUrn(P.Server,P.Database, q_name, type);

            // Validate the items exist in the database collection
            Urn urn = new Urn(urnStr);

            // {Server[@Name='DevI9']/Database[@Name='Farming_dev']/Schema[@Name='dbo']
            // Server[@Name='DevI9']/Database[@Name='Farming_dev']/Table[@Name='s2_UpdtCntsTbl' and @Schema='test']
            // Server[@Name='DevI9']/Database[@Name='Farming_dev']/Table[@Name='Cleanup' and @Schema='test']

            try { obj = Server?.GetSmoObject(urn); }
            catch(Microsoft.SqlServer.Management.Smo.FailedOperationException)
            {
               LogC($"schema: [{q_name}] not found in database - continuing the script ...");
               continue;
            }

            if (obj == null)
            {
               // continue if schema not found as we re calling this in a loop, and not all databases might have all the required schema
               LogC($"schema: [{q_name}] not found in database - continuing the script ...");
               continue;
            }

            LogI($"Adding {type.GetAlias2()} {q_name} to the filter list");
            list.Add(urn);
         }

         return list;
      }

      /// <summary>
      /// sole access to writing to the file/ stringbuilder
      /// </summary>
      /// <param name="line"></param>
      /// <param name="sb"></param>
      protected void ScriptLine(string line, StringBuilder? sb = null)
      {
         if (!line.EndsWith("\r\n"))
            line += ("\r\n");

         Writer?.Write(line);
         sb?.Append(line);
      }

      /// <summary>
      /// Initializes file writer if writerFilePath is a valid path
      /// if file not specified issues a warning, closes the writer
      /// if the file exists prior to this call then it is deleted - exception if not possible to delete
      /// calls IsValid at end
      /// 
      /// Utils.PreconditionS: exportScript path is not null
      ///   
      /// POSTCONDITIONS:
      /// POST 1: writer open pointing to the export file AND
      ///       writer file same as ExportFilePath and both equal exportFilePath parameter
      /// POST 2: sets ScriptFile from P.ExportScript path or error if not specified
      /// </summary>
      /// <param name="exportFilePath"></param>
      /// <param msg="possible error/warning message"></param>
      /// <returns>success of the writer initialisation</returns>
      protected bool InitWriter(out string msg)
      {
         string scriptFile = P.ScriptFile ?? "";
         LogS($"Script file: [{scriptFile}]");
         bool ret = false;

         try
         {
            do
            {
               // Close the writer
               CloseWriter();

               // POST 2
               Precondition(!string.IsNullOrEmpty(scriptFile), "exportScriptPath must be specified");

               // ASSERTION: writer intialised
               string? directory = Path.GetDirectoryName(scriptFile);

               if(directory == null)
                  throw new Exception("directory not specified");

               if (!Directory.Exists(directory))
                  Directory.CreateDirectory(directory);

               // ASSERTION: directory exists

               if (File.Exists(scriptFile))
                  File.Delete(scriptFile);

               // ASSERTION: scriptFile does not exist

               var fs = new FileStream(scriptFile, FileMode.CreateNew);
               Writer = new StreamWriter(fs) { AutoFlush = true }; // writerFilePath AutoFlush = true debug to dump cache immediately

               // POST 1: writer open pointing to the export file AND
               //         writer file same as ExportFilePath and both equal exportFilePath parameter
               if ((Writer == null) ||
                         !((FileStream)(Writer.BaseStream)).Name.Equals(P.ScriptFile, StringComparison.OrdinalIgnoreCase))
               {
                  msg = "Writer not initialised properly";
                  break;
               }

               // ASSERTION: writer intialised and target file has been created and is empty

               ret = true;
               msg = "";
            } while (false);
         }
         catch (Exception e)
         {
            msg = e.Message;
            LogException(e);
            CloseWriter();
         }

         // POST 4: <returns>true if successful, false and msg populated otherwise</returns>
         if (!ret)
         {
            LogE($"there was an error: {msg}");
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");
         }

         return LogR(ret, "writer init OK");
      }

      /// <summary>
      /// Single point of entry, also used in testing
      /// </summary>
      protected void CloseWriter()
      {
         LogS();
         Writer?.Close();
         LogL();
      }

      /*// <summary>
      /// Exports the script
      /// 
      /// Preconditions:
      /// 
      /// 
      /// Postconditions:
      /// 
      /// 
      /// </summary>
      /// <param name="sb"></param>
      /// <param name="script"></param>
      /// <param name="msg"></param>
      /// <returns></returns>
      protected bool ExportSchemas(StringBuilder sb, out string script, out string msg)
      {
         LogS();
         msg = "";
         script = "";
         bool ret = false;

         try
         {
            do
            {
               // Specialise the Options config for this op
               //ExportSchemasInit(); done already

               // Create a list of SMO schema objects
               List<Schema> schemas = new();

               // Create and add the required Schema smo objects to the schema obj list
               // Schemas[] is case insensitve
               foreach (var schemaName in P.RequiredSchemas)
               {
                  LogDirect($"Adding {schemaName} to the schema list");
                  var schema = Database.Schemas[schemaName];

                  if(schema != null)
                     schemas.Add(schema);
               }

               // Assertion we have a list of children

               // Add the use db statement if required
               if (P.ScriptUseDb)
                  ScriptUse(sb);

               // If creating then create the schemas now
               // test schemas need to be registerd with the tSQLt framework
               // if altering dont create the schemas
               if (P.CreateMode == CreateModeEnum.Create)
                  ScriptCreateSchemas(schemas, sb);

               LogC("DbScripter.Export Stage 3: Get Schema Dependencies Walk...");

               // Create the schema dependency walk returns false if no items
               if (!GetItemsToScript((P.CreateMode == CreateModeEnum.Create || P.CreateMode == CreateModeEnum.Alter),out List<Urn> walk, out msg))
               {
                  // This is not an error - if the database has no items to script given the criteria
                  // if GetSchemaDependencyWalk() encounters an error then it will throw exception
                  script = "";
                  ret = true;
                  break;
               }

               int i = 0;
               msg = $"Stage 4: scripting {walk.Count} schema objects";
               LogC(msg);

               // Assertion
               // 241122: [tSQLt].[@tSQLt:RunOnlyOnHostPlatform] causes eror we take @tSQLt not @tSQLt:RunOnlyOnHostPlatform
               // Script the items
               foreach (Urn urn in walk)
                  ScriptItemToFile(++i, urn);

               ret = true;
               msg = "";
               script = sb.ToString();
               LogDirect($"Stage 5: all completed successfully");
         
               // finally
               ret =  true;
            } while(false);
         }
         catch (Exception e)
         {
            msg = e.Message;
            LogC($"DbScripter.Export caught exception {e}");
            LogException(e);//, $"key: {key}");
            throw;
         }

         return LogR(ret);
      }*/

      /// <summary>
      /// Performs the Init for the Export, givne the main DbScripter.Init has been called.
      /// 
      /// Process:
      ///   Validate Preconditions
      ///   Open the script file
      ///   Set the script config
      /// </summary>
      /// <param name="msg"></param>
      /// <returns></returns>
      protected bool ExportInit(out string msg)
      {
         LogS();

         // Validate Preconditions
         if (! ValidateExportPreconditions(out msg))
            return LogR(false, $"ValidateExportPreconditions failed: {msg}");

         // Open the script file
         if (!InitWriter(out msg))
            return LogR(false, $"InitWriter failed: {msg}");

         // Set the script config
         ScriptOptions.AllowSystemObjects       = false;
         ScriptOptions.ContinueScriptingOnError = false;
         ScriptOptions.ChangeTracking           = false;
         ScriptOptions.ClusteredIndexes         = true;
         ScriptOptions.Default                  = true;
         ScriptOptions.DriAll                   = true;
         ScriptOptions.DriAllConstraints        = true;
         ScriptOptions.DriAllKeys               = true;
         ScriptOptions.DriChecks                = true;
         ScriptOptions.DriClustered             = true;
         ScriptOptions.DriDefaults              = true;
         ScriptOptions.DriForeignKeys           = true;
         ScriptOptions.DriIndexes               = true;
         ScriptOptions.DriPrimaryKey            = true;
         ScriptOptions.DriUniqueKeys            = true;
         ScriptOptions.IncludeHeaders           = false;
         ScriptOptions.Indexes                  = true;
         ScriptOptions.NoCommandTerminator      = false;
         ScriptOptions.PrimaryObject            = true;
         ScriptOptions.NoAssemblies             = false;

         return LogR(true);
      }

      /*// <summary>
      /// PRE: P.RequiredTypes not null
      /// 
      /// POST:RequiredTypes contains Type
      /// </summary>
      protected void EnsureRequiredTypesContainsType(SqlTypeEnum sqlType)
      {
         Utils.Precondition((P.RequiredTypes?.Count ?? 0) > 0, "Target Types are not defined");

         if (!(P.RequiredTypes?.Contains(sqlType)?? true))
            P.RequiredTypes.Add(sqlType);
      }
      */

      protected void ScriptUse(StringBuilder sb) //, bool onlyOnce = false)
      {
         LogS();
         ScriptLine($"USE [{Database.Name}]", sb);
         //ScriptGo(sb); // new way of scripting adds gos at the start of the next of the next statement
         // so we are getting 2 gos

         //if (onlyOnce)
         //   ScriptOptions.IncludeDatabaseContext = false;

         LogL();
      }

      protected void ScriptCreateSchemas(List<Schema> schemas, StringBuilder sb)
      {
         // If creating then create the schemas now
         // test schemas need to be registerd with the tSQLt framework
         // if altering dont create the schemas
         LogC("DbScripter.Export Stage 2: scripting schema create sql...");

         foreach (var schema in schemas)
         {
            if (IsTestSchema(schema.Name))
               ScriptLine($"EXEC tSQLt.NewTestClass '{schema.Name}';", sb);
            else
               ExportSchemaStatement(schema, sb);
         }
      }

      /// <summary>
      /// Determeintes if the  schema is a test schema and therfpre should be creeated
      /// or dropped using the tSQLt methods
      /// 
      /// PRECONDITION: schema name is valid
      ///   create mode is either create or drop not Alter or undefined
      ///   
      /// POSTCONDITIONS:
      ///   returns true if schema is using tSQLt false otherwise
      /// 
      /// </summary>
      /// <param name="schema"></param>
      /// <returns></returns>
      protected static bool IsTestSchema(string schemaName)
      {
         return schemaName.IndexOf("test", StringComparison.OrdinalIgnoreCase) > -1;
      }

      /// <summary>
      /// This will script just the create or drop schema <achewma name>
      /// N.B.: Does NOT export the child types: Tables, views, sps, fns ...
      /// 
      /// Pre: all initialisation done
      /// 
      /// PRE: Init called
      ///      P.IsExprtngSchema is true
      ///      
      /// POST: single line like CREATE Schema [schema name]; emiited
      /// 
      /// </summary>
      public string ExportSchemaStatement(Schema schema, StringBuilder sb)
      {
         //Utils.Precondition<ArgumentException>(P.IsExportingSchema == true, "Inconsistent state: P.IsExportingSchema not set but ExportSchemaStatement called");
         StringBuilder sb_ = new StringBuilder();

         try
         {
            ScriptingOptions so = new()
            {
               ScriptDrops = (P.CreateMode == CreateModeEnum.Drop),
               ScriptBatchTerminator = true
            };

            var coll = schema.Script();

            ScriptTransactions(coll, sb_, schema.Urn, wantGo: true);
            sb.Append(sb_);
         }
         catch (Exception e)
         {
            LogException(e);
            throw;
         }

         return sb_.ToString();
      }

      /// <summary>
      /// Use this when we dont need to look for the CREATE RTN statement
      /// if mode is alter and not schema or db then modify statements here
      /// tables need to drop and create
      /// </summary>
      /// <param name="transactions"></param>
      /// <param name="sb"></param>
      protected void ScriptTransactions(StringCollection? transactions, StringBuilder sb, Microsoft.SqlServer.Management.Sdk.Sfc.Urn urn, bool wantGo)
      {
         //Precondition(transactions != null, "oops: null transactions parameter");
         var key = GetUrnDetails(urn, out var type, out _, out var schemaNm, out var entityNm);

         if(transactions == null)
               throw new Exception("E0000: null transactions collection");

         if (transactions.Count > 0)
         {
            var op = P.CreateMode.GetAlias();
            //var type = MapSmoTypeToSqlType(smoType);
            int x = 0;
            bool found = false;

            // Need to put a go top and bottom of routine between the set ansi nulls etc to
            // make the export toutine the only thing in the transaction
            // only replace the alter once in the script
            foreach (string? transaction in transactions)
            {
               if(transaction != null)
               { 
                  if (wantGo)
                  {
                     string line;

                     if (!found)
                     {
                        var m = Regex.Matches(transaction, $@"^[ \t]*{op}[ \t]*(.*)", RegexOptions.Multiline | RegexOptions.IgnoreCase);
                        var numFnsAct = m.Count;

                        // Plan is to add a go before the CREATE|ALTER|DROP statement
                        if (m.Count > 0)
                        {
                           // Got the Create mode: {CREATE|ALTER|DROP}
                           line = $"{m[0].Groups[1].Value}";
                           // Signatures must have [] for this to work
                           var m2 = Regex.Matches(line, $@"{type}[ \[]*([^\]]*)([\]\.\[]+)([^\]]*)([\]\(]*)", RegexOptions.IgnoreCase);

                           if (m2.Count > 0)
                           {
                              // Got the RTN TY {CREATE|ALTER|DROP
                              // line like: "test].[fnDummy]()\r"
                              // grp 0 is the schema
                              // grp 1 is ].[
                              // grp 2 is the entityNm
                              var act_schema = m2[0].Groups[1].Value;
                              var act_entityNm = m2[0].Groups[3].Value;

                              if (schemaNm.Equals(act_schema, StringComparison.OrdinalIgnoreCase))
                              {
                                 // 2 scenarios here:
                                 // 1 is the normal one altering a schema child
                                 // 2: handling the create schema line in which case 
                                 //    (act_entityNm = "") AND (schemaNm = act_schema) AND (entityNm = schemaNm)
                                 if (entityNm.Equals(act_entityNm, StringComparison.OrdinalIgnoreCase) ||
                                    (act_entityNm.Length == 0 && schemaNm.Equals(act_schema, StringComparison.OrdinalIgnoreCase))
                                    && (schemaNm.Equals(entityNm, StringComparison.OrdinalIgnoreCase)))
                                 {
                                    // Trailing blank line after GO statement
                                    ScriptGo(sb, true);
                                    found = true;
                                 }
                                 else
                                 {
                                    LogW($"oops 1: exp_entityNm: [{entityNm}], act_entityNm: [{act_entityNm}]");
                                    ScriptGo(sb, true);
                                    found = true;
                                 }
                              }
                              else
                              {
                                 LogW($"oops 2: exp_schema: [{schemaNm}], act_schemma: [{act_schema}]");
                                 ScriptGo(sb, true);
                                 found = true;
                              }
                           }
                           else
                           {
                              //LogW($"oops 3 scripting GO before the rtn script: {line}");
                              ScriptGo(sb, true);
                           }
                        }

                        x++;
                     }
                  }

                  // Place a GO immediatly before the transaction
                  ScriptLine(transaction, sb);

                  if (WantBlankLineBetweenTransactions())
                     ScriptBlankLine(sb);
               }
            }

            if (wantGo)
               ScriptGo(sb);

            // if scripted here add to exported lists
            //AddToExportedLists( key);
         }
         else
         {
            throw new Exception($"no script produced for {key}");
         }
      }

      /// <summary>
      /// Add GO statements to for the SQL execution at that point
      /// </summary>
      /// <param name="sb"></param>
      private void ScriptGo(StringBuilder sb, bool blankLineAfter = false)
      {
         var line = GO;

         if (blankLineAfter)
            if (!line.EndsWith("\r\n"))
               line += ("\r\n");

         line += "\r\n";

         ScriptLine(line, sb);
      }

      /// <summary>
      /// If scripting drops where the transactions are 1 or 2 lines then dont want a blank line
      /// PRE: Init called
      /// </summary>
      /// <returns></returns>
      private bool WantBlankLineBetweenTransactions()
      {
         return (P.CreateMode != CreateModeEnum.Drop);//!IsDropOperation(dbOpType);
      }

      /// <summary>
      /// Adds a new line to the script file, and the string builder
      /// </summary>
      /// <param name="sb"></param>
      private void ScriptBlankLine(StringBuilder sb)
      {
         ScriptLine(Environment.NewLine, sb);
      }

      /// <summary>
      /// Creates an Urn given the details
      /// Example:
      /// UDF    urn: BuildUrn("MyDatabase", "dbo", "MyFunction", "UserDefinedFunction");
      /// schema urn: Server[@Name='DevI9']/Database[@Name='Farming_dev']/Schema[@Name='dbo']
      /// assembly:   Server[@Name='DevI9']/Database[@Name='Farming_dev']/SqlAssembly[@Name='RegEx']
      /// sp:         Server[@Name='DevI9']/Database[@Name='Farming_dev']/StoredProcedure[@Name='SetCtxFixupRowId' and @Schema='dbo']
      /// </summary>
      /// <param name="dbName"></param>
      /// <param name="schema"></param>
      /// <param name="objectName"></param>
      /// <param name="objectType"></param>
      /// <returns></returns>
      public string CreateUrn(string? server, string db, string q_name, SqlTypeEnum type)
      {
         var parts = q_name.Replace("[", "").Replace("]", "").Split('.');
         string? schema = parts.Length > 1 ? parts[0] : parts[0];
         string? name = parts.Length > 1 ? parts[1] : parts[0];
         string? s = $"Server[@Name='{server}']/Database[@Name='{db}']";

         if (type == SqlTypeEnum.Schema || type == SqlTypeEnum.Assembly)
            s= $"{s}/{type.GetAlias2()}[@Name='{name}']";

         // All other sorts
         // sp: Server[@Name='DevI9']/Database[@Name='Farming_dev']/StoredProcedure[@Name='SetCtxFixupRowId' and @Schema='dbo']
         if (type != SqlTypeEnum.Schema && type != SqlTypeEnum.Assembly)
            s = $"{s}/{type.GetAlias2()}[@Name='{name}' and @Schema='{schema}']";

         return s;
      }

      #region private fields

      private const string GO = "GO";

      #endregion private fields

      /// <summary>
      /// Gets the urn key and details
      ///
      /// Levels: 
      ///   0: Server
      ///   1: Database
      ///   2: Entity with name and possibly other attributes
      ///
      /// PRECONDITIONS:
      ///   (urn not null)
      ///
      /// POSTCONDITIONS
      ///    POST 1 returns the key as the return value and its parts as out params
      ///    POST 2 type   has been found msg: "failed to get type   from urn: {urn}");
      ///    POST 3 db     has been found msg: "failed to get schema from urn: {urn}");
      ///    POST 4 schema has been found msg: "failed to get schema from urn: {urn}");
      ///
      /// </summary>
      /// <param name="urn"></param>
      /// <param name="attr_map">map of the attribute name/value paurs for this level</param>
      /// <returns>true if found level, false otherwise</returns>
      public static string GetUrnDetails(Urn urn, out SqlTypeEnum ty1, out string dbName, out string schemaName, out string entityName)
      {
         string name;
         string ty_str = urn.Type;
         // Use the Sql types list not our names
         ty1 = ty_str.FindEnumByAlias2<SqlTypeEnum>(true);
         dbName = "";
         schemaName = "";
         entityName = "";
         var xpr = urn.XPathExpression;
         var len = xpr.Length;
         XPathExpressionBlock blok;
         List<string> schemaWantedTypes = new() { "User Defined Function", "Table", "Stored Procedure" };
         Dictionary<string, Dictionary<string, string>> attr_map = new();

         for (int level = 0; level < len; level++)
         {
            blok = xpr[level];
            name = blok.Name;
            // map of level attrs
            var map = new Dictionary<string, string>();

            foreach (var ky in (blok.FixedProperties.Keys))
            {
               string key = ky.ToString() ?? "";
               var x = blok.FixedProperties[ky];

               if(x != null)
               {
                  string s = x.ToString() ?? "";
                  string val = s.Trim(new[] { '\'' });

                  // level 1: Database
                  if (name.Equals("Database", StringComparison.OrdinalIgnoreCase))
                     dbName = val;

                  // level 1, 2: Entity with name and possibly other attributes like schema
                  if (name.Equals("Schema", StringComparison.OrdinalIgnoreCase) &&
                     key.Equals("Name", StringComparison.OrdinalIgnoreCase))
                     schemaName = val;

                  // level 2: Entity with name and possibly other attributes like schema
                  if (key.Equals("Schema", StringComparison.OrdinalIgnoreCase))
                     schemaName = val;

                  // 241128: preferred name is the level 2 name, but some objects are getting into the required list that have fewer levels
                  if (level <= 2 && key == "Name")
                     entityName = val;

                  map[key] = val;
               }
               //else Log("(x != null)");

               if(!attr_map.ContainsKey(name))
                  attr_map.Add(name, map);
            }
         }

         // POSTCONDITION checks:
         // POST 1 returns the key as the return value and its parts as out params
         //Assertion(!string.IsNullOrEmpty(ty), $"failed to get type   from urn: {urn}");

         // POST 2 database has been found msg: "failed to get type   from urn: {urn}");
         Assertion(!string.IsNullOrEmpty(dbName), $"failed to get schema from urn: {urn}");

         // POST 3 schema has been found (provided it is wanted for the type) msg: "failed to get schema from urn: {urn}");
         if ((schemaName.Length == 0) && (schemaWantedTypes.Any(s => s.Equals(ty_str, StringComparison.OrdinalIgnoreCase))))
            AssertFail($"failed to get schema from urn: {urn}");

         // POST 4 schema has been found msg: "failed to get schema from urn: {urn}");
         return GetUrnKey(ty1, dbName, schemaName, entityName);
      }

      protected static string GetUrnKey(SqlTypeEnum ty, string dbName, string schemaName, string entityName)
      {
         return $"{dbName}.{schemaName}.{entityName,-25}: {ty.GetAlias()}";
      }

      protected static string GetUrnKey(Urn urn)
      {
         return GetUrnDetails(urn, out _, out _, out _, out string _);
      }

      protected static SqlTypeEnum MapSmoTypeToSqlType(string smoType)
      {
         var ty_str = smoType.ToUpper() switch
         {
            "USERDEFINEDFUNCTION" => "FUNCTION",
            "STOREDPROCEDURE"     => "PROCEDURE",
            "ASSEMBLY"            => "ASSEMBLY",
            "TABLE"               => "Table",
            "USERDEFINEDDATATYPE$"=> "UserDefinedDataType",
            _ => smoType
         };

         return ty_str.FindEnumByAlias<SqlTypeEnum>(true);
      }


      /// <summary>
      /// Utils.PreconditionS:
      /// PRE 1:  server        instantiated
      /// PRE 2:  database name specified
      ///
      ///
      /// POSTCONDITIONS:
      /// POST 1: database smo is instantiated and connected
      /// POST 2: database state is normal
      /// POST 3: schemas exist in database smo
      /// POST 4: <returns>true if successful, false and msg populated otherwise</returns>
      /// </summary>
      /// <param name="databaseName"></param>
      protected bool InitDatabase(string? databaseName, out string msg)
      {
         LogSD();
         bool ret = false;
         msg = "";

         try
         {
            do
            {
               // -------------------------
               // Validate Utils.Preconditions
               // -------------------------

               if (Server == null)
               {
                  msg = "server not instantiated";      // PRE 1
                  break;
               }

               if (string.IsNullOrEmpty(databaseName))
               {
                  msg = "database name not specified";  // PRE 2
                  break;
               }

               // -----------------------------------------
               // ASSERTION: Utils.Preconditions validated
               // -----------------------------------------

               var databases = Server.Databases;

               if (!databases.Contains(databaseName))
                  Server.Refresh();


               if (databases.Contains(databaseName))
               {
                  Database = Server.Databases[databaseName];
               }
               else
               {
                  msg = $"database [{databaseName}] not found on server {Server.Name}";  // PRE 2
                  break;
               }

               // ASSERTION: if here then database exists

               // -------------------------
               // Validate postconditions
               // -------------------------

               /// POST: Database     instantiated and connected
               if (database == null)
               {
                  msg = $"database {databaseName} smo object not created"; // POST 1
                  break;
               }

               if ((Database.Status & DatabaseStatus.Normal) != DatabaseStatus.Normal)
               {
                  msg = $"database {databaseName} state is not normal";    // POST 2
                  break;
               }

               if (Database.Schemas.Count == 0)
               {
                  msg = $"database {databaseName} smo object not connected or no schemas exist"; // POST 3
                  break;
               }

               DbCollmap[SqlTypeEnum.Assembly]            = Database.Assemblies;
               DbCollmap[SqlTypeEnum.Schema]              = Database.Schemas;
               DbCollmap[SqlTypeEnum.Table]               = Database.Tables;
               DbCollmap[SqlTypeEnum.View]                = Database.Views;
               DbCollmap[SqlTypeEnum.Function]            = Database.UserDefinedFunctions;
               DbCollmap[SqlTypeEnum.StoredProcedure]     = Database.StoredProcedures;
               DbCollmap[SqlTypeEnum.UserDefinedDataType] = Database.UserDefinedDataTypes;
               DbCollmap[SqlTypeEnum.UserDefinedType]     = Database.UserDefinedTypes;
               DbCollmap[SqlTypeEnum.UserDefinedTableType]= Database.UserDefinedTableTypes;


               // -----------------------------------------
               // ASSERTION: postconditions validated
               // -----------------------------------------
               ret = true;
            } while (false);
         }
         catch (Exception e)
         {
            LogException(e);
            msg = e.ToString();
         }

         // POST 4: <returns>true if successful, false and msg populated otherwise</returns>
         if (!ret)
         {
            LogE($"there was an error: {msg}");
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");
         }

         return LogRD(ret, msg);
      }      /// <summary>
             /// Initializes server connection - default database: databaseName.
             /// This will fail if the server is not online or cannot be connected to.
             /// 
             /// Utils.PreconditionS:
             ///   serverName not null
             ///   instanceName not null
             ///   
             /// POSTCONDITIONS:
             ///  POST 1: Server smo object created and connected
             ///  POST 2: the server is online
             ///  POST 3: <returns>true if successful, false and msg populated otherwise</returns>
             ///  
             /// Changes:
             /// 240921: Allow no instance:  [Server] is a valid source
             /// </summary>
             /// <param name="serverName"></param>
             /// <param name="instanceName"></param>
      protected bool InitServer(string serverName, string instanceName, out string msg)
      {
         LogS($"server:[{serverName}]  instance:[{instanceName}]");
         bool ret = false;
         msg = "";

         try
         {
            do
            {
               // -------------------------
               // Validate Utils.Preconditions
               // -------------------------

               if (string.IsNullOrEmpty(serverName))
               {
                  msg = "Server not specified";
                  break;
               }

               /*if(string.IsNullOrEmpty(instanceName))
               {
                  msg = "Instance not specified";
                  break;
               }*/

               // -----------------------------------------
               // ASSERTION: Utils.Preconditions validated
               // -----------------------------------------

               CreateAndOpenServer(serverName, instanceName);

               // -----------------------------------------
               // ASSERTION: server created and connected
               // -----------------------------------------

               //  POST 1: Server smo object created
               //  POST 2: the server is online and connected
               if (Server == null)
               {
                  msg = "Could not create Server smo object";
                  break;
               }
               //var ver = Server.Information.Version;

               // Set the default loaded fields to include IsSystemObject
               // SetDefaultInitFields(Type,params string[] fields will be deprecated - use the one below)
               // SetDefaultInitFields(Type typeObject, DatabaseEngineEdition databaseEngineEdition, params string[] fields)
               Server.SetDefaultInitFields(typeof(Table), "IsSystemObject");
               Server.SetDefaultInitFields(typeof(StoredProcedure), "IsSystemObject");
               Server.SetDefaultInitFields(typeof(UserDefinedFunction), "IsSystemObject", "FunctionType");
               Server.SetDefaultInitFields(typeof(View), "IsSystemObject");

               // -------------------------
               // Validate postconditions
               // -------------------------

               if (Server.Status != ServerStatus.Online)
               {
                  msg = "Could not connect to Server";
                  break;
               }

               // -----------------------------------------
               // ASSERTION: postconditions validated
               // -----------------------------------------
               ret = true;
            } while (false);
         }
         catch (Exception e)
         {
            LogException(e);
            Log($"server:[{serverName}]  instance:[{instanceName}]");
            throw;
         }

         // POST 3: <returns>true if successful, false and msg populated otherwise</returns>
         if (!ret)
         {
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");
            LogE($"there was an error: {msg}");
         }

         return LogRD(ret, msg);
      }

      /// <summary>
      /// Creates a Server from the parameters
      ///  throws exception if fails
      ///  returns the server
      ///  
      /// Utils.PreconditionS: none
      /// 
      /// POSTCONDITIONS:
      ///   1: server returned otherwise exception thrown
      /// </summary>
      /// <param name="serverName"></param>
      /// <param name="instance"></param>
      /// <param name="databaseName"></param>
      /// <returns>instantiated and comnnectd server or exception thrown</returns>
      public void CreateAndOpenServer(string? serverName, string? instance)// string databaseName )
      {
         Assertion(!string.IsNullOrEmpty(serverName), "Server not specified");
         //Assertion(!string.IsNullOrEmpty(instance)    , "Instance not specified");

         // ASSERTION: serverName, serverName, instance are all specified

         SqlConnectionInfo sqlConnectionInfo = new(serverName)
         {
            UseIntegratedSecurity = true
         };

         ServerConnection serverConnection = new(sqlConnectionInfo);
         Postcondition(serverConnection != null, "Could not create Server object");
         Server = new Server(serverConnection);
      }

      protected static void LogExportedList(string type, StringBuilder sb, SortedList<string, string> list)
      {
         var hdr = $"{type,-22}: {list.Count,+3} items";
         LogDirect($"\r\n\t{hdr}");
         sb.AppendLine($"{hdr} items");

         foreach (var t in list)
            LogDirect($"\t\t{t.Key}");
      }
      /// <summary>
      /// Sets up the general scripter options
      /// 
      /// Utils.PreconditionS:
      ///   PRE 1: P is valid
      ///   
      /// POSTCONDITIONS:
      ///  general: Scripter.Options state initialised with general settings
      ///  specific:
      ///  POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
      ///  POST 2: ensure either emit schema or data, if not specified then emit schema else scripter will error
      ///  
      /// TESTS:
      ///   DbScriptorTests.InitScriptingOptionsTest()
      ///   
      /// </summary>
      /// <param name="dbOpType"></param>
      protected bool InitScriptingOptions(out string msg)
      {
         LogSD();
         bool ret = false;

         do
         {
            // -------------------------
            // Validate Utils.Preconditions
            // -------------------------
            if (!P.IsValid(out msg))
               break; // PRE 1

            // -----------------------------------------
            // ASSERTION: Utils.Preconditions validated
            // -----------------------------------------

            //Scripter = new Scripter(Server);

            ScriptOptions = new ScriptingOptions()
            {
               ScriptForCreateDrop = false, // DetermineScriptForCreateDrop(perFile, urn),
               AllowSystemObjects = false,
               AnsiFile = true,
               AnsiPadding = false,
               AppendToFile = true,     // needed if we use script builder repetitively
               Bindings = false,
               ContinueScriptingOnError = false,
               ConvertUserDefinedDataTypesToBaseType = false,
               DriAll = true,
               ExtendedProperties = true,
               IncludeDatabaseContext = false, // we need more control P?.ScriptUseDb ?? false, // only if required
               IncludeHeaders = false,
               IncludeIfNotExists = false,
               Indexes = true,
               NoCollation = true,
               NoCommandTerminator = false, //noGoflag, // true means don't emit GO statements after every SQLstatement
               NoIdentities = false,
               NonClusteredIndexes = true,
               Permissions = false,
               SchemaQualify = true,  //  e.g. [dbo].sp_bla
               SchemaQualifyForeignKeysReferences = true,
               NoAssemblies = false,
               ScriptBatchTerminator = true,
               ScriptData = P.IsExportingData,
               ScriptDrops = (P.CreateMode == CreateModeEnum.Drop),
               ScriptForAlter = false, // issue here:  Dont script alter here - it doesnt work for functions, tables ... (P.CreateMode == CreateModeEnum.Alter), do in Script transactions method
               ScriptSchema = P.IsExportingSchema,
               WithDependencies = false, // issue here: dont set true: Smo.FailedOperationException true, Unable to cast object of type 'System.DBNull' to type 'System.String'.
               ClusteredIndexes = true,
               FullTextIndexes = true,
               EnforceScriptingOptions = true,
               Triggers = true
            }; 


            // Ensure either emit schema or data, if not specified then emit schema
            if ((!ScriptOptions.ScriptSchema) && (!ScriptOptions.ScriptData))
               ScriptOptions.ScriptSchema = true;

            // -------------------------
            // Validate postconditions
            // -------------------------
            //  POST 2: ensure either emit schema or data, if not specified then emit schema
            if (!(ScriptOptions.ScriptSchema || ScriptOptions.ScriptData))
            {
               msg = "either script schema or script data must be specified";//  POST 1:
               break;
            }

            // -----------------------------------------
            // ASSERTION: postconditions validated
            // -----------------------------------------
            //Scripter.Options = ScriptOptions;
            ret = true;
         } while (false);


         // POST 3: <returns>true if successful, false and msg populated otherwise</returns>
         if (!ret)
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");

         Log(OptionsToString(ScriptOptions));

         // POST 4: <returns>true if successful, false and msg populated otherwise</returns>
         if (!ret)
         {
            LogE($"there was an error: {msg}");
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");
         }

         return LogRD(ret, msg);
      }

      /// <summary>
      /// Used to check parameters
      /// </summary>
      /// <param name="o"></param>
      /// <returns></returns>
      public static string OptionsToString(ScriptingOptions? o)
      {
         var sb = new StringBuilder();

         if(o != null)
         { 
            sb.AppendLine($"AgentAlertJob                         {o.AgentAlertJob}");
            sb.AppendLine($"AgentJobId                            {o.AgentJobId}");
            sb.AppendLine($"AgentNotify                           {o.AgentNotify}");
            sb.AppendLine($"AllowSystemObjects                    {o.AllowSystemObjects}");
            sb.AppendLine($"AnsiFile                              {o.AnsiFile}");
            sb.AppendLine($"AnsiPadding                           {o.AnsiPadding}");
            sb.AppendLine($"AppendToFile                          {o.AppendToFile}");
            sb.AppendLine($"ChangeTracking                        {o.ChangeTracking}");
            sb.AppendLine($"BatchSize                             {o.BatchSize}");
            sb.AppendLine($"Bindings                              {o.Bindings}");
            sb.AppendLine($"ClusteredIndexes                      {o.ClusteredIndexes}");
            sb.AppendLine($"ColumnStoreIndexes                    {o.ColumnStoreIndexes}");
            sb.AppendLine($"ContinueScriptingOnError              {o.ContinueScriptingOnError}");
            sb.AppendLine($"ConvertUserDefinedDataTypesToBaseType {o.ConvertUserDefinedDataTypesToBaseType}");
            sb.AppendLine($"DdlBodyOnly                           {o.DdlBodyOnly}");
            sb.AppendLine($"DdlHeaderOnly                         {o.DdlHeaderOnly}");
            sb.AppendLine($"Default                               {o.Default}");
            sb.AppendLine($"DriAll                                {o.DriAll}");
            sb.AppendLine($"DriAllConstraints                     {o.DriAllConstraints}");
            sb.AppendLine($"DriAllKeys                            {o.DriAllKeys}");
            sb.AppendLine($"DriChecks                             {o.DriChecks}");
            sb.AppendLine($"DriClustered                          {o.DriClustered}");
            sb.AppendLine($"DriDefaults                           {o.DriDefaults}");
            sb.AppendLine($"DriForeignKeys                        {o.DriForeignKeys}");
            sb.AppendLine($"DriIncludeSystemNames                 {o.DriIncludeSystemNames}");
            sb.AppendLine($"DriIndexes                            {o.DriIndexes}");
            sb.AppendLine($"DriNonClustered                       {o.DriNonClustered}");
            sb.AppendLine($"DriPrimaryKey                         {o.DriPrimaryKey}");
            sb.AppendLine($"DriUniqueKeys                         {o.DriUniqueKeys}");
            sb.AppendLine($"DriWithNoCheck                        {o.DriWithNoCheck}");
            sb.AppendLine($"Encoding                              {o.Encoding}");
            sb.AppendLine($"EnforceScriptingOptions               {o.EnforceScriptingOptions}");
            sb.AppendLine($"ExtendedProperties                    {o.ExtendedProperties}");
            sb.AppendLine($"FileName                              {o.FileName}");
            sb.AppendLine($"FullTextCatalogs                      {o.FullTextCatalogs}");
            sb.AppendLine($"FullTextIndexes                       {o.FullTextIndexes}");
            sb.AppendLine($"FullTextStopLists                     {o.FullTextStopLists}");
            sb.AppendLine($"IncludeDatabaseContext                {o.IncludeDatabaseContext}");
            sb.AppendLine($"IncludeDatabaseContext                {o.IncludeDatabaseContext}");
            sb.AppendLine($"IncludeDatabaseRoleMemberships        {o.IncludeDatabaseRoleMemberships}");
            sb.AppendLine($"IncludeFullTextCatalogRootPath        {o.IncludeFullTextCatalogRootPath}");
            sb.AppendLine($"IncludeHeaders                        {o.IncludeHeaders}");
            sb.AppendLine($"IncludeIfNotExists                    {o.IncludeIfNotExists}");
            sb.AppendLine($"IncludeScriptingParametersHeader      {o.IncludeScriptingParametersHeader}");
            sb.AppendLine($"Indexes                               {o.Indexes}");
            sb.AppendLine($"LoginSid                              {o.LoginSid}");
            sb.AppendLine($"NoAssemblies                          {o.NoAssemblies}");
            sb.AppendLine($"NoCollation                           {o.NoCollation}");
            sb.AppendLine($"NoCommandTerminator                   {o.NoCommandTerminator}");
            sb.AppendLine($"NoExecuteAs                           {o.NoExecuteAs}");
            sb.AppendLine($"NoFileGroup                           {o.NoFileGroup}");
            sb.AppendLine($"NoFileStream                          {o.NoFileStream}");
            sb.AppendLine($"NoFileStreamColumn                    {o.NoFileStreamColumn}");
            sb.AppendLine($"NoIdentities                          {o.NoIdentities}");
            sb.AppendLine($"NoIndexPartitioningSchemes            {o.NoIndexPartitioningSchemes}");
            sb.AppendLine($"NoMailProfileAccounts                 {o.NoMailProfileAccounts}");
            sb.AppendLine($"NoMailProfilePrincipals               {o.NoMailProfilePrincipals}");
            sb.AppendLine($"NonClusteredIndexes                   {o.NonClusteredIndexes}");
            sb.AppendLine($"NoTablePartitioningSchemes            {o.NoTablePartitioningSchemes}");
            sb.AppendLine($"NoVardecimal                          {o.NoVardecimal}");
            sb.AppendLine($"NoViewColumns                         {o.NoViewColumns}");
            sb.AppendLine($"NoXmlNamespaces                       {o.NoXmlNamespaces}");
            sb.AppendLine($"OptimizerData                         {o.OptimizerData}");
            sb.AppendLine($"Permissions                           {o.Permissions}");
            sb.AppendLine($"PrimaryObject                         {o.PrimaryObject}");
            sb.AppendLine($"SchemaQualify                         {o.SchemaQualify}");
            sb.AppendLine($"SchemaQualifyForeignKeysReferences    {o.SchemaQualifyForeignKeysReferences}");
            sb.AppendLine($"ScriptBatchTerminator                 {o.ScriptBatchTerminator}");
            sb.AppendLine($"ScriptData                            {o.ScriptData}");
            sb.AppendLine($"ScriptDataCompression                 {o.ScriptDataCompression}");
            sb.AppendLine($"ScriptDrops                           {o.ScriptDrops}");
            sb.AppendLine($"ScriptForAlter                        {o.ScriptForAlter}");
            sb.AppendLine($"ScriptForCreateDrop                   {o.ScriptForCreateDrop}");
            sb.AppendLine($"ScriptOwner                           {o.ScriptOwner}");
            sb.AppendLine($"ScriptSchema                          {o.ScriptSchema}");
            sb.AppendLine($"SpatialIndexes                        {o.SpatialIndexes}");
            sb.AppendLine($"Statistics                            {o.Statistics}");
            sb.AppendLine($"TargetDatabaseEngineEdition           {o.TargetDatabaseEngineEdition}");
            sb.AppendLine($"TargetDatabaseEngineType              {o.TargetDatabaseEngineType}");
            sb.AppendLine($"TargetServerVersion                   {o.TargetServerVersion}");
            sb.AppendLine($"TimestampToBinary                     {o.TimestampToBinary}");
            sb.AppendLine($"ToFileOnly                            {o.ToFileOnly}");
            sb.AppendLine($"Triggers                              {o.Triggers}");
            sb.AppendLine($"WithDependencies                      {o.WithDependencies}");
            sb.AppendLine($"XmlIndexes                            {o.XmlIndexes}");
         }

         return sb.ToString();
      }
      /// <summary>
      /// Validates the initialization
      /// Utils.PreconditionS: 
      ///   P config pop
      /// </summary>
      /// <returns></returns>
      protected bool IsValid(out string msg)
      {
         LogSD();
         var ret = false;

         do
         {
            if (!P.IsValid(out msg))
               break;

            if (Writer == null)
            {
               msg = "write not initialised";
               break;
            }

            string x = (((FileStream)Writer.BaseStream)?.Name ?? "not defined");

            // ((FileStream)(Writer.BaseStream)).Name.Equals(P.ExportScriptPath, StringComparison.OrdinalIgnoreCase)	D:\Dev\Repos\DbScripter\DbScripterLib\DbScripter.cs	493	37	DbScripterLib	Read	InitWriter	DbScripter	
            if (!x.Equals(P?.ScriptFile ?? "xxx", StringComparison.OrdinalIgnoreCase))
            {
               msg = "Writer not initialised properly";
               break;
            }

            // Lastly if here then all checks have passed
            ret = true;
         } while (false);

         return LogRD(ret, msg);
      }

      /// <summary>
      /// Creates a file for each item
      /// </summary>
      /// <param name="sb"></param>
      /// <param name="v"></param>
      /// <param name="urn"></param>
      protected string ScriptItemToFile(int v, Urn urn)
      {
         StringBuilder sb = new StringBuilder();
         var urns = new Urn[1];
         urns[0] = urn;
         // 241122: issue tSQlt functions like Server[@Name='DevI9']/Database[@Name='Farming_Dev']/UserDefinedFunction[@Name='@tSQLt:MaxSqlMajorVersion' and @Schema='tSQLt']
         SetScripterOptions(ScriptOptions, urn, P.CreateMode, true);

         var urn_s = GetUrnDetails(urn, out SqlTypeEnum type, out string dbName, out string schemaName, out string entityName);
         dynamic? item;
         //SqlTypeEnum type = MapSmoTypeToSqlType(ty);

         do
         {
            // items are stored in 2 different places depending on type
            // m ost are stored on the datab 
            if (type == SqlTypeEnum.UserDefinedDataType)
            {
               if (Database.UserDefinedDataTypes.Contains(entityName, schemaName))
               {
                  item = Database.UserDefinedDataTypes[entityName, schemaName];
                  Console.WriteLine($"Found UserDefinedDataType {schemaName}.{entityName}");
               }
               else
               {
                  if (Database.UserDefinedTableTypes.Contains(entityName, schemaName))
                  {
                     item = Database.UserDefinedTableTypes[entityName, schemaName];
                     Console.WriteLine($"Found UserDefinedTableType {schemaName}.{entityName}");
                  }
                  else
                  {
                     Console.WriteLine($"UserDefinedDataType {schemaName}.{entityName} was not found in the database UserDefinedDataTypes or UserDefinedTableTypes collections");
                     break;
                  }
               }
            }
            else
            {
               item = Server?.GetSmoObject(urn);
            }

            if(item == null)
            {
               var msg = $" {urn} not found ";
               LogE(msg);
               throw new Exception(msg);
            }

            Assertion(ScriptOptions.ScriptForAlter == false);
            StringCollection transactions = (item?.Script(ScriptOptions)) ?? new StringCollection();

            if(transactions.Count == 0)
            { 
               LogE($"no script generated for {item?.Urn}");
               //Assertion(transactions.Count > 0);
               break;
            }

            //string key = GetUrnDetails(urn, out string smo_type, out _, out _, out _);
            string sqlType = type.GetAlias();//MapSmoTypeToSqlType(ty);
            string action;

            // if mode IS NOT alter then script normally
            // if mode IS     alter then modify statements
            if (P.CreateMode != CreateModeEnum.Alter)
               action = ScriptItemNormally(transactions, sb, urn);
            else
               action = ScriptItemHandleAlter(transactions, sqlType, sb, urn);

            string scriptFilePath = CreateIndividualFileName(urn);
            LogI($"{scriptFilePath}");

            // WriteAllText creates a new file, writes the specified string to the file, and then closes the file. 
            // If the target file already exists, it is overwritten.
            File.WriteAllText(scriptFilePath, sb.ToString());
            RegisterResult(urn_s, sqlType, action);
         } while (false);

         return sb.ToString();
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="smo"></param>
      /// <param name="so"></param>
      /// <param name="sb"></param>
      /// <returns>action string </returns>
      protected string ScriptItemNormally(StringCollection transactions, StringBuilder sb, Urn urn)
      {
         string key = GetUrnKey(urn);
         ScriptTransactions(transactions, sb, urn, true);
         return $"script {P.CreateMode.GetAlias()} {key} normally";
      }

      /// <summary>
      /// This handles the alter CREATEMODE
      /// 
      /// Changes:
      /// 240921: Handle alter table by doing a drop/create
      /// </summary>
      /// <param name="smo"></param>
      /// <param name="so"></param>
      /// <param name="sb"></param>
      protected string ScriptItemHandleAlter(StringCollection transactions, string sqlType, StringBuilder sb, Urn urn)
      {
         string key = GetUrnDetails(urn, out _, out _, out var schemaNm, out var entityNm);

         // Chk we got a script from the smo scripter
         Assertion(transactions.Count > 0, $"no script produced for {key}");

         // Handle tables differently
         if ((sqlType == "Table") || (sqlType == "UserDefinedType") || (sqlType == "UserDefinedDataType") || (sqlType == "UserDefinedTableType"))
         {
            ScriptItemHandleNonAlterableTypes(sqlType, transactions, schemaNm, entityNm, sb);
         }
         else
         {
            // Iterate the script transactions looking for the create xxx to replace with alter xxx
            foreach (string? transaction in transactions)
               if(transaction != null)
                  ReplaceCreateWithAlter(transaction, sb,  /*key,*/ sqlType, schemaNm, entityNm);//, ref found);
         }

         ScriptGo(sb);
         return $"script ALTER:[{P.CreateMode.GetAlias()} {key} handle alter"; ;
      }

      /// <summary>
      /// Some types are not alterable like table, usedDefeined tabletype
      /// for these we need to drop and recreate
      /// IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Action]') AND type in (N'U'))
      /// DROP TABLE[dbo].[Action]
      /// GO
      /// </summary>
      /// <param name="smo"></param>
      /// <param name="so"></param>
      /// <param name="sqlType"></param>
      /// <param name="sb"></param>
      /// <param name="transactions"></param>
      /// <returns></returns>
      protected void ScriptItemHandleNonAlterableTypes(string ty, StringCollection transactions, string schemaNm, string entityNm, StringBuilder sb)
      {
         LogI($"ScriptItemHandleNonAlterableTypes: {ty}: {schemaNm}].[{entityNm}]");
         transactions.Insert(0, "GO");
         transactions.Insert(0, $"    DROP {ty}[{schemaNm}].[{entityNm}];");
         transactions.Insert(0, $"IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[{schemaNm}].[{entityNm}]') AND type in (N'U'))");

         foreach (string? txn in transactions)
            sb.AppendLine(txn);

         string str = sb.ToString();
      }

      /// <summary>
      /// Gets the list of wanted items and their dependencies in create dependency order
      /// 
      /// Called by: ExportSchemas()
      /// </summary>
      /// <param name="schemas"></param>
      /// <param name="mostDependentFirst"></param>
      /// <returns>true if succeeded, false if no items</returns>
      public bool GetItemsToScript(HashSet<Urn> rootUrns, bool mostDependentFirst, out List<Urn> urns, out string msg)
      {
         LogS();
         bool ret = false;
         msg = "";

         do
         {
            // Pass 1:
            // Get list of child items for all roots
            // filter for 'is not system object', wanted type, duplicates etc.
            urns = GetWantedItems() ?? new();

            if (urns.Count == 0)
            {
               msg = $"{Database.Name} has no items to script for the required schemas";
               LogC(msg);
               break;
            }

            // Userdefined DataTypes and Table types will throw here has they are not held by the server but by the database
            // so we need to filter them out for the dependency walk
            var serverItems= urns.Where(c => c.Type != "UserDefinedDataType").ToList();//.ToArray();
            var databaseItems = urns.Where(c => c.Type == "UserDefinedDataType").ToArray();

            // Create a walk of smo items to scrpt in dependency order
            List<Urn> candidates = GetDependencyWalk(serverItems.ToHashSet(), mostDependentFirst);
            LogDirect($"Dependency walk contains {urns.Count} items to script", LogLevel.Info);
            ret = true;
         } while (false);

         return LogR(ret, msg);
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="childUrn"></param>
      /// <param name="filterUnwantedTypes"> set true if want to filter unewanted types e.g. when in alter mode then a table is NOT wanted</param>
      /// <param name="sb"></param>
      /// <param name="schemaNames"></param>
      /// <param name="map"></param>
      /// <returns>true if child is wanted</returns>
      protected bool ConsiderCandidate(Urn childUrn, bool filterUnwantedTypes/*, StringBuilder sb*/, IEnumerable<string> schemaNames)//, Dictionary<string, Urn> map)
      {
         //bool ret    = true;
         bool isWanted = false;
         string key = GetUrnDetails(childUrn, out SqlTypeEnum type, out var dbName, out string schemaName, out string name);
         //var sqlType = MapSmoTypeToSqlType(ty);

         RegisterAction(key, SelectionRuleEnum.Considering);
         int i = ConsisderedEntities.Count;

         LogSD($"Considering [{i}]: {key} fuwtypes: {filterUnwantedTypes}");

         try
         {
            do
            {
               if (!ConsisderedEntities.ContainsKey(key))
               {
                  ConsisderedEntities.Add(key, key);
               }
               else
               {
                  //  Unwanted duplicate
                  RegisterAction(key, SelectionRuleEnum.DuplicateDependency);
                  isWanted = false;
                  break;
               }

               /*
               if (ty == "UnresolvedEntity")
               {
                  RegisterAction(key, SelectionRuleEnum.UnresolvedEntity);
                  isWanted = false;
                  break;
               }
               */

               if (!(Database.Name).Equals(dbName, StringComparison.OrdinalIgnoreCase))
               {
                  RegisterAction(key, SelectionRuleEnum.DifferentDatabase);
                  isWanted = false;
                  break;
               }

               // if filtering unwanted types
               // and "UserDefinedDataType for now because currently Server.GetSmoObject throws an exception getting this object type
               // MissingObjectException: The UserDefinedDataType '[tSQLt].[AssertStringTable]' does not exist on the server.
               if (filterUnwantedTypes == true)
               {
                  if (!IsTypeWanted(type))
                  {
                     // Unwanted type
                     RegisterAction(key, SelectionRuleEnum.UnwantedType);
                     isWanted = false;
                     break;
                  }
               }

               //-------------------------------------------------------------
               // Assertion the type is wanted
               //-------------------------------------------------------------

               SqlSmoObject? childSmo = null;

               if (type == SqlTypeEnum.UserDefinedDataType)
               {
                  if (Database.UserDefinedDataTypes.Contains(name, schemaName))
                  {
                     UserDefinedDataType? item = Database.UserDefinedDataTypes[name];
                     Console.WriteLine($"Found UserDefinedDataType {schemaName}.{name}");
                  }
                  else
                  {
                     if (Database.UserDefinedTableTypes.Contains(name, schemaName))
                     {
                        UserDefinedTableType item = Database.UserDefinedTableTypes[name];
                        Console.WriteLine($"Found UserDefinedTableType {schemaName}.{name}");
                     }
                     else
                     {
                        Console.WriteLine($"UserDefinedDataType {name} was not found in the database UserDefinedDataTypes or UserDefinedTableTypes collections");

                        // For now do this
                        RegisterAction(key, SelectionRuleEnum.UnknownEntity);
                        isWanted = false;
                        break;
                     }
                  }

                  isWanted = true;
                  break;
               }
               else
               {
                  childSmo = Server?.GetSmoObject(childUrn);
               }

               if (childSmo?.Properties.Contains("IsSystemObject") ?? false)
               {
                  var property = childSmo.Properties["IsSystemObject"];

                  if (((bool)property.Value) == true && type != SqlTypeEnum.Assembly)
                  {
                     // Unwanted system object
                     RegisterAction(key, SelectionRuleEnum.SystemObject);
                     isWanted = false;
                     break;
                  }
               }

               // Only add if the item is in a required schema
               if ((!schemaNames.Contains(schemaName)) && type != SqlTypeEnum.Assembly)
               {
                  //  Unwanted Schema
                  RegisterAction(key, SelectionRuleEnum.UnwantedSchema);
                  isWanted = false;
                  break;
               }

               // ASSERTION: if here then item is wanted
               isWanted = true;
            } while (false);
         }
         catch (Exception e)
         {
            LogException(e, $"item:  [{i}]: {GetUrnKey(childUrn)}");
            BadBin.Add(key, e.Message);
         }

         LogLD($"isWanted: {isWanted}");
         return isWanted;
      }

      protected void SetScripterOptions(ScriptingOptions options, Urn urn, CreateModeEnum? createMode, bool individualFile)
      {
         switch (createMode)
         {
            case CreateModeEnum.Alter:
               if (urn.Type == "Table")
               {
                  options.ScriptDrops = true;
                  options.ScriptForAlter = false;
               }
               else
               {
                  options.ScriptDrops = false;
                  options.ScriptForAlter = false; // true;
               }
               break;

            case CreateModeEnum.Create:
               options.ScriptDrops = false;
               options.ScriptForAlter = false;    // true
               break;

            case CreateModeEnum.Drop:
               options.ScriptDrops = true;
               options.ScriptForAlter = false;    // issue here:  Dont script alter here - it doesnt work for functions, tables ... (P.CreateMode == CreateModeEnum.Alter), do in Script transactions method
               break;
         }

         if (individualFile == true)
            FileName = CreateIndividualFileName(urn);
      }

      /// <summary>
      /// Creates the individual script filename - do not use timestamp
      /// as the Dbscriptor can be used to take snapshots of the routines for version management
      /// which relies on file name not being changed
      /// </summary>
      /// <param name="urn"></param>
      /// <returns></returns>
      protected string CreateIndividualFileName(Urn urn)
      {
         //string timestamp = P.AddTimestamp == true ? $"_{P.Timestamp}_" : "";
         string key = GetUrnDetails(urn, out SqlTypeEnum type, out string dbName, out string schemaNm, out string entityNm);
         string fileName = @$"{P.ScriptDir}\{schemaNm}.{entityNm}.sql";
         return fileName;
      }

      protected void RegisterAction(string key, SelectionRuleEnum rule)
      {
         LogDirect($"{key} : {rule.GetAlias()}");
         SortedList<string, string>? list = null;

         try
         {
            switch (rule)
            {
               case SelectionRuleEnum.Wanted: list = WantedItems; break;
               case SelectionRuleEnum.Considering: list = WantedItems; break;
               case SelectionRuleEnum.UnwantedType: list = UnwantedTypes; break;
               case SelectionRuleEnum.UnwantedSchema: list = UnwantedSchemas; break;
               case SelectionRuleEnum.SystemObject: list = SystemObjects; break;
               case SelectionRuleEnum.DuplicateDependency: list = DuplicateDependencies; break;
               case SelectionRuleEnum.DifferentDatabase: list = DifferentDatabases; break;
               case SelectionRuleEnum.UnresolvedEntity: list = UnresolvedEntities; break;
               case SelectionRuleEnum.UnknownEntity: list = UnknownEntities; break;

               default: AssertFail($"RegisterAction unhandled rule: {rule.GetAlias()}"); break;
            }

            RegisterAction2(key, list, rule);
         }
         catch (Exception e)
         {
            LogException(e);
            throw;
         }
      }

      void RegisterAction2(string key, SortedList<string, string>? list, SelectionRuleEnum rule)
      {
         if (!list?.ContainsKey(key) ?? false)
            list?.Add(key, key);
         //else
         //   LogDirect($"{key} rule: {rule.GetAlias()} entry already exists in list");
      }

      /// <summary>
      /// Filters against the current IsExprtng type  Flags
      /// </summary>
      /// <returns></returns>

      /// <summary>
      /// Filters against the current IsExprtng type  Flags
      /// </summary>
      /// <returns></returns>
      protected bool IsTypeWanted(string typeName)
      {
         bool ret = false;

         // Schema filter
         switch (typeName.ToUpper())
         {
            case "DATA": ret = P.IsExportingData; break;
            case "DATABASE": ret = P.IsExportingDb; break;
            case "USERDEFINEDFUNCTION": ret = P.IsExportingFunctions; break;
            case "STOREDPROCEDURE": ret = P.IsExportingStoredProcedures; break;
            case "SCHEMA": ret = P.IsExportingSchema; break;
            case "TABLE": ret = P.IsExportingTables; break;
            case "USERDEFINEDTABLETYPE": ret = P.IsExportingTableTys; break;
            case "VIEW": ret = P.IsExportingVws; break;
            case "SQLASSEMBLY": ret = P.IsExportingAssemblies; break;
            case "USERDEFINEDTYPE": ret = P.IsExportingUserDefinedTypes; break;
            case "USERDEFINEDDATATYPE": ret = P.IsExportingUserDefinedTypes; break;
            case "FOREIGNKEY":
            case "SERVICEQUEUE": ret = false; break;

            default: Utils.Postcondition(false, $"IsTypeWanted() unexpected type: [{typeName}]"); break;
         }

         return ret;
      }

      protected bool IsTypeWanted(SqlTypeEnum type)
      {
         bool ret = false;

         // Schema filter
         switch (type)
         {
//            case "DATA": ret = P.IsExportingData; break;
            case SqlTypeEnum.Database:             ret = P.IsExportingDb; break;
            case SqlTypeEnum.Function:             ret = P.IsExportingFunctions; break;
            case SqlTypeEnum.StoredProcedure:      ret = P.IsExportingStoredProcedures; break;
            case SqlTypeEnum.Schema:               ret = P.IsExportingSchema; break;
            case SqlTypeEnum.Table:                ret = P.IsExportingTables; break;
            case SqlTypeEnum.UserDefinedTableType: ret = P.IsExportingTableTys; break;
            case SqlTypeEnum.View:                 ret = P.IsExportingVws; break;
            case SqlTypeEnum.Assembly:             ret = P.IsExportingAssemblies; break;
            case SqlTypeEnum.UserDefinedType:      ret = P.IsExportingUserDefinedTypes; break;
            case SqlTypeEnum.UserDefinedDataType:  ret = P.IsExportingUserDefinedTypes; break;
//            case SqlTypeEnum.Database:"FOREIGNKEY":
//            case SqlTypeEnum.Database:"SERVICEQUEUE": ret = false; break;

            default: Utils.Postcondition(false, $"IsTypeWanted() unexpected type: [{type}]"); break;
         }

         return ret;
      }

      /// <summary>
      /// Substitutes 'CREATE' with 'ALTER' 
      /// </summary>
      /// <param name="transaction"></param>
      /// <param name="sb"></param>
      /// <param name="key"></param>
      /// <param name="expSqlType"></param>
      /// <param name="expSchema"></param>
      /// <param name="expEntity"></param>
      /// <param name="found"></param>
      protected void ReplaceCreateWithAlter(string transaction, StringBuilder sb, /*, string key, */string expSqlType, string expSchema, string expEntity)//, ref bool found)
      {
         //LogS();
         var regOptns = RegexOptions.Multiline | RegexOptions.IgnoreCase;

         do
         {
            // Look for Create type ...
            MatchCollection? matches = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]+{expSqlType}", regOptns);
            var nMatches = matches.Count;

            // the first 2 transaction dont usually have the main SQL command (create) e,g "SET ANSI NULLS ON" or "SET QUOTED_IDENTIFIER ON"
            if (nMatches == 0)
               break;

            if (nMatches > 1)
            {
               // Found more than 1 match
               // This can happen if there is a CREATE in a blok comment
               // or a create in the code body of an sp
               // Look for the first transaction with a line beginning with 0 or more wsp and CREATE
               matches = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]*([^ \[]*)([ \[]+)([^\]]*)([\[\.\]]+)([^\]]*)", regOptns);
            }
            else
            {
               // Found exactly 1 match
               //matches = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]+{expType}[ \t]*([^ \[]*)([ \[]+)([^\]]*)([\[\.\]]+)([^\]]*)", regOptns);
               matches = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]+{expSqlType}[ \t]*([^ \[]*)([ \[]+)([^\]]*)([\[\.\]]+)([^\]]*)", regOptns);
            }

            nMatches = matches.Count;
            // Assert 1 match found
            Assertion(nMatches == 1, $"ScriptTransactionsHandleAlter: failed to get match for ^create");

            // Plan is to add a go before the CREATE|ALTER|DROP statement
            // Got the Create mode: {CREATE|ALTER|DROP}
            //var actType   = matches[0].Groups[1].Value; // ??
            var actSchema = matches[0].Groups[3].Value;
            var actEntity = matches[0].Groups[5].Value;

            // ?? Signatures must have [] for this to work
            if (/*expSqlType.Equals(actType,   StringComparison.OrdinalIgnoreCase) &&*/
               expSchema.Equals(actSchema, StringComparison.OrdinalIgnoreCase) &&
               expEntity.Equals(actEntity, StringComparison.OrdinalIgnoreCase))
            {
               // Add a go after the set ansi nulls on etc but before the alter statement
               ScriptGo(sb);
               var ndx = matches[0].Index;
               Assertion(ndx > -1);

               // Substitute 'CREATE' with 'ALTER' 
               transaction = transaction.Substring(0, ndx) + "ALTER" + transaction.Substring(ndx + 6);
            }
            // else
            // Sometimes there is a ^ *Create etc in the block comments AssertFail($"oops Type mismatch, key: {key}");
         } while (false);

         // Always script the transaction
         ScriptLine(transaction, sb);

         if (WantBlankLineBetweenTransactions())
            ScriptBlankLine(sb);
      }


      /// <summary>
      /// 
      /// </summary>
      /// <param name="key"></param>
      /// <param name="sqlType"></param>
      protected void RegisterResult(string key, string sqlType, string action)
      {
         bool bAddEntityToXprtLsts = false;

         switch (sqlType)
         {
            // Do not script Alter Table - ignore it
            case "TABLE":
               if(P.CreateMode == CreateModeEnum.Alter)
                  action = $"Not scripting ALTER {key}]";
               else
                  bAddEntityToXprtLsts = true;
               break;

            case "PROCEDURE":
            case "FUNCTION":
            case "VIEW":
               // Handle here
               // Change create to alter for Prcedures and functions
               // Log($"scripting with mod: CREATE -> ALTER {sqlType} for {key}");
               bAddEntityToXprtLsts = true;
               break;

            default:
               // Script normally
               /*            Log(action);
                           action = $"scripting normally: {key}";
                           transactions = ((dynamic)smo).Script(so);

                           if(transactions.Count==0)
                              Utils.Assertion(transactions.Count>0, $"no script produced for {expEntity}");

                           // N.B.: this will add the entity to export lists , string op, string type, string name
                           ScriptTransactions( transactions, sb, urn, wantGo: true);
               */
               bAddEntityToXprtLsts = true; // 250706 was false
               break;
         }

         // if scripted here add to exported lists
         if (bAddEntityToXprtLsts)
            AddToExportedLists(key);
      }

      protected void AddToExportedLists(string key)
      {
         _exportedItemCnt++;
         DecodeUrnKey(key, out string ty, out string database, out string schema, out string entityName);
         
         var type = ty.FindEnumByAliasExact<SqlTypeEnum>(true);
         var shortKey = $"{schema}.{entityName}";
         SortedList<string, string>? exported_items = ExportedItems[type];

         var val = type == SqlTypeEnum.Database ? database :
                         type == SqlTypeEnum.Schema   ? schema : shortKey;

         if (!exported_items.ContainsKey(val))
            exported_items.Add(val, val);
         else
         { 
            var msg = $"duplicate Exported {ty}: {val}";
            LogE(msg);
            throw new Exception(msg);
         }
      }
      /*         switch (ty)
               {
                  case "Database":
                     ExportedDatbases.Add(database, database);
                     break;

                  case "Schema":
                     shortKey = $"{database}.{schema}";
                     ExportedSchemas.Add(shortKey, shortKey);
                     break;

                  case "Table":
                     ExportedTables.Add(shortKey, shortKey);
                     break;

                  case "UserDefinedFunction":

                     if(ExportedFunctions.ContainsKey(shortKey))
                     {
                        LogE($"Duplicate item: {key}");
                        break;
                     }

                     ExportedFunctions.Add(shortKey, shortKey);
                     break;

                  case "StoredProcedure":
                     ExportedProcedures.Add(shortKey, shortKey);
                     break;

                  case "View":
                     ExportedViews.Add(shortKey, shortKey);
                     break;

                  case "UserDefinedTableType":
                     ExportedTableTypes.Add(shortKey, shortKey);
                     break;

                  default:
                     Utils.AssertFail($"Unhandled item: {key}");
                     break;
               }
            }
      */


      /// <summary>
      /// Desc: Produces a unique list of wanted items in the required schemas
      ///   filters:
      ///      1: is a wanted type {View, UserDefinedFunction, StoredProcedure, DataType}
      ///      2: Is not a System Object
      ///      3: is not already on the wanted list
      ///
      /// PRECONDITIONS:
      ///   PRE 1: P.RootType == SqlTypeEnum.Schema
      ///   
      /// POSTCONDITIONS:
      /// 
      /// </summary>
      /// <param name="schemaNames"></param>
      /// <returns></returns>
      protected List<Urn> GetWantedItems()
      {
         LogS();
         Dictionary<string, Urn> urns = new Dictionary<string, Urn>();

         // Add in order
         foreach (SqlTypeEnum type in Enum.GetValues(typeof(SqlTypeEnum)))
            GetUrnsOfTypeIfWanted(SqlTypeEnum.Assembly, DbCollmap[type], urns); ;

         // Checks
         Assertion(RunChecks(urns, out var msg), msg);

         LogL();
         return urns.Values.ToList();
      }

      /// <summary>
      /// Filters the specific Database collection against the following criteria
      /// 1: if not Assembly then schema or ALL
      /// 2: ignore unresolved items
      /// 3: check the item exists in the wanted items or the wnat all flag is set
      /// </summary>
      /// <param name="type"></param>
      /// <param name="collection"></param>
      /// <param name="urns"></param>
      private void GetUrnsOfTypeIfWanted(SqlTypeEnum type, SortedListCollectionBase collection, Dictionary<string, Urn> urns)
      {
         LogS($"type {type.GetAlias2()}");
         string key;

         if (P.IsExportingType(type))
         {
            LogI($"type {type.GetAlias2()} is wanted");

            foreach (dynamic item in collection)
            {
               var urn = item.Urn;
               key = GetUrnKey(urn);
               var items = DecodeUrnKey(key, out string ty, out string dbName, out string schemaName, out string entityName);

               // Override this with a simpler idea
               entityName = urn.Name;

               // 1: if it is Not an assembly (assenmblies are not part of a schema)
               // then is it in a required schema or are ALL schemqas wanted?
               if (ty != "SqlAssembly")
                  if ((!P.WantAll(SqlTypeEnum.Schema) && !P.RequiredSchemas.Contains(schemaName)))
                  {
                     LogI($"Ignoring {key}");
                     continue;
                  }

               // 2: ignore unresolved items
               if (key.IndexOf("unresolved", StringComparison.OrdinalIgnoreCase) > -1)
                  LogW($"found unresolved item: {key}");

               if (key.Contains("unresolved", StringComparison.OrdinalIgnoreCase))
                  LogW($"found unresolved item: {key}");

               // 3: check the item exists in the wanted items or the want all flag is set
               if (IsItemWanted(type, dbName, schemaName, entityName))
                  urns.Add(key, item.Urn);
            }
         }
         else
         {
            LogI($"type {type.GetAlias2()} not wanted");
         }

         LogL();
      }

      /// <summary>
      /// This return true if the item is wanted against the criteria, false otherwise
      /// 
      /// The criteria for is_wanted = true are:
      /// 1. the database must be the current data base 
      /// 2. if the relevant wantall flag is set then wanted is true
      /// 3. else if the Name is contained the relevant required container then wanted is true
      /// 4. false otherwise
      /// 
      /// </summary>
      /// <param name="type"></param>
      /// <param name="dbName"></param>
      /// <param name="schemaName"></param>
      /// <param name="entityName"></param>
      /// <returns></returns>
      private bool IsItemWanted(SqlTypeEnum type, string dbName, string schemaName, string entityName)
      {
         // The criteria for is_wanted = true are:
         // 1. the database must be the current data base 
         if (dbName != P.Database)
            return false;

         // 2. if the relevant wantall flag is set then wanted is true
         if (P.WantAll(type))
            return true;

         // 3. else if the Name is contained the relevant required container then wanted is true
         // 4. false otherwise
         return IsRequiredItem(type, schemaName, entityName);
      }

      /// <summary>
      /// Generic is type wated 
      /// </summary>
      /// <param name="type"></param>
      /// <param name="schemaName"></param>
      /// <param name="entityName"></param>
      /// <returns></returns>
      private bool IsRequiredItem(SqlTypeEnum type, string schemaName, string entityName)
      {
         var map = P.RequiredItemMap[type];
         string name = CreateEntityName(type, schemaName, entityName);
         return map.Contains(name);
      }

      public string CreateEntityName(SqlTypeEnum type, string schemaName, string entityName)
      {
         string name;

         switch(type)
         {
            case SqlTypeEnum.Assembly: name = $"{entityName}"; break;
            case SqlTypeEnum.Function: name = $"{schemaName}.{entityName}"; break;
            case SqlTypeEnum.StoredProcedure: name = $"{schemaName}.{entityName}"; break;
            case SqlTypeEnum.Schema: name = $"{entityName}"; break;
            case SqlTypeEnum.Table: name = $"{schemaName}.{entityName}"; break;
            case SqlTypeEnum.UserDefinedTableType: name = $"{schemaName}.{entityName}"; break;
            case SqlTypeEnum.UserDefinedDataType: name = $"{schemaName}.{entityName}"; break;
            case SqlTypeEnum.UserDefinedType: name = $"{schemaName}.{entityName}"; break;
            case SqlTypeEnum.View: name = $"{schemaName}.{entityName}"; break;
            case SqlTypeEnum.Database: name = $"{entityName}"; break;
            default: throw new Exception($"CreateEntitiyName({type}): unhandled type: {type}");
         }

         return name;
      }

      protected static bool RunChecks(Dictionary<string, Urn> map, out string msg)
      {
         bool ret = false;

         do
         {
            // Checks
            bool chk = map.Any(x => x.Key.ToString().IndexOf("Unresolved", StringComparison.OrdinalIgnoreCase) > -1);
            
            if (chk)
            {
               var x = map.FirstOrDefault(x => x.Key.ToString().IndexOf("Unresolved", StringComparison.OrdinalIgnoreCase) > -1);
               msg = $"Unresolved item found in candidate list";
               break;
            }

            /*/ chk using a back map
            var map2 = new Dictionary<string, string>();

            foreach(var item in map)
               map2.Add(item.Value, item.Key);

            if(map.Count != map2.Count)
            {
               msg = $"oops Backup map test failed";
               break;
            }
            */
            msg = "";
            ret = true;
         } while (false);

         return ret;
      }

      protected List<Urn> GetDependencyWalk(HashSet<Urn> rootUrns, bool mostDependentFirst)
      {
         LogS();
         List<Urn> walk = new();
         var dw = new DependencyWalker(Server);
         DependencyTree depTree;
         DependencyType depTy = mostDependentFirst ? DependencyType.Parents : DependencyType.Children;

         try
         {
            depTree = dw.DiscoverDependencies(rootUrns.ToArray(), depTy);
            DependencyCollection? dependencies = dw.WalkDependencies(depTree);

            foreach (DependencyCollectionNode item in dependencies)
            {
               Urn urn = item.Urn;
               var type = urn.Type;
               string? database = urn.GetNameForType("Database");
               string? schema   = urn.GetAttribute("Schema");

               string? name = urn.GetAttribute("Name");

               // Remove items from other databases
               if (!P.Database.Equals(database, StringComparison.OrdinalIgnoreCase))
               {
                  LogW($"ignoring foreign object: {database}.{schema}.{name}");
                  continue;
               }

               // filter any ites from another database or are unresolved
               // GetNameForType
               if (type.Equals("UnresolvedEntity", StringComparison.OrdinalIgnoreCase))
               {
                  LogW($"ignoring unresolved dependency : database: {database}.{name}");
                  continue;
               }

               if(GetUrnType(urn) == SqlTypeEnum.Schema)
               {
                  LogW($"ignoring schema object: {database}.{name}");
                  continue;
               }

               // Finally all OK: 
               walk.Add(urn);
            }
         }
         catch (Exception e)
         {
            /*
            InternalEnumeratorException: Schema is not supported in dependency discovery. 
            Only objects of the following types are supported: 
             UserDefinedFunction, View, Table, StoredProcedure, Default, Rule, Trigger, UserDefinedAggregate
            ,Synonym, Sequence, SecurityPolicy, UserDefinedDataType, XmlSchemaCollection, UserDefinedType
            ,UserDefinedTableType, PartitionScheme, PartitionFunction, DdlTrigger, PlanGuide, SqlAssembly, UnresolvedEntity.
            */
            // MS code can do raise exception if dangling references to non existent procedures exist in db routines
            LogException(e, $"GetSchemaDependencyWalk");
            LogC($@"GetSchemaDependencyWalk failed:
MS code can do raise exception if dangling references to non existent procedures exist in db routines
Trying to script schema dependnecies in order tables, functions procedures
Script may need manual rearranging to get dependency order correct.
{e}");
            Assertion(GetSchemaChildren(P.RequiredSchemas ?? new List<string>(), out walk), "GetSchemaChildren failed");
         }

         // ASSERTION walk populated
         LogL($"walk contains: {walk.Count} items");
         return walk;
      }

      /// <summary>
      /// This produces a list of schema children for the set of schema provided
      /// </summary>
      /// <param name=""></param>
      /// <param name=""></param>
      /// <returns></returns>
      protected bool GetSchemaChildren(List<string> requiredSchemas, out List<Urn> walk)
      {
         walk = new List<Urn>();

         foreach (var schemaName in requiredSchemas)
            Assertion(GetSchemaChildren(schemaName, walk) == true);

         return true;
      }

      /// <summary>
      /// second best attempt
      /// </summary>
      /// <param name="schemaName"></param>
      /// <param name="walk"></param>
      /// <returns></returns>
      protected bool GetSchemaChildren(string schemaName, List<Urn> walk)
      {
         //LogS();
         string key;
         Schema? schema = Database.Schemas[schemaName];

         if(schema == null)
            return false;

         Dictionary<string, Dictionary<string, Urn>> mn_map = new();

         // Since we cant get proper dependnecy order then we will script in type order
         List<string> order = new() { "Table", "UserDefinedFunction", "StoredProcedure", "Data type" };

         Urn[] urns = schema.EnumOwnedObjects();
         Dictionary<string, Urn> map;

         foreach (Urn urn in urns)
         {
            key = GetUrnDetails(urn, out var type, out string databaseName, out var schemaNm, out var entityNm);
            var ty_str = type.GetAlias();

            if (mn_map.ContainsKey(ty_str))
            {
               map = mn_map[ty_str];
            }
            else
            {
               map = new Dictionary<string, Urn>();

               // in case we missed a grouping
               if (!order.Contains(ty_str))
                  order.Add(ty_str);

               mn_map.Add(ty_str, map);
            }

            if (!map.ContainsKey(entityNm))
               map.Add(entityNm, urn);
         }

         // Walk the items in order: tables, datatypes, functions, procedures
         foreach (var item_type in order)
         {
            if (mn_map.ContainsKey(item_type))
            {
               var itm_coll = mn_map[item_type].Values;

               foreach (var itm in itm_coll)
                  walk.Add(itm);
            }
         }

         var ret = (walk.Count > 0);
         return ret;
      }

      /// <summary>
      ///  Decodes the information in the urn key
      ///  
      /// Changes: 
      /// 241122 ISSUE: tSQLt uses fn names like [tSQLt].[@tSQLt:MinSqlMajorVersion]
      /// its URN is "Farming_Dev.tSQLt.@tSQLt:MaxSqlMajorVersion: UserDefinedFunction"
      /// other keys:
      ///             Farming_Dev.tSQLt.GetTestResultFormatter   : UserDefinedFunction
      ///  nthis is different from the normal naming
      /// </summary>
      /// <param name="key"></param>
      /// <param name="ty"></param>
      /// <param name="dbName"></param>
      /// <param name="schemaName"></param>
      /// <param name="entityName"></param>
      /// <returns></returns>
      protected static string[] DecodeUrnKey(string key, out string ty, out string dbName, out string schemaName, out string entityName)
      {
         string[] items = key.Split(new[] { ':', '.' }); //, '.', '[', ']' });
         var itmCnt = items.Length;

         if (itmCnt > 6)
            Utils.Assertion(items.Length <= 6);

         dbName = items[0].Trim();
         schemaName = items[1].Trim();

         switch (itmCnt)
         {
            case 4:
               entityName = items[2].Trim();
               break;

            case 5:
               entityName = $"{items[2]}.{items[3]}";
               break;

            case 6: // assembly like: 'Farming_dev..Microsoft.SqlServer.Types: SqlAssembly'
               entityName = $"{items[0]}.{items[5]}";
               break;

            default:
               throw new Exception($"DecodeUrnKey({key}): unrecognised key type - it has {itmCnt} items - expect 2 or 3");
         }

         ty = items[items.Length - 1].Trim(); // tSQLt annotations have 5 items, ty is the last
         return items;
      }

      /// <summary>
      /// Fast decode of type
      /// </summary>
      /// <param name="urn"></param>
      /// <returns></returns>
      /// <exception cref="Exception"></exception>
      public static SqlTypeEnum GetUrnType(Urn urn)
      {
         string? type_str = urn.Type;
         SqlTypeEnum type = type_str.FindEnumByAliasExact<SqlTypeEnum>(true);
         return type;
      }

   }
}

