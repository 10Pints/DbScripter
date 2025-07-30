//using System.Xml.Linq;

using CommonLib;

using Microsoft.SqlServer.Management.Common;
//using Microsoft.SqlServer.Management.HadrModel;
using Microsoft.SqlServer.Management.Sdk.Sfc;
using Microsoft.SqlServer.Management.Smo;
//using System;
//using System.Collections.Generic;
using System.Collections.Specialized;
using System.Security.Policy;
//using System.Diagnostics.Eventing.Reader;
//using System.IO;
//using System.Linq;
//using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;

using static CommonLib.Logger;
using static CommonLib.Utils;

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

      //private int _exportedItemCnt = 0;

      public DbScripter()
      {
         P = new Params();
      }

      /// <summary>
      /// Initializes the Scrioter
      /// Preconditions
      /// none??
      /// 
      /// Postconditions
      /// POST 01: (init succeeded AND ret = true AND msg = "") OR (init failed AND ret = false AND msg != "")
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

            if(Directory.Exists(P.ScriptDir))
               Directory.Delete(P.ScriptDir, recursive: true);

            Assertion(!Directory.Exists(P.ScriptDir), "directory still exists ");

            SqlTypeEnum[]? weekendDays = Enum.GetValues<SqlTypeEnum>();

            foreach(var ty in Enum.GetValues<SqlTypeEnum>())
               ExportedItems[ty] = new SortedList<string, string>(new StringCompareNoCase());

            // Create the server object and makes a connection, throws exception otherwise
            if (!InitServer(P.Server ?? "", P.Instance ?? "", out msg))
               break;

            if (!InitDatabase(P.Database, out msg))
               break;

            if (!InitScriptingOptions(out msg))
               break;

            ret = IsValid(out msg);

         } while(false);

         // POST 01: (init succeeded AND ret = true AND msg = "") OR (init failed AND ret = false AND msg != "")
         Postcondition(((ret ==true) &&  (msg == "")) || ((ret == false) && (msg != "")));
         return LogR(ret);
      }

      /// <summary>
      /// The Main entry point for exporting scripts
      /// Design: EA: Model.Use Case Model.Main Use Case Model.Export.Export.Export_ActivityGraph.Export Files Act
      /// 
      /// Preconditions
      ///   Logger init
      ///   Params init
      ///   Database init
      ///   
      /// Postconditions:
      /// POST 01: ret = true and schema objects exported to the named export file
      ///          OR (error AND ret = 0 and suitable error msg)
      ///
      /// Tests: DbScripterTests.DbScripterTests
      /// </summary>
      /// <param name="msg"></param>
      /// <returns></returns>
      public bool Export(out string msg)
      {
         LogSN("Main entry point for exporting scripts");
         bool ret = false;

         do
         {
            // Init the writer
            LogN("Calling ExportInit");

            if (!ExportInit(out msg))
               break;

            StringBuilder sb = new();

            // Get the list of all specifically required root urns
            LogN("Get the list of required root urns");
            HashSet<Urn> rootUrns = GetSpecificRequiredRootUrns(); // urn_map

            // Get the list of all urns for each 'want all' type
            LogN("Get the list of all 'want all' urns and types");
            GetWantAllUrns(rootUrns);

            // Filter unwanted items
            LogN($"Filter unwanted items from the root urns");
            rootUrns = FilterUnwantedItems(rootUrns);

            // Get the dependency tree for all roots: this includes the roots
            LogN("Get the dependency tree for all roots");
            DependencyTree? dependencyTree = GetDependencies(rootUrns, mostDependentFirst: true);

            // If no dependencies then nothing to script
            if (dependencyTree == null || dependencyTree.Count == 0)
            {
               msg = "No dependencies found to script";
               LogE(msg);
               break;
            }

            // Create the dependency walk in least first dependency order
            LogN("Create the dependency walk in least first dependency order");
            List<Urn>? walk = CreateDependencyWalk( dependencyTree);
            Dictionary<string, Dictionary<string, List<string>>> schemaMap = new Dictionary<string, Dictionary<string, List<string>>>();
            DisplayExportFiles(walk);

            // If no walk then nothing to script
            if (walk == null || walk.Count == 0)
            {
               msg = "No items to script";
               LogE(msg);
               break;
            }

            // Script all items to text file and add to the main script in dependency order
            LogN("Script the items to file in dependency order");

            // If a composite file then script the output file header 
            ScriptCompositeHdr(sb);

            // Finally
            ret = ScriptItems(sb, walk, out msg);
            //ret = true;
         } while(false);

         return LogRN(ret, msg);
      }

      protected void DisplayExportFiles(List<Urn> walk)
      {
         Dictionary<string, Dictionary<string, List<string>>> schemaMap = new Dictionary<string, Dictionary<string, List<string>>>();

         foreach (var urn in walk)
         {
            string type = urn.Type;
            string name = urn.GetAttribute("Name");
            string schema = urn.GetAttribute("Schema") ?? "";
            string q_name = (schema == null) ? name : $"{schema}.{name}";

            if (!schemaMap.Keys.Contains(type))
               schemaMap[type] = new();

            var map = schemaMap[type];

            if (!map.Keys.Contains(schema ?? ""))
               map[schema] = new List<string>();

            map[schema].Add(q_name);
         }

         foreach (KeyValuePair<string, Dictionary<string, List<string>>> pr in schemaMap)
         {
            //LogI($"{pr.Value.Count()} {pr.Key}s");

            foreach (var pr2 in pr.Value)
               LogI($"{pr2.Value.Count()} {pr2.Key} {pr.Key}s");
         }

         LogI();

         foreach (KeyValuePair<string, Dictionary<string, List<string>>> pr in schemaMap)
         {
            LogI($"{pr.Value.Count()} {pr.Key}s:");

            foreach (var pr2 in pr.Value)
            {
               LogI($"\tschema: {pr2.Key}");

               foreach (var item in pr2.Value)
                  LogI($"\t\t{item}");
            }
         }
      }

      /// <summary>
      /// Filters the unwanted items including the following:
      /// Assemblies: Microsoft.SqlServer.Types
      /// schema: sys, tSQLt, INFORMATION_SCHEMA
      /// sysdiagrams, fn_diagramobjects
      /// do not want schemas in the depednency discovery process - will cause a
      /// Microsoft.SqlServer.Management.Smo.FailedOperationException exception
      /// </summary>
      /// <param name="rootUrns"></param>
      public HashSet<Urn> FilterUnwantedItems(HashSet<Urn> rootUrns)
      {
         int         cnt         = rootUrns.Count;
         int         i           = 0; // 1 based numbering
         int         j           = 0;
         int         k           = 0;
         HashSet<Urn> filteredUrns       = new();
         LogS($" {cnt} candidate urns");

         foreach (Urn urn in rootUrns)
         {
            if(IsWanted( ++i, urn))
            {
               //----------------------------
               // ASSERTION: item is wanted
               //----------------------------
               filteredUrns.Add(urn);
               ++j;
            }
            else
               ++k; // not wanted
         }

         Logger.Flush = false;
         LogL($"total candidate urns: {cnt}, #filtered: {filteredUrns.Count}, #ignored: {k}");
         return filteredUrns;
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="type"></param>
      /// <param name="name"></param>
      /// <param name="schema"></param>
      /// <param name="wanted_str"></param>
      /// <param name="database"></param>
      /// <param name="wanted"></param>
      /// <param name="i"></param>
      /// <param name="j"></param>
      /// <param name="k"></param>
      /// <param name="digits"></param>
      /// <param name="sqlType"></param>
      /// <param name="filteredUrns"></param>
      /// <param name="urn"></param>
      /// <exception cref="Exception"></exception>
      private bool IsWanted(int i, Urn urn)
      {
         bool   is_wanted = true;
         string wanted_str = "";
         string type = urn.Type;
         string name = urn.GetAttribute("Name");
         string schema = urn.GetAttribute("Schema");
         string database = GetDatabaseNameFromUrn(urn) ?? "";

         //if(i==62)
         //   wanted_str = "stp";

         do
         {
            // Always filter foreign items not in this database
            if (!database.Equals(P.Database, StringComparison.OrdinalIgnoreCase))
            {
               is_wanted = false;
               break;
            }

            if (type == "UnresolvedEntity")
            {
               is_wanted = false;
               break;
            }

            SqlTypeEnum sqlType = type.FindEnumByAlias2Exact<SqlTypeEnum>(bThrowIfNotFound: true);

            if (schema != null && P.UnwantedSchemas.Contains(schema))
            {
               is_wanted = false;
               break;
            }

            switch (type)
            {
               case "SqlAssembly":
                  if (P.UnwantedAssemblies.Contains(name))
                     is_wanted = false;
                  break;

               // do not want schemas in the depednency discovery process - will cause a
               // Microsoft.SqlServer.Management.Smo.FailedOperationException exception
               case "Schema":
                  is_wanted = false;
                  break;

               default:
                  // If the type key is not in the unwanted schemaMap then this is an error
                  if (!P.UnwantedItemMap.TryGetValue(sqlType, out List<string>? items))
                     throw new Exception($"E4000: FilterUnwantedItems unrecognised type: [{type}]");

                  // If the type is not in the unwanted schemaMap then it is wanted
                  if (P.UnwantedItemMap[sqlType].Contains(name))
                     is_wanted = false;
                  break;
            } // end switch
         } while (false); // end do

         wanted_str = is_wanted ? "" : "not ";
         LogI($"[{(++i).ToString($"D4")}] {wanted_str}wanted: {type} {database}.{schema}.{name}");
         return is_wanted;
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="urn"></param>
      /// <returns></returns>
      public static string? GetDatabaseNameFromUrn(Urn urn)
      {
         if (urn == null)
            return null;

         // Navigate up the URN hierarchy to find the Database node
         Urn current = urn;
         while (current != null && current.Type != "Database")
            current = current.Parent;

         // If a Database node is found, get its Name attribute
         if (current != null && current.Type == "Database")
            return current.GetAttribute("Name");

         return null; // Database node not found
      }

      /// <summary>
      /// Script all items in dependency order
      /// </summary>
      /// <param name="sb"></param>
      /// <param name="walk"></param>
      /// <returns></returns>
      private bool ScriptItems(StringBuilder sb, List<Urn> walk, out string msg)
      {
         LogS("Stage 2 : export the required objects in dependency order");
         int tot_cnt = 0; // total number of items scripted
         int ok_cnt = 0;  // number of items scripted ok
         bool ret = false;

         try
         { 
            msg = "";

            // Add the use db statement if required
            if (P.ScriptUseDb)
               ScriptUse(sb);

            // Script the items to text file and add to the main script
            foreach (Urn urn in walk)
            {
               sb.AppendLine(ScriptItemToString(++tot_cnt, urn, out ret));
               if(ret)
                  ok_cnt++;
               else
               {

                  msg = $"Error scripting item {tot_cnt}: {urn}";
                  LogE(msg);
                  BadBin.Add(urn.ToString(), msg);
               }
            }

            // Finally, if AOK
            ret = true;
         }
         catch(Exception e)
         {
            msg = $"ScriptItems caught the following exception: {e}";
         }
         finally
         {
            Writer?.Close();
            sb.Clear();
         }

         return LogR(ret, $" scripted {ok_cnt}/{tot_cnt} items, last error: {msg}");
      }

      /// <summary>
      /// This gets the list of all specified required root urns 
      /// as defined in the Params wantall schemaMap
      /// </summary>
      /// <param name="urn_map"></param>
      /// <returns></returns>
      public HashSet<Urn> GetSpecificRequiredRootUrns()
      {
         LogS();
         HashSet<Urn>? rootUrns = new HashSet<Urn>();
         Urn? urn = null;
         int i = 0;

         /// 1. Get all the specified required root urns 
         /// 2. for each 'want all' type: all the urns of that type in the db
         foreach (KeyValuePair<SqlTypeEnum, List<string>> pr in P.RequiredItemMap)
            foreach(string q_nm in pr.Value)
            {
               i++;
               // Get the urn from the q name this item
               urn = GetUrnFromName(pr.Key, q_nm);

               if(urn != null)
                  rootUrns.Add(urn);
            }

         LogL($"found {rootUrns.Count} root items, candidate item cnt:: {i}");

         foreach (var item in rootUrns)
            LogI($"{item}");

         return rootUrns;
      }

      /// <summary>
      /// Most objects are held on the server
      /// But assemblies are held on the Database
      /// </summary>
      /// <param name="type"></param>
      /// <param name="q_nm"></param>
      /// <returns></returns>
      public Urn? GetUrnFromName(SqlTypeEnum type, string q_nm)
      {
         Urn? urn = CreateUrn(Server.Name, Database.Name, q_nm, type);
         SqlSmoObject? item = null;

         switch (type)
         {
            // Probably an MS bug - Assemblies cannot be found by Server.GetSmoObject(urn)
            case SqlTypeEnum.Assembly:
               item = Database.Assemblies[q_nm];
               urn = item?.Urn ?? null;
               break;

            // Generic processing assumes object is held on the server
            default:
               try
               { 
                  if (Server.GetSmoObject(urn) == null)
                     urn = null;
               }
               catch(Exception e)
               {
                  LogException(e);
                  urn = null;
               }
               break;
         }

         return urn;
      }

      /// <summary>
      /// This adds all 'want the all' urns to root_urns set
      /// Populates 
      /// as defined in the Params wantall schemaMap
      /// </summary>
      /// <param name="urns"></param>
      public void GetWantAllUrns(HashSet<Urn> rootUrns)
      {
         LogS();

         /// 1. Get all the specified required root urns 
         /// 2. for each 'want all' type: all the urns of that type in the db
         foreach (KeyValuePair<SqlTypeEnum, bool> pr in P.WantAllMap.Where(x => x.Value))
         {
            SortedListCollectionBase? dbColl = DbCollmap[pr.Key];

            foreach (dynamic item in dbColl)
               rootUrns.Add(item.Urn);
         }

         LogL($"found {rootUrns.Count} root items:");
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

            // 250707: Init Writer file is not opened before necessary else can lead to file locks during testing
            if (!InitWriter(out msg))
               break;

            if (database == null)
            {
               msg = "E0002: Precondition violation: Database not specified";
               break;
            }

            msg = "";
            ret = true;
         } while(false);

         return LogR(ret, msg);
      }

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
      /// 
      /// POST 3: creates the subfolders: StoredProcedures, Functions, Views, Tables, UserDefinedTypes
      /// </summary>
      /// <param name="exportFilePath"></param>
      /// <param msg="possible error/warning message"></param>
      /// <returns>ret of the writer initialisation</returns>
      protected bool InitWriter(out string msg)
      {
         string scriptFile = P.ScriptFile ?? "";
         LogS($"Script file: [{scriptFile}]");
         bool ret = false;
         msg = "";

         try
         {
            do
            {
               // Close the writer
               CloseWriter();

               // POST 2
               if(string.IsNullOrEmpty(scriptFile))
               { 
                  msg = "exportScriptPath must be specified";
                  break;
               }

               //---------------------------------------
               // ASSERTION: writer intialised
               //---------------------------------------
               string? directory = Path.GetDirectoryName(scriptFile);

               if(directory == null)
               {
                  msg = "directory not specified";
                  break;
               }

               if (!Directory.Exists(directory))
                  Directory.CreateDirectory(directory);

               //---------------------------------------
               // ASSERTION: the root directory exists
               //---------------------------------------

               // POST 3: create the subfolders: StoredProcedures, Functions, Views, Tables, UserDefinedTypes
               Directory.CreateDirectory(Path.Combine(directory, "StoredProcedures"));
               Directory.CreateDirectory(Path.Combine(directory, "Functions"));
               Directory.CreateDirectory(Path.Combine(directory, "Views"));
               Directory.CreateDirectory(Path.Combine(directory, "Tables"));
               Directory.CreateDirectory(Path.Combine(directory, "UserDefinedTypes"));
               Directory.CreateDirectory(Path.Combine(directory, "Misc"));

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

               if (Writer == null)
               {
                  msg = "write not initialised";
                  break;
               }

               string scripteFilePath = ((FileStream?)Writer?.BaseStream)?.Name ?? "not defined";

               if (!scripteFilePath.Equals(P?.ScriptFile ?? "", StringComparison.OrdinalIgnoreCase))
               {
                  msg = $"Writer not initialised properly, scripteFilePath: {scripteFilePath}";
                  break;
               }

               // ---------------------------------------------------------------------------
               // ASSERTION: writer intialised and target file has been created and is empty
               // Processing complete
               // ---------------------------------------------------------------------------

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
      /// Utility method to replace multiple consecutive CRLF sequences with a single CRLF.
      /// This is useful because the SQL server routine compuiler tends to create multiple CRLF unnesessarily
      /// Maythis should be a struing extension method
      /// </summary>
      /// <param name="input"></param>
      /// <returns></returns>
      public static string ReplaceMultipleCrlf(string input)
   {
      // Pattern: Matches two or more \r\n sequences
      return Regex.Replace(input, @"(\r\n){2,}", "\r\n");
   }

      /// <summary>
      /// Use this when we dont need to look for the CREATE RTN statement
      /// if mode is alter and not schema or db then modify statements here
      /// tables need to drop and create
      /// 
      /// changes:
      /// 250724: replace multiple /r/n pairs with 1 /r/n pr
      /// </summary>
      /// <param name="transactions"></param>
      /// <param name="sb"></param>
      protected void ScriptTransactions(StringCollection? transactions, StringBuilder sb, Microsoft.SqlServer.Management.Sdk.Sfc.Urn urn, bool wantGo)
      {
         var key = GetUrnDetails(urn, out var type, out _, out var schemaNm, out var entityNm);

         if(transactions == null)
               throw new Exception("E0000: null transactions collection");

         if (transactions.Count > 0)
         {
            var op = P.CreateMode.GetAlias();
            //int x = 0;
            //bool found = false;

            // Need to put a go top and bottom of routine between the set ansi nulls etc to
            // make the export toutine the only thing in the transaction
            // only replace the alter once in the script
            foreach (string? transaction_ in transactions)
            {
               if (transaction_ != null)
               {
                  // 250724: replace multiple /r/n pairs with 1 /r/n pr
                  string transaction = transaction_;

                  if (transaction.Contains("\r\n\r\n"))
                     transaction = transaction.ReplaceMultipleCrlf("\r\n");

                  transaction = transaction.Trim();
                  bool ignoreGo = transaction.StartsWith("SET ANSI_NULLS"); // || transaction.Contains("SET QUOTED_IDENTIFIER ON");
                  
                  if (wantGo && !ignoreGo)
                     ScriptGo(sb, false);
                  /*

                  if (wantGo && !ignoreGo)
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
                                    ScriptGo(sb, false);
                                    found = true;
                                 }
                                 else
                                 {
                                    ScriptGo(sb, false);
                                    found = true;
                                 }
                              }
                              else
                              {
                                 ScriptGo(sb, false);
                                 found = true;
                              }
                           }
                           else
                           {
                              ScriptGo(sb, false);
                           }
                        }

                        x++;
                     }
                  }
                  */

                  ScriptLine(transaction, sb);
               }
            }

            // Place a GO immediatly after the transaction
            if (wantGo)
               ScriptGo(sb, false);

            if (WantBlankLineBetweenTransactions())
               ScriptBlankLine(sb);
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
      public static string CreateUrn(string? server, string db, string q_name, SqlTypeEnum type)
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
      /// <param name="attr_map">schemaMap of the attribute name/value paurs for this level</param>
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
            // schemaMap of level attrs
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

               if(!attr_map.ContainsKey(name))
                  attr_map.Add(name, map);
            }
         }

         // POSTCONDITION checks:
         // POST 1 returns the key as the return value and its parts as out params

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

               // -------------------------
               // ASSERTION: database exists
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
      }
      
      /// <summary>
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

               // Set the default loaded fields to include IsSystemObject
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
      public void CreateAndOpenServer(string? serverName, string? instance)
      {
         Assertion(!string.IsNullOrEmpty(serverName), "Server not specified");

         // ASSERTION: serverName, serverName, instance are all specified

         SqlConnectionInfo sqlConnectionInfo = new(serverName)
         {
            UseIntegratedSecurity = true
         };

         ServerConnection serverConnection = new(sqlConnectionInfo);
         Postcondition(serverConnection != null, "Could not create Server object");
         Server = new Server(serverConnection);
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
               NoCommandTerminator = false, // noGoflag, // true means don't emit GO statements after every SQLstatement
               NoIdentities = false,
               NonClusteredIndexes = true,
               Permissions = false,
               SchemaQualify = true,        //  e.g. [dbo].sp_bla
               SchemaQualifyForeignKeysReferences = true,
               NoAssemblies = false,
               ScriptBatchTerminator = true,
               ScriptData = P.IsExportingData,
               ScriptDrops = (P.CreateMode == CreateModeEnum.Drop),
               ScriptForAlter = false,     // issue here:  Dont script alter here - it doesnt work for functions, tables ... (P.CreateMode == CreateModeEnum.Alter), do in Script transactions method
               ScriptSchema = P.IsExportingSchema,
               WithDependencies = false,   // issue here: dont set true: Smo.FailedOperationException true, Unable to cast object of type 'System.DBNull' to type 'System.String'.
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


            // Lastly if here then all checks have passed
            ret = true;
         } while (false);

         return LogRD(ret, msg);
      }

      /// <summary>
      /// Creates a string for each item
      /// </summary>
      /// <param name="sb"></param>
      /// <param name="v"></param>
      /// <param name="urn"></param>
      protected string ScriptItemToString(int v, Urn urn, out bool success)
      {
         StringBuilder sb = new StringBuilder();
         var urns = new Urn[1];
         var typeStr = urn.Type;
         success = false;
         urns[0] = urn;
         // 241122: issue tSQlt functions like Server[@Name='DevI9']/Database[@Name='Farming_Dev']/UserDefinedFunction[@Name='@tSQLt:MaxSqlMajorVersion' and @Schema='tSQLt']
         SetScripterOptions(ScriptOptions, urn, P.CreateMode, true);

         var urn_s = GetUrnDetails(urn, out SqlTypeEnum type, out string dbName, out string schemaName, out string entityName);
         dynamic? item = null;

         if(entityName.Contains("fnCrtCodeTstHdr"))
         {
            LogI($"found fnCrtCodeTstHdr");
         }

         do
         {
            try
            {
               Console.WriteLine($"[{v:D3}]: {typeStr} {schemaName}.{entityName}");
               // items are stored in 2 different places depending on type
               // most are stored on the database
               if (type == SqlTypeEnum.UserDefinedDataType)
               {
                  if (Database.UserDefinedDataTypes.Contains(entityName, schemaName))
                     item = Database.UserDefinedDataTypes[entityName, schemaName];
                  else
                  {
                     if (Database.UserDefinedTableTypes.Contains(entityName, schemaName))
                        item = Database.UserDefinedTableTypes[entityName, schemaName];
                  }
               }
               else
               {
                  item = Server?.GetSmoObject(urn);
               }

               if (item == null)
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
                  break;
               }

               string sqlType = type.GetAlias();
               string action;

               // if mode IS NOT alter then script normally
               // if mode IS     alter then modify statements
               if (P.CreateMode == CreateModeEnum.Alter)
                  action = ScriptItemHandleAlter(transactions, sqlType, sb, urn);
               else
                  action = ScriptItemNormally(transactions, sb, urn);

               string scriptFilePath = CreateIndividualFileName(urn);
               LogI($"{scriptFilePath}");

               // WriteAllText creates a new file, writes the specified string to the file, and then closes the file. 
               // If the target file already exists, it is overwritten.
               File.WriteAllText(scriptFilePath, sb.ToString());
               RegisterResult(urn_s, sqlType, action);
               success = true;
            }
            catch(Exception e)
            {
               string msg = $"[{v:D3}] failed to script:  {typeStr} {schemaName}.{entityName} {e.Message}";
               LogException(e, msg);
               sb.AppendLine(msg);
               // continue
            }
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
      /// 
      /// </summary>
      /// <param name="options"></param>
      /// <param name="urn"></param>
      /// <param name="createMode"></param>
      /// <param name="individualFile"></param>
      protected void SetScripterOptions(ScriptingOptions options, Urn urn, CreateModeEnum? createMode, bool individualFile)
      {
         switch (createMode)
         {
            case CreateModeEnum.Alter:
               if (urn.Type == "Table")
               {
                  options.ScriptDrops    = true;
                  options.ScriptForAlter = false;
               }
               else
               {
                  options.ScriptDrops    = false;
                  options.ScriptForAlter = false; // true;
               }
               break;

            case CreateModeEnum.Create:
               options.ScriptDrops       = false;
               options.ScriptForAlter    = false;    // true
               break;

            case CreateModeEnum.Drop:
               options.ScriptDrops       = true;
               options.ScriptForAlter    = false;    // issue here:  Dont script alter here - it doesnt work for functions, tables ... (P.CreateMode == CreateModeEnum.Alter), do in Script transactions method
               break;
         }

         if (individualFile == true)
            FileName = CreateIndividualFileName(urn);
      }

      /// <summary>
      /// Creates the individual script filePath 
      /// NOTE: do not use timestamp
      /// as the Dbscriptor can be used to take snapshots of the routines for version management
      /// which relies on file name not being changed
      /// </summary>
      /// <param name="urn"></param>
      /// <returns></returns>
      protected string CreateIndividualFileName(Urn urn)
      {
         string objectType = urn.Type;                          // e.g. "StoredProcedure"
         string name = urn.GetAttribute("Name");                // e.g. "usp_DoSomething"
         string schema = urn.GetAttribute("Schema") ?? "dbo";   // handle null schemas
         string folderName;

         switch (objectType)
         {
            case "StoredProcedure":
               folderName = "StoredProcedures";
               break;
            case "UserDefinedFunction":
               folderName = "Functions";
               break;
            case "View":
               folderName = "Views";
               break;
            case "Table":
               folderName = "Tables";
               break;
            case "UserDefinedDataType":
               folderName = "UserDefinedTypes";
               break;
            default:
               folderName = "Misc";
               break;
         }
           
         string key = GetUrnDetails(urn, out SqlTypeEnum type, out string dbName, out string schemaNm, out string entityNm);
         string filePath = (schemaNm == "") ? @$"{P.ScriptDir}\{folderName}\{entityNm}.sql"
                                            : @$"{P.ScriptDir}\{folderName}\{schemaNm}.{entityNm}.sql";

         return filePath;
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
               matches = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]+{expSqlType}[ \t]*([^ \[]*)([ \[]+)([^\]]*)([\[\.\]]+)([^\]]*)", regOptns);
            }

            nMatches = matches.Count;
            // Assert 1 match found
            Assertion(nMatches == 1, $"ScriptTransactionsHandleAlter: failed to get match for ^create");

            // Plan is to add a go before the CREATE|ALTER|DROP statement
            // Got the Create mode: {CREATE|ALTER|DROP}
            var actSchema = matches[0].Groups[3].Value;
            var actEntity = matches[0].Groups[5].Value;

            // ?? Signatures must have [] for this to work
            if (expSchema.Equals(actSchema, StringComparison.OrdinalIgnoreCase) &&
                expEntity.Equals(actEntity, StringComparison.OrdinalIgnoreCase))
            {
               // Add a go after the set ansi nulls on etc but before the alter statement
               ScriptGo(sb);
               var ndx = matches[0].Index;
               Assertion(ndx > -1);

               // Substitute 'CREATE' with 'ALTER' 
               transaction = transaction.Substring(0, ndx) + "ALTER" + transaction.Substring(ndx + 6);
            }
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
         switch (sqlType)
         {
            // Do not script Alter Table - ignore it
            case "TABLE":
               if(P.CreateMode == CreateModeEnum.Alter)
                  action = $"Not scripting ALTER {key}]";
               break;

            case "PROCEDURE":
            case "FUNCTION":
            case "VIEW":
               // Handle here
               // Change create to alter for Prcedures and functions
               break;

            default:
               // Script normally
               break;
         }

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

      /// <summary>
      /// 
      /// </summary>
      /// <param name="type"></param>
      /// <param name="schemaName"></param>
      /// <param name="entityName"></param>
      /// <returns></returns>
      /// <exception cref="Exception"></exception>
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

            msg = "";
            ret = true;
         } while (false);

         return ret;
      }

      /// <summary>
      /// This uses the Microsoft MSO scripting library to get the dependency tree of all the items to script in SQL ser4ver database.
      /// </summary>
      /// <param name="rootUrns"></param>
      /// <param name="mostDependentFirst"></param>
      /// <returns> the dependendency tree for all root and their dependant items</returns>
      protected DependencyTree? GetDependencies(HashSet<Urn> rootUrns, bool mostDependentFirst)
      {
         LogS($"Root list has {rootUrns.Count} items");

         // If there are no rootUrns then return an empty list
         if (rootUrns.Count == 0)
         {
            LogE("GetDependencies: rootUrns is empty");
            return null;
         }

         // ASSERTION rootUrns.Count > 0
         Assertion(rootUrns.Count > 0, "GetDependencyWalk: precondition violation: rootUrns.Count > 0");
         List<Urn> walk = new();
         DependencyWalker? dependencyWalker = new DependencyWalker(Server);
         DependencyTree? depTree = null;
         DependencyType depTy = mostDependentFirst ? DependencyType.Parents : DependencyType.Children;

         try
         {
            depTree = dependencyWalker.DiscoverDependencies(rootUrns.ToArray(), depTy);
         }
         catch (Exception e)
         {
            // Sqlserver has a problem if dangling references to non existent procedures exist in db routines
            LogException(e, $"GetSchemaDependencyWalk");
            LogE($@"GetSchemaDependencyWalk failed:
MS code can do raise exception if dangling references to non existent procedures exist in db routines
Trying to script schema dependnecies in order tables, functions procedures
Script may need manual rearranging to get dependency order correct.
{e}");
            Assertion(GetSchemaChildren(P.RequiredSchemas ?? new List<string>(), out walk), "GetSchemaChildren failed");
         }

         LogL($"dependency tree contains {depTree?.Count ?? 0} items");
         return depTree;
      }

      protected List<Urn> CreateDependencyWalk(DependencyTree? depTree)
      {
         LogS();
         List<Urn> walk = new List<Urn>();

         // If the depTree is null then return an empty walk
         if (depTree == null)
         {
            LogE("GetDependencyWalk: depTree is null");
            return walk;
         }

         LogI($"GetDependencyWalk: depTree has {depTree.Count} items");

         //-------------------------------------------------------------
         // ASSERTION depTree populated
         //-------------------------------------------------------------

         // Walk the dependency tree and add items to the walk list
         DependencyWalker? dw = new DependencyWalker(Server);
         DependencyCollection? dependencies = dw.WalkDependencies(depTree);

         LogI($"GetDependencyWalk: found {dependencies.Count} dependencies");
         int i=0;

         foreach (DependencyCollectionNode item in dependencies)
         {
            Urn urn = item.Urn;
            var type = urn.Type;
            string? database = urn.GetNameForType("Database");
            string? schema = urn.GetAttribute("Schema");

            string? name = urn.GetAttribute("Name");

            // Do the second filter
            if(!IsWanted(++i, urn))
               continue;

            // Remove items from other databases
            if (!P.Database.Equals(database, StringComparison.OrdinalIgnoreCase))
            {
               LogW($"ignoring foreign object: {database}.{schema}.{name}");
               continue;
            }

            // filter any ites from another database or are unresolved
            if (type.Equals("UnresolvedEntity", StringComparison.OrdinalIgnoreCase))
            {
               LogW($"ignoring unresolved dependency : database: {database}.{name}");
               continue;
            }

            // Ignore schema objects
            if (GetUrnType(urn) == SqlTypeEnum.Schema)
            {
               LogW($"ignoring schema object: {database}.{name}");
               continue;
            }

            // Finally all OK: so add the item
            LogI($"Adding {urn}");
            walk.Add(urn);
         }

         LogL($"GetDependencyWalk: found {walk.Count} dependencies");
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

