
#nullable enable
#pragma warning disable CS8602

using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Collections.Specialized;
using RSS.Test;
using RSS.Common;
using Microsoft.SqlServer.Management.Sdk.Sfc;
using RSS.UtilsNS;
using static RSS.Common.Logger;
using static RSS.Common.Utils;
using System.Text.RegularExpressions;

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
      public string? Export( ref Params p)
      {
         Logger.LogS();

         string? script = null;
         StringBuilder sb = Init(p);

         try
         {
            // switch on the top level export type
            // exporting schema will NOT also export its children
            // All export routines must check the validity of the parmaeter state first
            switch(p.RootType)
            {
            case SqlTypeEnum.Schema    : script = ExportSchemas   (sb); break;
            case SqlTypeEnum.Database  : script = ExportDatabase  (sb); break;
            case SqlTypeEnum.Function  : script = ExportFunctions (sb); break;
            case SqlTypeEnum.Procedure : script = ExportProcedures(sb); break;
            case SqlTypeEnum.Table     : script = ExportTables    (sb); break;
          //case SqlTypeEnum.TableType : script = ExportTableTypes(sb); break;
          //case SqlTypeEnum.View      : script = ExportViews     (sb); break;
            case SqlTypeEnum.Undefined:  Utils.AssertFail<ArgumentException>("RootType must be defined")  ; break;
            default:  Utils.AssertFail<NotImplementedException>($"{p.RootType.GetAlias()} notimplemented"); break;
            }
         
            sb.Clear();
            // sb will have a counts summary of teh exported lists
            LogResults(sb);

            // Write results summary to file
            ScriptLine($"/*\r\n{sb.ToString()}\r\n*/");

            // Return updated parameters to the client
            p.CopyFrom(P);
         }
         catch(Exception e)
         {
            Logger.LogException(e);
            throw;
         }
         finally
         {
            Writer?.Close();
         }

         Logger.LogL();
         return script;
      }

      public virtual string GetTimestamp()
      { 
         return DateTime.Now.ToString("yyMMdd-HHmm");
      }

      public DbScripter(Params? p = null)
      {
         Logger.LogS();
         Init(p);
      }

      #endregion IDbScripter Impl
      #region    properties
      #region    primary properties

      // Primary properties
      // are set by the constructor
      public Params P {get;set; } = new Params();
      public static string DefaultLogFile {get; protected set;} = @"D:\Logs\DbScripter.log";
      public static string DefaultScriptDir {get; protected set;} = @"D:\Dev\Repos\C#\Db\Scripts";
      public string ScriptFile{get; protected set;} = "";
      

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
      #region    minor scripting properties

      private int _exportedItemCnt = 0;
      private int _scripted_cnt    = 0;
      #endregion minor scripting properties
      #region scripter info cache

      // These properties are info caches for the scripted items
      public SortedList<string, string> ExportedDatbases       { get; protected set; } = new ();
      public SortedList<string, string> ExportedSchemas        { get; protected set; } = new ();
      public SortedList<string, string> ExportedTables         { get; protected set; } = new ();
      public SortedList<string, string> ExportedProcedures     { get; protected set; } = new ();
      public SortedList<string, string> ExportedFunctions      { get; protected set; } = new ();
      public SortedList<string, string> ExportedViews          { get; protected set; } = new ();
      public SortedList<string, string> ExportedTableTypes     { get; protected set; } = new ();

      // dependency eval
      public SortedList<string, string> WantedItems            { get; protected set; } = new();
      public SortedList<string, string> ConsisideredEntities   { get; protected set; } = new ();
      public SortedList<string, string> DifferentDatabases     { get; protected set; } = new();
      public SortedList<string, string> DuplicateDependencies  { get; protected set; } = new();
      public SortedList<string, string> SystemObjects          { get; protected set; } = new();
      public SortedList<string, string> UnresolvedEntities     { get; protected set; } = new();
      public SortedList<string, string> UnwantedSchemas        { get; protected set; } = new();
      public SortedList<string, string> UnwantedTypes          { get; protected set; } = new();
      #endregion scripter info cache

      #endregion properties
      #region    public methods

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
      ///   
      /// </summary>
      /// <param name="serverName">DESKTOP-UAULS0U\SQLEXPRESS</param>
      /// <param name="instanceName">like SQLEXPRESS</param>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath">like C:\tmp\Covid_T1_export.sql</param>
      protected StringBuilder Init( Params? p, bool append = false)
      {
         Logger.LogS();
         string? msg = "";
         StringBuilder sb = new();

         if(p != null)
         { 
            // ---------------------------------------------------------------
            // Validate Utils.Preconditions
            // ---------------------------------------------------------------
            // PRE: the following export parameters must be defined:
            // PRE 1: the params struct must not be null
            // PRE 2: Sql Type
            // PRE 3: Create   Mode
            // PRE 4: Server   Name
            // PRE 5: Instance Name
            var defMsg = "must be specified";
            Utils.Precondition<ArgumentException>(p != null, $"Params arg {defMsg}");                                                              // PRE 1
            Utils.Precondition<ArgumentException>((p.RootType    ?? SqlTypeEnum   .Undefined) != SqlTypeEnum   .Undefined, $"RootType {defMsg}");    // PRE 2
            Utils.Precondition<ArgumentException>((p.CreateMode ?? CreateModeEnum.Undefined) != CreateModeEnum.Undefined, $"CreateMode {defMsg}"); // PRE 3
            Utils.Precondition<ArgumentException>(!string.IsNullOrEmpty(p.ServerName  ), $"server {defMsg}");                                      // PRE 4
            Utils.Precondition<ArgumentException>(!string.IsNullOrEmpty(p.InstanceName), $"instance {defMsg}");                                    // PRE 5

            // -----------------------------------------
            // ASSERTION: Utils.Preconditions validated
            // -----------------------------------------

            // First clear all
            if(!append)
               ClearState();


            P.PopFrom(p);      // 1: Initialise the initial state, SqlTypeEnum.Undefined will cause exception
            Normalise(P);
            P.TargetChildTypes = CorrectRequiredTypes(P.RootType ?? SqlTypeEnum.Undefined, P.CreateMode ?? CreateModeEnum.Undefined, P.TargetChildTypes);

            // Defaults:
            if(string.IsNullOrEmpty(P.LogFile))
               P.LogFile = GetLogFileFromConfig();

            if(string.IsNullOrEmpty(P.ExportScriptPath))
               P.ExportScriptPath = @$"{GetScriptDirFromConfig()}\{P.DatabaseName}_{GetTimestamp()}.sql";

            // Add timespamp if required
            if(P.AddTimestamp ?? false)
            { 
               // change <path><fiemname>.<ext> to <path><fiemname>_<ts>.<ext>
               var x = P.ExportScriptPath;
               var tmp = $@"{Path.GetDirectoryName(x)}\{Path.GetFileNameWithoutExtension(x)}_{GetTimestamp()}{Path.GetExtension(x)}";
               P.ExportScriptPath = tmp;
            }

            //   2: server and makes a connection, throws exception otherwise
            InitServer(P.ServerName, P.InstanceName);
            InitDatabase(P.DatabaseName);
            InitScriptingOptions();

            // InitWriter calls IsValid() - returns the Validation status - 
            // NOTE: can continue if not all initialised so long as the final init is performed before any write op
            // PRE:  P pop with export path
            // POST: Writer open
            InitWriter();
            ScriptLine($"/*\r\n\r\nLog    file {Logger.LogFile}\r\n", sb);
            ScriptLine($"\r\n\r\nScript file {ScriptFile}\r\n", sb);
            ScriptLine($"\r\nParameters:", sb);
            ScriptLine($"{P}*/\r\n\r\n", sb);

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
         Utils.Postcondition((IsInitialised==false) || P.IsValid(out msg) , msg);
         // OR 2: clears the IsInitialised flag
         Logger.LogL();
         return sb;
      }

      /// <summary>
      /// Description:
      /// Makes params secondary state consistent 
      /// with the primary (user set) state
      /// especially the IsExporting flags
      /// Based on the Root type
      /// 
      /// NB: if the value is already set then it is not altered
      ///     this only updates the undefiend (null( state
      /// </summary>
      /// <param name="p"></param>
      protected static void Normalise( Params p)
      {
         LogS();

         switch(p.RootType)
         {
          case SqlTypeEnum.Database:
            p.IsExprtngDb     ??= true;
            p.IsExprtngSchema ??= false;
            p.IsExprtngProcs  ??= false;
            p.IsExprtngFns    ??= false;
            p.IsExprtngVws    ??= false;
            p.IsExprtngTbls   ??= false;
            p.IsExprtngTTys   ??= false;
            p.IsExprtngFKeys  ??= false;
            p.IsExprtngData   ??= false;
            break;

        case SqlTypeEnum.Schema:
            p.IsExprtngDb     ??= false;
            p.IsExprtngSchema ??= true;
            p.IsExprtngProcs  ??= true;
            p.IsExprtngFns    ??= true;
            p.IsExprtngVws    ??= true;
            p.IsExprtngTbls   ??= false;
            p.IsExprtngTTys   ??= false;
            p.IsExprtngFKeys  ??= false;
            p.IsExprtngData   ??= false;
            break;

         case SqlTypeEnum.Procedure:
            p.IsExprtngDb     ??= false;
            p.IsExprtngSchema ??= false;
            p.IsExprtngProcs  ??= true;
            p.IsExprtngFns    ??= false;
            p.IsExprtngVws    ??= false;
            p.IsExprtngTbls   ??= false;
            p.IsExprtngTTys   ??= false;
            p.IsExprtngFKeys  ??= false;
            p.IsExprtngData   ??= false;
            break;

         case SqlTypeEnum.Function:
            p.IsExprtngDb     ??= false;
            p.IsExprtngSchema ??= false;
            p.IsExprtngProcs  ??= false;
            p.IsExprtngFns    ??= true;
            p.IsExprtngVws    ??= false;
            p.IsExprtngTbls   ??= false;
            p.IsExprtngTTys   ??= false;
            p.IsExprtngFKeys  ??= false;
            p.IsExprtngData   ??= false;
            break;

         case SqlTypeEnum.View:
            p.IsExprtngDb     ??= false;
            p.IsExprtngSchema ??= false;
            p.IsExprtngProcs  ??= false;
            p.IsExprtngFns    ??= false;
            p.IsExprtngVws    ??= true;
            p.IsExprtngTbls   ??= false;
            p.IsExprtngTTys   ??= false;
            p.IsExprtngFKeys  ??= false;
            p.IsExprtngData   ??= false;
            break;

         case SqlTypeEnum.Table:
            p.IsExprtngDb     ??= false;
            p.IsExprtngSchema ??= false;
            p.IsExprtngProcs  ??= false;
            p.IsExprtngFns    ??= false;
            p.IsExprtngVws    ??= false;
            p.IsExprtngTbls   ??= true;
            p.IsExprtngTTys   ??= false;
            p.IsExprtngFKeys  ??= true;
            p.IsExprtngData   ??= false;
            break;

         case SqlTypeEnum.TableType:
            p.IsExprtngDb     ??= false;
            p.IsExprtngSchema ??= false;
            p.IsExprtngProcs  ??= false;
            p.IsExprtngFns    ??= false;
            p.IsExprtngVws    ??= false;
            p.IsExprtngTbls   ??= false;
            p.IsExprtngTTys   ??= true;
            p.IsExprtngFKeys  ??= false;
            p.IsExprtngData   ??= false;
            break;

         default:
            AssertFail($"Unrecognised export type: {p.RootType.GetAlias()}");
            break;
         }

         p.ScriptUseDb        ??= true;
         p.AddTimestamp       ??= false;
         LogS();
      }

      /// <summary>
      /// Description: returns the standard log file
      /// use this when the Params config does not specify a Log
      /// NOTE there is a similar requirement for Script Dir: GetScriptDirFromConfig()
      ///
      /// PRECONDITIONS:
      ///   none
      ///
      /// POSTCONDITIONS:
      ///   returns:
      ///      if appconfig app settings contains the key: "Log File" then value
      ///      else the DbScripter.DefaultLogFile property
      ///
      /// THROWS: none
      /// METHOD:
      ///   if appconfig app settings contains the key: "Log File" then return it
      ///   else return the DbScripter.DefaultLogFile property
      /// </summary>
      /// <returns></returns>
      protected static string GetLogFileFromConfig()
      { 
         //   if appconfig app settings contains the key: "Log File" then return it
         //   else return the DbScripter.DefaultLogFile property
         return ConfigurationManager.AppSettings.Get("Log File") ?? DefaultLogFile;
      }

      /// <summary>
      /// Description: returns the standard Script Directory
      /// use this when the Params config does not specify a Script Dir
      /// NOTE there is a similar requirement for Script Dir: GetLogFileFromConfig()
      ///
      /// PRECONDITIONS:
      ///   none
      ///
      /// POSTCONDITIONS:
      ///   returns:
      ///      if appconfig app settings contains the key: "Script Dir" then value
      ///      else the DbScripter.DefaultScriptDir property
      ///
      /// THROWS: none
      /// METHOD:
      ///   if appconfig app settings contains the key: "Log File" then return it
      ///   else return the DbScripter.DefaultLogFile property
      /// </summary>
      /// <returns></returns>
      protected static string GetScriptDirFromConfig()
      {
         return ConfigurationManager.AppSettings.Get("Script Dir") ?? DefaultScriptDir;
      }

      /// <summary>
      /// Required types depends on the export type
      /// For example if Exporting procedures then required types should be procedures only
      /// 
      /// If the export type is     schema then { Table, Function, Procedure, Table, TableType, View} are required
      /// If the export type is not schema or database then only the same 1 export type is required
      /// 
      /// PRECONDITIONS:
      ///   PRE 1: required_type not SqlTypeEnum.Undefined
      ///
      /// POSTCONDITIONS:
      ///   POST 1: If the export type is schema then the following are required:
      ///            if create or drop:{ Table, Function, Procedure, TableType, View}
      ///            if alter         :{        Function, Procedure, TableType, View}
      ///            if other mode: throw exception
      ///            
      ///   POST 2: If the export type is not schema or database then only the same 1 export type is required
      /// </summary>
      protected static List<SqlTypeEnum> CorrectRequiredTypes( SqlTypeEnum required_type, CreateModeEnum createMode, List<SqlTypeEnum>? requiredTypesIn)
      {
         Logger.LogS($"required_type: {required_type.GetAlias()}, createMode: {createMode.GetAlias()}");
         List<SqlTypeEnum> requiredTypesOut;

         // PRE 1: required_type not SqlTypeEnum.Undefined
         Utils.Precondition(required_type != SqlTypeEnum.Undefined, $"SqlTypeEnum.Undefined is not allowed here");

         switch(required_type)
         {
         case SqlTypeEnum.Schema:
            // set to all types not Db and schema
            switch(createMode)
            {
               case CreateModeEnum.Create:
               case CreateModeEnum.Drop:
                  requiredTypesOut = new List<SqlTypeEnum>() { SqlTypeEnum.Table, SqlTypeEnum.Function, SqlTypeEnum.Procedure, SqlTypeEnum.TableType, SqlTypeEnum.View};
                  break;

               case CreateModeEnum.Alter:
                  requiredTypesOut = new List<SqlTypeEnum>() { SqlTypeEnum.Function, SqlTypeEnum.Procedure, SqlTypeEnum.TableType, SqlTypeEnum.View};
                  break;

               default:
                  throw new Exception($"CorrectRequiredTypes({createMode.GetAlias()}): Unhandled create mode");
            }
            break;

         default: 
            // For all types not schema:
            if((requiredTypesIn != null)  && (requiredTypesIn.Count == 1) && requiredTypesIn.Contains(required_type))
               requiredTypesOut = requiredTypesIn;
            else
               requiredTypesOut = new List<SqlTypeEnum>() { required_type};
            break;
         }

         // POSTCONDITION chk:
         // POST 1: If the export type is schema and mode = create or drop then { Table, Function, Procedure, Table, TableType, View} are required
         // POST 2: If the export type is schema and mode = alter          then { Function, Procedure, Table, TableType, View}        are required
         // POST 3: If the export type is not schema or database then only the same 1 export type is required
         Utils.Postcondition(
            ((required_type == SqlTypeEnum.Schema) && (requiredTypesOut.Count == 5))  && ((createMode == CreateModeEnum.Create) || (createMode == CreateModeEnum.Drop )) || // POST 1
            ((required_type == SqlTypeEnum.Schema) && (requiredTypesOut.Count == 4))  && (createMode == CreateModeEnum.Alter )  ||                                          // POST 2
            ((required_type != SqlTypeEnum.Schema) && (requiredTypesOut.Count == 1))                                                                                        // POST 3
            );

         Logger.LogL();
         return requiredTypesOut;
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
      ///  
      /// </summary>
      /// <param name="serverName"></param>
      /// <param name="instanceName"></param>
      protected void InitServer( string? serverName, string? instanceName)
      {
         Logger.LogS();

         try
         {
            // -------------------------
            // Validate Utils.Preconditions
            // -------------------------

            Utils.Precondition<ArgumentException>(!string.IsNullOrEmpty(serverName)  , "Server not specified");
            Utils.Precondition<ArgumentException>(!string.IsNullOrEmpty(instanceName), "Instance not specified");

            // -----------------------------------------
            // ASSERTION: Utils.Preconditions validated
            // -----------------------------------------

            Server  = Utils.CreateAndOpenServer( serverName, instanceName);
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
            Utils.Postcondition(Server != null,                         "Could not create Server smo object");
            Utils.Postcondition(Server.Status == ServerStatus.Online,   "Could not connect to Server");

            // -----------------------------------------
            // ASSERTION: postconditions validated
            // -----------------------------------------
         }
         catch(Exception e)
         { 
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
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
      /// </summary>
      /// <param name="databaseName"></param>
      protected void InitDatabase(string? databaseName)
      { 
         Logger.LogS();

         try
         {
            // -------------------------
            // Validate Utils.Preconditions
            // -------------------------

            Utils.Precondition<ArgumentException>(Server != null                     , "server not instantiated");      // PRE 1
            Utils.Precondition<ArgumentException>(!string.IsNullOrEmpty(databaseName), "database name not specified");  // PRE 2

            // -----------------------------------------
            // ASSERTION: Utils.Preconditions validated
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
            Utils.Postcondition(Database        != null                 , $"database {databaseName} smo object not created"); // POST 1
            Utils.Postcondition(Database.Status == DatabaseStatus.Normal, $"database {databaseName} state is not normal");    // POST 2
            Utils.Assertion<ConfigurationException>(Database.Schemas.Count > 0, $"database {databaseName} smo object not connected or no schemas exist"); // POST 3
 
            // -----------------------------------------
            // ASSERTION: postconditions validated
            // -----------------------------------------
        }
         catch(Exception e)
         { 
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
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
      protected void InitScriptingOptions()
      {
         Logger.LogS();
         // -------------------------
         // Validate Utils.Preconditions
         // -------------------------
         Utils.Precondition<ArgumentException>(P.IsValid(out string? msg), msg); // PRE 1

         // -----------------------------------------
         // ASSERTION: Utils.Preconditions validated
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
            IncludeDatabaseContext  = false, // we need more control P?.ScriptUseDb ?? false, // only if required
            IncludeHeaders          = false,
            IncludeIfNotExists      = false,
            Indexes                 = true,
            NoCollation             = true,
            NoCommandTerminator     = false, //noGoflag, // true means don't emit GO statements after every SQLstatement
            NoIdentities            = true,
            NonClusteredIndexes     = true,
            Permissions             = false,
            SchemaQualify           = true,     //  e.g. [dbo].sp_bla
            SchemaQualifyForeignKeysReferences = true,
            ScriptBatchTerminator   = true,
            ScriptData              = P.IsExprtngData    ?? false,
            ScriptDrops             = (P.CreateMode == CreateModeEnum.Drop),
            ScriptForAlter          = false,    //issue here:  Dont script alter here - it doesnt work for functions, tables ... (P.CreateMode == CreateModeEnum.Alter), do in Script transactions method
            ScriptSchema            = P.IsExprtngSchema  ?? false,
            WithDependencies        = false,    // issue here: dont set true: Smo.FailedOperationException true, Unable to cast object of type 'System.DBNull' to type 'System.String'.
            ClusteredIndexes        = true,
            FullTextIndexes         = true,
            EnforceScriptingOptions = true,
         };


         // Ensure either emit schema or data, if not specified then emit schema
         if((!ScriptOptions.ScriptSchema) && (!ScriptOptions.ScriptData))
            ScriptOptions.ScriptSchema = true;

         if(P.RootType == SqlTypeEnum.Schema)
            SetExportSchemaFlags();

         // -------------------------
         // Validate postconditions
         // -------------------------
         Utils.Postcondition((P.RootType == SqlTypeEnum.Table && P.CreateMode != CreateModeEnum.Alter) || 
            ((P.RootType != SqlTypeEnum.Table)), "if exporting tables dont specify alter");//  POST 1: 
         //  POST 2: ensure either emit schema or data, if not specified then emit schema
         Utils.Postcondition((ScriptOptions.ScriptSchema || ScriptOptions.ScriptData));

         // -----------------------------------------
         // ASSERTION: postconditions validated
         // -----------------------------------------
         Scripter.Options = ScriptOptions;
         Logger.LogL( OptionsToString(Scripter.Options));
      }

      /// <summary>
      /// Initializes file writer if writerFilePath is a valid path
      /// if file not specified issues a warning, closes the writer
      /// if the file exists prior to this call then it is deleted - exception if not possible to delete
      /// calls IsValid at end
      /// 
      /// Utils.PreconditionS: exportScriptPath is not null
      ///   
      /// POSTCONDITIONS:
      /// POST 1: writer open pointing to the export file AND
      ///       writer file same as ExportFilePath and both equal exportFilePath parameter
      /// POST 2: sets ScriptFile from P.ExportScriptPath or error if not specified
      /// </summary>
      /// <param name="exportFilePath"></param>
      /// <param msg="possible error/warning message"></param>
      /// <returns>success of the writer initialisation</returns>
      protected void InitWriter()
      {
         try
         {
            Logger.LogS();
            // Close the writer
            Writer?.Close();
            ScriptFile = P.ExportScriptPath ?? "";

            // POST 2
            Utils.Precondition(!string.IsNullOrEmpty(ScriptFile), "xportScriptPath must be specified");

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
            Utils.Postcondition((Writer != null) && 
                      ((FileStream)(Writer.BaseStream)).Name.Equals(P.ExportScriptPath, StringComparison.OrdinalIgnoreCase)
                      , "Writer not initialised properly");
 
            // ASSERTION: writer intialised and target file has been created and is empty
            Logger.LogL();
         }
         catch(Exception e)
         {
            Logger.LogException(e);
            Writer?.Close();
            throw;
         }
      }

      protected void ClearState()
      {
         Logger.LogS();
         // primary properties
         P.ClearState();

         // major scripting properties
         Database       = null;
         Scripter       = null;
         ScriptOptions  = null;
         Server         = null;
         Writer         = null;

         // info cache
         ClearCaches();
         Logger.LogL();
      }

      protected void ClearCaches()
      {
         Logger.LogS();

         // info cache
         ExportedDatbases     .Clear();
         ExportedSchemas      .Clear();
         ExportedTables       .Clear();
         ExportedProcedures   .Clear();
         ExportedFunctions    .Clear();
         ExportedViews        .Clear();
         ExportedTableTypes   .Clear();

         ConsisideredEntities .Clear();
         DifferentDatabases   .Clear();
         DuplicateDependencies.Clear();
         SystemObjects        .Clear();
         UnresolvedEntities   .Clear();
         UnwantedSchemas      .Clear();
         UnwantedTypes        .Clear();
         WantedItems          .Clear();

         Logger.LogL();
      }

      #endregion public methods
      #region private methods

      /// <summary>
      /// Validates the initialization
      /// Utils.PreconditionS: 
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

      protected  static SqlTypeEnum MapTypeToSqlType(string typeName)
      {
         var sty = typeName switch
         {
            "Database"              => SqlTypeEnum.Database,
            "UserDefinedFunction"   => SqlTypeEnum.Function,
            "StoredProcedure"       => SqlTypeEnum.Procedure,
            "Schema"                => SqlTypeEnum.Schema,
            "Table"                 => SqlTypeEnum.Table,
            "View"                  => SqlTypeEnum.View,
            "UserDefinedTableType"  => SqlTypeEnum.TableType,
            _                       => SqlTypeEnum.Undefined,
         };

         if(sty == SqlTypeEnum.Undefined)
            Postcondition<ArgumentException>(sty != SqlTypeEnum.Undefined, $"MapTypeToSqlType failed for {typeName}");

         return sty;
      }

      /// <summary>
      /// Use this when we dont need to look for the CREATE RTN statement
      /// if mode is alter and not schema or db then modify statements here
      /// tables need to drop and create
      /// </summary>
      /// <param name="transactions"></param>
      /// <param name="sb"></param>
      protected void ScriptTransactions( StringCollection transactions, StringBuilder sb, Urn urn, bool wantGo)
      {
         var key = GetUrnKeyFromUrn(urn, out var smoType, out var dbNm, out var schemaNm, out var entityNm);

         if(transactions.Count> 0)
         { 
            var op   = P.CreateMode.GetAlias();
            var type = MapSmoTypeToSqlType( smoType);
            int x = 0;
            bool found = false;

            // Need to put a go top and bottom of routine between teh set ansi nulls etc to
            // make the export toutine the only thing in the transaction
            // only replace the alter once in the script
            foreach( string transaction in transactions)
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
                                 ScriptGo(sb);
                                 found = true;
                              }
                              else
                              {
                                 LogW($"oops: exp_entityNm: [{entityNm}], act_entityNm: [{act_entityNm}]");
                              }
                           }
                           else
                           {
                              LogW($"oops: exp_schema: [{schemaNm}], act_schemma: [{act_schema}]");
                           }
                        }
                        else
                        {
                           LogW($"oops: {line}");
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
            AddToExportedLists( key);
         }
         else
         {
            Utils.AssertFail($"no script produced for {key}");
         }
      }

      /// <summary>
      /// if mode IS NOT alter then script normally
      /// if mode IS     alter then modify statements here
      /// and not schema or db 
      /// tables need to drop and create
      /// </summary>
      /// <param name="transactions"></param>
      /// <param name="sb"></param>
      protected void ScriptTransactionsHandleAlter( SqlSmoObject? smo, ScriptingOptions? so, StringBuilder sb, string op, string type, string name)
      {
         string action;
         StringCollection transactions;
         var    urn = smo.Urn;
         string key = GetUrnKeyFromUrn(urn, out var expType, out var dbNm, out var expSchema, out var expEntity);
         expType = MapSmoTypeToSqlType(expType);
         LogS($"[{_scripted_cnt++}]{key}");
         bool bAddEntityToXprtLsts = false;

         do
         {
            // if mode IS NOT alter then script normally
            if(P.CreateMode != CreateModeEnum.Alter)
            {
               Log("P.CreateMode != CreateModeEnum.Alter");
               action = $"script {P.CreateMode.GetAlias()} {key} normally";
               transactions = ((dynamic)smo).Script(so);
               ScriptTransactions( transactions, sb, urn, true);
               bAddEntityToXprtLsts = false;
               break;
            }

            Utils.Assertion(P.CreateMode == CreateModeEnum.Alter);

            //------------------------------------------------------------
            // ASSERTION: ALTER MODE
            //------------------------------------------------------------

            Logger.Log($"ASSERTION: ALTER MODE for {key}");

            // if mode IS     alter then modify statements here
   //#pragma warning disable CS8600 // Converting null literal or possible null value to non-nullable type.
   //         ScriptingOptions soDrop = Utils.ShallowClone(so);
   //#pragma warning restore CS8600 // Converting null literal or possible null value to non-nullable type.

            switch(expType)
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
               Log($"scripting with mod: CREATE -> ALTER {expType} for {key}");
               action       = $"scripting ALTER: {key}]";
               transactions = ((dynamic)smo).Script(so);
               bool found = false;

               if(transactions.Count> 0)
               { 
                  foreach(string transaction_ in transactions)
                  {
                     // Make a copy
                     string transaction = transaction_;
                     int pos = transaction.IndexOf("CREATE", StringComparison.OrdinalIgnoreCase);
                     string line;

                     if(!found)
                     { 
                        // Look for the first transaction with a line beginning with 0 or more wsp and CREATE
                        var m = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]*([^ \[]*)([ \[]+)([^\]]*)([\[\.\]]+)([^\]]*)"
                                             ,RegexOptions.Multiline | RegexOptions.IgnoreCase);

                        var numFnsAct = m.Count;

                        // Plan is to add a go before the CREATE|ALTER|DROP statement
                        if(m.Count>0)
                        {
                           // Got the Create mode: {CREATE|ALTER|DROP}
                           line = $"{m[0].Groups[1].Value}";
                           var actType   = m[0].Groups[1].Value;
                           var actSchema = m[0].Groups[3].Value;
                           var actEntity = m[0].Groups[5].Value;

                           // Signatures must have [] for this to work
                           if(expType.Equals(actType, StringComparison.OrdinalIgnoreCase))
                           {
                              if(expSchema.Equals(actSchema, StringComparison.OrdinalIgnoreCase))
                              { 
                                 if(expEntity.Equals(actEntity, StringComparison.OrdinalIgnoreCase))
                                 { 
                                    // Add a go after the set ansi nulls on etc but before the alter statement
                                    ScriptGo(sb);
                                    // Replace the first occurrence of of ^[ \t*]Create case insensitive"
                                    var m2 = Regex.Match(transaction,"^[ \t]*(CREATE)", RegexOptions.IgnoreCase | RegexOptions.Multiline);
                                    var ndx = m2.Index;
                                    Assertion(ndx>-1);
                                    transaction = transaction.Substring(0, ndx) + "ALTER" + transaction.Substring(ndx+6);
                                    found = true;
                                 }
                                 else
                                 {
                                    AssertFail($"oops Entity mismatch, key: {key}");
                                 }
                              }
                              else
                              {
                                 AssertFail($"oops Schema mismatch, key: {key}");
                              }
                           }
                           else
                           {
                             AssertFail($"oops Type mismatch, key: {key}");
                           }
                        }
                     }

                     ScriptLine( transaction, sb);

                     if(WantBlankLineBetweenTransactions())
                        ScriptBlankLine(sb);
                  }

                  ScriptGo(sb);
               }
               else
               {
                  AssertFail($"no script produced for {key}");
               }

               Assertion(found, $"Failed to replace create with alter, key: {key}");


               bAddEntityToXprtLsts = true;
               break;

            default:
               // Script normally
               action = $"scripting normally: {key}";
               Logger.Log(action);
               transactions = ((dynamic)smo).Script(so);

               if(transactions.Count==0)
                  Utils.Assertion(transactions.Count>0, $"no script produced for {expEntity}");

               // N.B.: this will add the entity to export lists , string op, string type, string name
               ScriptTransactions( transactions, sb, urn, wantGo: true);
               bAddEntityToXprtLsts = false;
               break;
            }
         } while(false);

         // if scripted here add to exported lists
         if(bAddEntityToXprtLsts)
            AddToExportedLists( key);

         Logger.LogL(action);
      }

      protected void AddToExportedLists( string key)
      {
         _exportedItemCnt++;
         DecodeUrnKey(key, out string ty, out string database, out string schema, out string entityName);
         var shortKey = $"{schema}.{entityName}";

         switch(ty)
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
      /// sole access to writing to the file/ strinbuilder
      /// </summary>
      /// <param name="line"></param>
      /// <param name="sb"></param>
      protected void ScriptLine(string line, StringBuilder? sb = null)
      { 
         if(!line.EndsWith("\r\n"))
            line = line +("\r\n");

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
      /// PRE:  NONE
      /// POST: all UNDEFINED flags set true
      /// </summary>
      protected void SetExportSchemaFlags()
      {
         P.IsExprtngFns    = true;
         P.IsExprtngProcs  = true;
         P.IsExprtngSchema = true;
         P.IsExprtngTbls   = P.CreateMode != CreateModeEnum.Alter;
         P.IsExprtngTTys   = true;
         P.IsExprtngVws    = true;
      }

      /// <summary>
      /// This will script all required schemas
      /// create or drop the schemas and script in dependnency order
      /// if altering dont create the schemas

      /// PRE: Init called
      /// 
      /// POST: 
      /// 
      /// </summary>
      public string ExportSchemas(StringBuilder sb)
      {
         Logger.LogS();
         Utils.Precondition(IsValid(out var msg), msg);
         string key = "";
         string op = P.CreateMode.GetAlias();
         string type = "";

         try
         {
            // determine id schema is a test
            // Specialise the Options config for this op
            Logger.LogDirect($"Stage 1: init");
            ExportSchemaScriptInit();
            List<Schema> schemas = new List<Schema>();

            foreach( var schemaName in P.RequiredSchemas)
            {
               Logger.LogDirect($"Adding {schemaName} to the schema list");
               schemas.Add(Database.Schemas[schemaName]);
            }

            Logger.LogDirect($"Stage 2: Get Schema Dependencies Walk");
            List<Urn> walk = GetSchemaDependencyWalk
               ( P.RequiredSchemas, 
                 (P.CreateMode == CreateModeEnum.Create || P.CreateMode == CreateModeEnum.Alter)
               );

            if(P.ScriptUseDb ?? false)
               ScriptUse(sb);

            // If creating then create the schemas now
            // test schemas need to be registerd with the tSQLt framework
            // if altering dont create the schemas
            if(P.CreateMode == CreateModeEnum.Create)
            {
               Logger.LogDirect($"Stage 3: scripting the schemas create sql");

               foreach(var schema in schemas)
               {
                  if(IsTestSchema(schema.Name))
                     ScriptLine( $"EXEC tSQLt.NewTestClass '{schema.Name}';", sb);
                  else
                     ExportSchemaStatement(schema, sb);
               }
            }

            int i = 0;
            Logger.LogDirect($"Stage 4: scripting the schema objects");

            foreach(Urn urn in walk)
            {
               i++;
               key = GetUrnKeyFromUrn(urn, out var ty, out var dbName, out var schemaName, out var entityName);

               type = MapSmoTypeToSqlType(ty);

               if(urn.Type == "UnresolvedEntity")
               {
                  Logger.LogDirect($"Not Scripting [{i}]: {key}");
                  continue;
               }

               SqlSmoObject smo = Server.GetSmoObject(urn);

               // If the database and the schema is required then script 
               if(P.DatabaseName.Equals(dbName, StringComparison.OrdinalIgnoreCase) && P.RequiredSchemas.Contains(schemaName))
               {
                  // Handle alter
                  Logger.LogDirect($"Scripting handling alter [{i}]: {key}");
                  ScriptTransactionsHandleAlter(smo, ScriptOptions, sb, op: op, type, name: entityName);
               }
               else
               {
                  Logger.LogDirect($"Not Scripting [{i}]: {key}");
               }
            }

            // If dropping then drop schemas now
            if(P.CreateMode == CreateModeEnum.Drop)
            {
               Logger.LogDirect($"Stage 5: scripting the drop schema sql");

               foreach(var schema in schemas)
               {
                  if(IsTestSchema(schema.Name))
                     ScriptLine( $"EXEC tSQLt.DropClass '{schema.Name}';", sb);
                  else
                     ExportSchemaStatement(schema, sb);
               }
            }

            Logger.LogDirect($"Stage 6: all completed successfully");
         }
         catch(Exception e)
         { 
            Logger.LogException(e, $"key: {key}");
            throw;
         }

         Logger.LogL();
         return sb.ToString();
      }

      protected string MapSmoTypeToSqlType(string smoType)
      {
         var type = smoType.ToUpper() switch
               {
                  "USERDEFINEDFUNCTION" => "FUNCTION",
                  "STOREDPROCEDURE"     => "PROCEDURE",
                  _ => smoType.ToUpper()
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
         Logger.LogS($"schema: {schema.Name}");
         Utils.Precondition<ArgumentException>((P.IsExprtngSchema ?? false) == true, "Inconsistent state P.IsExprtngSchema is not true");
         var sb_ = new StringBuilder(); 

         try
         {
            ScriptingOptions so = new ScriptingOptions();
            so.ScriptDrops = (P.CreateMode == CreateModeEnum.Drop);
            so.ScriptBatchTerminator = true;
            var coll = schema.Script();
            
            ScriptTransactions(coll, sb_, schema.Urn, wantGo: true);
            sb.Append(sb_);
         }
         catch(Exception e)
         { 
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
         return sb_.ToString();
      }

      protected static string GetUrnKey(string ty, string dbName, string schemaName, string entityName)
      {
         return $"{dbName}.{schemaName}.{entityName, -25}: {ty}";
      }



      /// <summary>
      /// gets the attributes for an urn at level 3 - this is usually what we need
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
      public static string GetUrnKeyFromUrn(Urn urn, out string ty, out string dbName, out string schemaName, out string entityName)
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
         List<string> schemaWantedTypes = new List<string>(){ "User Defined Function", "Table", "Stored Procedure"};
         Dictionary<string, Dictionary<string, string>> attr_map = new Dictionary<string, Dictionary<string, string>>();

         for(int level=0; level<len; level++)
         {
            blok = xpr[level];
            name = blok.Name;
            // map of level attrs
            var map = new Dictionary<string, string>();

            foreach(var ky in (blok.FixedProperties.Keys))
            {
               string key = ky.ToString();
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

               // Entity Level" 2
               if(level==2 && key == "Name")
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
         if((schemaName == "") && (schemaWantedTypes.Any( s => s.Equals(type, StringComparison.OrdinalIgnoreCase))))
            AssertFail($"failed to get schema from urn: {urn}");

         // POST 4 schema has been found msg: "failed to get schema from urn: {urn}");
         return GetUrnKey( ty, dbName, schemaName, entityName);
      }

      /*// <summary>
      /// gets the attributes for an urn at level 3 - this is usually what we need
      ///
      /// PRECONDITIONS:
      ///   (urn not null)
      ///
      /// POSTCONDITIONS
      ///   returns true if found level, false otherwise
      ///
      /// </summary>
      /// <param name="urn"></param>
      /// <param name="attr_map">map of the attribute name/value paurs for this level</param>
      /// <returns>true if found level, false otherwise</returns>
      public static bool GetUrnDbDetails(Urn urn, out string dbName)
      { 
         bool ret = GetUrnDetailForLevel(urn, 1, out Dictionary<string, string> attr_map);
         dbName = ret ? attr_map["Name"] : "<Unknown>";
         return ret;
      }



      /// <summary>
      /// gets the attributes for an urn at a level  - this is usually what we need
      ///
      /// PRECONDITIONS:
      ///   (urn not null)
      ///
      /// POSTCONDITIONS
      ///   returns true if found level, false otherwise
      ///
      /// </summary>
      /// <param name="urn">The urn to interrogate</param>
      /// <param name="level">the level in its xpath</param>
      /// <param name="attr_map">map of the attribute name/value paurs for this level</param>
      /// <returns>true if found level, false otherwise</returns>
      public static bool GetUrnDetailForLevel(Urn urn, int level, out Dictionary<string, string> attributes)
      {
         var ty = urn.Type;

         if(string.IsNullOrEmpty(ty))
            AssertFail("Invalid urn ty");

         bool isValid = urn.IsValidUrn();

         if(!isValid)
            Assertion(isValid, "Invalid urn");

         attributes = new();
         var xpath  = urn.XPathExpression;

         if(xpath.Length<=level)
            return Logger.LogW($"urn error: did not find level {level}");

         // Assertion: we have the level

         XPathExpressionBlock childBlk = xpath[level];
         var list = childBlk.FixedProperties;
         int i = 0;
         var seps = new[]{'\'' };

         foreach(System.Collections.DictionaryEntry kv_pr in list)
         {
            string key   = kv_pr.Key.ToString().Trim(seps);
            string value = kv_pr.Value.ToString().Trim(seps);

            try
            {
               attributes.Add(key, value);
            }
            catch(Exception e)
            {
               Logger.LogException(e);
            }

            i++;
         }

         //attributes.Add("Name", childBlk.Name);
         return true;
      }
      */
      protected static string [] DecodeUrnKey(string key, out string ty, out string dbName, out string schemaName, out string entityName)
      {
         //"{ty}: {dbName}.{schemaName}.{entityName}";
         string [] items = key.Split(new [] {':', '.', '[', ']'});

         if(items.Length != 4)
            Utils.Assertion(items.Length == 4);

         dbName      = items[0].Trim();
         schemaName  = items[1].Trim();
         entityName  = items[2].Trim();
         ty          = items[3].Trim();
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
         Logger.LogS($"schema: {schema.Name}");
         Utils.Precondition<ArgumentException>((P.IsExprtngSchema ?? false) == true, "Inconsistent state P.IsExprtngSchema is not true");
         var sb_ = new StringBuilder(); 

         try
         {
            ScriptingOptions so = new(){ScriptDrops = (P.CreateMode == CreateModeEnum.Drop) };
            
            // lastly:
            ExportSchemaStatement( schema, sb);
         }
         catch(Exception e)
         { 
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
         return sb_.ToString();
      }

 
      /// <summary>
      /// PRE: P.TargetChildTypes not null
      /// 
      /// POST:TargetChildTypes contains Type
      /// </summary>
      protected void EnsureRequiredTypesContainsType(SqlTypeEnum sqlType)
      {
         Utils.Precondition(P.TargetChildTypes != null);

         if(!P.TargetChildTypes.Contains(sqlType))
            P.TargetChildTypes.Add(sqlType);
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
         Logger.LogS();
         // Pre 1: Init() called, P DbOpType configured
         Utils.Precondition(IsValid(out var msg), $"{msg}");
         // Pre 2: Create type is not alter
         Utils.Precondition(P.CreateMode != CreateModeEnum.Undefined , $"create mode must be defined");

         // Process
         // Set the export schema flags
         EnsureRequiredTypesContainsType(SqlTypeEnum.Schema);

         if(P.CreateMode != CreateModeEnum.Alter)
            EnsureRequiredTypesContainsType(SqlTypeEnum.Table);

         EnsureRequiredTypesContainsType(SqlTypeEnum.View);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Procedure);
         EnsureRequiredTypesContainsType(SqlTypeEnum.Function);

         if(P.CreateMode != CreateModeEnum.Alter)
            EnsureRequiredTypesContainsType(SqlTypeEnum.TableType);

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

         // Wrap up
         Logger.LogL();
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
         Logger.LogS();
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
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
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
         Logger.LogS();
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
            Logger.Log(msgs);
            throw;
         }

         Logger.LogL();
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
         Logger.LogS();
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
            Logger.Log(msgs);
            throw;
         }

         sb.Append(sb_);
         Logger.LogL();
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
         Logger.LogS();
         Init(p);
         StringBuilder sb = new();
         ExportDropDatabaseScript( sb);
         Logger.LogL();
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
      public string ExportDatabase(StringBuilder sb)
      {
         Logger.LogS();
         Utils.Precondition(Database != null, "database must be instantiated");
         
         var script = ExportDatabase( Database, sb);
         Logger.LogL();
         return script;
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
      public string ExportDatabase( Database? db, StringBuilder sb)
      {
         Logger.LogS();
         // PRE: P init
         StringBuilder sb_ = new StringBuilder();
         Utils.Precondition<Exception>(IsInitialised, "scripter must be initialised before use");
         var script = db.Script(ScriptOptions);
         ScriptTransactions(script, sb_, db.Urn, wantGo: true);
         sb.Append(sb_);
         Logger.LogL();
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
         Logger.LogS();

         try
         {
            Init(p);
            throw new NotImplementedException("ScriptDataExport()");
         }
         catch(Exception e)
         { 
            Logger.LogException(e);
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
         Logger.LogS();
         StringBuilder sb = new StringBuilder();

         try
         {
            Init(p);
         
            foreach(var schemaName in P.RequiredSchemas)
               ExportViews( schemaName, sb );

         }
         catch(Exception e)
         { 
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
         return sb.ToString();
      }

      /// <summary>
      /// PRE: Init called
      /// Scripts Create and Drop
      /// </summary>
      public string ExportViews( string currentSchemaName, StringBuilder sb )
      {
         Logger.LogS();
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
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
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
         Logger.LogS();
         StringBuilder sb_ = new StringBuilder();

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
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
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
      public string? ExportTables(StringBuilder sb)
      {
         Logger.LogS();
         Utils.Precondition(IsValid(out string? msg), msg);
         ScriptingOptions? so = InitTableExport();

         try
         {
            foreach(var schemaName in P.RequiredSchemas)
               ExportTables( Database.Schemas[schemaName], so, sb );
         }
         catch(Exception e)
         { 
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
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
         Logger.LogS();
         // -------------------------
         // Validate Utils.Preconditions
         // -------------------------
         //  PRE 1: Scriptor Initialised
         Utils.Precondition(IsValid(out string? msg), "Scriptor must be initised first" + msg);

         // -----------------------------------------
         // ASSERTION: Utils.Preconditions validated
         // -----------------------------------------

         var so   = Utils.ShallowClone(ScriptOptions);
         var orig = Utils.ShallowClone(ScriptOptions);
         so.ScriptForAlter          = false;
         so.ScriptForCreateOrAlter  = false;

         // -------------------------
         // Validate postconditions
         // -------------------------
         // POST 1: returned config so will support table export 
         //          and its script for alter flags are cleared
         Utils.Postcondition(!(so.ScriptForAlter || so.ScriptForCreateOrAlter), "POST 1 failed");

         //  POST 2: the original config is not changed
         if(!OptionEquals(ScriptOptions, orig, out msg))
         {
            Logger.Log("was\r\n",     OptionsToString(orig));
            Logger.Log("\r\nnow\r\n", OptionsToString(ScriptOptions));
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
         Logger.LogL();
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
         Logger.LogS(schema.Name);

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
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
      }

      /// <summary>
      /// Main entry point to export 1 table to the supplied StringBuilder
      /// PRE: table exists
      /// </summary>
      /// <param name="tableName"></param>
      /// <param name="sb"></param>
      public void ExportTable( string? tableName, Params? p, StringBuilder sb)
      {
         Logger.LogS();

         try
         {
            Init(p);
            ScriptingOptions so = Utils.ShallowClone(ScriptOptions) ?? new ();

            var table = Database.Tables[tableName];
            Utils.Assertion(table != null, $"Attempting to Export non existent table: [{tableName}]");
            ExportTable(table, so, sb);
         }
         catch(Exception e)
         { 
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
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
      public void ExportTable( Table? table, ScriptingOptions so, StringBuilder sb )
      {
         Logger.LogS();
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
            Logger.Log(msgs);
            ScriptLine($"{table.Name} error: {msgs}", sb);
            throw;
         }

         Logger.LogL();
      }

      /// <summary>
      /// Exports the foreign keys
      /// </summary>
      protected void ExportForeignKeys( string currentSchemaName, StringBuilder sb )
      {
         Logger.LogS();

         foreach(Table table in Database.Tables)
            ExportForeignKeys( currentSchemaName, table, sb);

         Logger.LogL();
      }

      /// <summary>
      /// Exports the FKs for a given table provided it is not a system object
      /// </summary>
      /// <param name="table"></param>
      /// <param name="sb">string builder to populate the serialisation all the table's ForeignKeys as a set of SQL statements</param>
      protected void ExportForeignKeys( string currentSchemaName, Table table, StringBuilder sb )
      {
         Logger.LogS();

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
            Logger.Log(msgs);
            throw;
         }

         Logger.LogL();
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
      protected string ExportProcedures(StringBuilder sb)
      { 
         Logger.LogS();
         Utils.Precondition(IsValid(out string? msg), msg);// PRE: Init called

         foreach(string schemaName in P.RequiredSchemas)
            ExportProcedures(schemaName, sb);

         return sb.ToString();
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
      protected string ExportFunctions(StringBuilder sb)
      {
         Logger.LogS();
         Utils.Precondition(IsValid(out string? msg), msg);// PRE: Init called

         foreach(string schemaName in P.RequiredSchemas)
            ExportFunctions(schemaName, sb);

         Logger.LogL();
         return sb.ToString();
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
         Logger.LogS();

         try
         { 
            Utils.Precondition(IsValid(out string? msg), $"{msg}");

            // Save state
            P.RootType = SqlTypeEnum.Function;
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
            var msgs = e.GetAllMessages();
            Logger.Log(msgs);
            throw;
         }

         Logger.LogL();
      }

      protected void ExportFunction( UserDefinedFunction function, StringBuilder sb )
      {
         Logger.LogS();

         try
         {
            //ScriptTransactions(function.Script(ScriptOptions), sb, GetUrnKey(function.Urn), wantGo: true);
            ScriptTransactions(function.Script(ScriptOptions), sb, function.Urn, wantGo: true);
         }
         catch(Exception e)
         {
            var msgs = e.GetAllMessages();
            Logger.Log(msgs);
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
         Logger.LogS();
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
         Logger.LogS();
         StringBuilder sb_ = new StringBuilder();

         try
         { 
            Utils.Assertion<ConfigurationException>(Database != null, "ExportProcedures(): Null database");
            Utils.Assertion(ScriptOptions != null, "ExportProcedures() PRECONDION: Options != null");

            // Save state
            P.RootType = SqlTypeEnum.Procedure;
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
            Logger.LogException(e);
            var msgs = e.GetAllMessages();
            Logger.Log(msgs);
            throw;
         }

         Logger.LogL();
         return sb_.ToString();
      }

      protected void ExportProcedure( StoredProcedure proc, StringBuilder sb )
      {
         Logger.LogS();
         try
         { 
            Logger.LogS($" exporting procedure: {proc.Name}");
            ScriptTransactions(proc.Script(ScriptOptions), sb, proc.Urn, wantGo: true);
            Logger.LogL();
         }
         catch(Exception e)
         {
            Logger.LogException(e);
            throw;
         }
      }

      
      /// <summary>
      /// PRE: 
      /// </summary>
      /// <returns>Serialisation of all the user defined types as a set of SQL statements</returns>
      protected string ExportTableTypes( string currentSchemaName, StringBuilder sb )
      {
         Logger.LogS();
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
            Logger.LogException(e);
            throw;
         }

         sb.Append(sb_);
         Logger.LogL();
         return sb_.ToString();
      }

      protected void ExportTableType( UserDefinedTableType tbl_ty, StringBuilder sb )
      {
         Logger.LogS();
         try
         { 
            ScriptTransactions(tbl_ty.Script(ScriptOptions), sb, tbl_ty.Name, wantGo: true);
         }
         catch(Exception e)
         {
            Logger.LogException(e);
            throw;
         }

         Logger.LogL();
     }

      /// <summary>
      /// Scripts the line USE database
      ///                  GO
      /// 
      /// Relies on Database being set
      /// </summary>
      protected void ScriptUseDatabaseStatement( StringBuilder sb )
      {
         Logger.LogS();

         if(ScriptOptions.IncludeDatabaseContext)
            ScriptUse(sb, true);

         Logger.LogL();
      }

      protected void ScriptUse( StringBuilder sb, bool onlyOnce = false )
      {
         Logger.LogS();
         ScriptLine($"USE [{Database.Name}]", sb);
         //ScriptGo(sb); // new way of scripting adds gos at the start of teh next of the next statement
         // so we ar3e getting 2 gos

         if(onlyOnce)
            ScriptOptions.IncludeDatabaseContext = false;
      }

      private SchemaCollectionBase? GetSchemaCollectionForType( Type type )
      {
         Logger.LogS();
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

         Utils.Assertion(collection != null);
         Logger.LogL();
         return collection;
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="tables"></param>
      /// <returns></returns>
      public List<string> GetDependencyWalk( List<Table> tables )
      {
         Logger.LogS();
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

         Logger.LogL();
         return walk;
      }

      /// <summary>
      /// Cannot directly get the dependencies for schemas, so we need to get deps for child objects
      /// Tables, procedures, functions views
      /// Remove any duplicate dependencies
      /// </summary>
      /// <param name="schemas"></param>
      /// <param name="mostDependentFirst"></param>
      /// <returns></returns>
      public List<Urn> GetSchemaDependencyWalk( IEnumerable<string> schemaNames, bool mostDependentFirst)
      {
         Logger.LogS();
         string ty = "", name = "", schemaName, key;
         int cnsidrd_cnt      = 0;
         int selctd_cnt       = 0;
         int nw_cnt           = 0;
         int nw_dup_dep_cnt   = 0;
         int nw_alien_cnt     = 0;
         int nw_sch_cnt       = 0;
         int nw_unres_cnt     = 0;
         var dw               = new DependencyWalker(Server);
         Urn[] child_ary      = GetFilteredItems(schemaNames);
         var depTree          = dw.DiscoverDependencies(child_ary, mostDependentFirst ? DependencyType.Parents : DependencyType.Children);
         var walk1            = dw.WalkDependencies(depTree);
         var walk2            = new List<Urn>();
         var sb               = new StringBuilder("\r\n\r\nItems to be scripted:\r\n");
         Dictionary<string, Urn> map = new();

         try
         {
            foreach( DependencyCollectionNode node in walk1)
            {
               Urn urn = node.Urn;
               cnsidrd_cnt++;
               key = GetUrnKeyFromUrn( urn, out ty, out var dbName, out schemaName, out name);

               RegisterAction(key, SelectionRuleEnum.Considering);

               if(ty == "UnresolvedEntity")
               {
                  RegisterAction(key, SelectionRuleEnum.UnresolvedEntity);
                  continue;
               }

               if(!Database.Name.Equals(dbName, StringComparison.OrdinalIgnoreCase))
               {
                  nw_cnt++;
                  RegisterAction(key, SelectionRuleEnum.DifferentDatabase);
                  continue;
               }

               var smo = Server.GetSmoObject(urn);
               
               if(smo.Properties.Contains("IsSystemObject"))
               { 
                  var property = smo.Properties["IsSystemObject"];

                  if(((bool)property.Value) == true)
                  { 
                     nw_cnt++;
                     // Log and store the entity and the exclusion rule
                     RegisterAction(key, SelectionRuleEnum.UnwantedSchema);
                     continue;
                  }
               }

               // Only add if the item is in a required schema
               if( !schemaNames.Contains(schemaName))
               {
                  nw_cnt++;
                  // Log and store the entity and the exclusion rule
                  RegisterAction(key, SelectionRuleEnum.UnwantedSchema);
                  continue;
               }
               
               if(!map.ContainsKey(key))
               {
                  map.Add(key, urn);
                  ty = ty.PadRight(20);
                  Utils.Assertion(!string.IsNullOrEmpty(schemaName));
                  sb.AppendLine($"{ty}: {schemaName}.{name}");
                  walk2.Add(node.Urn);
                  // Log and store the entity in the candidate list
                  RegisterAction(key, SelectionRuleEnum.Wanted);
               }
               else
               {
                  nw_cnt++;
                  // Log and store the entity and the exclusion rule: Duplicate Dependency
                  RegisterAction(key, SelectionRuleEnum.DuplicateDependency);
                  continue;
               }
            }
         }
         catch(Exception e)
         {
            Logger.LogException(e, $"{ty}: {name}");
            throw;
         }

         Logger.LogDirect($"{sb.ToString()}");
         Logger.LogL($"{cnsidrd_cnt} deps considrd, {selctd_cnt} selctd, {nw_cnt} not wanted: {nw_dup_dep_cnt} dups, {nw_unres_cnt} unres ents {nw_alien_cnt} aliens {nw_sch_cnt} nwntd schemas");
         return walk2;
      }

      /// <summary>
      /// desc: Produces a unique list of items in the required schemas
      /// 
      /// PRECONDITIONS:
      ///   PRE 1: P.RootType == SqlTypeEnum.Schema
      ///   
      /// POSTCONDITIONS:
      /// 
      /// </summary>
      /// <param name="schemaNames"></param>
      /// <returns></returns>
      protected Urn[] GetFilteredItems(IEnumerable<string> schemaNames)
      {
         Logger.LogS();
         Utils.Assertion(P.RootType == SqlTypeEnum.Schema);
         List<Urn> children= new List<Urn>();
         string key, ty, dbNm, schemaNm, entityNm;
         int cnsidrd_cnt   = 0;
         int i             = 0;
         int sel_cnt       = 0;
         int duplicateCount= 0;
         int sysObjCount   = 0;
         bool ret          = false;
         var smoSchemas    = new SqlSmoObject[schemaNames.Count()];
         Set<string> set   = new Set<string>();
         Dictionary<string, Urn> map = new();
         List<string> wanted = new () { "View", "UserDefinedFunction", "StoredProcedure", "DataType"};

         if(P.CreateMode != CreateModeEnum.Alter)
            wanted.Add("Table");

         Logger.LogDirect($"Stage 1: Get the objects owned by the schemas");

         foreach( var schemaName_ in schemaNames)
         {
            var schema = Database.Schemas[schemaName_];
            smoSchemas[i++] = schema;
            Logger.LogDirect($"Stage 1: [{i}] - get the objects owned by the schema: {schemaName_}");

            foreach(Urn urn in schema.EnumOwnedObjects())
            {
               ret = false;
               cnsidrd_cnt++;
               key = GetUrnKeyFromUrn( urn, out ty, out dbNm, out schemaNm, out entityNm);
               RegisterAction(key, SelectionRuleEnum.Considering);

               if(!wanted.Contains(urn.Type))
               {
                  // Log and store the entity and the exclusion rule
                  RegisterAction(key, SelectionRuleEnum.UnwantedType);
                  continue; 
               }

               var smo = Server.GetSmoObject(urn);

               if((((dynamic)smo)?.IsSystemObject ?? true))
               {
                  sysObjCount++;
                  RegisterAction(key, SelectionRuleEnum.SystemObject);
               }

               // Add candidate
               // Add if not already added
               if(!map.ContainsKey(key))
               {
                  // Log and store the entity in the candidates 2 list
                  RegisterAction(key, SelectionRuleEnum.Wanted);
                  ret = true;
                  map.Add(key, urn);
                  sel_cnt++;
               }
               else
               {
                  duplicateCount++;
                  RegisterAction(key, SelectionRuleEnum.DuplicateDependency);
               }

               Logger.LogDirect($"item: {key}: {(ret ? "" : "not ")} wanted.");
            }
         }

        Logger.LogS($"returning {map.Count} items, {cnsidrd_cnt} items considered, {sel_cnt} items selected, {duplicateCount} duplicates, {sysObjCount} system objects");
        return map.Values.ToArray();
      }

      /// <summary>
      /// Used to check parameters
      /// </summary>
      /// <param name="o"></param>
      /// <returns></returns>
      public string OptionsToString( ScriptingOptions? o )
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
      public bool OptionEquals( ScriptingOptions? a, ScriptingOptions? b, out string msg)
      {
         var sb = new StringBuilder();
         bool ret = false;
         AssertNotNull(a);
         AssertNotNull(b);

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

         Logger.LogL($"ret: {ret}");
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

         Utils.Assertion(schemaName!= null, $"could not determine schema for {type} {name}");

         // Check is of the current schema
         if(!schemaName.Equals(currentSchemaName, StringComparison.OrdinalIgnoreCase))
            return false;

         // Handle required types filter
         SqlTypeEnum sqlTy = MapTypeToSqlType(obj);

         if(P.TargetChildTypes == null || P.TargetChildTypes.Contains(sqlTy))
            ret = true;

         Logger.LogL($"ret: {ret}");
         return ret;
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
            Utils.Postcondition(false, $"IsTypeWanted() unexpected type: [{typeName}]"); break;
         }

         Logger.LogL($"ret: {ret}");
         return ret;
      }

      /// <summary>
      /// if 
      /// </summary>
      /// <param name="addTimestamp"></param>
      /// <returns></returns>
      protected string HandleExportFilePath( string? exportFilePath, bool addTimestamp )
      {
         Logger.LogS();
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

         Logger.LogL();
         return modifiedExportFilePath;
      }

      protected void LogResults(StringBuilder sb)
      {
         var line = new string('-', 100);
         LogS();
         sb.AppendLine("\r\n{line}\r\nSummary:\r\n");
         LogDirect($"\r\n\r\n{line}\r\n\r\nLists of scripted items:");
         LogExportedList("Datbases"                , sb, ExportedDatbases);
         LogExportedList("Schemas"                 , sb, ExportedSchemas);
         LogExportedList("Tables"                  , sb, ExportedTables);
         LogExportedList("Procedures"              , sb, ExportedProcedures);
         LogExportedList("Functions"               , sb, ExportedFunctions);
         LogExportedList("Views"                   , sb, ExportedViews);
         LogExportedList("Table Types"             , sb, ExportedTableTypes);
         LogExportedList("Wanted Items"            , sb, WantedItems);
         LogExportedList("Consisidered Entities"   , sb, ConsisideredEntities);
         LogExportedList("Different Databases"     , sb, DifferentDatabases);
         LogExportedList("Duplicate Dependencies"  , sb, DuplicateDependencies);
         LogExportedList("System Objects"          , sb, SystemObjects);
         LogExportedList("Unresolved Entities"     , sb, UnresolvedEntities);
         LogExportedList("Unwanted Schems"         , sb, UnwantedTypes);
         LogExportedList("Different Databases"     , sb, DifferentDatabases);
         LogExportedList("Duplicate Dependencies"  , sb, DuplicateDependencies);
         LogExportedList("SystemObjects"           , sb, SystemObjects);
         LogDirect($"\r\n{line}\r\n");
         LogL();
      }

      protected void LogExportedList(string type, StringBuilder sb, SortedList<string, string> list)
      {
         var hdr = $"{type,-22}: {list.Count, +3} items";
         LogDirect($"\r\n\t{hdr}");
         sb.AppendLine($"{hdr} items");

         foreach( var t in list)
            LogDirect($"\t\t{t.Key}"); 
      }

      protected void RegisterAction(string key, SelectionRuleEnum rule)
      {
         LogDirect($"{rule.GetAlias()}: {key}");
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
         else
            LogDirect($"{key} rule: {rule.GetAlias()} entry already exists in list");
      }

      #endregion protected methods
      #region private fields

      private const string GO = "GO";

      #endregion private fields
   }
}
