
#nullable enable
#pragma warning disable CS8602

using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Sdk.Sfc;
using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using RSS;
using static RSS.Utils;
using static RSS.Logger;
using System.Collections.Specialized;

namespace DbScripterLib
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
      #region private fields

      private const string GO = "GO";

      #endregion private fields
      #region    properties
      #region    primary properties
      // Primary properties
      // are set by the constructor
      public Params P {get;set; } = new Params();
      #endregion primary properties
      #region    major scripting properties

      // Major properties
      public Database?         Database       { get; private set; }
      public Scripter?         Scripter       { get; private set; }
      public ScriptingOptions? ScriptOptions  { get; private set; }
      public Server?           Server         { get; private set; }
      public StreamWriter?     Writer         { get; private set; }
      public bool              IsInitialised  { get; private set; } = false;
 
      #endregion major scripting properties
      #region scripter info cache

      // These properties are info caches for the scripted items
      public SortedList<string, string> ExportedFunctions { get; private set; } = new SortedList<string, string>();
      public SortedList<string, string> ExportedProcedures{ get; private set; } = new SortedList<string, string>();
      public SortedList<string, string> ExportedTables    { get; private set; } = new SortedList<string, string>();

      public SortedList<string, string> ExportedViews     { get; private set; } = new SortedList<string, string>();
      #endregion scripter info cache

      #endregion properties
      #region    public methods

      /// <summary>
      /// Main constructor
      /// If params are specified then initialises state with params
      /// Test: DbScriptorTests.DbScriptorTest
      /// 
      /// PRECONDITIONS: none
      /// 
      /// POSTCONDITIONS:
      /// ServerName     = serverName
      /// InstanceName   = instanceName
      /// DatabaseName   = databaseName
      /// WriterFilePath = writerFilePath
      /// DbOpType       = opType
      /// 
      /// </summary>
      public DbScripter(Params? p = null)
      {
         if(p != null)
            Init(p);
      }

      /// <summary>
      /// Initialize state, deletes the writerFilePath file if it exists
      /// Only completes the initialisation if the parameters are all specified
      /// 
      /// PRECONDITIONS: none
      ///   P.ServerName   specified
      ///   P.InstanceName specified
      ///   P.OpType       specified
      ///   
      /// POSTCONDITIONS:
      ///   1: Initialises the initial state
      ///   2: server and makes a connection, throws exception otherwise
      ///   3: database connected
      ///   4: sets the scripter options configuration based on optype
      ///   5: sets the IsInitialised flag
      ///   
      /// </summary>
      /// <param name="serverName">DESKTOP-UAULS0U\SQLEXPRESS</param>
      /// <param name="instanceName">like SQLEXPRESS</param>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath">like C:\tmp\Covid_T1_export.sql</param>
      public void Init( Params? p, bool append = false)
      {
         LogS(p?.ToString() ?? "");
         var specMsg = "must be specified";
         Precondition<ArgumentException>(p != null, $"Params arg {specMsg}");
         Precondition<ArgumentException>((!string.IsNullOrEmpty(P.ServerName  ))||(!string.IsNullOrEmpty(p.ServerName  )), $"server {specMsg}");
         Precondition<ArgumentException>((!string.IsNullOrEmpty(P.InstanceName))||(!string.IsNullOrEmpty(p.InstanceName)), $"instance {specMsg}");
         Precondition<ArgumentException>(p.DbOpType != null, $"Op type {specMsg}");

         // First clear all
         if(!append)
            ClearState();

         P.PopFrom(p);      // 1: Initialise the initial state

         //   2: server and makes a connection, throws exception otherwise
         InitServer(P.ServerName, P.InstanceName);
         InitDatabase(P.DatabaseName);

         // PRE: P pop
         InitScriptingOptions();

         // InitWriter calls IsValid() - returns the Validation status - 
         // NOTE: can continue if not all initialised so long as the final init is performed before any write op
         // PRE:  P pop with export path
         // POST: Writer open
         InitWriter();

         /// POSTCONDITION CHECKS:
         ///   1: Initialises the initial state
         ///   2: server and makes a connection, throws exception otherwise
         ///   3: database connected
         ///   4: sets the scripter options configuration based on optype
         Postcondition(Server != null,             "Server not initialised");
         Postcondition(Server.Databases.Count > 0, "Server not initialised");
         Postcondition(Database != null,           "Database not not initialised");
         Postcondition(Database.Schemas.Count > 0, "Database not not initialised");
         IsInitialised = true;
         LogL();
      }

      /// <summary>
      /// Initializes server connectio - default database: databaseName
      /// 
      /// PRECONDITIONS:
      ///   
      /// POSTCONDITIONS:
      ///  Server created and connected or serverName is null
      /// </summary>
      /// <param name="databaseName"></param>
      protected void InitServer( string? serverName, string? instanceName)
      {
         LogS();

         try
         {
            if(serverName == null)
            {
               Server   = null;
               Database = null;
               return;
            }

            Precondition<ArgumentException>(!string.IsNullOrEmpty(serverName)  , "Server not specified");
            Assertion(!string.IsNullOrEmpty(instanceName), "Instance not specified");

            // ASSERTION: serverName, serverName, instance are all specified

            Server = CreateAndOpenServer( serverName, instanceName);//, databaseName );
            var ver = Server.Information.Version;

            // Set the default loaded fields to include IsSystemObject
            Server.SetDefaultInitFields(typeof(Table),              "IsSystemObject" /*",CreateDate"*/);
	         Server.SetDefaultInitFields(typeof(StoredProcedure),    "IsSystemObject" /*",CreateDate"*/);
	         Server.SetDefaultInitFields(typeof(UserDefinedFunction),"IsSystemObject" /*",CreateDate#"*/,"FunctionType");
	         Server.SetDefaultInitFields(typeof(View),               "IsSystemObject" /*",CreateDate"*/);

            // Post condition chk
            Postcondition(((Server != null) || (serverName == null)),   "Could not create Server object");
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
      }

      /// <summary>
      /// PRE:  server       instantiated
      /// PRE:  databaseName specified
      /// POST: Database     instantiated and connected
      /// </summary>
      /// <param name="databaseName"></param>
      protected void InitDatabase(string? databaseName)
      { 
         LogS();

         try
         {
            Precondition<ArgumentException>(Server != null , "Server not instantiated");
            Precondition<ArgumentException>(!string.IsNullOrEmpty(databaseName), "databaseName not specified");

            var databases = Server.Databases;

            //FeedbackComponentProvider.Append(this, "Init", $"Getting the SMO database object for  object for the database name: [{databaseName}].");
            if(!databases.Contains(databaseName))
               Server.Refresh();

            // ASSERTION: if here then database exists

            if(databases.Contains(databaseName))
               Database = Server.Databases[databaseName];
            else
               Database = new Database(Server, databaseName);

            // Post condition chks
            Assertion<ConfigurationException>(Database != null, $"database {databaseName} not found");
            Assertion<ConfigurationException>(Database.Schemas.Count > 0, $"database {databaseName} not found");
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
     }



      /// <summary>
      /// Encapsulates the scripter options and OPType setup
      /// 
      /// PRECONDITIONS:
      ///   P configured
      /// POSTCONDITIONS:
      ///  
      /// </summary>
      /// <param name="dbOpType"></param>
      private bool InitScriptingOptions()
      {
         LogS();

         // Bow out quick if default
         if(P.DbOpType != DbOpTypeEnum.Undefined)
         {
            // set SqlType
            // Map the dbOpType to the corresponding sql obect type that the dbOpType works on
            // 
            // POSTCONDITIONS:
            // 1: dbOpType is successfully mapped and returned
            // </summary>
            // <param name="dbOpType"></param>
            // <returns></returns>
            P.SqlType = GetSqlTypeFromDbOpType(P.DbOpType ?? DbOpTypeEnum.Undefined);

            // SqlType known

            Scripter = new Scripter(Server);

            var noGoflag = (P.DbOpType == DbOpTypeEnum.CreateStaticData);

            ScriptOptions = new ScriptingOptions()
            {
               IncludeDatabaseContext  = P?.ScriptUseDb ?? false, // Do not Script the USE Database line
               AllowSystemObjects      = false,
               AnsiPadding             = false,
               AppendToFile            = true,  // needed if we use script builder repetitively
               IncludeIfNotExists      = false,
               ContinueScriptingOnError= false,
               ConvertUserDefinedDataTypesToBaseType = false,
               ScriptForAlter          = (P.CreateMode == CreateModeEnum.Alter),
               WithDependencies        = false, //= true Smo.FailedOperationException true, Unable to cast object of type 'System.DBNull' to type 'System.String'.
               IncludeHeaders          = false, // true,

               // Include Scripting Parameters Header: False
               // Include system constraint names: False
               // Include unsupported statements: False
               Bindings                = false, // Script Bindings: False
               NoCollation             = true,  // Script Collation: False
               DriDefaults             = true,  // Script Defaults: True
                                                // Script DROP and CREATE: Script CREATE
               ExtendedProperties      = true,  // Script Extended Properties: True
                                                // FileName                                = scripterFilePath, redundant now we know how to get around the bug in populate the script with GO statements
               NoIdentities            = true,  // From SQL Man,Studio/Tools/Options/SQL Server Object Explorer/Scripting
                                                // Script for Server Version: SQL Server 2017
                                                // Script for the database engine edition: Microsoft SQL Server Standard Edition
                                                // Script for the database engine type: Stand - alone instance
                                                // Script LogUtils.LogIns: False
                                                // Script Object - Level Permissions: False
                                                // Script Owner: False
                                                // Script Statistics: Do not script statistics
                                                // Script USE DATABASE: True
                                                // Types of data to script: Schema only

               // Table / View Options
               // Script Change Tracking: False
               // Script Check Constraints: True
               // Script Data Compression Options: False
               // Script Foreign Keys: True

               SchemaQualifyForeignKeysReferences = true, // 
                                                  // Script Full - Text Indexes: False

               DriIndexes              = true,  // Script Indexes: True
               DriPrimaryKey           = true,  // Script Primary Keys: True
                                                // Script Triggers: False
               DriUniqueKeys           = true,  // Script Unique Keys: True

               ScriptBatchTerminator   = false,
               // Exclude GOs after every line

               NoCommandTerminator     = noGoflag, // false means should emit GO statements - don't emit GO statements after every SQL insert statement for static data
               Indexes                 = true,
               DriForeignKeys          = false, // We script FKs later after all tables so that dependencies work
               DriAll                  = false,
               DriAllKeys              = false,
               Permissions             = false,
               DriAllConstraints       = true,  // include referential constraints in the script
               SchemaQualify           = true,  // Schema qualify object names.: True e.g. [dbo]
               AnsiFile                = true,
               //SchemaQualifyForeignKeysReferences= true;
               //Indexes                           = true,
               //DriIndexes                        = true,
               DriClustered            = true,
               DriNonClustered         = true,
               NonClusteredIndexes     = true,
               ClusteredIndexes        = true,
               FullTextIndexes         = true,
               EnforceScriptingOptions = true,
            };

            //FeedbackComponentProvider.Append(this, "Init", "Created ScriptingOptions object.");
            // Modified per op Type
            ScriptOptions.ScriptData   = P.DbOpType == DbOpTypeEnum.CreateStaticData; // More needed here to filter the static data only - now done in Export Tables
            ScriptOptions.ScriptSchema = P.DbOpType != DbOpTypeEnum.CreateStaticData;

            ScriptOptions.ScriptDrops  =  (P.DbOpType == DbOpTypeEnum.DropDatabase) 
                                       || (P.DbOpType == DbOpTypeEnum.DropSchema) 
                                       || (P.DbOpType == DbOpTypeEnum.DropTables) 
                                       || (P.DbOpType == DbOpTypeEnum.DropProcedures) 
                                       || (P.DbOpType == DbOpTypeEnum.DropStaticData)
                                       || (P.DbOpType == DbOpTypeEnum.DropViews)
                                       ;

            Scripter.Options = ScriptOptions;

            // Make the flags and the ops consistent
            // Set required types specifically 
            switch(P.DbOpType)
            {
               case DbOpTypeEnum.CreateSchema: ExportSchemaScriptInit(); break;
               case DbOpTypeEnum.DropSchema:   ExportSchemaScriptInit(); break;
            }
         }

         LogL($" {(P.DbOpType == DbOpTypeEnum.Undefined ? "not ": "")} initialised");
         return true;
      }

      /// <summary>
      /// Initializes file writer if writerFilePath is a valid path
      /// if file not specified issues a warning, closes the writer
      /// if the file exists prior to this call then it is deleted - exception if not possible to delete
      /// calls IsValid at end
      /// 
      /// PRECONDITIONS: exportScriptPath is not null
      ///   
      /// POSTCONDITIONS:
      /// POST 1: writer open pointing to the export file AND
      ///       writer file same as ExportFilePath and both equal exportFilePath parameter
      /// </summary>
      /// <param name="exportFilePath"></param>
      /// <param msg="possible error/warning message"></param>
      /// <returns>success of the writer initialisation</returns>
      protected void InitWriter()
      {
         try
         {
            LogS();
            // Close the writer
            Writer?.Close();
            string? exportScriptPath = P.ExportScriptPath;

            // Bail out if not path set
            Precondition(!string.IsNullOrEmpty(exportScriptPath), "xportScriptPath must be specified");

            if(string.IsNullOrEmpty(P.ExportScriptPath))
               P.ExportScriptPath = $"{Directory.GetCurrentDirectory()}{Database.Name}_export.sql";  //$"{Path.GetTempPath()}{Database.Name}_export.sql";

            P.ExportScriptPath = Path.GetFullPath(P.ExportScriptPath);
 
            // ASSERTION: writer intialised

            if(File.Exists(P.ExportScriptPath))
               File.Delete(P.ExportScriptPath);

            var fs = new FileStream(P.ExportScriptPath, FileMode.CreateNew);
            Writer = new StreamWriter(fs){ AutoFlush = true }; // writerFilePath AutoFlush = true debug to dump cache immediately

            // POST 1: writer open pointing to the export file AND
            //         writer file same as ExportFilePath and both equal exportFilePath parameter
            Postcondition((Writer != null) && 
                      ((FileStream)(Writer.BaseStream)).Name.Equals(P.ExportScriptPath, StringComparison.OrdinalIgnoreCase)
                      , "Writer not initialised properly");
 
            // ASSERTION: writer intialised and target file has been created and is empty
            LogL();
         }
         catch(Exception e)
         {
            LogException(e);
            Writer?.Close();
            throw;
         }
      }

      protected void ClearState()
      {
         LogS();
         // primary properties
         P.ClearState();

         // major scripting properties
         Database          = null;
         Scripter          = null;
         ScriptOptions     = null;
         Server            = null;
         Writer            = null;

         // info cache
         ExportedFunctions .Clear();
         ExportedProcedures.Clear();
         ExportedTables    .Clear();
         ExportedViews     .Clear();
         LogL();
      }

      /// <summary>
      /// Exports all stored procedures and functions
      /// Initialises the major scripting elements
      /// </summary>
      /// <returns>Serialisation of all the user functions and user stored procedures as a set of SQL statements</returns>
      public string ExportRoutines( Params? p)
      {
         LogS();
         var sb = new StringBuilder();

         try
         {
            Init(p);

            // ASSERTION: P pop

            // PRE:   P pop
            var requiredSchemaAry = p.RequiredSchemas;

            InitScriptingOptions();

            if(P.AddTimestamp ?? false)
               P.ExportScriptPath = HandleExportFilePath(P.ExportScriptPath, P.AddTimestamp ?? false);

            // PRE:  P pop with export path
            // POST: Writer open
            InitWriter();

            if(P.ScriptUseDb?? false)
            {
               ScriptLine($"USE {P.DatabaseName}", sb);
               ScriptGo(sb);
            }

            foreach(var schemaName in P.RequiredSchemas)
               ExportRoutines (schemaName, sb);

            Writer.Close();
            LogL();
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
         return sb.ToString();
      }


      /// <summary>
      /// Exports all stored procedures and functions
      /// Initialises the major scripting elements
      /// 
      /// PRE:  Initialised
      /// POST: Sps and fns exported for the given schema
      /// </summary>
      /// <returns>Serialisation of all the user functions and user stored procedures as a set of SQL statements</returns>
      public string ExportRoutines( string? currentSchemaName, StringBuilder sb)
      {
         LogS($"currentSchemaName: {currentSchemaName}");
         StringBuilder sb_ = new ();

         try
         {
            ExportFunctions (currentSchemaName, sb_);
            ExportProcedures(currentSchemaName, sb_);
            sb.Append(sb_);
            LogL();
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         return sb_.ToString();
      }

      /// <summary>
      /// if 
      /// </summary>
      /// <param name="addTimestamp"></param>
      /// <returns></returns>
      protected string HandleExportFilePath( string? exportFilePath, bool addTimestamp )
      {
         // Add the file path as a comment in the first line in the script
         // D:\Dev\Db\Ut\Tests\ut_{dbo,test}_FP_210214-0709_export.sql
         string? modifiedExportFilePath = null;
         var lastFolderPos = exportFilePath.LastIndexOf('\\');
         var dirs = exportFilePath.Substring(0, lastFolderPos);
         var pos2 = exportFilePath.LastIndexOf('\\');

         var secondPart = exportFilePath.Substring(lastFolderPos + 1);
         var extPos = secondPart.LastIndexOf('.');
         var len = secondPart.Length;
         var ext = secondPart.Substring(extPos+1, len-(extPos+1));
         var fileName = secondPart.Substring(0, extPos);
         // if timestamp is already specified then fileName is like this: ut_{dbo,test}_FP_210214-0709_export
         var parts = exportFilePath.Split(new []{'_'});

         if(parts.Length >= 5)
         {
            // file name is fully specified including timestamp so dont change
            modifiedExportFilePath = exportFilePath;
         }
         else
         {
            // file name is not fully specified so append timestamp
            modifiedExportFilePath = $@"{ dirs}\{fileName}_{GetTimestamp()}.{ext}";
         }

         return modifiedExportFilePath;
      }

      public virtual string GetTimestamp()
      { 
         return DateTime.Now.ToString("yyMMdd-HHmm");
      }

      #endregion public methods
      #region private methods

      /// <summary>
      /// Validates the initialization
      /// PRECONDITIONS: 
      ///   P config pop
      /// </summary>
      /// <returns></returns>
      private bool IsValid()
      {
         var isValid = false;

         do
         {
            if(P.DbOpType == DbOpTypeEnum.Undefined)
               break;

            if(Writer == null)
               break;

            // Lastly if here then all checks have passed
            isValid = true;
         } while(false);

         return isValid;
      }

      /// <summary>
      /// Maps the dbOpType to the corresponding sql obect type
      /// that the dbOpType works on
      /// 
      /// POSTCONDITIONS:
      /// 1: dbOpType is successfully mapped and returned
      /// </summary>
      /// <param name="dbOpType"></param>
      /// <returns></returns>
      SqlTypeEnum GetSqlTypeFromDbOpType( DbOpTypeEnum dbOpType )
      {
         if(dbOpType == DbOpTypeEnum.Undefined)
            Assertion(dbOpType != DbOpTypeEnum.Undefined, $"Unhandled optype: {dbOpType}");
 
         SqlTypeEnum sqlType =
         dbOpType == DbOpTypeEnum.CreateDatabase   ? SqlTypeEnum.Database  :
         dbOpType == DbOpTypeEnum.CreateProcedures ? SqlTypeEnum.Procedure :
         dbOpType == DbOpTypeEnum.CreateSchema     ? SqlTypeEnum.Schema    :
         dbOpType == DbOpTypeEnum.CreateStaticData ? SqlTypeEnum.Undefined :
         dbOpType == DbOpTypeEnum.CreateTables     ? SqlTypeEnum.Table     :
         dbOpType == DbOpTypeEnum.DropDatabase     ? SqlTypeEnum.Database  :
         dbOpType == DbOpTypeEnum.DropProcedures   ? SqlTypeEnum.Procedure :
         dbOpType == DbOpTypeEnum.DropSchema       ? SqlTypeEnum.Schema    :
         dbOpType == DbOpTypeEnum.DropStaticData   ? SqlTypeEnum.Data      :
         dbOpType == DbOpTypeEnum.DropTables       ? SqlTypeEnum.Table     :
         dbOpType == DbOpTypeEnum.DropViews        ? SqlTypeEnum.View      :
         dbOpType == DbOpTypeEnum.ExportDynamicData? SqlTypeEnum.Data      :
         dbOpType == DbOpTypeEnum.ExportStaticData ? SqlTypeEnum.Data      : SqlTypeEnum.Undefined;

         if(sqlType == SqlTypeEnum.Undefined)
            Assertion(sqlType != SqlTypeEnum.Undefined, $"Unhandled optype: {dbOpType}");

         return sqlType;
      }

      /// <summary>
      /// PRE: none
      /// Main Export entry point
      /// </summary>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath"></param>
      /// <param name="staticDataTables">can configure the static data tables now</param>
      /// <returns></returns>
      public string? Export( Params p)
      {
         LogS();
         string? script = null;

         try
         {
            switch(p.DbOpType)
            {
            case DbOpTypeEnum.CreateDatabase:   script = ExportCreateDbScript(p);      break;
            case DbOpTypeEnum.CreateSchema:     script = ExportSchemas(p);             break;
            case DbOpTypeEnum.CreateProcedures: script = ExportProcedures(p);          break;
            case DbOpTypeEnum.DropDatabase:     script = ExportDropDatabaseScript(p);  break;
            case DbOpTypeEnum.DropProcedures:   script = ExportDropProceduresScript(p);break;
            case DbOpTypeEnum.CreateTables:     script = ExportTables(p);              break;
            case DbOpTypeEnum.DropTables:       script = ExportTables(p);              break;
            case DbOpTypeEnum.DropSchema:       script = ExportDropSchemaScript(p);    break; 

            case DbOpTypeEnum.CreateStaticData: throw new NotImplementedException("Unhandled request type: .DropStaticData");
            case DbOpTypeEnum.ExportStaticData: throw new NotImplementedException("Unhandled request type: .ExportStaticData");
            case DbOpTypeEnum.ExportDynamicData:throw new NotImplementedException("Unhandled request type: .ExportDynamicData");
            case DbOpTypeEnum.DropStaticData:   throw new NotImplementedException("Unhandled request type: .DropStaticData");

            default:
               script = "";
               Assertion(false, $"SQL Export Scriptor error: unhandled script export case: {P.DbOpType.GetAlias()}");
               break;
            }
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }
         finally
         {
            Writer?.Close();
         }

         LogL();
         return script;
      }

      /// <summary>
      /// PRE: InitEnsuringDatabaseExists called with DbOpTypeEnum.ExportCreateDatabaseScript
      /// </summary>
      protected string ExportCreateDbScript( Params p )
      {
         LogS();
         var sb = new StringBuilder();

         try
         {
            Init(p);

            Assertion<Exception>((P.DbOpType == DbOpTypeEnum.CreateDatabase), "ExportCreateDbScript not initialised properly");
            // Initialise configuration
            var originalNoCommandTerminator     = ScriptOptions.NoCommandTerminator;
            var originalIncludeDatabaseContext  = ScriptOptions.IncludeDatabaseContext;
            ScriptOptions.NoCommandTerminator   = false;
            ScriptOptions.IncludeDatabaseContext= true;

            // Create the script
            SerialiseScript(Database.Script(ScriptOptions), sb);

            // Reset configuration
            ScriptOptions.NoCommandTerminator = originalNoCommandTerminator;
            ScriptOptions.IncludeDatabaseContext = originalIncludeDatabaseContext;

            // Do not keep scripting use database lines unless necessary
            if(ScriptOptions.IncludeDatabaseContext)
               ScriptOptions.IncludeDatabaseContext = false;
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
         return sb.ToString();
      }

      /// <summary>
      /// Use this when we dont need to look for the CREATE RTN statement 
      /// </summary>
      /// <param name="transactions"></param>
      /// <param name="sb"></param>
      private void SerialiseScript( IEnumerable transactions, StringBuilder sb )
      {
         foreach(string transaction in transactions)
         {
            ScriptLine( transaction, sb);

            if(WantBlankLineBetweenTransactions())
               ScriptBlankLine(sb);
         }
      }

      /// <summary>
      /// sole access to writing to the file/ strinbuilder
      /// </summary>
      /// <param name="line"></param>
      /// <param name="sb"></param>
      protected void ScriptLine(string line, StringBuilder sb)
      { 
         if(!line.EndsWith("\r\n"))
            line = line +("\r\n");

         Writer.Write(line);
         sb.Append(line);
      }

      /// <summary>
      /// If scripting drops where the transactions are 1 or 2 lines then dont want a blank line
      /// </summary>
      /// <returns></returns>
      private bool WantBlankLineBetweenTransactions( DbOpTypeEnum dbOpType = DbOpTypeEnum.Undefined )
      {
         return !IsDropOperation(dbOpType);
      }

      /// <summary>
      /// Determines if db operation is a drop type
      /// </summary>
      /// <param name="dbOpType">defalt: use the OpType property</param>
      /// <returns></returns>
      private bool IsDropOperation( DbOpTypeEnum dbOpType = DbOpTypeEnum.Undefined )
      {
         if(dbOpType == DbOpTypeEnum.Undefined)
            dbOpType = P.DbOpType ?? DbOpTypeEnum.Undefined;

         return dbOpType == DbOpTypeEnum.DropDatabase    ? true :
                dbOpType == DbOpTypeEnum.DropProcedures  ? true :
                dbOpType == DbOpTypeEnum.DropSchema      ? true :
                dbOpType == DbOpTypeEnum.DropStaticData  ? true :
                dbOpType == DbOpTypeEnum.DropTables      ? true :
                dbOpType == DbOpTypeEnum.DropViews       ? true : false;
      }

      /// <summary>
      /// Drop Scripts are handled differently.
      /// The drops are repetitive and simple transactions so don want a blank after
      /// each transaction emitted from the scripter.
      /// However if the is a drop operation then we DO want a blank line at the end of the
      /// Script part
      /// </summary>
      /// <param name="sb"></param>
      /// <param name="dbOpType"></param>
      private void CloseScript( StringBuilder sb, DbOpTypeEnum dbOpType = DbOpTypeEnum.Undefined )
      {
         if(dbOpType == DbOpTypeEnum.Undefined)
            dbOpType = P.DbOpType ?? DbOpTypeEnum.Undefined;

         // If a drop operation then add a blank line
         if(!WantBlankLineBetweenTransactions(dbOpType))
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
      /// PRE:  NONE
      /// POST: all UNDEFIEND flags set true
      /// </summary>
      protected void SetUndefinedExportSchemaFlags()
      {
         if(P.IsExprtngFns    == null) P.IsExprtngFns    = true;
         if(P.IsExprtngProcs  == null) P.IsExprtngProcs  = true;
         if(P.IsExprtngSchema == null) P.IsExprtngSchema = true;
         if(P.IsExprtngTbls   == null) P.IsExprtngTbls   = true;
         if(P.IsExprtngTTys   == null) P.IsExprtngTTys   = true;
         if(P.IsExprtngVws    == null) P.IsExprtngVws    = true;
      }

      /// <summary>
      /// This will script all required schemas
      /// </summary>
      public string ExportSchemas(Params p)
      {
         LogS();
         var sb = new StringBuilder(); 

         try
         {
            Init(p);
            // specialise the Options config for this op
            ExportSchemaScriptInit();

            foreach(var schemaName in P.RequiredSchemas)
               ExportSchema( Database.Schemas[schemaName], sb);
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
         return sb.ToString();
      }


      /// <summary>
      /// This will script the given schema in create mode
      /// and will export all child types: Tables, views, sps, fns ...
      /// Pre: all initialisation done
      /// </summary>
      public string ExportSchema(Schema schema, StringBuilder sb)
      {
         LogS();
         var sb_ = new StringBuilder(); 

         try
         {
            // Create the scripts
            Assertion<ArgumentException>(schema !=null);

            // Finally drop the schema itself
            if(P.IsExprtngSchema ?? false)
               ScriptSchemaCreateLine(schema, sb_);

            // Export tables and checks but not FKs as they may depend on tables not defined yet
            if(P.IsExprtngTbls ?? false)
               ExportTables( schema, sb_);

            if(P.IsExprtngFKeys ?? false)
               ExportForeignKeys(schema.Name, sb_);

            if(P.IsExprtngTTys ?? false)
               ExportTableTypes(schema.Name, sb_);

            if(P.IsExprtngFns ?? false)
               ExportFunctions(schema.Name, sb_);

            if(P.IsExprtngProcs ?? false)
               ExportProcedures(schema.Name, sb_);

            if(P.IsExprtngVws ?? false)
               ExportViews(schema.Name, sb_);
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         sb.Append(sb_);
         return sb_.ToString();
      }

 
      /// <summary>
      /// PRE: P.RequiredTypes not null
      /// 
      /// POST:RequiredTypes contains Type
      /// </summary>
      protected void EnsureRequiredTypesContainsType(SqlTypeEnum sqlType)
      {
         Precondition(P.RequiredTypes != null);

         if(!P.RequiredTypes.Contains(sqlType))
            P.RequiredTypes.Add(sqlType);
      }

      /// <summary>
      /// Pre:  P.RequiredTypes not null
      ///       Init() called, P DbOpType configured
      /// Post: state for Export of create or drop schema configured
      /// 
      /// Rules all types required that are children* of a schema
      /// schema, table, view, proc, fn, fkey, tty

      /// </summary>
      private void ExportSchemaScriptInit()
      {
         LogS();
         SetUndefinedExportSchemaFlags();

         EnsureRequiredTypesContainsType(SqlTypeEnum.Schema);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Table);
         EnsureRequiredTypesContainsType(SqlTypeEnum.View);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Procedure);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Function);
         EnsureRequiredTypesContainsType(SqlTypeEnum.TableType);
         EnsureRequiredTypesContainsType(SqlTypeEnum.FKey);
         EnsureRequiredTypesContainsType(SqlTypeEnum.TableType);

         P.IsExprtngFKeys  = true;
         P.IsExprtngFns    = true;
         P.IsExprtngProcs  = true;
         P.IsExprtngSchema = true;
         P.IsExprtngTbls   = true;
         P.IsExprtngTTys   = true;
         P.IsExprtngVws    = true;

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
         ScriptOptions.IncludeHeaders           = true;
         ScriptOptions.Indexes                  = true;
         ScriptOptions.NoCommandTerminator      = false;
         ScriptOptions.PrimaryObject            = true;
         LogL();
      }

      /// <summary>
      /// Main entry point for Exporting the Drop Schema Script
      /// This will script the create or drop schema
      /// Done in reverse order to create (dependencies first)
      /// PRE the schema to drop is in the required schemas
      /// PRE: there is only 1 schema in the required schemas list
      ///
      ///  Rules:
      ///   R01: 1 and only 1 schema can be dropped at a time 
      ///   R02: schema name must not be null and have at least 1 character
      ///   R03: Schema {tgtSchemaName} does not exist in the database {Database.Name}
      /// </summary>
      protected string ExportDropSchemaScript(Params p)
      {
         var sb = new StringBuilder();
         LogS();

         try
         { 
            Init(p);
            Precondition<ArgumentException>(P.RequiredSchemas.Count==1, "R01: 1 and only 1 schema can be dropped at a time");
            
            // specialise the Options config for this op
            ExportSchemaScriptInit();

            Assertion(ScriptOptions.ScriptDrops == true);
            Assertion((P.DbOpType == DbOpTypeEnum.DropSchema) || (P.DbOpType == DbOpTypeEnum.DropDatabase));

            // get the target schema  to drop
            foreach(var shemaName in P.RequiredSchemas)
            { 
               var schemaName = P.RequiredSchemas.First();
               Precondition<ArgumentException>((!string.IsNullOrEmpty(schemaName)) && (schemaName.Length>1), 
                  "R02: schema name must not be null and have at least 1 character");

               Schema tgtSchema  = Database.Schemas[schemaName];
               Assertion<ArgumentException>(tgtSchema!= null, $"R03: Schema {schemaName} does not exist in the database {Database.Name}");

               // Export types:
               ScriptUseDatabaseStatement(sb);

               if(P.IsExprtngVws ?? false)
                  ExportViews(shemaName, sb);

               // Once one export is written then do not keep scripting 'use database' lines
               if(ScriptOptions.IncludeDatabaseContext)
                  ScriptOptions.IncludeDatabaseContext = false;

               // Drop stored procedures while all functions, tables and types defined
               if(P.IsExprtngProcs ?? false)
                  ExportProcedures(shemaName, sb);

               // Drop functions while all tables and types defined
               if(P.IsExprtngFns ?? false)
                  ExportFunctions(shemaName, sb);

               if(P.IsExprtngTTys ?? false)
                  ExportTableTypes(shemaName, sb);

               // Drop FKs while all tables defined
               if(P.IsExprtngTbls ?? false)
               {
                  ExportForeignKeys(shemaName, sb);
#pragma warning disable CS8604 // Possible null reference argument.
                  ExportTables     (tgtSchema, sb);
#pragma warning restore CS8604 // Possible null reference argument.
               }

               // finally drop the schema itself
               if(P.IsExprtngSchema ?? false)
                  ExportDropSchema(schemaName, sb);
            }
         }
         catch(Exception e)
         {
            var msgs = e.GetAllMessages();
            Log(msgs);
            throw;
         }

         LogL();
         return sb.ToString();
      }

      /// <summary>
      /// PRE: script options already set to drop or create
      /// <param name="exportFilePath">file to export to</param>
      /// </summary>
      public string ExportDropSchema( string schemaName, StringBuilder sb_ )
      {
         LogS();
         StringBuilder sb = new StringBuilder();
         Precondition<ArgumentException>((!string.IsNullOrEmpty(schemaName)) && (schemaName.Length>1), 
            "R02: schema name must not be null and have at least 1 character");

         Schema schema  = Database.Schemas[schemaName];
         Assertion<ArgumentException>(schema!= null, $"R03: Schema {schemaName} does not exist in the database {Database.Name}");
         var transactions = schema.Script(); // this.ScriptOptions
         SerialiseScript(transactions, sb);
         sb_.Append(sb);
         LogL();
         return sb.ToString();
      }

      /// <summary>
      /// To script tables in dependency order (avoiding the issue of a newly created table having a FK referencing 
      /// a non existent primary table)
      /// Get the tables list - i.e. all the tables in Database.Tables
      /// This list is NOT in dependency order
      /// Create a new list from the tables list minus any tables we don't want
      /// Get a walk from this list in dependency order
      /// Script out each table
      /// </summary>
      /// <param name="isStaticData"></param>
      /// <param name="exportFilePath"></param>
      private string ScriptDependencyWalk( string currentSchemaName, bool isStaticData, string exportFilePath )
      {
         LogS();
         var tables = new List<Table>();
         string? script = null;

         try
         {
            foreach(Table table in Database.Tables)
               tables.Add(table);

            script =  ScriptTables( currentSchemaName, tables, exportFilePath);
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
         return script;
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="tables"></param>
      /// <param name="exportFilePath"></param>
      /// <returns></returns>
      private string ScriptTables( string currentSchemaName, List<Table> tables, string exportFilePath )
      {
         LogS();
         var sb = new StringBuilder();
         string script = null;

         try
         { 
            var walk = GetDependencyWalk(tables);

            var options = new ScriptingOptions
            {
               ScriptData = true,
               ScriptDrops = false,
               ScriptSchema = false,//true,
               EnforceScriptingOptions = true,
               Indexes = true,
               IncludeHeaders = false,//true,
               WithDependencies = false, //true
                                         //FileName = exportFilePath,
               NoCommandTerminator = true,
               AppendToFile = true
            };

            foreach(var tableName in walk)
            { 
               Table table = Database.Tables[tableName];

               if(IsWanted(currentSchemaName, table))
                  ScriptTable(tableName, options, sb);
            }

            script = sb.ToString();
            Writer.Write(script);
         }
         catch(Exception e)
         {
            var msgs = e.GetAllMessages();
            Log(msgs);
            throw;
         }

         LogL();
         return script;
      }

      /// <summary>
      /// Script 1 table
      /// </summary>
      /// <param name="tableName"></param>
      /// <param name="options"></param>
      /// <param name="sb"></param>
      string ScriptTable( string tableName, ScriptingOptions options, StringBuilder sb )
      {
         LogS();
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
         LogL();
         return sb.ToString();
      }

      /// <summary>
      /// Add GO statements to for the SQL execution at that point
      /// </summary>
      /// <param name="sb"></param>
      private void ScriptGo( StringBuilder sb )
      {
         ScriptLine(GO, sb);
      }

      /// <summary>
      /// Main entry point to create the "Drop Database Script"
      /// Produces a SQL script to drop the given database, kicking off any users
      /// </summary>
      /// <param name="databaseName"></param>
      /// <returns></returns>
      public string ExportDropDatabaseScript( Params p)
      {
         // PRE: p pop
         LogS();
         Init(p);
         StringBuilder sb = new();
         ExportDropDatabaseScript( sb);
         LogL();
         return sb.ToString();
      }

      public string ExportDropDatabaseScript( StringBuilder sb)
      {
         // PRE: P init
         Precondition<Exception>(IsInitialised, "scripter must be initialised before use");
         var script = $"Drop database [{P.DatabaseName}];";
         ScriptLine(script, sb);
         return script;
      }

      /// <summary>
      /// Main entry point to create the "Create Database Script"
      /// PRE:   p specified
      /// POST:  p.DbOpType unchanged
      /// </summary>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath"></param>
      public string ExportCreateDatabaseScript(Params p)
      {
         LogS();
         StringBuilder sb = new StringBuilder();

         try
         {
            Precondition(p != null, "CreateDatabase(p) pust be specifed");

            p.DbOpType = DbOpTypeEnum.CreateDatabase;
            Init(p);

            StringCollection lines = Database.Script();

            foreach(var line in  lines)
               ScriptLine(line, sb);

            Postcondition(p.DbOpType == DbOpTypeEnum.CreateDatabase, "CreateDatabase(p) p.DbOpType should be DbOpTypeEnum.CreateDatabase");
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
         return sb.ToString();
      }

      /// <summary>
      /// Main entry point to create the "Create Schema Script"
      /// 
      /// </summary>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath"></param>
      public string ScriptSchemaCreateLine( Schema? schema, StringBuilder sb)
      {
         Precondition<ArgumentException>(schema!=null);
         StringBuilder sb_ = new StringBuilder();
         var coll = schema.Script();
         SerialiseScript(coll, sb_);
         sb.Append(sb_);
         return sb_.ToString();
      }

      /// <summary>
      /// Main entry point to create the "Export Static Data Script"
      /// 
      /// </summary>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath"></param>
      protected void ScriptDataExport( Params p)
      {
         LogS();

         try
         {
            Init(p);
            throw new NotImplementedException("ScriptDataExport()");
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
      }

      /// <summary>
      /// Main entry point for Exporting Views
      /// PRE: none
      /// Scripts Create and Drop
      /// </summary>
      public string ExportViews( Params p )
      {
         LogS();
         StringBuilder sb = new StringBuilder();

         try
         {
            Init(p);
         
            foreach(var schemaName in P.RequiredSchemas)
               ExportViews( schemaName, sb );

         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
         return sb.ToString();
      }

      /// <summary>
      /// PRE: Init called
      /// Scripts Create and Drop
      /// </summary>
      public string ExportViews( string currentSchemaName, StringBuilder sb )
      {
         LogS();
         // Local script
         StringBuilder sb_ = new StringBuilder();

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

         LogL();
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
         LogS();
         StringBuilder sb_ = new StringBuilder();

         try
         { 
            //ScriptOption so = ;
            var scriptOptions = new ScriptingOptions(){ ScriptDrops = ScriptOptions.ScriptDrops };//ScriptDrops = true};- works, ScriptForAlter=true does not work
            // Generate script for table, want blan lines between each transaction
            // Don't want blank line for drops
            var script = view.Script(scriptOptions);//ScriptOptions);
            SerialiseScript(script, sb_);
            ExportedViews.Add(view.Name, view.Name);
            sb.Append(sb_);
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }

         LogL();
         return sb_.ToString();
     }



      /// <summary>
      /// Main entry point for exporting tables
      /// Exports all required tables for each required schema
      /// PRE:
      /// 
      /// POST:
      ///    init called
      ///    
      /// </summary>
      /// <param name="sb"></param>
      public string? ExportTables( Params? p )
      {
         LogS();
         StringBuilder sb = new StringBuilder();

         try
         {
            Init(p);

            foreach(var schemaName in P.RequiredSchemas)
               ExportTables( Database.Schemas[schemaName], sb );
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
         return sb.ToString();
      }

      /// <summary>
      /// PRE:
      ///   init called
      ///   
      /// POST:
      /// 
      /// </summary>
      /// <param name="sb"></param>
      public void ExportTables( Schema schema, StringBuilder sb )
      {
         LogS(schema.Name);
         // Save the previous state
         var orig = ShallowClone(Scripter.Options);

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
            ScriptOptions.ScriptForCreateOrAlter   = false;
            ScriptOptions.ScriptSchema             = true;

            if(ScriptOptions.ScriptDrops)
               ExportForeignKeys(schema.Name, sb);

            //Assertion<Exception>(P.Status, "SQL Scripter not initialised");
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
                  ExportTable(table, sb);

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
         finally
         {
            // reset state
            Scripter.Options = ShallowClone(Scripter.Options);
         }

         LogL();
      }

      /// <summary>
      /// Main entry point to export 1 table to the supplied StringBuilder
      /// PRE: table exists
      /// </summary>
      /// <param name="tableName"></param>
      /// <param name="sb"></param>
      public void ExportTable( string? tableName, Params? p, StringBuilder sb)
      {
         LogS();

         try
         {
            Init(p);

            var table = Database.Tables[tableName];
            Assertion(table != null, $"Attempting to Export non existent table: [{tableName}]");
            ExportTable(table, sb);
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
      }


      /// <summary>
      /// Scripts a single table
      /// </summary>
      /// <param name="table"></param>
      /// <param name="sb"></param>
      public void ExportTable( Table? table, StringBuilder sb )
      {
         LogS();
         StringCollection transactions;

         try
         { 
            transactions = table.Script(Scripter.Options);

            if(transactions.Count>0)
               SerialiseScript(transactions, sb);
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

         LogL();
      }

      /// <summary>
      /// Exports the foreign keys
      /// </summary>
      protected void ExportForeignKeys( string currentSchemaName, StringBuilder sb )
      {
         foreach(Table table in Database.Tables)
            ExportForeignKeys( currentSchemaName, table, sb);
      }

      /// <summary>
      /// Exports the FKs for a given table provided it is not a system object
      /// </summary>
      /// <param name="table"></param>
      /// <param name="sb">string builder to populate the serialisation all the table's ForeignKeys as a set of SQL statements</param>
      protected void ExportForeignKeys( string currentSchemaName, Table table, StringBuilder sb )
      {
 
         try
         { 
            // Foreign keys
            foreach(ForeignKey fkey in table.ForeignKeys)
               if(IsWanted( currentSchemaName, fkey))
                  SerialiseScript(fkey.Script(ScriptOptions), sb);
         }
         catch(Exception e)
         {
            var msgs = e.GetAllMessages();
            Log(msgs);
            throw;
         }
      }

      /// <summary>
      /// This is the main entry point for exports Stored procedures and functions without a use statementy
      /// </summary>
      /// <returns>Serialisation of all the user stored procedures as a set of SQL statements</returns>
      protected string ExportDropProceduresScript(Params p)
      {
         Init(p); 
         var sb = new StringBuilder();
         // Set temporary state
         var oldDrops = ScriptOptions.ScriptDrops;
         ScriptOptions.ScriptDrops = true;

         foreach(var schemaName in P.RequiredSchemas)
         {
            //ExportFunctions (schemaName, sb);
            ExportProcedures(schemaName, sb);
         }

         // Reset state
         ScriptOptions.ScriptDrops = oldDrops;

         // Do not keep scripting use database lines unless necessary
         if(ScriptOptions.IncludeDatabaseContext)
            ScriptOptions.IncludeDatabaseContext = false;

         return sb.ToString();
      }

      /// <summary>
      /// PRE: Init called
      /// Database database, Scripter scriptor, StreamWriter writer
      /// PRECONDITION: 
      /// UserDefinedFunctions pop, Options, Create mode set
      /// </summary>
      /// <param name="sb">string builder to populate the serialisation all the user defined functions as a set of SQL statements</param>
      protected void ExportFunctions( string? currentSchemaName, StringBuilder sb)
      {
         try
         { 
            Precondition(ScriptOptions != null, "ExportFunctions() PRECONDION: Options != null");

            Precondition(P.CreateMode  != CreateModeEnum.Undefined   || 
                         P.DbOpType    == DbOpTypeEnum.DropSchema    || 
                         P.DbOpType    == DbOpTypeEnum.DropFunctions, "CreateMode must be defined");

            // Save state
            P.SqlType = SqlTypeEnum.Function;
            var oldWithDependencies  = ScriptOptions.WithDependencies;
            ScriptOptions.WithDependencies = false;  // We want in dependency order

            foreach(UserDefinedFunction function in Database.UserDefinedFunctions)
               if(IsWanted(currentSchemaName, function))
                  ExportFunction(function, sb);

            //If drops then add a blank line at the end
            CloseScript(sb);

            // Reset state
            ScriptOptions.WithDependencies = oldWithDependencies;
         }
         catch(Exception e)
         {
            var msgs = e.GetAllMessages();
            Log(msgs);
            throw;
         }
      }

      protected void ExportFunction( UserDefinedFunction function, StringBuilder sb )
      {
         try
         { 
            SerialiseScript(function.Script(ScriptOptions), sb);
            ExportedFunctions.Add($"{function.Schema}.{function.Name}", $"{function.Schema}.{function.Name}");
         }
         catch(Exception e)
         {
            var msgs = e.GetAllMessages();
            Log(msgs);
            throw;
         }
      }

      /// <summary>
      /// Main entry point for exporting procedures
      /// </summary>
      /// <param name="sb"></param>
      /// <param name="required_schemas"></param>
      protected string ExportProcedures( Params p)
      {
         Init(p);
         StringBuilder sb = new StringBuilder();

         foreach(var schemaName in P.RequiredSchemas)
            ExportProcedures( schemaName, sb);

         return sb.ToString();
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
         StringBuilder sb_ = new StringBuilder();
         LogS();

         try
         { 
            Assertion<ConfigurationException>(Database != null, "ExportProcedures(): Null database");
            Assertion(ScriptOptions != null, "ExportProcedures() PRECONDION: Options != null");

            // Save state
            P.SqlType = SqlTypeEnum.Procedure;
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

         LogL();
         return sb_.ToString();
      }

      protected void ExportProcedure( StoredProcedure proc, StringBuilder sb )
      {
         try
         { 
            LogS($" exporting procedure: {proc.Name}");
            SerialiseScript(proc.Script(ScriptOptions), sb);
            ExportedProcedures.Add($"{proc.Schema}.{proc.Name}", $"{proc.Schema}.{proc.Name}");
            LogL();
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }
      }

      
      /// <summary>
      /// PRE: 
      /// </summary>
      /// <returns>Serialisation of all the user defined types as a set of SQL statements</returns>
      protected string ExportTableTypes( string currentSchemaName, StringBuilder sb )
      {
         LogS();
         StringBuilder sb_ = new StringBuilder();

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
         LogL();
         return sb_.ToString();
      }

      protected void ExportTableType( UserDefinedTableType tbl_ty, StringBuilder sb )
      {
         LogS();
         try
         { 
            SerialiseScript(tbl_ty.Script(ScriptOptions), sb);
         }
         catch(Exception e)
         {
            LogException(e);
            throw;
         }

         LogL();
     }

      /// <summary>
      /// Scripts the line USE database
      ///                  GO
      /// 
      /// Relies on Database being set
      /// </summary>
      protected void ScriptUseDatabaseStatement( StringBuilder sb )
      {
         LogS();

         if(ScriptOptions.IncludeDatabaseContext)
            ScriptUse(sb, true);

         LogL();
      }

      protected void ScriptUse( StringBuilder sb, bool onlyOnce = false )
      {
         ScriptLine($"USE [{Database.Name}]", sb);
         ScriptGo(sb);

         if(onlyOnce)
            ScriptOptions.IncludeDatabaseContext = false;
      }

      private SchemaCollectionBase? GetSchemaCollectionForType( Type type )
      {
         SchemaCollectionBase collection; // SchemaCollectionBase

         switch(type.Name)
         {
         case "UserDefinedTableType": // 
            collection = Database.UserDefinedTableTypes;
            break;

         case "StoredProcedure":     // StoredProcedure
            collection = Database.StoredProcedures;
            break;

         case "Table":               // Tables
            collection = Database.Tables;
            break;

         case "UserDefinedFunction":  // Functions
            collection = Database.UserDefinedFunctions;
            break;

         case "View":  // Functions
            collection = Database.Views;
            break;

         default:
            throw new NotImplementedException();
         }

         Assertion(collection != null);
         return collection;
      }

      /*// <summary>
      /// returns true if table is registered as static data
      /// </summary>
      /// <param name="tableName"></param>
      /// <returns>Returns true if table is part of the static data, false otherwise</returns>
      protected bool IsStaticData(string tableName )
      {
          return StaticDataTables.Contains(tableName);
      }*/

      public List<string> GetDependencyWalk( List<Table> tables )
      {
         var walk = new List<string>();
         string name;
         var dw = new DependencyWalker(Server);
         var smoTables = new SqlSmoObject[tables.Count];

         for(int i = 0; i < tables.Count; i++)
            smoTables[i] = tables[i];

         var tree = dw.DiscoverDependencies(smoTables, DependencyType.Parents);
         var coll = dw.WalkDependencies(tree);

         foreach(DependencyCollectionNode node in coll)
         {
            var ty = node.Urn.Type;

            if(String.Compare(ty, "Table", StringComparison.Ordinal) == 0)
            {
               name = node.Urn.GetAttribute("Name");
               walk.Add(name);
               Debug.WriteLine($"table: {name}");
            }
         }

         return walk;
      }

      /// <summary>
      /// Used to check parameters
      /// </summary>
      /// <param name="o"></param>
      /// <returns></returns>
      private string OptionsToString( ScriptingOptions o )
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
      /// Filters against the  current parameters
      /// </summary>
      /// <returns></returns>
      protected bool IsWanted(string? currentSchemaName, SqlSmoObject obj)
      {
         string? schemaName = null;
         string? name = null;
         string type = obj.GetType().Name;
         Schema? schema = null;

         Precondition<ArgumentException>(obj != null);

         if(obj.Properties.Contains("IsSystemObject"))
         { 
            var property = obj.Properties.GetPropertyObject("IsSystemObject");

            if((bool)(property?.Value  ?? false) == true )
               return false;
         }

         // Schema filter
         if(obj is Schema)
         {
            schema = (obj as Schema);
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

         Assertion(schemaName!= null, $"could not determine schema for {type} {name}");

         // Check is of the current schema
         if(!schemaName.Equals(currentSchemaName, StringComparison.OrdinalIgnoreCase))
            return false;

/*            // check schemas insensitive
         if( P.RequiredSchemas != null && 
            schemaName != null && P.RequiredSchemas.Count > 0 && 
            !P.RequiredSchemas.Contains( schemaName, StringComparer.OrdinalIgnoreCase))
            return false;
*/
         // Handle required types filter
         SqlTypeEnum sqlTy = MapTypeToSqlType(obj);

         if(P.RequiredTypes != null && !P.RequiredTypes.Contains(sqlTy))
            return false;

         return true;
      }

      /// <summary>
      /// Filters against the current IsExprtng type  Flags
      /// </summary>
      /// <returns></returns>
      protected bool IsTypeWanted(string typeName) //, string itemName
      {
         bool ret = false;
         // Schema filter
         switch(typeName.ToUpper())
         {
         case "Data"                : ret = P.IsExprtngData   ?? false; break;
         case "Database"            : ret = P.IsExprtngDb     ?? false; break;
         case "ForeignKey"          : ret = P.IsExprtngFKeys  ?? false; break;
         case "UserDefinedFunction" : ret = P.IsExprtngFns    ?? false; break;
         case "Procedure"           : ret = P.IsExprtngProcs  ?? false; break;
         case "Schema"              : ret = P.IsExprtngSchema ?? false; break;
         case "Table"               : ret = P.IsExprtngTbls   ?? false; break;
         case "UserDefinedTableType": ret = P.IsExprtngTTys   ?? false; break;
         case "View"                : ret = P.IsExprtngVws    ?? false; break;

         default:
            Postcondition(false, $"IsTypeWanted() unexpected type: [{typeName}]"); break;
         }

         return ret;
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
      public static SqlTypeEnum MapTypeToSqlType(SqlSmoObject smo)
      { 
         Precondition(smo != null, $"MapTypeToSqlType: smo parameter must be defined");
         return MapTypeToSqlType(smo.GetType().Name);
      }

      public static SqlTypeEnum MapTypeToSqlType(string typeName)
      { 
         SqlTypeEnum sty;

         switch(typeName)
         {
            case "Database"            : sty = SqlTypeEnum.Database;  break;
            case "ForeignKey"          : sty = SqlTypeEnum.FKey;      break;
            case "UserDefinedFunction" : sty = SqlTypeEnum.Function;  break;
            case "StoredProcedure"     : sty = SqlTypeEnum.Procedure; break;
            case "Schema"              : sty = SqlTypeEnum.Schema;    break;
            case "Table"               : sty = SqlTypeEnum.Table;     break;
            case "View"                : sty = SqlTypeEnum.View;      break;
            case "UserDefinedTableType": sty = SqlTypeEnum.TableType; break;

            default                    : sty = SqlTypeEnum.Undefined; break;
         }

         if(sty == SqlTypeEnum.Undefined) Postcondition<ArgumentException>(sty != SqlTypeEnum.Undefined, $"MapTypeToSqlType failed for {typeName}");

         return sty;
      }

      #endregion private methods
   }
}
