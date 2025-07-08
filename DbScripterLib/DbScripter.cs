
#nullable enable
#pragma warning disable CS8602
#pragma warning disable CA1031 // Do not catch general exception types
//Microsoft.SqlServer.Management.Smo
using Microsoft.SqlServer.Management.Smo;
using System.Configuration;
using System.Diagnostics;
using System.Text;
using System.Collections.Specialized;
using CommonLib;
using Microsoft.SqlServer.Management.Sdk.Sfc;
using static CommonLib.Logger;
using static CommonLib.Utils;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.Management.Common;

namespace DbScripterLibNS
{
   /// <summary>
   /// This class is a universal exporter of any SQL database schema and data
   /// It uses the Microsoft.SqlServer.Management.Smo.Scripter class to export the scripts
   /// 
   /// Scripts functions are:
   ///     Create Database
   ///     Create Schema      (tables and stored procedures etc.
   ///     Create static data  (populate the fixed data like LightMode constants and Colony Format types
   ///     DropDatabase the database
   /// 
   /// The scripts are standard SQL scripts - and as such can be used any SQL interpreter
   /// There is another significant use data backups
   /// 
   /// By using standard SQL two advantages are available:
   ///     1. Can easily test on any database
   ///     2. Can filter the backups based on criteria like time span
   ///         e.g. Backup all Project related data for the last month
   ///         This would keep backups small and relevant, 
   ///         Bigger restores could be achieved by iterating several backups - e.g. in a directory
   /// </summary>
   public class DbScripter : IDbScripter
   {
      #region IDbScripter Impl
      /// <summary>
      /// Description: Main Export entry point
      ///
      /// DESIGN
      ///   Export Requirements
      ///   Export Activity Diagram
      ///
      /// When exporting a schema we should be able to specify which types are to be exported
      /// the default should be all types
      /// but if we define a set of types then that should take precidence
      ///
      /// PRE: the following export parameters must be defined:
      /// PRE 1: the params struct must not be null
      /// PRE 2: Sql Type
      /// PRE 3: Create   Mode
      /// PRE 4: Server   Name
      /// PRE 5: Instance Name
      /// 
      /// POST: Export completed
      ///   params arg updated
      /// </summary>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath"></param>
      /// <param name="staticDataTables">can configure the static data tables now</param>
      /// <returns></returns>
      ///
      /// Tests:
      ///   Count_Crt_Export_Tables_only_Schemas_dbo_tst_Test
      ///   ExportSchemas_Alter_1_ut_dbo_Test
      ///   ExportSchemas_Alter_2_ut_dbo_tst_Test
      ///   ExportSchemas_Alter_1_ut_tst_Test
      ///   ExportSchemas_Alter_1_cvdT1_dbo_Test
      ///   ExportSchemas_Alter_1_cvdT1_1_test_Test
      ///   ExportSchemas_Alter_1_cvd_dbo_Test
      ///   ExportSchemas_Alter_2_cvd_dbo_tst_Test
      ///   ExportProceduresDropTest
      ///   ExportProceduresDropTest
      ///   ExportFunctionsTest
      ///   ExportDatabaseTest
      ///   ExportSchemas_Create_cvd_1_tst_Test
      ///   ExportSchemas_Create_ut_1_tst_Test
      ///   ExportSchemas_Alter_2_cvdT1_dbo_tst_Test
      ///   ExportSchemas_Drop_1_tst_Test
      ///   ExportFunctionsCreateTest
      ///   ExportFunctionsDropTest
      ///   Count1CrtSTableTestBothExpSchemaAndExpDataNotDefinedTest
      ///   ExportSchemas_Create_2_cvdT1_dbo_tst_Test
      public bool Export( Params p, out string msg)
      {
         LogSN();
         bool ret = false;
         msg      = "";
         StringBuilder sb = new();

         try
         {
            do
            {
               LogN("Stage 1 : initialising export");

               if(!Init(p, out msg))
                  break;

               LogI($"Params at Export: \r\n{P.ToString()}");

               // if a composite file create the output file header 
               if (!P.IndividualFiles)
               { 
                  ScriptLine($"/*", sb);
                  ScriptLine($"Parameters:", sb);
                  ScriptLine($"{P}*/\r\n\r\n", sb);
               }

               // Clear the list of required schemas
               var schemaList = new List<string>(P.RequiredSchemas);
               P.RequiredSchemas.Clear();

               // Validate the schemas exist in the database - Add the required Schema smo objects to schema obj list - Schemas[] is case insensitve
               foreach( var schemaName in schemaList)
               {
                  LogI($"Adding {schemaName} to the schema list");
                  var schema= Database.Schemas[schemaName];

                  if(schema == null)
                  {
                     // continue if schema not found as we might be calling this in a loop, and not all databases might have all the required schema
                     // if the schema does not exist - its ok ...
                     LogC( $"schema: [{schemaName}] not found in database - continuing the script ...");
                     continue;
                  }

                  P.RequiredSchemas.Add(schema.Name);
               }

               if(msg.Length>0)
                  break; // error finding schema

               // Export the required objects in dependency order
               LogN("Stage 2 : export the required objects in dependency order");
               var dbAssemblies = Database.Assemblies;

               // if ExportSchemas returns false then no items were found to script
               if (!ExportSchemas(sb, out string script, out msg))
                  break;

               // Write the 'all objects' script to the main sql export file
               string sql = sb.ToString();
               File.WriteAllText("D:\\Dev\\DbScripter\\DbScripterLibTests\\Scripts\\out.sql", sql);
               sb.Clear();

               // Log the results to the export summary file
               // sb will have a counts summary of the exported lists
               LogN("Stage 3 : logging the results");
               LogResults(sb);

               // Write results summary to file
               ScriptLine($"/*\r\n{sb}*/"); // \r\n

               // If there is a message: write it to the SQL file
               if (!string.IsNullOrEmpty(msg))
                  ScriptLine($"/*\r\n {msg}\r\n*/");

               ret = true;
            } while(false);
         }
         catch(Exception e)
         {
            LogException(e);
         }
         finally
         {
            LogN("Stage 6 : closing the script writer");
            CloseWriter();
         }

         // Either success and no msg or error and msg
         //Postcondition(((ret == true) && (msg.Length == 0)) ||((ret == false) && (msg.Length > 0)));
         return LogRN(ret, msg);
      }

      /// <summary>
      /// Determines if scripter should display the script
      /// Override in the testable scripter so that this can be turned off in tests
      /// </summary>
      /// <returns></returns>
      protected virtual bool ShoulDisplayScript()
      {
         return P.ShoulDisplayScript();
      }

      /// <summary>
      /// Determines if scripter should display the log
      /// Override in the testable scripter so that this can be turned off in tests
      /// </summary>
      /// <returns></returns>
      protected virtual bool ShoulDisplayLog()
      {
         return P.ShoulDisplayLog();
      }

      /// <summary>
      /// Single point of entry, also used in testing
      /// </summary>
      protected void CloseWriter()
      {
         Writer?.Close();
      }

      /// <summary>
      /// This scripts all required schemas and their child objects in dependency order.
      /// The child types are filtered by the requireed tpes list in the config
      /// 
      /// if altering dont create the schemas.
      /// 
      /// When exporting a schema we should be able to specify which types are exported
      /// the default should be all types
      /// but if we define a set of types then that should take precidence
      /// PRE: Init called
      /// 
      /// Design:
      ///   Model.Use Case Model.UC01: Export schema.UC01: Export schema_ActivityGraph.UC01: Export schema_ActivityGraph
      ///   
      /// Strategy: 
      ///   get all wanted objects
      ///   get all their wanted dependiencies
      /// 
      /// CALLED BY: Export main entry point
      /// POST:
      ///  returns true if items were scripted
      ///  false if no items were scripted.
      ///  
      ///  if error then an exception is thrown
      /// sb
      /// </summary>
      public bool ExportSchemas(StringBuilder sb, out string script, out string msg)
      {
         LogC("DbScripter.ExportSchemas starting...");
         bool   ret  = false;
         string key  = "";
         script = "";

         try
         {
            do
            {
               // List the exported schemas to log
               LogC("Exporting the following schemas:");

               foreach(var schemaName in P.RequiredSchemas)
                  LogC($"   {schemaName}");

               LogC();

               // Check IsValid
               LogC("DbScripter.Export Stage 1: init...");
               Precondition(IsValid(out msg), msg);

               // Specialise the Options config for this op
               ExportSchemaScriptInit();

               // Create a list of SMO schema objects
               List<Schema> schemas = new();

               // Create and add the required Schema smo objects to the schema obj list
               // Schemas[] is case insensitve
               foreach( var schemaName in P.RequiredSchemas)
               {
                  LogDirect($"Adding {schemaName} to the schema list");
                  schemas.Add(Database.Schemas[schemaName]);
               }

               // Assertion we have a list of children
               if(P.ScriptUseDb)
                  ScriptUse(sb);

               // If creating then create the schemas now
               // test schemas need to be registerd with the tSQLt framework
               // if altering dont create the schemas
               if(P.CreateMode == CreateModeEnum.Create)
                  ScriptCreateSchemas(schemas, sb);

               LogC("DbScripter.Export Stage 3: Get Schema Dependencies Walk...");

               // Create the schema dependency walk returns false if no items
               if(!GetSchemaDependencyWalk( P.RequiredSchemas, (P.CreateMode == CreateModeEnum.Create || P.CreateMode == CreateModeEnum.Alter), out List<Urn> walk, out msg))
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

               // Script each smo item in walk order
               //foreach(Urn urn in walk)
               //   ScriptChildItem(sb, ++i, urn);

               // TODO: complete and test this individual file stuff
               // 241122: [tSQLt].[@tSQLt:RunOnlyOnHostPlatform] causes eror we take @tSQLt not @tSQLt:RunOnlyOnHostPlatform
               foreach (Urn urn in walk)
                  ScriptItemToFile( ++i, urn);

               // If dropping then drop schemas now
               if (P.CreateMode == CreateModeEnum.Drop)
                  ScriptDropSchemas( schemas, sb);

               ret = true;
               msg = "";
               script = sb.ToString();
               LogDirect($"Stage 5: all completed successfully");
            }
            while(false);
         }
         catch(Exception e)
         {
            msg = e.Message;
            LogC($"DbScripter.Export caught exception {e}");
            LogException(e, $"key: {key}");
            throw;
         }

         LogC("DbScripter.Export completed");
         LogL($"ret: {ret}");
         return ret;
      }

      protected void SetScripterOptions(ScriptingOptions options, Urn urn, CreateModeEnum? createMode, bool individualFile)
      {
         switch(createMode)
         {
            case CreateModeEnum.Alter:
               if(urn.Type=="Table")
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
               options.ScriptDrops    = false;
               options.ScriptForAlter = false;    // true
               break;

            case CreateModeEnum.Drop:
               options.ScriptDrops    = true;
               options.ScriptForAlter = false;    // issue here:  Dont script alter here - it doesnt work for functions, tables ... (P.CreateMode == CreateModeEnum.Alter), do in Script transactions method
               break;
         }

         if(individualFile == true)
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
         string key = GetUrnDetails(urn, out string type, out string dbName,out string schemaNm, out string entityNm);
         string fileName = @$"{P.ScriptDir}\{schemaNm}.{entityNm}.sql";
         return fileName;
      }

      protected void ScriptCreateSchemas(List<Schema> schemas, StringBuilder sb)
      {
         // If creating then create the schemas now
         // test schemas need to be registerd with the tSQLt framework
         // if altering dont create the schemas
         LogC("DbScripter.Export Stage 2: scripting schema create sql...");

         foreach(var schema in schemas)
         {
            if(IsTestSchema(schema.Name))
               ScriptLine( $"EXEC tSQLt.NewTestClass '{schema.Name}';", sb);
            else
               ExportSchemaStatement(schema, sb);
         }
      }

      protected void ScriptDropSchemas(List<Schema> schemas, StringBuilder sb)
      {
         LogDirect($"Stage 5: scripting drop schema sql");
         LogC("DbScripter.Export Stage 5: scripting drop schema sql...");

         foreach(var schema in schemas)
         {
            if(IsTestSchema(schema.Name))
               ScriptLine( $"EXEC tSQLt.DropClass '{schema.Name}';", sb);
            else
               ExportSchemaStatement(schema, sb);
         }
      }


      public DbScripter(/*Params? p = null*/)
      {
         LogS();
         //Init(p);
      }

      #endregion IDbScripter Impl
      #region    properties
      #region    primary properties

      // Primary properties
      // are set by the constructor
      public Params P {get;set; } = new Params();
      public string ScriptFile{get; protected set;} = "";
      

      #endregion primary properties
      #region    major scripting properties

      // Major properties
      public Database?         Database       { get; private set; }
      protected Scripter       Scripter       { get; private set; } = new Scripter();
      public ScriptingOptions  ScriptOptions  { get; private set; } = new ScriptingOptions();
      public Server?           Server         { get; private set; }
      public StreamWriter?     Writer         { get; private set; }
      public bool              IsInitialised  { get; private set; } = false;
      public string FileName { get; set; } = "";

      #endregion major scripting properties
      #region    minor scripting properties

      private int _exportedItemCnt = 0;
      //private int _scripted_cnt    = 0;
      #endregion minor scripting properties
      #region scripter info cache

      // These properties are info caches for the scripted items
      public SortedList<string, string> BadBin                 { get; protected set; } = new ();
      public SortedList<string, string> ExportedDatbases       { get; protected set; } = new (new StringCompareNoCase());
      public SortedList<string, string> ExportedSchemas        { get; protected set; } = new (new StringCompareNoCase());
      public SortedList<string, string> ExportedTables         { get; protected set; } = new (new StringCompareNoCase());
      public SortedList<string, string> ExportedProcedures     { get; protected set; } = new (new StringCompareNoCase());
      public SortedList<string, string> ExportedFunctions      { get; protected set; } = new (new StringCompareNoCase());
      public SortedList<string, string> ExportedViews          { get; protected set; } = new (new StringCompareNoCase());
      public SortedList<string, string> ExportedTableTypes     { get; protected set; } = new ();

      // dependency eval
      public SortedList<string, string> WantedItems            { get; protected set; } = new();
      public SortedList<string, string> ConsisderedEntities    { get; protected set; } = new ();
      public SortedList<string, string> DifferentDatabases     { get; protected set; } = new();
      public SortedList<string, string> DuplicateDependencies  { get; protected set; } = new();
      public SortedList<string, string> SystemObjects          { get; protected set; } = new();
      public SortedList<string, string> UnresolvedEntities     { get; protected set; } = new();
      public SortedList<string, string> UnwantedSchemas        { get; protected set; } = new();
      public SortedList<string, string> UnwantedTypes          { get; protected set; } = new();
      public SortedList<string, string> UnknownEntities        { get; protected set; } = new();

      public SortedList<string, string> PrintedItems { get; protected set; } = new ();

      #endregion scripter info cache

      #endregion properties
      #region    public methods

      public virtual string GetTimestamp()
      { 
         return DateTime.Now.ToString("yyMMdd-HHmm");
      }

            
      public void DisplayScript()
      {
         if(P.ScriptFile != null)
            Process.Start($"Notepad++.exe", P.ScriptFile);
      }


      /// <summary>
      /// Initialize state, deletes the writerFilePath file if it exists
      /// Only completes the initialisation if the parameters are all specified
      /// 
      /// PRECONDITIONS:
      ///   1: p              specified
      ///   2: P.ServerName   specified
      ///   3: P.InstanceName specified
      ///   4: P.CreateMode   specified
      ///   
      /// POSTCONDITIONS:
      ///   1: EITHER:
      ///   (
      ///      1.1: Initialises the initial state
      ///      1.2: server and makes a connection, throws exception otherwise
      ///      1.3: database connected
      ///      1.4: sets the scripter options configuration based on optype
      ///      1.5. sets the IsInitialised flag
      ///      1.6: writer open
      ///      1.7: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
      ///   )
      ///   OR
      ///   2: clears the IsInitialised flag
      ///   <returns>true if successful, false and msg populated otherwise</returns>
      ///   
      /// </summary>
      /// <param name="serverName">DevI9\SQLEXPRESS</param>
      /// <param name="instanceName">like SQLEXPRESS</param>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath">like C:\tmp\Covid_T1_export.sql</param>
      /// <returns>true if successful, false and msg populated otherwise</returns>
      protected bool Init( Params p, out string msg) //, StringBuilder? sb = null)
      {
         LogC("DbScripter.Init starting");
         LogC($"parameters at Init():" +
            $"\n {P.ToString()}");

         bool ret = false;
         msg = "";

         P = p;

         try
         {
            do
            {
               // -----------------------------------------
               // ASSERTION: Utils.Preconditions validated
               // -----------------------------------------


               // ClearState if not appending
               //ClearState();

               // Validate user settings now
               if(!ValidateInit(P, out msg))
                  break;


               // Set the defaults before we pop from incoming parameters
               //P.SetDefaults();

               // Initialise the initial state, only if curnt property is null
               //P.PopFrom2(p);
               //P = p;

               // Set the IsExporting flags based on the root type
               // Defaults:
               //if(!P.Normalise( out msg))
               //  break;

               // Create the server object and makes a connection, throws exception otherwise
               if(!InitServer(P.Server ?? "", P.Instance ?? "", out msg))
                  break;

               if(!InitDatabase(P.Database, out msg))
                  break;

               if(!InitScriptingOptions( out msg))
                  break;

               // InitWriter calls IsValid() - returns the Validation status - 
               // NOTE: can continue if not all initialised so long as the final init is performed before any write op
               // PRE:  P pop with export path
               // POST: Writer open
               if(!InitWriter(out msg))
                  break;

               /*
               ScriptLine($"/*\r\n\r\n\r\n", sb);
               ScriptLine($"Parameters:", sb);
               ScriptLine($"{P}\r\n\r\n", sb);
               */

               IsInitialised = true;

                // POSTCONDITION CHECKS:
               //  IsInitialised is true 
               //  AND
               //  (
               //     1.1: Initialises the initial state
               //     1.2: server and makes a connection, throws exception otherwise
               //     1.3: database connected
               //     1.4: sets the scripter options configuration based on optype
               //     1.5. sets the IsInitialised flag
               //     1.6: writer open
               //     1.7: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
               //  )

               ret = IsValid( out msg);
               // OR 2: clears the IsInitialised flag
            } while(false);
         }
         catch(Exception e)
         {
            LogException(e);
         }

         // POST: <returns>true if successful, false and msg populated otherwise</returns>
         if(!ret)
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");

         return LogRD(ret, msg);
      }

      /// <summary>
      /// Validation at the start of initialisation
      /// This should be applied to the user input not the corrected imput
      /// The following parameters must be specified:
      /// p, p.database
      /// 
      /// Changes:
      /// 240921: allow table export when ALTER defined, use drop/create
      /// </summary>
      /// <param name="p"></param>
      /// <param name="msg"></param>
      /// <returns></returns>
      protected static bool ValidateInit(Params p, out string msg)
      {
         LogSD();
         bool ret = false;
         // ---------------------------------------------------------------
         // Validate Preconditions
         // ---------------------------------------------------------------
         // PRE: the following export parameters must be defined:
         // PRE 1: the params struct must not be null
         // PRE 2: Sql Type
         // PRE 3: Create   Mode
         // PRE 4: Server   Name
         // PRE 5: Instance Name
         var defMsg  = "must be specified";
         msg         = "";

         do
         {
            if(p == null)
            {
               msg = $"Params arg {defMsg}";          // PRE 1
               break;
            }

            if(p.Database == null)
            {
               msg = $"database {defMsg}";            // PRE 2
               break;
            }

            // dont export tables if alter
            /*
            if((p.IsExportingTbls ?? false) == true && (p.CreateMode ?? CreateModeEnum.Error) == CreateModeEnum.Alter)
            {
               msg = "tables cannot be exported in alter mode";            // PRE 2
               break;
            }
            */

            ret = true;
         } while(false);

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
      protected bool InitServer( string serverName, string instanceName, out string msg)
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

               if(string.IsNullOrEmpty(serverName))
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

               Server  = CreateAndOpenServer( serverName, instanceName);
               var ver = Server.Information.Version;

               // Set the default loaded fields to include IsSystemObject
               // SetDefaultInitFields(Type,params string[] fields will be deprecated - use the one below)
               // SetDefaultInitFields(Type typeObject, DatabaseEngineEdition databaseEngineEdition, params string[] fields)
               Server.SetDefaultInitFields(typeof(Table),              "IsSystemObject");
	            Server.SetDefaultInitFields(typeof(StoredProcedure),    "IsSystemObject");
	            Server.SetDefaultInitFields(typeof(UserDefinedFunction),"IsSystemObject","FunctionType");
	            Server.SetDefaultInitFields(typeof(View),               "IsSystemObject");

               // -------------------------
               // Validate postconditions
               // -------------------------

               //  POST 1: Server smo object created
               //  POST 2: the server is online and connected
               if(Server == null)
               {
                  msg = "Could not create Server smo object";
                  break;
               }

               if(Server.Status != ServerStatus.Online)
               {
                  msg = "Could not connect to Server";
                  break;
               }

               // -----------------------------------------
               // ASSERTION: postconditions validated
               // -----------------------------------------
               ret = true;
            } while(false);
         }
         catch(Exception e)
         { 
            LogException(e);
            Log($"server:[{serverName}]  instance:[{instanceName}]");
            throw;
         }

         // POST 3: <returns>true if successful, false and msg populated otherwise</returns>
         if(!ret)
         {
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");
            LogE($"there was an error: {msg}");
         }

         return LogRD(ret, msg);
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

               if(Server == null)
               {
                  msg = "server not instantiated";      // PRE 1
                  break;
               }

               if(string.IsNullOrEmpty(databaseName))
               {
                  msg =  "database name not specified";  // PRE 2
                  break;
               }

               // -----------------------------------------
               // ASSERTION: Utils.Preconditions validated
               // -----------------------------------------

               var databases = Server.Databases;

               if(!databases.Contains(databaseName))
                  Server.Refresh();


               if(databases.Contains(databaseName))
               {
                  Database = Server.Databases[databaseName];
               }
               else
               {
                  msg =  $"database [{databaseName}] not found on server {Server.Name}";  // PRE 2
                  break;
               }

               // ASSERTION: if here then database exists

               // -------------------------
               // Validate postconditions
               // -------------------------

               /// POST: Database     instantiated and connected
               if( Database== null)
               {
                  msg = $"database {databaseName} smo object not created"; // POST 1
                  break;
               }

               if( (Database.Status & DatabaseStatus.Normal)!= DatabaseStatus.Normal)
               {
                  msg = $"database {databaseName} state is not normal";    // POST 2
                  break;
               }

               if( Database.Schemas.Count == 0)
               {
                  msg = $"database {databaseName} smo object not connected or no schemas exist"; // POST 3
                  break;
               }

               // -----------------------------------------
               // ASSERTION: postconditions validated
               // -----------------------------------------
               ret = true;
            } while(false);
         }
         catch(Exception e)
         { 
            LogException(e);
            msg = e.ToString();
         }

         // POST 4: <returns>true if successful, false and msg populated otherwise</returns>
         if(!ret)
         {
            LogE($"there was an error: {msg}");
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");
         }

         return LogRD(ret, msg);
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
            if(!P.IsValid(out msg))
               break; // PRE 1

            // -----------------------------------------
            // ASSERTION: Utils.Preconditions validated
            // -----------------------------------------

            //Scripter = new Scripter(Server);

            ScriptOptions = new ScriptingOptions()
            {
               ScriptForCreateDrop     = false, // DetermineScriptForCreateDrop(perFile, urn),
               AllowSystemObjects      = false,
               AnsiFile                = true,
               AnsiPadding             = false,
               AppendToFile            = true,     // needed if we use script builder repetitively
               Bindings                = false,
               ContinueScriptingOnError= false,
               ConvertUserDefinedDataTypesToBaseType = false,
               DriAll                  = true,
               ExtendedProperties      = true,
               IncludeDatabaseContext  = false, // we need more control P?.ScriptUseDb ?? false, // only if required
               IncludeHeaders          = false,
               IncludeIfNotExists      = false,
               Indexes                 = true,
               NoCollation             = true,
               NoCommandTerminator     = false, //noGoflag, // true means don't emit GO statements after every SQLstatement
               NoIdentities            = false,
               NonClusteredIndexes     = true,
               Permissions             = false,
               SchemaQualify           = true,  //  e.g. [dbo].sp_bla
               SchemaQualifyForeignKeysReferences = true,
               NoAssemblies            = false,
               ScriptBatchTerminator   = true,
               ScriptData              = P.IsExportingData,
               ScriptDrops             = (P.CreateMode == CreateModeEnum.Drop),
               ScriptForAlter          = false, // issue here:  Dont script alter here - it doesnt work for functions, tables ... (P.CreateMode == CreateModeEnum.Alter), do in Script transactions method
               ScriptSchema            = P.IsExportingSchema,
               WithDependencies        = false, // issue here: dont set true: Smo.FailedOperationException true, Unable to cast object of type 'System.DBNull' to type 'System.String'.
               ClusteredIndexes        = true,
               FullTextIndexes         = true,
               EnforceScriptingOptions = true,
               Triggers                = true
            };


            // Ensure either emit schema or data, if not specified then emit schema
            if((!ScriptOptions.ScriptSchema) && (!ScriptOptions.ScriptData))
               ScriptOptions.ScriptSchema = true;

            // -------------------------
            // Validate postconditions
            // -------------------------
            //  POST 2: ensure either emit schema or data, if not specified then emit schema
            if(!(ScriptOptions.ScriptSchema || ScriptOptions.ScriptData))
            { 
               msg = "either script schema or script data must be specified";//  POST 1:
               break;
            }

            // -----------------------------------------
            // ASSERTION: postconditions validated
            // -----------------------------------------
            Scripter.Options = ScriptOptions;
            ret = true;
         } while(false);

 
         // POST 3: <returns>true if successful, false and msg populated otherwise</returns>
         if(!ret)
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");

         Log( OptionsToString(Scripter.Options));

         // POST 4: <returns>true if successful, false and msg populated otherwise</returns>
         if(!ret)
         {
            LogE($"there was an error: {msg}");
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");
         }

         return LogRD(ret, msg);
      }

      protected bool DetermineScriptForCreateDrop(bool perFile, Urn urn)
      {
         throw new NotImplementedException();
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
         ScriptFile = P.ScriptFile ?? "";
         LogS($"Script file: [{ScriptFile}]");
         bool ret = false;

         try
         {
            do
            {
               // Close the writer
               CloseWriter();

               // POST 2
               Precondition(!string.IsNullOrEmpty(ScriptFile), "exportScriptPath must be specified");

               // ASSERTION: writer intialised
               var directory = Path.GetDirectoryName(ScriptFile);

               if (!Directory.Exists(directory))
                  Directory.CreateDirectory(directory);


               if (File.Exists(ScriptFile))
                  File.Delete(ScriptFile);

               var fs = new FileStream(P.ScriptFile, FileMode.CreateNew);
               Writer = new StreamWriter(fs){ AutoFlush = true }; // writerFilePath AutoFlush = true debug to dump cache immediately

               // POST 1: writer open pointing to the export file AND
               //         writer file same as ExportFilePath and both equal exportFilePath parameter
               if((Writer == null) ||
                         !((FileStream)(Writer.BaseStream)).Name.Equals(P.ScriptFile, StringComparison.OrdinalIgnoreCase))
               { 
                  msg = "Writer not initialised properly";
                  break;
               }

               // ASSERTION: writer intialised and target file has been created and is empty
               ret = true;
               msg = "";
            } while(false);
         }
         catch(Exception e)
         {
            msg = e.Message;
            LogException(e);
            CloseWriter();
         }

         // POST 4: <returns>true if successful, false and msg populated otherwise</returns>
         if(!ret)
         {
            LogE($"there was an error: {msg}");
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");
         }

         return ret;
      }

      protected void ClearState()
      {
         //LogS();
         // primary properties
         P.ClearState();

         // major scripting properties
         Database       = null;
         //Scripter       = new Scripter();
         //ScriptOptions  = null;
         Server         = null;
         Writer         = null;

         // info cache
         ClearCaches();
         //LogL();
      }

      protected void ClearCaches()
      {
         LogS();

         // info cache
         BadBin               .Clear();
         ExportedDatbases     .Clear();
         ExportedSchemas      .Clear();
         ExportedTables       .Clear();
         ExportedProcedures   .Clear();
         ExportedFunctions    .Clear();
         ExportedViews        .Clear();
         ExportedTableTypes   .Clear();

         ConsisderedEntities  .Clear();
         DifferentDatabases   .Clear();
         DuplicateDependencies.Clear();
         SystemObjects        .Clear();
         UnresolvedEntities   .Clear();
         UnwantedSchemas      .Clear();
         UnwantedTypes        .Clear();
         UnknownEntities      .Clear();
         WantedItems          .Clear();

         LogL();
      }

      #endregion public methods
      #region private methods

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
            if(!P.IsValid(out msg))
              break;

            if(Writer == null)
            {
               msg = "write not initialised";
               break;
            }

            string x = (((FileStream)Writer.BaseStream)?.Name ?? "not defined");

            // ((FileStream)(Writer.BaseStream)).Name.Equals(P.ExportScriptPath, StringComparison.OrdinalIgnoreCase)	D:\Dev\Repos\DbScripter\DbScripterLib\DbScripter.cs	493	37	DbScripterLib	Read	InitWriter	DbScripter	
            if(!x.Equals(P?.ScriptFile ?? "xxx", StringComparison.OrdinalIgnoreCase))
            {
               msg = "Writer not initialised properly";
               break;
            }

            // Lastly if here then all checks have passed
            ret = true;
         } while(false);

         return LogRD(ret, msg);
      }

      /// <summary>
      /// determines the type of the smo object
      /// 
      /// PRE smo != null
      /// 
      /// POST return != SqlTypeEnum.Undefined
      /// maps the objerct type to the equivalent SqlTypeEnum
      /// 
      /// </summary>
      /// <param name="smo"></param>
      /// <returns></returns>
      protected static SqlTypeEnum MapTypeToSqlType(SqlSmoObject? smo)
      { 
         Utils.Precondition(smo != null, $"MapTypeToSqlType: smo parameter must be defined");
         return MapTypeToSqlType(smo?.GetType()?.Name ?? "Undefined");
      }

      protected static SqlTypeEnum MapTypeToSqlType(string sqlTypeNm)
      {
         SqlTypeEnum? sty = sqlTypeNm switch
         {
            "Assembly"              => SqlTypeEnum.Assembly,
            "Database"              => SqlTypeEnum.Database,
            "UserDefinedFunction"   => SqlTypeEnum.Function,
            "StoredProcedure"       => SqlTypeEnum.Procedure,
            "Schema"                => SqlTypeEnum.Schema,
            "Table"                 => SqlTypeEnum.Table,
            "View"                  => SqlTypeEnum.View,
            "UserDefinedTableType"  => SqlTypeEnum.TableType,
            _                       => null
         };

         Postcondition<ArgumentException>(sty != null, $"MapTypeToSqlType failed for string'{sqlTypeNm}'");
         return sty ?? SqlTypeEnum.Error;
      }

      /// <summary>
      /// Use this when we dont need to look for the CREATE RTN statement
      /// if mode is alter and not schema or db then modify statements here
      /// tables need to drop and create
      /// </summary>
      /// <param name="transactions"></param>
      /// <param name="sb"></param>
      protected void ScriptTransactions( StringCollection? transactions, StringBuilder sb, Urn urn, bool wantGo)
      {
         
         Precondition(transactions != null, "oops: null transactions parameter");
         var key = GetUrnDetails(urn, out var smoType, out _, out var schemaNm, out var entityNm);

         if(transactions.Count> 0)
         { 
            var op   = P.CreateMode.GetAlias();
            var type = MapSmoTypeToSqlType( smoType);
            int x = 0;
            bool found = false;

            // Need to put a go top and bottom of routine between the set ansi nulls etc to
            // make the export toutine the only thing in the transaction
            // only replace the alter once in the script
            foreach( string? transaction in transactions)
            {
               if(wantGo)
               {
                  string line;

                  if(!found)
                  {
                     var m = Regex.Matches(transaction, $@"^[ \t]*{op}[ \t]*(.*)", RegexOptions.Multiline | RegexOptions.IgnoreCase);
                     var numFnsAct = m.Count;

                     // Plan is to add a go before the CREATE|ALTER|DROP statement
                     if(m.Count>0)
                     {
                        // Got the Create mode: {CREATE|ALTER|DROP}
                        line = $"{m[0].Groups[1].Value}";
                        // Signatures must have [] for this to work
                        var m2= Regex.Matches(line, $@"{type}[ \[]*([^\]]*)([\]\.\[]+)([^\]]*)([\]\(]*)", RegexOptions.IgnoreCase);

                        if( m2.Count > 0 )
                        {
                           // Got the RTN TY {CREATE|ALTER|DROP
                           // line like: "test].[fnDummy]()\r"
                           // grp 0 is the schema
                           // grp 1 is ].[
                           // grp 2 is the entityNm
                           var act_schema   = m2[0].Groups[1].Value;
                           var act_entityNm = m2[0].Groups[3].Value;

                           if(schemaNm.Equals(act_schema, StringComparison.OrdinalIgnoreCase))
                           {
                              // 2 scenarios here:
                              // 1 is the normal one altering a schema child
                              // 2: handling the create schema line in which case 
                              //    (act_entityNm = "") AND (schemaNm = act_schema) AND (entityNm = schemaNm)
                              if(entityNm.Equals(act_entityNm, StringComparison.OrdinalIgnoreCase) ||
                                 ( act_entityNm.Length == 0 && schemaNm.Equals(act_schema, StringComparison.OrdinalIgnoreCase))
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
               ScriptLine( transaction, sb);

               if(WantBlankLineBetweenTransactions())
                  ScriptBlankLine(sb);
            }

            if(wantGo)
               ScriptGo(sb);

            // if scripted here add to exported lists
            //AddToExportedLists( key);
         }
         else
         {
            Utils.AssertFail($"no script produced for {key}");
         }
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="key"></param>
      /// <param name="sqlType"></param>
      protected void RegisterResult(string key, string sqlType, string action)
      {
         bool bAddEntityToXprtLsts;

         switch(sqlType)
         {
         // Do not script Alter Table - ignore it
         case "TABLE":
            action = $"Not scripting ALTER {key}]";
            bAddEntityToXprtLsts = false;
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
            bAddEntityToXprtLsts = false;
            break;
         }

         // if scripted here add to exported lists
         if(bAddEntityToXprtLsts)
            AddToExportedLists( key);

         //LogL(action);
      }

      /// <summary>
      /// sole access to writing to the file/ stringbuilder
      /// </summary>
      /// <param name="line"></param>
      /// <param name="sb"></param>
      protected void ScriptLine(string line, StringBuilder? sb = null)
      { 
         if(!line.EndsWith("\r\n"))
            line += ("\r\n");

         Writer.Write(line);
         sb?.Append(line);
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
      /// Drop Scripts are handled differently.
      /// The drops are repetitive and simple transactions so don want a blank after
      /// each transaction emitted from the scripter.
      /// However if the is a drop operation then we DO want a blank line at the end of the
      /// Script part
      /// 
      /// PRE: Init called
      /// 
      /// POST: 
      /// 
      /// </summary>
      /// <param name="sb"></param>
      /// <param name="dbOpType"></param>
      private void CloseScript( StringBuilder sb)
      {
         // If a drop operation then add a blank line
         if(!WantBlankLineBetweenTransactions())
            ScriptBlankLine(sb);
      }

      /// <summary>
      /// Adds a new line to the script file, and the string builder
      /// </summary>
      /// <param name="sb"></param>
      private void ScriptBlankLine( StringBuilder sb )
      {
         ScriptLine(Environment.NewLine, sb);
      }

      /// <summary>
      /// Desc: scripts an item from its Urn if both the database and the schema are required
      ///
      /// Design: Model.Use Case Model.UC01: Export schema.UC01: Export schema_ActivityGraph.ScriptChildItem.Script Child Item act.Script Child Item act
      ///
      /// METHOD:
      ///   Get smo object from server using the urn
      ///   If both the database and the schema are required then script this item
      /// 
      /// CALLS:     ScriptItem
      /// 
      /// CALLED BY: ExportSchemas
      /// 
      /// PRECONDITIONS:
      /// 
      /// POSTCONDITIONS:
      /// 
      /// TESTS:
      /// 
      /// </summary>
      /// <param name="urn">the sno object unique identifier</param>
      /// <returns>true if scripted, false if not</returns>
      protected bool ScriptChildItem(StringBuilder sb, int i, Urn urn)
      {
         var key = GetUrnDetails(urn, out var ty, out var dbName, out var schemaName, out var name);
         Log($"scripting {ty.PadRight(20)}: {name}");
         bool ret = false;
         string? msg;// = null;

         do
         {

            // Map smo type to its equivalent sql type
            string sqlType = MapSmoTypeToSqlType(ty);

            // Get smo object from server
            var smo  = Server.GetSmoObject(urn);

            // If both the database and the schema are required then script this item
            if(P.Database.Equals(dbName, StringComparison.OrdinalIgnoreCase) && P.RequiredSchemas.Contains(schemaName))
            {
               // Script the item
               msg = $"Scripting item [{i}]: {key}";
               ScriptItem(smo, ScriptOptions, sb);
               ret = true;
            }
            else
            {
               msg = $"Not Scripting unrequired item: {key}";
               break;
            }
         } while(false);

         return LogRD(ret, msg);
      }

      /// <summary>
      /// Handles the changes needed for an ALTER export
      /// 
      /// METHOD:
      ///   if mode IS NOT alter then script normally
      ///   if mode IS     alter then modify statements
      /// 
      /// CALLED BY:
      ///   ScriptChildItem
      /// 
      /// PRECONDITIONS:
      /// 
      /// POSTCONDITIONS:
      ///   script contains the export for this item
      ///   
      /// TESTS:
      /// 
      /// </summary>
      /// <param name="smo">database object to be scripted</param>
      /// <param name="so"></param>
      /// <param name="sqlType"></param>
      /// <param name="sb">the script stream</param>
      protected void ScriptItem(SqlSmoObject? smo, ScriptingOptions? so, StringBuilder sb)
      {
         LogST();
         string key = GetUrnDetails(smo.Urn, out string ty, out _, out _, out _);
         string sqlType = MapSmoTypeToSqlType(ty);
         LogDirect($"[{PrintedItems.Count + 1}] Scripting {sqlType} {smo}");
         string action;

         SqlSmoObject[] smos = new [] { smo }; // SqlSmoObject
         StringCollection transactions = ((dynamic)smo).Script(so) ?? new StringCollection();
         //StringCollection transactions = this.Scripter.Script(smos) ?? new StringCollection();

         // Assert not already scripted
         if (PrintedItems.Keys.Contains(key))
            AssertFail("duplicate item");

         PrintedItems.Add(key, key);

         // if mode IS NOT alter then script normally
         // if mode IS     alter then modify statements
         if (P.CreateMode != CreateModeEnum.Alter)
            action = ScriptItemNormally(transactions, sb, key);
         else
            action = ScriptItemHandleAlter(transactions, sqlType, sb, key);

         RegisterResult(key, sqlType, action);
         LogLT();
      }

      /// <summary>
      /// Creates a file for each item
      /// </summary>
      /// <param name="sb"></param>
      /// <param name="v"></param>
      /// <param name="urn"></param>
      protected void ScriptItemToFile(int v, Urn urn)
      {
         StringBuilder sb = new StringBuilder();
         var urns   = new Urn[1];
         urns[0]         = urn;
         // 241122: issue tSQlt functions like Server[@Name='DevI9']/Database[@Name='Farming_Dev']/UserDefinedFunction[@Name='@tSQLt:MaxSqlMajorVersion' and @Schema='tSQLt']
         SetScripterOptions(Scripter.Options, urn, P.CreateMode, true);

         var urn_s = GetUrnDetails(urn,out string ty, out string dbName, out string schemaName, out string entityName);
         dynamic item;

         do 
         { 
            if(ty == "UserDefinedDataType")
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
               item = Server.GetSmoObject(urn);
            }

            Assertion(ScriptOptions.ScriptForAlter == false);
            StringCollection transactions = (item.Script(ScriptOptions)) ?? new StringCollection();
            Assertion(transactions.Count > 0);
            string key = GetUrnDetails(urn, out string smo_type, out _, out _, out _);
            string sqlType = MapSmoTypeToSqlType(smo_type);
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
            RegisterResult(key, sqlType, action);
         } while(false);
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

      protected void AddToExportedLists(string key)
      {
         _exportedItemCnt++;
         DecodeUrnKey(key, out string ty, out string database, out string schema, out string entityName);
         var shortKey = $"{schema}.{entityName}";

         switch (ty)
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

      /// <summary>
      /// Scripts an item based on its type and name
      /// </summary>
      /// <param name="urn">unique identifier of the database object to be scripted<m</param>
      /// <param name="so">specific scripting options for this item</param>
      /// <param name="sb">the script stream</param>
      protected void ScriptItem(Urn urn, ScriptingOptions? so, StringBuilder sb)
      {
         var smo = Server.GetSmoObject(urn);
         ScriptItem(smo, so, sb);
      }

      /// <summary>
      /// Scripts an item based on its type and name
      /// </summary>
      /// <param name="urn">unique identifier of the database object to be scripted<m</param>
      /// <param name="sb">the script stream</param>
      protected void ScriptItem(Urn urn, StringBuilder sb)
      {
         ScriptItem(urn, ScriptOptions, sb);
      }


      /// <summary>
      /// This produces a list of schema children for the set of schema provided
      /// </summary>
      /// <param name=""></param>
      /// <param name=""></param>
      /// <returns></returns>
      protected bool GetSchemaChildren( List<string> requiredSchemas, out List<Urn> walk)
      {
         walk = new List<Urn>();

         foreach(var schemaName in requiredSchemas)
            Assertion(GetSchemaChildren( schemaName, walk) == true);

         return true;
      }

      /// <summary>
      /// second best attempt
      /// </summary>
      /// <param name="schemaName"></param>
      /// <param name="walk"></param>
      /// <returns></returns>
      protected bool GetSchemaChildren( string schemaName, List<Urn> walk)
      {
         //LogS();
         string key; // type, , schemaNm, entityNm
         Schema schema = Database.Schemas[schemaName];
         Dictionary<string, Dictionary<string, Urn> > mn_map = new();

         // Since we cant get proper dependnecy order then we will script in type order
         List<string> order = new(){ "Table", "UserDefinedFunction","StoredProcedure","Data type"};
         //walk.Clear();

         Urn[] urns = schema.EnumOwnedObjects();
         Dictionary<string, Urn> map;

         foreach(Urn urn in urns)
         {
            key = GetUrnDetails(urn, out var type, out string databaseName, out var schemaNm, out var entityNm);

            if(mn_map.ContainsKey(type))
            {
               map = mn_map[type];
            }
            else
            {
               map = new Dictionary<string, Urn>();

               // in case we missed a grouping
               if(!order.Contains(type))
                  order.Add(type);

               mn_map.Add(type, map);
            }

            if (!map.ContainsKey(entityNm))
               map.Add(entityNm, urn);
         }

         // Walk the items in order: tables, datatypes, functions, procedures
         foreach(var item_type in order)
         {
            if(mn_map.ContainsKey(item_type))
            {
               var itm_coll = mn_map[item_type].Values;

               foreach(var itm in itm_coll)
                  walk.Add(itm);
            }
         }

         var ret = (walk.Count > 0);
         //LogL($"ret: {ret} count: {walk.Count}");
         return ret;
      }

      protected static string MapSmoTypeToSqlType(string smoType)
      {
         var type = smoType.ToUpper() switch
               {
                  "USERDEFINEDFUNCTION" => "FUNCTION",
                  "STOREDPROCEDURE"     => "PROCEDURE",
                  _ => smoType
               };

         return type;
      }

      protected static void ScriptSchemaStatements(List<string> schemaNames, StringBuilder sb)
      {
         foreach(var schemaName in schemaNames)
         {
            string statement = IsTestSchema(schemaName) ? 
               $"EXEC tSQLt.NewTesClass {schemaName};" :
               $"CREATE SCHEMA [{schemaName}];";

            sb.AppendLine(statement);
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
         //List<Urn> dependencies = GetSchemaDependencyWalk( new []{ schemaName }, false, out var references_tSQLt);
         return schemaName.IndexOf("test", StringComparison.OrdinalIgnoreCase)>-1 ;
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
         Utils.Precondition<ArgumentException>(P.IsExportingSchema == true, "Inconsistent state: P.IsExportingSchema not set but ExportSchemaStatement called");
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
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         return sb_.ToString();
      }

      protected static string GetUrnKey(string ty, string dbName, string schemaName, string entityName)
      {
         return $"{dbName}.{schemaName}.{entityName, -25}: {ty}";
      }

      protected static string GetUrnKey(Urn urn)
      {
         return GetUrnDetails(urn, out _, out _, out _, out string _);
      }


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
      public static string GetUrnDetails(Urn urn, out string ty, out string dbName, out string schemaName, out string entityName)
      { 
         string name;
         string type = urn.Type;
         ty          = urn.Type;
         dbName      = "";
         schemaName  = "";
         entityName  = "";
         var xpr     = urn.XPathExpression;
         var len     = xpr.Length;
         XPathExpressionBlock blok;
         List<string> schemaWantedTypes = new(){ "User Defined Function", "Table", "Stored Procedure"};
         Dictionary<string, Dictionary<string, string>> attr_map = new();

         for(int level=0; level<len; level++)
         {
            blok = xpr[level];
            name = blok.Name;
            // map of level attrs
            var map = new Dictionary<string, string>();

            foreach(var ky in (blok.FixedProperties.Keys))
            {
               string key = ky.ToString() ?? "";
               string val = blok.FixedProperties[ky].ToString().Trim(new [] {'\''});

               // level 1: Database
               if(name.Equals("Database", StringComparison.OrdinalIgnoreCase))
                  dbName = val;

               // level 1, 2: Entity with name and possibly other attributes like schema
               if(name.Equals("Schema", StringComparison.OrdinalIgnoreCase) && 
                  key .Equals("Name"  , StringComparison.OrdinalIgnoreCase))
                  schemaName = val;

               // level 2: Entity with name and possibly other attributes like schema
               if(key.Equals("Schema", StringComparison.OrdinalIgnoreCase))
                  schemaName = val;

               // 241128: preferred name is the level 2 nmae, but some objects are getting into the required list that have fewer levels
               // 
               if(level <=2 && key == "Name")
                  entityName = val;

               map[key]=val;
            }

            attr_map.Add(name, map);
         }

         // POSTCONDITION checks:
         // POST 1 returns the key as the return value and its parts as out params
         Assertion(!string.IsNullOrEmpty(ty)        , $"failed to get type   from urn: {urn}");

         // POST 2 database has been found msg: "failed to get type   from urn: {urn}");
         Assertion(!string.IsNullOrEmpty(dbName)    , $"failed to get schema from urn: {urn}");

         // POST 3 schema has been found (provided it is wanted for the type) msg: "failed to get schema from urn: {urn}");
         if((schemaName.Length == 0) && (schemaWantedTypes.Any( s => s.Equals(type, StringComparison.OrdinalIgnoreCase))))
            AssertFail($"failed to get schema from urn: {urn}");

         // POST 4 schema has been found msg: "failed to get schema from urn: {urn}");
         return GetUrnKey( ty, dbName, schemaName, entityName);
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
      protected static string [] DecodeUrnKey(string key, out string ty, out string dbName, out string schemaName, out string entityName)
      {
         //"{ty}: {dbName}.{schemaName}.{entityName}";
         //string[] items = key.Split(new[] { ':', '.', '[', ']' });
         string[] items = key.Split(new[] { ':', '.' }); //, '.', '[', ']' });
         var itmCnt = items.Length;

         if (itmCnt > 5)
            Utils.Assertion(items.Length <= 5);

         //var qrn = items[0].Trim().Split('.');
         //Utils.Assertion(qrn.Length == 3);
         dbName      = items[0].Trim();
         schemaName  = items[1].Trim();

         switch(itmCnt)
         {
            case 4:
               entityName = items[2].Trim();
               break;

            case 5:
               entityName = $"{items[2]}.{items[3]}";
               break;

            default:
               throw new Exception($"DecodeUrnKey({key}): unrecognised key type - it has {itmCnt} items - expect 2 or 3");
         }

         ty = items[items.Length - 1].Trim(); // tSQLt annotations have 5 items, ty is the last
         return items;
      }

 
      /// <summary>
      /// This will export the entire drop including children
      /// independnecy order
      /// 
      /// Pre: all initialisation done
      /// 
      /// PRE: Init called
      ///      P.IsExprtngSchema is true
      ///      
      /// POST: all objects in the schema hierarchy are scripted in dependnecy orde
      /// so items with no dependnecies are scripted first, 
      /// then those that have all dependencies scripted recursively
      /// with drop schema to be the last statement
      /// 
      /// order:
      /// StoredProcedures
      /// Tables *
      /// Views *
      /// Functions *
      /// Tables
      /// Types
      /// Schema
      /// </summary>
      public string ExportSchema(Schema schema, StringBuilder sb)
      {
         LogS($"exporting schema: {schema.Name}");
         Utils.Precondition<ArgumentException>(P.IsExportingSchema == true, "Inconsistent state P.IsExprtngSchema is not true");
         var sb_ = new StringBuilder(); 

         try
         {
            ScriptingOptions so = new(){ScriptDrops = (P.CreateMode == CreateModeEnum.Drop) };
            
            // lastly:
            ExportSchemaStatement( schema, sb);
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL($"exported schema: {schema.Name}");
         return sb_.ToString();
      }

      /// <summary>
      /// PRE: P.RequiredTypes not null
      /// 
      /// POST:RequiredTypes contains Type
      /// </summary>
      protected void EnsureRequiredTypesContainsType(SqlTypeEnum sqlType)
      {
         Utils.Precondition((P.RequiredTypes?.Count ?? 0) > 0, "Target Types are not defined");

         if(!P.RequiredTypes.Contains(sqlType))
            P.RequiredTypes.Add(sqlType);
      }

      /// <summary>
      /// Utils.PreconditionS:
      /// Pre 1: IsValid()
      /// Pre 2: Create type is not undefined
      /// 
      /// POTCONDITIONS
      /// Post 1: state for Export of create or drop schema configured
      /// 
      /// Rules all types required that are children* of a schema
      /// schema, table, view, proc, fn, fkey, tty
      /// </summary>
      private void ExportSchemaScriptInit()
      {
         //LogS();
         // Pre 1: Init() called, P DbOpType configured
         Utils.Precondition(IsValid(out var msg), $"{msg}");
         // Pre 2: Create type is not alter
         Utils.Precondition(P.CreateMode != CreateModeEnum.Error , $"create mode must be defined");

         // Process
         // Set the export schema flags
         EnsureRequiredTypesContainsType(SqlTypeEnum.Schema);

         if(P.CreateMode != CreateModeEnum.Alter)
            EnsureRequiredTypesContainsType(SqlTypeEnum.Table);

         EnsureRequiredTypesContainsType(SqlTypeEnum.View);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Procedure);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Function);
         EnsureRequiredTypesContainsType(SqlTypeEnum.UserDefinedDataType);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Assembly);

         if (P.CreateMode != CreateModeEnum.Alter)
            EnsureRequiredTypesContainsType(SqlTypeEnum.TableType);

         ScriptOptions.AllowSystemObjects       = false;
         ScriptOptions.ContinueScriptingOnError = false; // Init was false
         ScriptOptions.ChangeTracking           = false; // Init was false
         ScriptOptions.ClusteredIndexes         = true;  // Init was false
         ScriptOptions.Default                  = true;  // Init was false
         ScriptOptions.DriAll                   = true;  // Init was false
         ScriptOptions.DriAllConstraints        = true;  // Init was false
         ScriptOptions.DriAllKeys               = true;  // Init was false
         ScriptOptions.DriChecks                = true;  // Init was false
         ScriptOptions.DriClustered             = true;  // Init was false
         ScriptOptions.DriDefaults              = true;  // Init was false
         ScriptOptions.DriForeignKeys           = true;  // Init was false
         ScriptOptions.DriIndexes               = true;  // Init was false
         ScriptOptions.DriPrimaryKey            = true;  // Init was false
         ScriptOptions.DriUniqueKeys            = true;  // Init was false
         ScriptOptions.IncludeHeaders           = false; // Init was false
         ScriptOptions.Indexes                  = true;  // Init was true
         ScriptOptions.NoCommandTerminator      = false; // Init was false
         ScriptOptions.PrimaryObject            = true;  // Init was true
         ScriptOptions.NoAssemblies             = false;

         // Wrap up
         //LogL();
      }

      /// <summary>
      /// Script 1 table
      /// </summary>
      /// <param name="tableName"></param>
      /// <param name="options"></param>
      /// <param name="sb"></param>
      string ScriptTable( string tableName, ScriptingOptions options, StringBuilder sb )
      {
         //LogS();
         StringBuilder sb_ = new();

         try
         { 
            // Get the insert lines for the table
            var transactions = Database.Tables[tableName].EnumScript(options);
            var enumerable = transactions as string[] ?? transactions.ToList().ToArray();

            if(!enumerable.Any())
               return "";

            // Each transction appears to be a single insert
            foreach(var transaction in enumerable)
               sb_.Append(transaction + "\r\n");

            // Only to the StringBuilder not the file - that is done later - ScriptGo(sb);
            ScriptLine(GO, sb_); //sb.AppendLine(GO);
         }
         catch(Exception e)
         {
            var msgs = e.GetAllMessages();
            Log(msgs);
            throw;
         }

         sb.Append(sb_);
         //LogL();
         return sb.ToString();
      }

      /// <summary>
      /// Add GO statements to for the SQL execution at that point
      /// </summary>
      /// <param name="sb"></param>
      private void ScriptGo( StringBuilder sb, bool blankLineAfter=false )
      {
         var line = GO;

         if(blankLineAfter)
            if (!line.EndsWith("\r\n"))
               line += ("\r\n");

         line += "\r\n";

         ScriptLine(line, sb);
      }

      /// <summary>
      /// Main entry point
      /// Just does the Create or Drop database SQL line
      /// 
      /// PRE: Init called
      ///   database must be instantiated
      ///   
      /// POST:
      /// script returned 
      /// 
      /// </summary>
      /// <returns></returns>
      public bool ExportDatabase(StringBuilder sb, out string script, out string msg)
      {
         LogS();
         bool ret = false;

         do
         {
            if(Database == null)
            {
               msg = "database must be instantiated";
               script = "";
               break;
            }
         
            if(!ExportDatabase( Database, sb, out script, out msg))
               break;

            ret = true;
            msg = "";
         } while(false);

         LogL($"ret: {ret}");
         return ret;
      }

      /// <summary>
      /// Just does the Create or Drop database SQL line
      /// 
      /// PRE: Init called
      ///   database must be instantiated
      ///   
      /// POST:
      /// script returned 
      /// 
      /// </summary>
      /// <param name="db"></param>
      /// <param name="sb"></param>
      /// <returns></returns>
      public bool ExportDatabase( Database? db, StringBuilder sb, out string script, out string msg)
      {
         //LogS();
         bool ret = false;
         msg = "";

         try
         {
            do
            {
               if(!IsInitialised)
               {
                  msg = "scripter must be initialised before use";
                  break;
               }

               var transactions  = db.Script(ScriptOptions);
               ScriptTransactions(transactions, sb, db.Urn, wantGo: true);
            } while(false);

            script = sb.ToString();
            ret = true;
         }
         catch(Exception e)
         {
            msg = e.Message;
            script = "";
            LogException(e);
         }

         //LogL($"ret={ret}");
         return ret;
      }

      /// <summary>
      /// Main entry point to create the "Export Static Data Script"
      /// 
      /// </summary>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath"></param>
      protected bool ScriptDataExport( out string msg)
      {
         LogS();
         msg = "";

         try
         {
            Init(P, out msg);
            throw new NotImplementedException("ScriptDataExport()");
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         //LogL();
         //return ret;
      }

      /// <summary>
      /// Main entry point for Exporting Views
      /// PRE: none
      /// Scripts Create and Drop
      /// </summary>
      public bool ExportViews( Params p, out string script, out string msg)
      {
         //LogS();
         StringBuilder sb = new();
         bool ret = false;

         try
         {
            do
            {
               Init(p, out msg);
         
               foreach(var schemaName in P.RequiredSchemas)
                  ExportViews( schemaName, sb );

               script = sb.ToString();
               ret = true;
            } while(false);
         }
         catch(Exception e)
         {
            script = "";
            LogException(e);
            msg = e.Message;
         }

         //LogL($"ret:{ret}");
         return ret;
      }

      /// <summary>
      /// PRE: Init called
      /// Scripts Create and Drop
      /// </summary>
      public string ExportViews( string currentSchemaName, StringBuilder sb )
      {
         //LogS();
         // Local script
         StringBuilder sb_ = new();

         try
         { 
            // Iterate through the tables in database and script each one. Display the script.
            foreach(View view in Database.Views)
            {
               // Check if the table is not a system table
               if(IsWanted( currentSchemaName, view))
                  ExportView(view, sb_);
            }

            // Want blank line at end of all drops
            CloseScript(sb_);
            // Append script string to the main script
            sb.Append(sb_);
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }

         //LogL();
         return sb_.ToString();
      }

 
      /// <summary>
      /// DESC: exports 1 view
      /// PRE: assumes initialised pop P
      /// </summary>
      /// <param name="view"></param>
      /// <param name="sb"></param>
      /// <returns></returns>
      protected string? ExportView(View view, StringBuilder sb)
      { 
         //LogS();
         StringBuilder sb_ = new();

         try
         { 
            //ScriptOption so = ;
            var scriptOptions = new ScriptingOptions(){ ScriptDrops = ScriptOptions.ScriptDrops };//ScriptDrops = true};- works, ScriptForAlter=true does not work
            // Generate script for table, want blan lines between each transaction
            // Don't want blank line for drops
            var script = view.Script(scriptOptions);//ScriptOptions);
            ScriptTransactions(script, sb_, view.Name, wantGo: true);
            ExportedViews.Add(view.Name, view.Name);
            sb.Append(sb_);
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }

         //LogL();
         return sb_.ToString();
     }


      /// <summary>
      /// Main entry point for exporting tables
      /// Exports all required tables for each required schema
      /// PRE:
      ///   Initialised
      /// 
      /// POST:
      ///    init called
      ///    
      /// </summary>
      /// <param name="sb"></param>
      public bool ExportTables(StringBuilder sb, out string script, out string msg)
      {
         LogS();
         bool ret = false;
         script   = "";
         StringBuilder sb_ = new();

         try
         {
            do
            {
               if(!IsValid(out msg))
                  break;

               if(!InitTableExport(out ScriptingOptions? so, out msg))
                  break;

               foreach(var schemaName in P.RequiredSchemas)
                  ExportTables( Database.Schemas[schemaName], so, sb_ );

               script = sb_.ToString();
               sb.Append(sb_);
               ret = true;
            } while(false);
         }
         catch(Exception e)
         {
            msg = e.ToString();
            LogException(e);
            throw;
         }

         LogL($"ret: {ret}");
         return ret;
      }
      public bool ExportAssemblies(StringBuilder sb, out string script, out string msg)
      {
         LogS();
         bool ret = false;
         string s;
         script = "";
         StringBuilder sb_ = new();

         try
         {
            do
            {
               if (!IsValid(out msg))
                  break;

               /*
               if (!InitTableExport(out ScriptingOptions? so, out msg))
                  break;

               foreach (var schemaName in P.RequiredSchemas)
                  ExportTables(Database.Schemas[schemaName], so, sb_);
               */
               //foreach (var schemaName in P.RequiredSchemas)
               foreach (var assembly in Database.Assemblies)
               {
                  s = assembly.ToString()?? "";
                  sb_.AppendLine(s);
               }

               script = sb_.ToString();
               sb.Append(sb_);
               ret = true;
            } while (false);
         }
         catch (Exception e)
         {
            msg = e.ToString();
            LogException(e);
            throw;
         }

         LogL($"ret: {ret}");
         return ret;
      }


      /// <summary>
      /// Call this before exporting any tables to get the correct 
      /// ScriptOptions config.
      /// It takes the current ScriptOptions config mamkes acopy
      /// and modifies the copy to be ok to export tables
      /// PRE:
      ///  PRE 1: Scriptor Initialised
      ///  
      /// POST:
      ///  POST 1: returned config so will support table export 
      ///          and its script for alter flags are cleared
      ///  POST 2: the original config is not changed
      /// </summary>
      /// <returns>so </returns>
      protected bool InitTableExport(out ScriptingOptions? so, out string msg)
      {
         //LogS();
         bool ret = false;
         so = null;

         do
         {
            // Validate PRE 1: Scriptor Initialised
            if(!IsValid(out msg))
            {
               msg ="Scriptor must be initised first" + msg;
               break;
            }

            // -----------------------------------------
            // ASSERTION: Utils.Preconditions validated
            // -----------------------------------------

            if(ScriptOptions == null)
            {
               msg ="Error: null ScriptOptions ??";
               break;
            }

            so = ShallowClone(ScriptOptions);
            var orig = ShallowClone(ScriptOptions);
            so.ScriptForAlter          = false;
            //so.ScriptForCreateOrAlter  = false;

            // -------------------------
            // Validate postconditions
            // -------------------------
            // POST 1: returned config so will support table export 
            //          and its script for alter flags are cleared
            // Utils.Postcondition(!(so.ScriptForAlter || so.ScriptForCreateOrAlter), "POST 1 failed");

            //  POST 2: the original config is not changed
            if(!OptionEquals(ScriptOptions, orig, out msg))
            {
               Log("was\r\n",     OptionsToString(orig));
               Log("\r\nnow\r\n", OptionsToString(ScriptOptions));
               var resultsDir = @"D:\Tests";
               var exp_file   = @$"{resultsDir}\InitTableExport_exp.txt";
               var act_file   = @$"{resultsDir}\InitTableExport_act.txt";
               File.WriteAllText(exp_file, OptionsToString(orig));  
               File.WriteAllText(act_file, $"{OptionsToString(ScriptOptions)}\r\nfirst diff field : {msg}");
               // display a BeyondCompare session for exp/act with unique file names
               //Process.Start( "BCompare.exe", $"{act_file} {exp_file}");

               // Fail the op
               msg ="Internal Error: ScriptOptions miss match";
               break;
            }

            msg = "";
            ret = true;
         } while(false);

         // -----------------------------------------
         // ASSERTION: postconditions validated
         // -----------------------------------------
         //LogL($"ret: {ret}");
         return ret;
      }

      /// <summary>
      /// PRE:
      ///   init called
      ///   so set up foir table export 
      ///   esp ScriptForAlter. ScriptForCreateOrAlter: false, 
      /// POST:
      /// 
      /// </summary>
      /// <param name="sb"></param>
      public void ExportTables( Schema? schema, ScriptingOptions? so, StringBuilder sb )
      {
         //LogS(schema.Name);

         try
         {
            // Set the state: don't do keys and checks if create
            ScriptOptions.AllowSystemObjects       = false;
            ScriptOptions.DriAll                   = true;
            ScriptOptions.DriAllConstraints        = true;
            ScriptOptions.DriForeignKeys           = true;
            ScriptOptions.DriAllKeys               = true;
            ScriptOptions.DriIndexes               = true;
            ScriptOptions.DriChecks                = false;
            ScriptOptions.WithDependencies         = false;
            ScriptOptions.ScriptForAlter           = false;
            ScriptOptions.ScriptSchema             = true;

            if(ScriptOptions.ScriptDrops)
               ExportForeignKeys(schema.Name, sb);

            var firstTime = true;
            Table[] allTables = new Table[Database.Tables.Count];

            // Iterate through the tables in database and script each one. Display the script.
            Database.Tables.CopyTo(allTables, 0);

            // Filter the tables by the wanted schema;
            var schemaTables = allTables.ToList().Where(t=>t.Schema.Equals(schema.Name));

            foreach(Table table in schemaTables)
            {
               // Check if the table is not a system table
               if(IsWanted(schema.Name, table))
               { 
                  ExportTable(table, so, sb);

                  if(firstTime)
                  {
                     firstTime = false;
                     Scripter.Options.IncludeDatabaseContext = false;
                     ScriptOptions.IncludeDatabaseContext = false;
                  }
               }
            }

            // Want blank line at end of all drops
            CloseScript(sb);
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }

         //LogL();
      }

      /// <summary>
      /// Main entry point to export 1 table to the supplied StringBuilder
      /// PRE: table exists
      /// </summary>
      /// <param name="tableName"></param>
      /// <param name="sb"></param>
      public bool ExportTable( string? tableName, Params p, StringBuilder sb, out string msg)
      {
         //LogS();
         bool ret = false;

         try
         {
            do
            { 
               if(!Init(p, out msg))
                  break;

               //ScriptingOptions so = Utils.ShallowClone(ScriptOptions) ?? new ();

               var table = Database.Tables[tableName];
               Utils.Assertion(table != null, $"Attempting to Export non existent table: [{tableName}]");
               ExportTable(table, ScriptOptions, sb);
            } while(false);
         }
         catch(Exception e)
         { 
            LogException(e);
            msg = e.Message;
         }

         //LogL($"ret: {ret}");
         return ret;
      }


      /// <summary>
      /// Scripts a single table
      /// 
      /// Utils.PreconditionS: 
      /// PRE 1: table exists
      /// PRE 2: this.IsValid() == true
      /// PRE 3: so initalised correctly
      /// </summary>
      /// <param name="table"></param>
      /// <param name="sb"></param>
      public void ExportTable( Table? table, ScriptingOptions? so, StringBuilder sb )
      {
         //LogS();
         // PRE 1: table exists
         Utils.Precondition(table != null);
         // PRE 2: this.IsValid() == true
         Utils.Precondition(IsValid(out string? msg), msg);
         StringCollection transactions;

         try
         { 
            transactions = table.Script(so);

            if(transactions.Count>0)
               ScriptTransactions(transactions, sb, table.Urn, wantGo: true);
            else
               ScriptLine($"{table.Name} has no transactions", sb);
         }
         catch(Exception e)
         {
            var msgs = e.GetAllMessages();
            Log(msgs);
            ScriptLine($"{table.Name} error: {msgs}", sb);
            throw;
         }

         //LogL();
      }

      /// <summary>
      /// Exports the foreign keys
      /// </summary>
      protected void ExportForeignKeys( string currentSchemaName, StringBuilder sb )
      {
         //LogS();

         foreach(Table table in Database.Tables)
            ExportForeignKeys( currentSchemaName, table, sb);

         //LogL();
      }

      /// <summary>
      /// Exports the FKs for a given table provided it is not a system object
      /// </summary>
      /// <param name="table"></param>
      /// <param name="sb">string builder to populate the serialisation all the table's ForeignKeys as a set of SQL statements</param>
      protected void ExportForeignKeys( string currentSchemaName, Table table, StringBuilder sb )
      {
         //LogS();

         try
         { 
            // Foreign keys
            foreach(ForeignKey fkey in table.ForeignKeys)
               if(IsWanted( currentSchemaName, fkey))
                  ScriptTransactions(fkey.Script(ScriptOptions), sb, fkey.Name, wantGo: true);
         }
         catch(Exception e)
         {
            var msgs = e.GetAllMessages();
            Log(msgs);
            throw;
         }

         //LogL();
      }

      /// <summary>
      /// exports all procedures from all required schemas
      /// Utils.Precondition: 
      /// Is valid
      /// 
      /// POSTCONDITIONS:
      ///  POST 1: all procedures from all required schemas exported
      /// 
      /// CALLED BY: Export()
      /// </summary>
      protected bool ExportProcedures(StringBuilder sb, out string script, out string msg)
      { 
         //LogS();
         bool ret = false;
         script = "";

         do
         {
            if(!IsValid(out msg))
               break;// PRE: Init called

            foreach(string schemaName in P.RequiredSchemas)
               ExportProcedures(schemaName, sb);

            script = sb.ToString();
            ret = true;
         } while(false);

         //LogL($"ret: {ret}");
         return ret;
      }


      /// <summary>
      /// exports all functions from all required schemas
      /// Utils.Precondition: 
      /// Is valid
      /// 
      /// POSTCONDITIONS:
      ///  POST 1: all functions from all required schemas exported
      /// 
      /// CALLED BY: Export()
      /// </summary>
      protected bool ExportFunctions(StringBuilder sb, out string script, out string msg)
      {
         //LogS();
         bool ret = false;
         script = "";

         do
         {
            if(!IsValid(out msg))// PRE: Init called
             break;

            foreach(string schemaName in P.RequiredSchemas)
               ExportFunctions(schemaName, sb);

            script = sb.ToString();
            ret = true;
         } while(false);

         //LogL($"ret: {ret}");
         return ret;
      }


      /// <summary>
      /// PRE: Init called
      /// Database database, Scripter scriptor, StreamWriter writer
      /// Utils.Precondition: 
      /// UserDefinedFunctions pop, Options, Create mode set
      /// </summary>
      /// <param name="sb">string builder to populate the serialisation all the user defined functions as a set of SQL statements</param>
      protected void ExportFunctions( string? currentSchemaName, StringBuilder sb)
      {
         //LogS();

         try
         { 
            Utils.Precondition(IsValid(out string? msg), $"{msg}");

            // Save state
            //P.RootType = SqlTypeEnum.Function;
            var oldWithDependencies  = ScriptOptions.WithDependencies;
            ScriptOptions.WithDependencies = false;  // We want in dependency order
            int i=0;


            foreach(UserDefinedFunction function in Database.UserDefinedFunctions)
            { 
               Log($"{function.Schema}.{function.Name} : Considering [{i}]");

               if(IsWanted(currentSchemaName, function))
               {
                  Log($"{function.Schema}.{function.Name} : is  wanted");
                  ExportFunction(function, sb);
               }
               else
               {
                  Log($"{function.Schema}.{function.Name} : NOT wanted");
               }

               i++;
            }

            //If drops then add a blank line at the end
            CloseScript(sb);

            // Reset state
            ScriptOptions.WithDependencies = oldWithDependencies;
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }

         //LogL();
      }

      protected void ExportFunction( UserDefinedFunction function, StringBuilder sb )
      {
         //LogS();

         try
         {
            //ScriptTransactions(function.Script(ScriptOptions), sb, GetUrnKey(function.Urn), wantGo: true);
            ScriptTransactions(function.Script(ScriptOptions), sb, function.Urn, wantGo: true);
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }

      //LogL();
     }

      /// <summary>
      /// Main entry point for exporting procedures
      /// </summary>
      /// <param name="sb"></param>
      /// <param name="required_schemas"></param>
      protected bool ExportProcedures( Params p, out string script, out string msg)
      {
         //LogS();
         bool ret = false;
         script   = "";

         try
         {
            do
            {
               if(!Init( p, out msg))
                  break;

               StringBuilder sb = new();

               foreach(var schemaName in P.RequiredSchemas)
                  ExportProcedures( schemaName, sb);

               script = sb.ToString();
               ret = true;
            } while(false);
         }
         catch(Exception e)
         {
            LogException(e);
            msg = e.Message;
         }

         return ret;
     }

      /// <summary>
      /// This exports all the procedures - it is much quicker than using the Scripter as that returns all the system stored procedures as well 
      /// - then we have to take ages to filter out the user stored procedures.
      /// 
      /// At least I have not found a way to stop it doing so yet
      /// Database database, Scripter, StreamWriter writer
      /// 
      /// PRE: Init called, P pop
      ///
      /// POST:
      /// 
      /// Called by: ExportProcedures( Params p)
      /// </summary>
      /// <param name="sb">string builder to populate the serialisation as a set of SQL statements</param>
      protected string ExportProcedures( string? currentSchemaName, StringBuilder sb)
      {
         //LogS();
         StringBuilder sb_ = new();

         try
         { 
            Utils.Assertion<ConfigurationException>(Database != null, "ExportProcedures(): Null database");
            Utils.Assertion(ScriptOptions != null, "ExportProcedures() PRECONDION: Options != null");

            // Save state
            //P.RootType = SqlTypeEnum.Procedure;
            var oldWithDependencies  = ScriptOptions.WithDependencies;
            ScriptOptions.WithDependencies = false;  // We want in dependency order ?? 2019: dep order fails

            foreach(StoredProcedure proc in Database.StoredProcedures)
               if(IsWanted( currentSchemaName, proc))
                  ExportProcedure(proc, sb_);

            CloseScript(sb_);
            sb.Append(sb_);

            // Reset state
            ScriptOptions.WithDependencies = oldWithDependencies;
         }
         catch(Exception e)
         {
            LogException(e);
            var msgs = e.GetAllMessages();
            Log(msgs);
            throw;
         }

         //LogL();
         return sb_.ToString();
      }

      protected void ExportProcedure( StoredProcedure proc, StringBuilder sb )
      {
         //LogS();
         try
         { 
            ScriptTransactions(proc.Script(ScriptOptions), sb, proc.Urn, wantGo: true);
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }

         //LogL();
      }

      
      /// <summary>
      /// PRE: 
      /// </summary>
      /// <returns>Serialisation of all the user defined types as a set of SQL statements</returns>
      protected string ExportTableTypes( string currentSchemaName, StringBuilder sb )
      {
         //LogS();
         StringBuilder sb_ = new();

         try
         { 
             foreach(UserDefinedTableType tbl_ty in Database.UserDefinedTableTypes)
               if(IsWanted( currentSchemaName, tbl_ty))
                  ExportTableType(tbl_ty, sb_);

             CloseScript(sb_);
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }

         sb.Append(sb_);
         //LogL();
         return sb_.ToString();
      }

      protected void ExportTableType( UserDefinedTableType tbl_ty, StringBuilder sb )
      {
         //LogS();

         try
         { 
            ScriptTransactions(tbl_ty.Script(ScriptOptions), sb, tbl_ty.Name, wantGo: true);
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }

         //LogL();
      }

      /// <summary>
      /// Scripts the line USE database
      ///                  GO
      /// 
      /// Relies on Database being set
      /// </summary>
      protected void ScriptUseDatabaseStatement( StringBuilder sb )
      {
         //LogS();

         if(ScriptOptions.IncludeDatabaseContext)
            ScriptUse(sb, true);

         //LogL();
      }

      protected void ScriptUse( StringBuilder sb, bool onlyOnce = false )
      {
         //LogS();
         ScriptLine($"USE [{Database.Name}]", sb);
         //ScriptGo(sb); // new way of scripting adds gos at the start of the next of the next statement
         // so we are getting 2 gos

         if(onlyOnce)
            ScriptOptions.IncludeDatabaseContext = false;

         //LogL();
     }

      private SchemaCollectionBase? GetSchemaCollectionForType( Type type )
      {
         //LogS();

         SchemaCollectionBase collection = type.Name switch
         {
            // 
            "UserDefinedTableType" => Database.UserDefinedTableTypes,
            // StoredProcedure
            "StoredProcedure" => Database.StoredProcedures,
            // Tables
            "Table" => Database.Tables,
            // Functions
            "UserDefinedFunction" => Database.UserDefinedFunctions,
            // Functions
            "View" => Database.Views,
            _ => throw new NotImplementedException(),
         };

         Assertion(collection != null);
         //LogL();
         return collection;
      }

      /// <summary>
      /// Cannot directly get the dependencies for schemas, so we need to get deps for child objects
      /// Tables, procedures, functions views
      /// Remove any duplicate dependencies.
      /// 
      /// DependencyTree.DiscoverDependencies() can fail in MS code if there is more than 1 reference to a an unresolved item like a missing stored procedure
      /// as was the case in ut / when commonly used sp name was changed and not all references were updated
      /// {"Item has already been added. Key in dictionary:
      /// 'Server[@Name='DevI9\\SQLEXPRESS']/Database[@Name='ut']
      /// UnresolvedEntity[@Name='sp_tst_hlpr_chk' and @Schema='test']'
      /// Key being added: 'Server[@Name='DevI9\\SQLEXPRESS']/Database[@Name='ut']/UnresolvedEntity[@Name='sp_tst_hlpr_chk' and @Schema='test']'"}
      /// 1 public DependencyTree DiscoverDependencies( Urn[] urns, DependencyType dependencyType );
      ///
      /// in which case this rtn will return false and we do it without using MS dependencies
      /// </summary>
      /// <param name="schemas"></param>
      /// <param name="mostDependentFirst"></param>
      /// <returns>true if succeeded, false if no items</returns>
      public bool GetSchemaDependencyWalk( IEnumerable<string> schemaNames, bool mostDependentFirst, out List<Urn> walk, out string msg)
      {
         LogS();
         //var sb = new StringBuilder("\r\n\r\nItems to be scripted:\r\n");
         bool ret = false;
         //Dictionary<string, Urn> map = new();
         walk = new List<Urn>();
         msg = "";

         do 
         { 
            // Pass 1:
            // Get list of Schema items filter for is system object, wanted type, duplicates etc.
            Urn[] schemaWantedChildItems = GetWantedChildren(schemaNames);

            if(schemaWantedChildItems.Length == 0)
            {
               msg = $"{Database.Name} has no items to script for the required schemas";
               LogC(msg);
               break;
            }

            // Userdefined DataTypes and Table types will throw here has they are not held by the server but by the database
            // so we need to filter them out for the dependency walk
            var serverItems = schemaWantedChildItems.Where(c => c.Type != "UserDefinedDataType").ToArray();
            var databaseItems = schemaWantedChildItems.Where(c => c.Type == "UserDefinedDataType").ToArray();

            List<Urn> candidates = GetSchemaDependencyWalk2(serverItems, mostDependentFirst);
            ConsisderedEntities.Clear();
            WantedItems.Clear();

            // Pass 2:
            // First add the udts as they have no dependencies ... 
            walk.AddRange(databaseItems);

            // Filter candidates again for any outside of the wanted schema or database
            foreach( Urn candidate in candidates)
               if(ConsiderCandidate(candidate, filterUnwantedTypes: true, schemaNames))//, map))
                  walk.Add(candidate);

            LogDirect($"Dependency walk contains {walk.Count} items to script", LogLevel.Info);
            ret = true;
         } while (false);

         //LogL($"Final walk of schema items: count: {walk.Count}, ret: {ret}");
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
      protected bool ConsiderCandidate( Urn childUrn, bool filterUnwantedTypes/*, StringBuilder sb*/, IEnumerable<string> schemaNames)//, Dictionary<string, Urn> map)
      {
         //bool ret    = true;
         bool isWanted = false;
         string key  = GetUrnDetails( childUrn, out string ty, out var dbName, out string schemaName, out string name);
         var sqlType = MapSmoTypeToSqlType(ty);
         RegisterAction(key, SelectionRuleEnum.Considering);
         int i = ConsisderedEntities.Count;

         LogSD($"Considering [{i}]: {key} fuwtypes: {filterUnwantedTypes}");

         if(childUrn.Type =="Table")
         {
            LogI("ConsiderCandidate: ty: table");
         }

         try
         { 
            do
            {
               if(!ConsisderedEntities.ContainsKey(key))
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

               if(ty == "UnresolvedEntity")
               {
                  RegisterAction(key, SelectionRuleEnum.UnresolvedEntity);
                  isWanted = false;
                  break;
               }

               if(!Database.Name.Equals(dbName, StringComparison.OrdinalIgnoreCase))
               {
                  RegisterAction(key, SelectionRuleEnum.DifferentDatabase);
                  isWanted = false;
                  break;
               }

               // if filtering unwanted types
               // and "UserDefinedDataType for now because currently Server.GetSmoObject throws an exception getting this object type
               // MissingObjectException: The UserDefinedDataType '[tSQLt].[AssertStringTable]' does not exist on the server.
               if (filterUnwantedTypes == true )
               {
                  if (!IsTypeWanted(ty))
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

               if (ty == "UserDefinedDataType")
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
                  childSmo = Server.GetSmoObject(childUrn);
               }

               if(childSmo?.Properties.Contains("IsSystemObject") ?? false)
               { 
                  var property = childSmo.Properties["IsSystemObject"];

                  if(((bool)property.Value) == true)
                  { 
                     // Unwanted system object
                     RegisterAction(key, SelectionRuleEnum.SystemObject);
                     isWanted = false;
                     break;
                  }
               }

               // Only add if the item is in a required schema
               if(!schemaNames.Contains(schemaName))
               {
                  //  Unwanted Schema
                  RegisterAction(key, SelectionRuleEnum.UnwantedSchema);
                  isWanted = false;
                  break;
               }

               // ASSERTION: if here then item is wanted
               isWanted = true;
            } while(false);
/*
            if (isWanted == true)
            {
               if ((!map.ContainsKey(key)))
               {
                  map.Add(key, childUrn);
                  ty = ty.PadRight(20);
                  Assertion(!string.IsNullOrEmpty(schemaName));
                  sb.AppendLine($"{ty}: {schemaName}.{name}");

                  // OK we want this one
                  RegisterAction(key, SelectionRuleEnum.Wanted);
                  ret = true;
               }
               else
               {
                  // Log and store the entity and the exclusion rule: Duplicate Dependency
                  RegisterAction(key, SelectionRuleEnum.DuplicateDependency);
               }
            }
*/
         }
         catch (Exception e)
         {
            LogException(e, $"item:  [{i}]: {GetUrnKey(childUrn)}");
            BadBin.Add(key, e.Message);
         }

         LogLD($"isWanted: {isWanted}");
         return isWanted;
      }

      protected List<Urn> GetSchemaDependencyWalk2( Urn[] child_ary, bool mostDependentFirst)
      {
         LogS();
         List<Urn> walk = new();
         var dw         = new DependencyWalker(Server);
         DependencyTree depTree;
         DependencyType depTy = mostDependentFirst ? DependencyType.Parents : DependencyType.Children;

         try
         {
            depTree = dw.DiscoverDependencies(child_ary, depTy);
            var walk1 = dw.WalkDependencies(depTree);

            foreach(var item in walk1)
               walk.Add(item.Urn);
         }
         catch(Exception e)
         {
            // MS code can do raise exception if dangling references to non existent procedures exist in db routines
            LogException(e, $"GetSchemaDependencyWalk");
            LogC($@"GetSchemaDependencyWalk failed:
MS code can do raise exception if dangling references to non existent procedures exist in db routines
Trying to script schema dependnecies in order tables, functions procedures
Script may need manual rearranging to get dependency order correct.
{e}");
            Assertion(GetSchemaChildren( P.RequiredSchemas ?? new List<string>(), out walk), "GetSchemaChildren failed");
         }

         // ASSERTION walk populated
         LogL($"walk contains: {walk.Count} items");
         return walk;
      }

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
      protected Urn[] GetWantedChildren(IEnumerable<string> schemaNames)
      {
         //StringBuilder sb = new();
         Dictionary<string, Urn> wantedChildren= new();
         string key; // , databaseName, schemaNm, entityNm
         int cnsidrd_cnt   = 0;
         int i             = 0;
         int duplicateCount= DuplicateDependencies.Count;
         var smoSchemas    = new SqlSmoObject[schemaNames.Count()];
         //Dictionary<string, Urn> map = new();
         List<string> wantedTypes = new () { "View", "UserDefinedFunction", "StoredProcedure", "DataType", "UserDefinedDataType" };

         // Add table type if not alter mode
         if(P.CreateMode != CreateModeEnum.Alter)
            wantedTypes.Add("Table");

         //LogDirect($"Stage 1: Get the objects owned by the schemas");

         var schemaAry = new Schema[Database.Schemas.Count];
         Database.Schemas.CopyTo(schemaAry, 0);
         

         // Iterate each required schema
         foreach( var schemaName_ in schemaNames)
         {
            var schema = schemaAry.FirstOrDefault(x=>x.Name.Equals(schemaName_, StringComparison.OrdinalIgnoreCase));//[schemaName_];
            smoSchemas[i++] = schema ?? new();
            //LogDirect($"Stage 1: [{i}] - get the objects owned by the schema: {schemaName_}");

            Urn[] ownedObjects = schema.EnumOwnedObjects();
            var cnt = ownedObjects.Count();
            LogDirect($"Stage 1: [{i}] - get the objects owned by the schema: {schemaName_}, count: {cnt}");

            // Iterate each item in the schema
            foreach (Urn childUrn in ownedObjects)
            {
               cnsidrd_cnt++;
               string entityNm;

               //key = GetUrnDetails(childUrn);//, out var ty, out var databaseName, out var schemaNm, out entityNm);
               key = GetUrnDetails(childUrn, out var ty, out var databaseName, out var schemaNm, out entityNm);

               // Conside the candidate: if the child item qualifies add it to the list
               if ( ConsiderCandidate( childUrn, filterUnwantedTypes: false, schemaNames))//, map))
               {
                  var id = $"{schemaNm}.{entityNm}";

                  if (!wantedChildren.Keys.Contains(id))
                     wantedChildren.Add(id, childUrn);
                  else
                  {
                     duplicateCount++;
                     Console.WriteLine($"Error duplicate item [{duplicateCount}]: {id}");
                     DuplicateDependencies.Add(id, id);
                  }
               }
            }
         }

         // Checks
         Assertion(RunChecks(wantedChildren, out var msg), msg);
         //duplicateCount = DuplicateDependencies.Count - duplicateCount;
         return wantedChildren.Values.ToArray(); //map.Values.ToArray();
      }

      protected static bool RunChecks(Dictionary<string, Urn> map , out string msg)
      {
         bool ret = false;

         do
         {
            // Checks
            bool chk = map.Any(x=>x.Key.ToString().IndexOf("Unresolved", StringComparison.OrdinalIgnoreCase) > -1);

            if(chk)
            {
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
         } while(false);

         return ret;
      }

      /// <summary>
      /// Used to check parameters
      /// </summary>
      /// <param name="o"></param>
      /// <returns></returns>
      public static string OptionsToString( ScriptingOptions? o )
      {
         var sb = new StringBuilder();
         sb.AppendLine($"AgentAlertJob                         {o.AgentAlertJob                        }");
         sb.AppendLine($"AgentJobId                            {o.AgentJobId                           }");
         sb.AppendLine($"AgentNotify                           {o.AgentNotify                          }");
         sb.AppendLine($"AllowSystemObjects                    {o.AllowSystemObjects                   }");
         sb.AppendLine($"AnsiFile                              {o.AnsiFile                             }");
         sb.AppendLine($"AnsiPadding                           {o.AnsiPadding                          }");
         sb.AppendLine($"AppendToFile                          {o.AppendToFile                         }");
         sb.AppendLine($"ChangeTracking                        {o.ChangeTracking                       }");
         sb.AppendLine($"BatchSize                             {o.BatchSize                            }");
         sb.AppendLine($"Bindings                              {o.Bindings                             }");
         sb.AppendLine($"ClusteredIndexes                      {o.ClusteredIndexes                     }");
         sb.AppendLine($"ColumnStoreIndexes                    {o.ColumnStoreIndexes                   }");
         sb.AppendLine($"ContinueScriptingOnError              {o.ContinueScriptingOnError             }");
         sb.AppendLine($"ConvertUserDefinedDataTypesToBaseType {o.ConvertUserDefinedDataTypesToBaseType}");
         sb.AppendLine($"DdlBodyOnly                           {o.DdlBodyOnly                          }");
         sb.AppendLine($"DdlHeaderOnly                         {o.DdlHeaderOnly                        }");
         sb.AppendLine($"Default                               {o.Default                              }");
         sb.AppendLine($"DriAll                                {o.DriAll                               }");
         sb.AppendLine($"DriAllConstraints                     {o.DriAllConstraints                    }");
         sb.AppendLine($"DriAllKeys                            {o.DriAllKeys                           }");
         sb.AppendLine($"DriChecks                             {o.DriChecks                            }");
         sb.AppendLine($"DriClustered                          {o.DriClustered                         }");
         sb.AppendLine($"DriDefaults                           {o.DriDefaults                          }");
         sb.AppendLine($"DriForeignKeys                        {o.DriForeignKeys                       }");
         sb.AppendLine($"DriIncludeSystemNames                 {o.DriIncludeSystemNames                }");
         sb.AppendLine($"DriIndexes                            {o.DriIndexes                           }");
         sb.AppendLine($"DriNonClustered                       {o.DriNonClustered                      }");
         sb.AppendLine($"DriPrimaryKey                         {o.DriPrimaryKey                        }");
         sb.AppendLine($"DriUniqueKeys                         {o.DriUniqueKeys                        }");
         sb.AppendLine($"DriWithNoCheck                        {o.DriWithNoCheck                       }");
         sb.AppendLine($"Encoding                              {o.Encoding                             }");
         sb.AppendLine($"EnforceScriptingOptions               {o.EnforceScriptingOptions              }");
         sb.AppendLine($"ExtendedProperties                    {o.ExtendedProperties                   }");
         sb.AppendLine($"FileName                              {o.FileName                             }");
         sb.AppendLine($"FullTextCatalogs                      {o.FullTextCatalogs                     }");
         sb.AppendLine($"FullTextIndexes                       {o.FullTextIndexes                      }");
         sb.AppendLine($"FullTextStopLists                     {o.FullTextStopLists                    }");
         sb.AppendLine($"IncludeDatabaseContext                {o.IncludeDatabaseContext               }");
         sb.AppendLine($"IncludeDatabaseContext                {o.IncludeDatabaseContext               }");
         sb.AppendLine($"IncludeDatabaseRoleMemberships        {o.IncludeDatabaseRoleMemberships       }");
         sb.AppendLine($"IncludeFullTextCatalogRootPath        {o.IncludeFullTextCatalogRootPath       }");
         sb.AppendLine($"IncludeHeaders                        {o.IncludeHeaders                       }");
         sb.AppendLine($"IncludeIfNotExists                    {o.IncludeIfNotExists                   }");
         sb.AppendLine($"IncludeScriptingParametersHeader      {o.IncludeScriptingParametersHeader     }");
         sb.AppendLine($"Indexes                               {o.Indexes                              }");
         sb.AppendLine($"LoginSid                              {o.LoginSid                             }");
         sb.AppendLine($"NoAssemblies                          {o.NoAssemblies                         }");
         sb.AppendLine($"NoCollation                           {o.NoCollation                          }");
         sb.AppendLine($"NoCommandTerminator                   {o.NoCommandTerminator                  }");
         sb.AppendLine($"NoExecuteAs                           {o.NoExecuteAs                          }");
         sb.AppendLine($"NoFileGroup                           {o.NoFileGroup                          }");
         sb.AppendLine($"NoFileStream                          {o.NoFileStream                         }");
         sb.AppendLine($"NoFileStreamColumn                    {o.NoFileStreamColumn                   }");
         sb.AppendLine($"NoIdentities                          {o.NoIdentities                         }");
         sb.AppendLine($"NoIndexPartitioningSchemes            {o.NoIndexPartitioningSchemes           }");
         sb.AppendLine($"NoMailProfileAccounts                 {o.NoMailProfileAccounts                }");
         sb.AppendLine($"NoMailProfilePrincipals               {o.NoMailProfilePrincipals              }");
         sb.AppendLine($"NonClusteredIndexes                   {o.NonClusteredIndexes                  }");
         sb.AppendLine($"NoTablePartitioningSchemes            {o.NoTablePartitioningSchemes           }");
         sb.AppendLine($"NoVardecimal                          {o.NoVardecimal                         }");
         sb.AppendLine($"NoViewColumns                         {o.NoViewColumns                        }");
         sb.AppendLine($"NoXmlNamespaces                       {o.NoXmlNamespaces                      }");
         sb.AppendLine($"OptimizerData                         {o.OptimizerData                        }");
         sb.AppendLine($"Permissions                           {o.Permissions                          }");
         sb.AppendLine($"PrimaryObject                         {o.PrimaryObject                        }");
         sb.AppendLine($"SchemaQualify                         {o.SchemaQualify                        }");
         sb.AppendLine($"SchemaQualifyForeignKeysReferences    {o.SchemaQualifyForeignKeysReferences   }");
         sb.AppendLine($"ScriptBatchTerminator                 {o.ScriptBatchTerminator                }");
         sb.AppendLine($"ScriptData                            {o.ScriptData                           }");
         sb.AppendLine($"ScriptDataCompression                 {o.ScriptDataCompression                }");
         sb.AppendLine($"ScriptDrops                           {o.ScriptDrops                          }");
         sb.AppendLine($"ScriptForAlter                        {o.ScriptForAlter                       }");
         sb.AppendLine($"ScriptForCreateDrop                   {o.ScriptForCreateDrop                  }");
         sb.AppendLine($"ScriptOwner                           {o.ScriptOwner                          }");
         sb.AppendLine($"ScriptSchema                          {o.ScriptSchema                         }");
         sb.AppendLine($"SpatialIndexes                        {o.SpatialIndexes                       }");
         sb.AppendLine($"Statistics                            {o.Statistics                           }");
         sb.AppendLine($"TargetDatabaseEngineEdition           {o.TargetDatabaseEngineEdition          }");
         sb.AppendLine($"TargetDatabaseEngineType              {o.TargetDatabaseEngineType             }");
         sb.AppendLine($"TargetServerVersion                   {o.TargetServerVersion                  }");
         sb.AppendLine($"TimestampToBinary                     {o.TimestampToBinary                    }");
         sb.AppendLine($"ToFileOnly                            {o.ToFileOnly                           }");
         sb.AppendLine($"Triggers                              {o.Triggers                             }");
         sb.AppendLine($"WithDependencies                      {o.WithDependencies                     }");
         sb.AppendLine($"XmlIndexes                            {o.XmlIndexes                           }");

         return sb.ToString();
      }


      /// <summary>
      /// Used to check parameters
      /// </summary>
      /// <param name="o"></param>
      /// <returns></returns>
      public static bool OptionEquals( ScriptingOptions? a, ScriptingOptions? b, out string msg)
      {
        // var sb = new StringBuilder();
         bool ret = false;
         AssertionNotNull(a);
         AssertionNotNull(b);

         do
         { 
            if(a.AgentAlertJob                         != b.AgentAlertJob                        ){ msg = "AgentAlertJob";                        break;}
            if(a.AgentJobId                            != b.AgentJobId                           ){ msg = "AgentJobId";                           break;}
            if(a.AgentNotify                           != b.AgentNotify                          ){ msg = "AgentNotify";                          break;}
            if(a.AllowSystemObjects                    != b.AllowSystemObjects                   ){ msg = "AllowSystemObjects";                   break;}
            if(a.AnsiFile                              != b.AnsiFile                             ){ msg = "AnsiFile";                             break;}
            if(a.AnsiPadding                           != b.AnsiPadding                          ){ msg = "AnsiPadding";                          break;}
            if(a.AppendToFile                          != b.AppendToFile                         ){ msg = "AppendToFile";                         break;}
            if(a.ChangeTracking                        != b.ChangeTracking                       ){ msg = "ChangeTracking";                       break;}
            if(a.BatchSize                             != b.BatchSize                            ){ msg = "BatchSize";                            break;}
            if(a.Bindings                              != b.Bindings                             ){ msg = "Bindings";                             break;}
            if(a.ClusteredIndexes                      != b.ClusteredIndexes                     ){ msg = "ClusteredIndexes";                     break;}
            if(a.ColumnStoreIndexes                    != b.ColumnStoreIndexes                   ){ msg = "ColumnStoreIndexes";                   break;}
            if(a.ContinueScriptingOnError              != b.ContinueScriptingOnError             ){ msg = "ContinueScriptingOnError";             break;}
            if(a.ConvertUserDefinedDataTypesToBaseType != b.ConvertUserDefinedDataTypesToBaseType){ msg = "ConvertUserDefinedDataTypesToBaseType";break;}
            if(a.DdlBodyOnly                           != b.DdlBodyOnly                          ){ msg = "DdlBodyOnly";                          break;}
            if(a.DdlHeaderOnly                         != b.DdlHeaderOnly                        ){ msg = "DdlHeaderOnly";                        break;}
            if(a.Default                               != b.Default                              ){ msg = "Default";                              break;}
            if(a.DriAll                                != b.DriAll                               ){ msg = "DriAll";                               break;}
            if(a.DriAllConstraints                     != b.DriAllConstraints                    ){ msg = "DriAllConstraints";                    break;}
            if(a.DriAllKeys                            != b.DriAllKeys                           ){ msg = "DriAllKeys";                           break;}
            if(a.DriChecks                             != b.DriChecks                            ){ msg = "DriChecks";                            break;}
            if(a.DriClustered                          != b.DriClustered                         ){ msg = "DriClustered";                         break;}
            if(a.DriDefaults                           != b.DriDefaults                          ){ msg = "DriDefaults";                          break;}
            if(a.DriForeignKeys                        != b.DriForeignKeys                       ){ msg = "DriForeignKeys";                       break;}
            if(a.DriIncludeSystemNames                 != b.DriIncludeSystemNames                ){ msg = "DriIncludeSystemNames";                break;}
            if(a.DriIndexes                            != b.DriIndexes                           ){ msg = "DriIndexes";                           break;}
            if(a.DriNonClustered                       != b.DriNonClustered                      ){ msg = "DriNonClustered";                      break;}
            if(a.DriPrimaryKey                         != b.DriPrimaryKey                        ){ msg = "DriPrimaryKey";                        break;}
            if(a.DriUniqueKeys                         != b.DriUniqueKeys                        ){ msg = "DriUniqueKeys";                        break;}
            if(a.DriWithNoCheck                        != b.DriWithNoCheck                       ){ msg = "DriWithNoCheck";                       break;}
            if(a.Encoding                              != b.Encoding                             ){ msg = "Encoding";                             break;}
            if(a.EnforceScriptingOptions               != b.EnforceScriptingOptions              ){ msg = "EnforceScriptingOptions";              break;}
            if(a.ExtendedProperties                    != b.ExtendedProperties                   ){ msg = "ExtendedProperties";                   break;}
            if(a.FileName                              != b.FileName                             ){ msg = "FileName";                             break;}
            if(a.FullTextCatalogs                      != b.FullTextCatalogs                     ){ msg = "FullTextCatalogs";                     break;}
            if(a.FullTextIndexes                       != b.FullTextIndexes                      ){ msg = "FullTextIndexes";                      break;}
            if(a.FullTextStopLists                     != b.FullTextStopLists                    ){ msg = "FullTextStopLists";                    break;}
            if(a.IncludeDatabaseContext                != b.IncludeDatabaseContext               ){ msg = "IncludeDatabaseContext";               break;}
            if(a.IncludeDatabaseContext                != b.IncludeDatabaseContext               ){ msg = "IncludeDatabaseContext";               break;}
            if(a.IncludeDatabaseRoleMemberships        != b.IncludeDatabaseRoleMemberships       ){ msg = "IncludeDatabaseRoleMemberships";       break;}
            if(a.IncludeFullTextCatalogRootPath        != b.IncludeFullTextCatalogRootPath       ){ msg = "IncludeFullTextCatalogRootPath";       break;}
            if(a.IncludeHeaders                        != b.IncludeHeaders                       ){ msg = "IncludeHeaders";                       break;}
            if(a.IncludeIfNotExists                    != b.IncludeIfNotExists                   ){ msg = "IncludeIfNotExists";                   break;}
            if(a.IncludeScriptingParametersHeader      != b.IncludeScriptingParametersHeader     ){ msg = "IncludeScriptingParametersHeader";     break;}
            if(a.Indexes                               != b.Indexes                              ){ msg = "Indexes";                              break;}
            if(a.LoginSid                              != b.LoginSid                             ){ msg = "LoginSid";                             break;}
            if(a.NoAssemblies                          != b.NoAssemblies                         ){ msg = "NoAssemblies";                         break;}
            if(a.NoCollation                           != b.NoCollation                          ){ msg = "NoCollation";                          break;}
            if(a.NoCommandTerminator                   != b.NoCommandTerminator                  ){ msg = "NoCommandTerminator";                  break;}
            if(a.NoExecuteAs                           != b.NoExecuteAs                          ){ msg = "NoExecuteAs";                          break;}
            if(a.NoFileGroup                           != b.NoFileGroup                          ){ msg = "NoFileGroup";                          break;}
            if(a.NoFileStream                          != b.NoFileStream                         ){ msg = "NoFileStream";                         break;}
            if(a.NoFileStreamColumn                    != b.NoFileStreamColumn                   ){ msg = "NoFileStreamColumn";                   break;}
            if(a.NoIdentities                          != b.NoIdentities                         ){ msg = "NoIdentities";                         break;}
            if(a.NoIndexPartitioningSchemes            != b.NoIndexPartitioningSchemes           ){ msg = "NoIndexPartitioningSchemes";           break;}
            if(a.NoMailProfileAccounts                 != b.NoMailProfileAccounts                ){ msg = "NoMailProfileAccounts";                break;}
            if(a.NoMailProfilePrincipals               != b.NoMailProfilePrincipals              ){ msg = "NoMailProfilePrincipals";              break;}
            if(a.NonClusteredIndexes                   != b.NonClusteredIndexes                  ){ msg = "NonClusteredIndexes";                  break;}
            if(a.NoTablePartitioningSchemes            != b.NoTablePartitioningSchemes           ){ msg = "NoTablePartitioningSchemes";           break;}
            if(a.NoVardecimal                          != b.NoVardecimal                         ){ msg = "NoVardecimal";                         break;}
            if(a.NoViewColumns                         != b.NoViewColumns                        ){ msg = "NoViewColumns";                        break;}
            if(a.NoXmlNamespaces                       != b.NoXmlNamespaces                      ){ msg = "NoXmlNamespaces";                      break;}
            if(a.OptimizerData                         != b.OptimizerData                        ){ msg = "OptimizerData";                        break;}
            if(a.Permissions                           != b.Permissions                          ){ msg = "Permissions";                          break;}
            if(a.PrimaryObject                         != b.PrimaryObject                        ){ msg = "PrimaryObject";                        break;}
            if(a.SchemaQualify                         != b.SchemaQualify                        ){ msg = "SchemaQualify";                        break;}
            if(a.SchemaQualifyForeignKeysReferences    != b.SchemaQualifyForeignKeysReferences   ){ msg = "SchemaQualifyForeignKeysReferences";   break;}
            if(a.ScriptBatchTerminator                 != b.ScriptBatchTerminator                ){ msg = "ScriptBatchTerminator";                break;}
            if(a.ScriptData                            != b.ScriptData                           ){ msg = "ScriptData";                           break;}
            if(a.ScriptDataCompression                 != b.ScriptDataCompression                ){ msg = "ScriptDataCompression";                break;}
            if(a.ScriptDrops                           != b.ScriptDrops                          ){ msg = "ScriptDrops";                          break;}
            if(a.ScriptForAlter                        != b.ScriptForAlter                       ){ msg = "ScriptForAlter";                       break;}
            if(a.ScriptForCreateDrop                   != b.ScriptForCreateDrop                  ){ msg = "ScriptForCreateDrop";                  break;}
            if(a.ScriptOwner                           != b.ScriptOwner                          ){ msg = "ScriptOwner";                          break;}
            if(a.ScriptSchema                          != b.ScriptSchema                         ){ msg = "ScriptSchema";                         break;}
            if(a.SpatialIndexes                        != b.SpatialIndexes                       ){ msg = "SpatialIndexes";                       break;}
            if(a.Statistics                            != b.Statistics                           ){ msg = "Statistics";                           break;}
            if(a.TargetDatabaseEngineEdition           != b.TargetDatabaseEngineEdition          ){ msg = "TargetDatabaseEngineEdition";          break;}
            if(a.TargetDatabaseEngineType              != b.TargetDatabaseEngineType             ){ msg = "TargetDatabaseEngineType";             break;}
            if(a.TargetServerVersion                   != b.TargetServerVersion                  ){ msg = "TargetServerVersion";                  break;}
            if(a.TimestampToBinary                     != b.TimestampToBinary                    ){ msg = "TimestampToBinary";                    break;}
            if(a.ToFileOnly                            != b.ToFileOnly                           ){ msg = "ToFileOnly";                           break;}
            if(a.Triggers                              != b.Triggers                             ){ msg = "Triggers";                             break;}
            if(a.WithDependencies                      != b.WithDependencies                     ){ msg = "WithDependencies";                     break;}
            if(a.XmlIndexes                            != b.XmlIndexes                           ){ msg = "XmlIndexes";                           break;}
            ret = true;
            msg = "";
         } while (false);

         LogL($"ret: {ret}");
         return ret;
      }

      /// <summary>
      /// Filters against the  current parameters
      /// </summary>
      /// <returns></returns>
      protected bool IsWanted(string? currentSchemaName, SqlSmoObject obj)
      {
         string? schemaName = null;
         string? name = null;
         string type = obj.GetType().Name;
         bool ret = false;

         Utils.Precondition<ArgumentException>(obj != null);

         if(obj.Properties.Contains("IsSystemObject"))
         { 
            var property = obj.Properties.GetPropertyObject("IsSystemObject");

            if((bool)(property?.Value  ?? false) == true )
               return false;
         }

         // Schema filter
         if(obj is Schema)
         {
            Schema? schema = (obj as Schema);
            schemaName = schema.Name;
            name = schemaName;
         }

         if(obj is ScriptSchemaObjectBase)
         {
            schemaName = (obj as ScriptSchemaObjectBase).Schema;
            name = schemaName;
         }

         if(obj is ForeignKey)
            schemaName = (obj as ForeignKey).ReferencedTableSchema;

         Utils.Assertion(schemaName!= null, $"could not determine schema for {type} {name}");

         // Check is of the current schema
         if(!schemaName.Equals(currentSchemaName, StringComparison.OrdinalIgnoreCase))
            return false;

         // Handle required types filter
         SqlTypeEnum sqlTy = MapTypeToSqlType(obj);

         if(P.RequiredTypes == null || P.RequiredTypes.Contains(sqlTy))
            ret = true;

         LogL($"ret: {ret}");
         return ret;
      }

      /// <summary>
      /// Filters against the current IsExprtng type  Flags
      /// </summary>
      /// <returns></returns>
      protected bool IsTypeWanted(string typeName) //, string itemName
      {
         bool ret = false;

         if(typeName=="Table")
         { 
            LogI("IsTypeWanted(): ty: table");
         }

         // Schema filter
         switch(typeName.ToUpper())
         {
         case "DATA"                : ret = P.IsExportingData      ; break;
         case "DATABASE"            : ret = P.IsExportingDb        ; break;
         case "USERDEFINEDFUNCTION" : ret = P.IsExportingFns       ; break;
         case "STOREDPROCEDURE"     : ret = P.IsExportingProcs     ; break;
         case "SCHEMA"              : ret = P.IsExportingSchema    ; break;
         case "TABLE"               : ret = P.IsExportingTbls      ; break;
         case "USERDEFINEDTABLETYPE": ret = P.IsExportingTTys      ; break;
         case "VIEW"                : ret = P.IsExportingVws       ; break;

         case "SQLASSEMBLY"         : ret = P.IsExportingAssemblies; break;
         case "TRIGGER"             : ret = P.IsExportingTriggers  ; break;
         case "USERDEFINEDTYPE"     : ret = P.IsExportingUsrDefTys ; break;
         case "USERDEFINEDDATATYPE" : ret = P.IsExportingUsrDefTys ; break;
         case "FOREIGNKEY"          :
         case "SERVICEQUEUE": ret = false; break;

            default:
            Utils.Postcondition(false, $"IsTypeWanted() unexpected type: [{typeName}]"); break;
         }

         //LogL($"ret: {ret}");
         return ret;
      }

       protected void LogResults(StringBuilder sb)
      {
         var line = new string('-', 100);
         sb.AppendLine($"{line}\r\nSummary:\r\n{line}");
         LogExportedList("Datbases"                , sb, ExportedDatbases);
         LogExportedList("Schemas"                 , sb, ExportedSchemas);
         LogExportedList("Tables"                  , sb, ExportedTables);
         LogExportedList("Procedures"              , sb, ExportedProcedures);
         LogExportedList("Functions"               , sb, ExportedFunctions);
         LogExportedList("Views"                   , sb, ExportedViews);
         LogExportedList("Table Types"             , sb, ExportedTableTypes);
         LogExportedList("UserDefinedDataTypes"    , sb, ExportedTableTypes);
         LogExportedList("Wanted Items"            , sb, WantedItems);
         LogExportedList("Consisidered Entities"   , sb, ConsisderedEntities);
         LogExportedList("Different Databases"     , sb, DifferentDatabases);
         LogExportedList("Duplicate Dependencies"  , sb, DuplicateDependencies);
         LogExportedList("System Objects"          , sb, SystemObjects);
         LogExportedList("Unresolved Entities"     , sb, UnresolvedEntities);
         LogExportedList("Unwanted Types"          , sb, UnwantedTypes);
         LogExportedList("Unknown Entities"        , sb, UnknownEntities);
         LogExportedList("Bad bin"                 , sb, BadBin);
         //sb.AppendLine($"{line}");
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
      public static Server? CreateAndOpenServer( string? serverName, string? instance)// string databaseName )
      {
         Assertion(!string.IsNullOrEmpty(serverName)  , "Server not specified");
         //Assertion(!string.IsNullOrEmpty(instance)    , "Instance not specified");

         // ASSERTION: serverName, serverName, instance are all specified

         SqlConnectionInfo sqlConnectionInfo = new(serverName)
         {
            UseIntegratedSecurity = true
         };

         ServerConnection serverConnection = new(sqlConnectionInfo);

         var server = new Server(serverConnection);

         Postcondition(server != null, "Could not create Server object");
         return server;
      }

      protected static void LogExportedList(string type, StringBuilder sb, SortedList<string, string> list)
      {
         var hdr = $"{type,-22}: {list.Count, +3} items";
         LogDirect($"\r\n\t{hdr}");
         sb.AppendLine($"{hdr} items");

         foreach( var t in list)
            LogDirect($"\t\t{t.Key}"); 
      }

      protected void RegisterAction(string key, SelectionRuleEnum rule)
      {
         LogDirect($"{key} : {rule.GetAlias()}");
         SortedList<string, string>? list = null;

         try
         {
            switch(rule)
            { 
            case SelectionRuleEnum.Wanted:               list = WantedItems;           break;
            case SelectionRuleEnum.Considering:          list = WantedItems;           break;
            case SelectionRuleEnum.UnwantedType:         list = UnwantedTypes;         break;
            case SelectionRuleEnum.UnwantedSchema:       list = UnwantedSchemas;       break;
            case SelectionRuleEnum.SystemObject:         list = SystemObjects;         break;
            case SelectionRuleEnum.DuplicateDependency:  list = DuplicateDependencies; break;
            case SelectionRuleEnum.DifferentDatabase:    list = DifferentDatabases;    break;
            case SelectionRuleEnum.UnresolvedEntity:     list = UnresolvedEntities;    break;
            case SelectionRuleEnum.UnknownEntity:        list = UnknownEntities;    break;

            default:   AssertFail($"RegisterAction unhandled rule: {rule.GetAlias()}");break;
            }

            RegisterAction2(key, list, rule);
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }
      }

      void RegisterAction2(string key, SortedList<string, string>? list, SelectionRuleEnum rule)
      {
         if(!list.ContainsKey(key))
            list.Add(key, key);
         //else
         //   LogDirect($"{key} rule: {rule.GetAlias()} entry already exists in list");
      }

      #endregion protected methods
      #region private fields

      private const string GO = "GO";

      #endregion private fields
   }
}

#pragma warning restore CA1031 // Do not catch general exception types
