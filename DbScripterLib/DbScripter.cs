
#nullable enable
#pragma warning disable CS8602

using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using RSS;
using static RSS.Common.Utils;
using static RSS.Common.Logger;
using System.Collections.Specialized;
using RSS.Test;
using RSS.Common;

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
      #region IDbScripter Impl
      /// <summary>
      /// Description: Main Export entry point
      /// 
      /// PRE: the following export parameters must be defined:
      /// PRE 1: the params struct must not be null
      /// PRE 2: Sql Type
      /// PRE 3: Create   Mode
      /// PRE 4: Server   Name
      /// PRE 5: Instance Name
      /// 
      /// POST: Export completed
      /// 
      /// </summary>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath"></param>
      /// <param name="staticDataTables">can configure the static data tables now</param>
      /// <returns></returns>
      public string? Export( Params p)
      {
         LogS();
         // hndl in init Precondition<ArgumentException>((p.SqlType ?? SqlTypeEnum.Undefined) != SqlTypeEnum.Undefined,"the main export SqlType must be defined");

         string? script = null;
         Init(p);

         try
         {
            // switch on the top level export type
            // exporting schema will NOT also export its children
            // All export routines must check the validity of the parmaeter state first
            switch(p.SqlType)
            {
            case SqlTypeEnum.Schema    : script = ExportSchemas();   break;
            case SqlTypeEnum.Database  : script = ExportDatabase();  break;
            case SqlTypeEnum.Function  : script = ExportFunctions(); break;
            case SqlTypeEnum.Procedure : script = ExportProcedures();break;
            case SqlTypeEnum.Table     : script = ExportTables();    break;
          //case SqlTypeEnum.TableType : script = ExportTableTypes();break;
          //case SqlTypeEnum.View      : script = Views();           break;
            case SqlTypeEnum.Undefined: AssertFail<ArgumentException>("SqlType must be defined")  ; break;
            default: AssertFail<NotImplementedException>($"{p.SqlType.GetAlias()} notimplemented"); break;
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

      public virtual string GetTimestamp()
      { 
         return DateTime.Now.ToString("yyMMdd-HHmm");
      }

      public DbScripter(Params? p = null)
      {
         Init(p);
      }

      #endregion IDbScripter Impl
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
      /// Initialize state, deletes the writerFilePath file if it exists
      /// Only completes the initialisation if the parameters are all specified
      /// 
      /// PRECONDITIONS: none
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
      ///   
      /// </summary>
      /// <param name="serverName">DESKTOP-UAULS0U\SQLEXPRESS</param>
      /// <param name="instanceName">like SQLEXPRESS</param>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath">like C:\tmp\Covid_T1_export.sql</param>
      protected void Init( Params? p, bool append = false)
      {
         LogS(p?.ToString() ?? "Params not defined");
         string? msg = "";

         if(p != null)
         { 
            // ---------------------------------------------------------------
            // Validate preconditions
            // ---------------------------------------------------------------
            // PRE: the following export parameters must be defined:
            // PRE 1: the params struct must not be null
            // PRE 2: Sql Type
            // PRE 3: Create   Mode
            // PRE 4: Server   Name
            // PRE 5: Instance Name
            var defMsg = "must be specified";
            Precondition<ArgumentException>(p != null, $"Params arg {defMsg}");                                                              // PRE 1
            Precondition<ArgumentException>((p.SqlType    ?? SqlTypeEnum   .Undefined) != SqlTypeEnum   .Undefined, $"SqlType {defMsg}");    // PRE 2
            Precondition<ArgumentException>((p.CreateMode ?? CreateModeEnum.Undefined) != CreateModeEnum.Undefined, $"CreateMode {defMsg}"); // PRE 3
            Precondition<ArgumentException>(!string.IsNullOrEmpty(p.ServerName  ), $"server {defMsg}");                                      // PRE 4
            Precondition<ArgumentException>(!string.IsNullOrEmpty(p.InstanceName), $"instance {defMsg}");                                    // PRE 5

            // -----------------------------------------
            // ASSERTION: preconditions va;idated
            // -----------------------------------------

            // First clear all
            if(!append)
               ClearState();

            P.PopFrom(p);      // 1: Initialise the initial state

            //   2: server and makes a connection, throws exception otherwise
            InitServer(P.ServerName, P.InstanceName);
            InitDatabase(P.DatabaseName);
            InitScriptingOptions();

            // InitWriter calls IsValid() - returns the Validation status - 
            // NOTE: can continue if not all initialised so long as the final init is performed before any write op
            // PRE:  P pop with export path
            // POST: Writer open
            InitWriter();
            IsInitialised = true;
         }

         // POSTCONDITION CHECKS:
         // 1: EITHER: 
         // ( 
         //    IsInitialised is true 
         //    AND (
         //       1.1: Initialises the initial state
         //       1.2: server and makes a connection, throws exception otherwise
         //       1.3: database connected
         //       1.4: sets the scripter options configuration based on optype
         //       1.5. sets the IsInitialised flag
         //       1.6: writer open
         //       1.7: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         //    )
         // )
         // OR
         // 2: IsInitialised is false
         Postcondition((IsInitialised==false) || P.IsValid(out msg) , msg);
         // OR 2: clears the IsInitialised flag

         LogL();
      }

      /// <summary>
      /// Initializes server connection - default database: databaseName.
      /// This will fail if the server is not online or cannot be connected to.
      /// 
      /// PRECONDITIONS:
      ///   serverName not null
      ///   instanceName not null
      ///   
      /// POSTCONDITIONS:
      ///  POST 1: Server smo object created and connected
      ///  POST 2: the server is online
      ///  
      /// </summary>
      /// <param name="serverName"></param>
      /// <param name="instanceName"></param>
      protected void InitServer( string? serverName, string? instanceName)
      {
         LogS();

         try
         {
            // -------------------------
            // Validate preconditions
            // -------------------------

            Precondition<ArgumentException>(!string.IsNullOrEmpty(serverName)  , "Server not specified");
            Precondition<ArgumentException>(!string.IsNullOrEmpty(instanceName), "Instance not specified");

            // -----------------------------------------
            // ASSERTION: preconditions validated
            // -----------------------------------------

            Server  = CreateAndOpenServer( serverName, instanceName);
            var ver = Server.Information.Version;

            // Set the default loaded fields to include IsSystemObject
            Server.SetDefaultInitFields(typeof(Table),              "IsSystemObject");
	         Server.SetDefaultInitFields(typeof(StoredProcedure),    "IsSystemObject");
	         Server.SetDefaultInitFields(typeof(UserDefinedFunction),"IsSystemObject","FunctionType");
	         Server.SetDefaultInitFields(typeof(View),               "IsSystemObject");

            // -------------------------
            // Validate postconditions
            // -------------------------

            //  POST 1: Server smo object created
            //  POST 2: the server is online and connected
            Postcondition(Server != null,                         "Could not create Server smo object");
            Postcondition(Server.Status == ServerStatus.Online,   "Could not connect to Server");

            // -----------------------------------------
            // ASSERTION: postconditions validated
            // -----------------------------------------
         }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
      }

      /// <summary>
      /// PRECONDITIONS:
      /// PRE 1:  server        instantiated
      /// PRE 2:  database name specified
      ///
      ///
      /// POSTCONDITIONS:
      /// POST 1: database smo is instantiated and connected
      /// POST 2: database state is normal
      /// POST 3: schemas exist in database smo
      /// </summary>
      /// <param name="databaseName"></param>
      protected void InitDatabase(string? databaseName)
      { 
         LogS();

         try
         {
            // -------------------------
            // Validate preconditions
            // -------------------------

            Precondition<ArgumentException>(Server != null                     , "server not instantiated");      // PRE 1
            Precondition<ArgumentException>(!string.IsNullOrEmpty(databaseName), "database name not specified");  // PRE 2

            // -----------------------------------------
            // ASSERTION: preconditions validated
            // -----------------------------------------

            var databases = Server.Databases;

            if(!databases.Contains(databaseName))
               Server.Refresh();

            // ASSERTION: if here then database exists

            if(databases.Contains(databaseName))
               Database = Server.Databases[databaseName];
            else
               Database = new Database(Server, databaseName);

            // -------------------------
            // Validate postconditions
            // -------------------------

            /// POST: Database     instantiated and connected
            Postcondition(Database        != null                 , $"database {databaseName} smo object not created"); // POST 1
            Postcondition(Database.Status == DatabaseStatus.Normal, $"database {databaseName} state is not normal");    // POST 2
            Assertion<ConfigurationException>(Database.Schemas.Count > 0, $"database {databaseName} smo object not connected or no schemas exist"); // POST 3
 
            // -----------------------------------------
            // ASSERTION: postconditions validated
            // -----------------------------------------
        }
         catch(Exception e)
         { 
            LogException(e);
            throw;
         }

         LogL();
     }


      /// <summary>
      /// Sets up the general scripter options
      /// 
      /// PRECONDITIONS:
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
      protected void InitScriptingOptions()
      {
         LogS();
         // -------------------------
         // Validate preconditions
         // -------------------------
         Precondition<ArgumentException>(P.IsValid(out string? msg), msg); // PRE 1

         // -----------------------------------------
         // ASSERTION: preconditions validated
         // -----------------------------------------

         Scripter = new Scripter(Server);

         var noGoflag = (P.CreateMode == CreateModeEnum.Create) || (P.CreateMode == CreateModeEnum.Alter);

         ScriptOptions = new ScriptingOptions()
         {
            AllowSystemObjects      = false,
            AnsiFile                = true,
            AnsiPadding             = false,
            AppendToFile            = true,     // needed if we use script builder repetitively
            Bindings                = false,
            ContinueScriptingOnError= false,
            ConvertUserDefinedDataTypesToBaseType = false,
            DriAll                  = true,
            ExtendedProperties      = true,
            IncludeDatabaseContext  = P?.ScriptUseDb ?? false, // only if required
            IncludeHeaders          = false,
            IncludeIfNotExists      = false,
            Indexes                 = true,
            NoCollation             = true,
            NoCommandTerminator     = noGoflag, // true means don't emit GO statements after every SQLstatement
            NoIdentities            = true,
            NonClusteredIndexes     = true,
            Permissions             = false,
            SchemaQualify           = true,     //  e.g. [dbo].sp_bla
            SchemaQualifyForeignKeysReferences = true,
            ScriptBatchTerminator   = false,
            ScriptData              = P.IsExprtngData    ?? false,
            ScriptDrops             = (P.CreateMode == CreateModeEnum.Drop),
            ScriptForAlter          = (P.CreateMode == CreateModeEnum.Alter),
            ScriptSchema            = P.IsExprtngSchema  ?? false,
            WithDependencies        = false,    // issue here: dont set true: Smo.FailedOperationException true, Unable to cast object of type 'System.DBNull' to type 'System.String'.
            ClusteredIndexes        = true,
            FullTextIndexes         = true,
            EnforceScriptingOptions = true,
         };


         // Ensure either emit schema or data, if not specified then emit schema
         if((!ScriptOptions.ScriptSchema) && (!ScriptOptions.ScriptData))
            ScriptOptions.ScriptSchema = true;

         // -------------------------
         // Validate postconditions
         // -------------------------
         Postcondition((P.SqlType == SqlTypeEnum.Table && P.CreateMode != CreateModeEnum.Alter) || ((P.SqlType != SqlTypeEnum.Table)), "if exporting tables dont specify alter");//  POST 1: 
         //  POST 2: ensure either emit schema or data, if not specified then emit schema
         Postcondition((ScriptOptions.ScriptSchema || ScriptOptions.ScriptData));

         // -----------------------------------------
         // ASSERTION: postconditions validated
         // -----------------------------------------
         Scripter.Options = ScriptOptions;

         LogL( OptionsToString(Scripter.Options));
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
         //LogS();
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
         //LogL();
      }

      /*// <summary>
      /// Exports all stored procedures and functions
      /// Initialises the major scripting elements
      /// </summary>
      /// <returns>Serialisation of all the user functions and user stored procedures as a set of SQL statements</returns>
      protected string ExportRoutines( Params? p)
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
*/

      /*// <summary>
      /// Exports all stored procedures and functions
      /// Initialises the major scripting elements
      /// 
      /// PRE:  Initialised
      /// POST: Sps and fns exported for the given schema
      /// </summary>
      /// <returns>Serialisation of all the user functions and user stored procedures as a set of SQL statements</returns>
      protected string ExportRoutines( string? currentSchemaName, StringBuilder sb)
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
*/

      #endregion public methods
      #region private methods

      /// <summary>
      /// Validates the initialization
      /// PRECONDITIONS: 
      ///   P config pop
      /// </summary>
      /// <returns></returns>
      protected bool IsValid(out string? msg)
      {
        msg = null;
        var ret = false;

         do
         {
            if(!P.IsValid(out msg))
              break;

            string x = (((FileStream)Writer.BaseStream)?.Name ?? "not defined");

            // ((FileStream)(Writer.BaseStream)).Name.Equals(P.ExportScriptPath, StringComparison.OrdinalIgnoreCase)	D:\Dev\Repos\DbScripter\DbScripterLib\DbScripter.cs	493	37	DbScripterLib	Read	InitWriter	DbScripter	
            if(!x.Equals(P?.ExportScriptPath ?? "xxx", StringComparison.OrdinalIgnoreCase))
            {
               msg = "Writer not initialised properly";
               break;
            }

            // Lastly if here then all checks have passed
            ret = true;
         } while(false);

         return ret;
      }

      /*// <summary>
      /// Maps the dbOpType to the corresponding sql obect type
      /// that the dbOpType works on
      /// 
      /// POSTCONDITIONS:
      /// 1: dbOpType is successfully mapped and returned
      /// 2: can return SqlTypeEnum.Undefined
      /// </summary>
      /// <param name="dbOpType"></param>
      /// <returns></returns>
      SqlTypeEnum MapDbOpTypeToSqlType( DbOpTypeEnum dbOpType )
      {
         //if(dbOpType == DbOpTypeEnum.Undefined)
         //   Assertion(dbOpType != DbOpTypeEnum.Undefined, $"Unhandled optype: {dbOpType}");
 
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

         //if(sqlType == SqlTypeEnum.Undefined)
         //   Assertion(sqlType != SqlTypeEnum.Undefined, $"Unhandled optype: {dbOpType}");

         return sqlType;
      }
      */


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
      protected static SqlTypeEnum MapTypeToSqlType(SqlSmoObject smo)
      { 
         Precondition(smo != null, $"MapTypeToSqlType: smo parameter must be defined");
         return MapTypeToSqlType(smo.GetType().Name);
      }

      protected  static SqlTypeEnum MapTypeToSqlType(string typeName)
      { 
         SqlTypeEnum sty;

         switch(typeName)
         {
            case "Database"            : sty = SqlTypeEnum.Database;  break;
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


      /*public static CreateModeEnum MapTypeToCreateMode(DbOpTypeEnum dbOptype)
      { 
         CreateModeEnum e;

         switch(dbOptype)
         {
            case DbOpTypeEnum.DropDatabase:        e = CreateModeEnum.Drop;      break;
            case DbOpTypeEnum.DropSchema:          e = CreateModeEnum.Drop;      break;
            case DbOpTypeEnum.DropFunctions:       e = CreateModeEnum.Drop;      break;
            case DbOpTypeEnum.DropProcedures:      e = CreateModeEnum.Drop;      break;
            case DbOpTypeEnum.DropTables:          e = CreateModeEnum.Drop;      break;
            case DbOpTypeEnum.DropViews:           e = CreateModeEnum.Drop;      break;
            case DbOpTypeEnum.DropStaticData:      e = CreateModeEnum.Drop;      break;
            case DbOpTypeEnum.CreateDatabase:      e = CreateModeEnum.Create;    break;
            case DbOpTypeEnum.CreateSchema:        e = CreateModeEnum.Create;    break;
            case DbOpTypeEnum.CreateTables:        e = CreateModeEnum.Create;    break;
            case DbOpTypeEnum.CreateFunctions:     e = CreateModeEnum.Create;    break;
            case DbOpTypeEnum.CreateProcedures:    e = CreateModeEnum.Create;    break;
            case DbOpTypeEnum.CreateStaticData:    e = CreateModeEnum.Create;    break;
            case DbOpTypeEnum.ExportStaticData:    e = CreateModeEnum.Create;    break;
            case DbOpTypeEnum.ExportDynamicData:   e = CreateModeEnum.Create;    break;
            case DbOpTypeEnum.Undefined:           e = CreateModeEnum.Undefined; break;
            default:                               e = CreateModeEnum.Undefined; break;
         }

         if(e == CreateModeEnum.Undefined) Postcondition<ArgumentException>(e != CreateModeEnum.Undefined, $"MapTypeToSqlType failed for DbOpType {dbOptype.GetAlias()}");

         return e;
      }*/
      /*// <summary>
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
      }*/

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
      /// PRE: Init called
      /// </summary>
      /// <returns></returns>
      private bool WantBlankLineBetweenTransactions()
      {
         return (P.CreateMode != CreateModeEnum.Drop);//!IsDropOperation(dbOpType);
      }

      /*// <summary>
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
      }*/

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
      /// PRE:  NONE
      /// POST: all UNDEFINED flags set true
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
      /// 
      /// PRE: Init called
      /// 
      /// POST: 
      /// 
      /// </summary>
      public string ExportSchemas()
      {
         LogS();
         var sb = new StringBuilder(); 

         try
         {
            //if((p.DbOpType ?? DbOpTypeEnum.Undefined) != DbOpTypeEnum.CreateSchema)            //   p.DbOpType = DbOpTypeEnum.CreateSchema;            //Init(p);

            // Specialise the Options config for this op
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
      /// This will script the given schema in the specified create mode
      /// N.B.: Does NOTl export the child types: Tables, views, sps, fns ...
      /// 
      /// Pre: all initialisation done
      /// 
      /// PRE: Init called
      ///      P.IsExprtngSchema is true
      ///      
      /// POST: single line like CREATE Schema [schema name]; emiited
      /// 
      /// </summary>
      public string ExportSchema(Schema schema, StringBuilder sb)
      {
         LogS($"schema: {schema.Name}");
         Precondition<ArgumentException>((P.IsExprtngSchema ?? false) == true, "Inconsistent state P.IsExprtngSchema is not true");
         var sb_ = new StringBuilder(); 

         try
         {
            ScriptingOptions so = new ScriptingOptions();
            so.ScriptDrops = (P.CreateMode == CreateModeEnum.Drop);
            var coll = schema.Script();
            SerialiseScript(coll, sb_);
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
         Precondition(ScriptOptions != null, "ScriptOptions undefined");
         SetUndefinedExportSchemaFlags();

         EnsureRequiredTypesContainsType(SqlTypeEnum.Schema);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Table);
         EnsureRequiredTypesContainsType(SqlTypeEnum.View);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Procedure);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Function);
         EnsureRequiredTypesContainsType(SqlTypeEnum.TableType);
//       EnsureRequiredTypesContainsType(SqlTypeEnum.FKey);
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
         string? script = null;

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

      /*// <summary>
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
      }*/

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
      public string ExportDatabase( )
      {
         LogS();
         Precondition(Database != null, "database must be instantiated");
         StringBuilder sb = new StringBuilder();
         
         return ExportDatabase( Database, sb);
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
      public string ExportDatabase( Database db, StringBuilder sb)
      {
         LogS();
         // PRE: P init
         StringBuilder sb_ = new StringBuilder();
         Precondition<Exception>(IsInitialised, "scripter must be initialised before use");
         var script = db.Script(ScriptOptions);
         SerialiseScript(script, sb_);
         sb.Append(sb_);
         return sb_.ToString();
      }

      /*// <summary>
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
      */

      /*// <summary>
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
      }*/

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

         //LogL();
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
      ///   Initialised
      /// 
      /// POST:
      ///    init called
      ///    
      /// </summary>
      /// <param name="sb"></param>
      public string? ExportTables()
      {
         LogS();
         Precondition(IsValid(out string? msg), msg);
         StringBuilder     sb = new StringBuilder();
         ScriptingOptions? so = InitTableExport();

         try
         {
            foreach(var schemaName in P.RequiredSchemas)
               ExportTables( Database.Schemas[schemaName], so, sb );
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
      protected ScriptingOptions InitTableExport()
      { 
         // -------------------------
         // Validate preconditions
         // -------------------------
         //  PRE 1: Scriptor Initialised
         Precondition(IsValid(out string? msg), "Scriptor must be initised first" + msg);

         // -----------------------------------------
         // ASSERTION: preconditions validated
         // -----------------------------------------

         var so   = ShallowClone(ScriptOptions);
         var orig = ShallowClone(ScriptOptions);
         so.ScriptForAlter          = false;
         so.ScriptForCreateOrAlter  = false;

         // -------------------------
         // Validate postconditions
         // -------------------------
         // POST 1: returned config so will support table export 
         //          and its script for alter flags are cleared
         Postcondition(!(so.ScriptForAlter || so.ScriptForCreateOrAlter), "POST 1 failed");

         //  POST 2: the original config is not changed
         if(!OptionEquals(ScriptOptions, orig, out msg))
         {
            Log("was\r\n",     OptionsToString(orig));
            Log("\r\nnow\r\n", OptionsToString(ScriptOptions));
            var resultsDir = TestHelper.ResultsDir;
            var exp_file   = @$"{resultsDir}\InitTableExport_exp.txt";
            var act_file   = @$"{resultsDir}\InitTableExport_act.txt";
            File.WriteAllText(exp_file, OptionsToString(orig));  
            File.WriteAllText(act_file, $"{OptionsToString(ScriptOptions)}\r\nfirst diff field : {msg}");
            // display a BeyondCompare session for exp/act with unique file names
            Process.Start( "BCompare.exe", $"{act_file} {exp_file}");

            // Fail the op
         }

         // -----------------------------------------
         // ASSERTION: postconditions validated
         // -----------------------------------------
         return so;
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
      public void ExportTables( Schema? schema, ScriptingOptions so, StringBuilder sb )
      {
         LogS(schema.Name);

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
            ScriptingOptions? so = ShallowClone(ScriptOptions);

            var table = Database.Tables[tableName];
            Assertion(table != null, $"Attempting to Export non existent table: [{tableName}]");
            ExportTable(table, so, sb);
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
      /// 
      /// PRECONDITIONS: 
      /// PRE 1: table exists
      /// PRE 2: this.IsValid() == true
      /// PRE 3: so initalised correctly
      /// </summary>
      /// <param name="table"></param>
      /// <param name="sb"></param>
      public void ExportTable( Table? table, ScriptingOptions so, StringBuilder sb )
      {
         LogS();
         // PRE 1: table exists
         Precondition(table != null);
         // PRE 2: this.IsValid() == true
         Precondition(IsValid(out string? msg), msg);
         StringCollection transactions;

         try
         { 
            transactions = table.Script(so);

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
      /// exports all procedures from all required schemas
      /// PRECONDITION: 
      /// Is valid
      /// 
      /// POSTCONDITIONS:
      ///  POST 1: all procedures from all required schemas exported
      /// 
      /// CALLED BY: Export()
      /// </summary>
      protected string ExportProcedures()
      { 
         Precondition(IsValid(out string? msg), msg);// PRE: Init called
         var sb = new StringBuilder();

         foreach(string schemaName in P.RequiredSchemas)
            ExportProcedures(schemaName, sb);

         return sb.ToString();
      }


      /// <summary>
      /// exports all functions from all required schemas
      /// PRECONDITION: 
      /// Is valid
      /// 
      /// POSTCONDITIONS:
      ///  POST 1: all functions from all required schemas exported
      /// 
      /// CALLED BY: Export()
      /// </summary>
      protected string ExportFunctions()
      {
         Precondition(IsValid(out string? msg), msg);// PRE: Init called
         var sb = new StringBuilder();

         foreach(string schemaName in P.RequiredSchemas)
            ExportFunctions(schemaName, sb);

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
            Precondition(IsValid(out string? msg), $"{msg}");

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

      /*// <summary>
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
      }*/

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
      /// Used to check parameters
      /// </summary>
      /// <param name="o"></param>
      /// <returns></returns>
      private bool OptionEquals( ScriptingOptions a, ScriptingOptions b, out string msg)
      {
         var sb = new StringBuilder();
         bool ret = false;

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

      #endregion protected methods
      #region private fields

      private const string GO = "GO";

      #endregion private fields
   }
}

      /*// <summary>
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
*/
