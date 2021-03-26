
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
      /// 
      /// When exporting a schema we should be able to specift which types are exported
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
      public bool Export( ref Params p, out string script, out string msg)
      {
         LogS();
         LogC("DbScripter.Export starting...");
         bool ret = false;
         script   = "";
         msg      = "";
         StringBuilder sb = new();

         try
         {
            do
            {
               if(!Init(p, out msg, sb))
                  break;

               // switch on the top level export type
               // exporting schema will NOT also export its children
               // All export routines must check the validity of the parmaeter state first
               switch(p.RootType)
               {
               case SqlTypeEnum.Schema    : ret = ExportSchemas   (sb, out script, out msg); break;
               case SqlTypeEnum.Database  : ret = ExportDatabase  (sb, out script, out msg); break;
               case SqlTypeEnum.Function  : ret = ExportFunctions (sb, out script, out msg); break;
               case SqlTypeEnum.Procedure : ret = ExportProcedures(sb, out script, out msg); break;
               case SqlTypeEnum.Table     : ret = ExportTables    (sb, out script, out msg); break;

               case SqlTypeEnum.Undefined:  msg = "RootType must be defined"; break;
               default:  msg = $"{p.RootType.GetAlias()} notimplemented"; ;break;
               }
            
               sb.Clear();
               // sb will have a counts summary of the exported lists
               LogResults(sb);

               // Write results summary to file
               ScriptLine($"/*\r\n{sb.ToString()}\r\n*/");

               if(!string.IsNullOrEmpty(msg))
                  ScriptLine($"/*\r\nError : {msg}\r\n*/");

               // Return updated parameters to the client
               p.CopyFrom(P);
            }while(false);
         }
         catch(Exception e)
         {
            Logger.LogException(e);
         }
         finally
         {
            Writer?.Close();
         }

         Logger.LogL($"Ret: {ret}");
         return ret;
      }

      public virtual string GetTimestamp()
      { 
         return DateTime.Now.ToString("yyMMdd-HHmm");
      }

      public DbScripter(/*Params? p = null*/)
      {
         Logger.LogS();
         //Init(p);
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
      ///   <returns>true if successful, false and msg populated otherwise</returns>
      ///   
      /// </summary>
      /// <param name="serverName">DESKTOP-UAULS0U\SQLEXPRESS</param>
      /// <param name="instanceName">like SQLEXPRESS</param>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath">like C:\tmp\Covid_T1_export.sql</param>
      /// <returns>true if successful, false and msg populated otherwise</returns>
      protected bool Init( Params p, out string msg, StringBuilder? sb = null, bool append = false)
      {
         Logger.LogS();
         bool ret = false;
         msg = "";

         if(sb == null)
            sb = new StringBuilder();

         try
         {
            do
            {
               // ---------------------------------------------------------------
               // Validate Preconditions
               // ---------------------------------------------------------------
               // PRE: the following export parameters must be defined:
               // PRE 1: the params struct must not be null
               // PRE 2: Sql Type
               // PRE 3: Create   Mode
               // PRE 4: Server   Name
               // PRE 5: Instance Name
               var defMsg = "must be specified";

               if(p == null)
               {
                  msg = $"Params arg {defMsg}";          // PRE 1
                  break;
               }

               if((p.RootType   ?? SqlTypeEnum   .Undefined) == SqlTypeEnum.Undefined)
               {
                  msg = $"RootType {defMsg}";            // PRE 2
                  break;
               }
               if((p.CreateMode ?? CreateModeEnum.Undefined) == CreateModeEnum.Undefined)
               {
                  msg = $"CreateMode {defMsg}";          // PRE 3
                  break;
               }

               if(string.IsNullOrEmpty(p.ServerName))
               {
                  msg =$"server {defMsg}";               // PRE 4
                  break;
               }

               if(string.IsNullOrEmpty(p.InstanceName))
               {
                  msg = $"instance {defMsg}";            // PRE 5
                  break;
               }

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
               if(!InitServer(P.ServerName ?? "", P.InstanceName ?? "", out msg))
                  break;

               if(!InitDatabase(P.DatabaseName, out msg))
                  break;

               if(!InitScriptingOptions( out msg))
                  break;

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

         Logger.LogL($"ret: {ret}");
         return ret;
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
      ///  POST 3: <returns>true if successful, false and msg populated otherwise</returns>
      ///  
      /// </summary>
      /// <param name="serverName"></param>
      /// <param name="instanceName"></param>
      protected bool InitServer( string serverName, string instanceName, out string msg)
      {
         Logger.LogS();
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

               if(string.IsNullOrEmpty(instanceName))
               {
                  msg = "Instance not specified";
                  break;
               }

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
            Logger.LogException(e);
            throw;
         }

         // POST 3: <returns>true if successful, false and msg populated otherwise</returns>
         if(!ret)
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");

         Logger.LogL($"ret: {ret}");
         return ret;
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
         Logger.LogS();
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
            Logger.LogException(e);
            msg = e.ToString();
         }

         // POST 4: <returns>true if successful, false and msg populated otherwise</returns>
         if(!ret)
            Postcondition(msg.Length > 0, "if there is an error then there must be a suitable error message");

         Logger.LogL($"ret: {ret}");
         return ret;
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
         Logger.LogS();
         bool ret = false;
         msg = "";

         do
         {
            // -------------------------
            // Validate Utils.Preconditions
            // -------------------------
            if(!P.IsValid(out msg))
               break;; // PRE 1

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
            if(!((P.RootType == SqlTypeEnum.Table && P.CreateMode != CreateModeEnum.Alter) || 
               ((P.RootType != SqlTypeEnum.Table))))
            { 
               msg = "if exporting tables dont specify alter";//  POST 1:
               break;
            }

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

         Logger.Log( OptionsToString(Scripter.Options));
         Logger.LogL( $"ret: {ret}");
         return ret;
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
      protected bool IsValid(out string msg)
      {
        //msg = null;
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
         LogS($"[ScriptTransactionsHandleAlterCnt][{_scripted_cnt++}]{key}");
         bool bAddEntityToXprtLsts = false;
         MatchCollection? matches = null;
         var regOptns = RegexOptions.Multiline | RegexOptions.IgnoreCase;

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
               action       = $"scripting ALTER:[{_scripted_cnt}] {key}] stg 1";
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
                        //Regex regex = new Regex($@"^[ \t]*CREATE[ \t]*([^ \[]*)([ \[]+)([^\]]*)([\[\.\]]+)([^\]]*)");
                        Regex regex = new Regex($@"^[ \t]*CREATE[ \t]+{expType}", regOptns);
                        matches = regex.Matches(transaction);
                        var nMatches = matches.Count;

                        if(nMatches == 0)
                           continue;

                        if(nMatches > 1)
                        {
                           // Found more than 1 match
                           // This can happen if there is a CREATE in a blok comment
                           // or a create in the code body of an sp
                           // Look for the first transaction with a line beginning with 0 or more wsp and CREATE
                           matches = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]*", regOptns);
                           nMatches = matches.Count;
                           action       = $"scripting ALTER:[{_scripted_cnt}] {key}] stg 2";

                           matches = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]*([^ \[]*)", regOptns);
                           nMatches = matches.Count;

                           matches = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]*([^ \[]*)([ \[]+)", regOptns);
                           nMatches = matches.Count;

                           matches = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]*([^ \[]*)([ \[]+)([^\]]*)", regOptns);
                           nMatches = matches.Count;
                         
                           matches= Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]*([^ \[]*)([ \[]+)([^\]]*)([\[\.\]]+)", regOptns);
                           nMatches = matches.Count;
                         
                           matches= Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]*([^ \[]*)([ \[]+)([^\]]*)([\[\.\]]+)([^\]]*)", regOptns);
                           nMatches = matches.Count;
                        }
                        else
                        {
                            action       = $"scripting ALTER:[{_scripted_cnt}] {key}] stg 3";
                            // Found exactly 1 match
                            matches = Regex.Matches(transaction, $@"^[ \t]*CREATE[ \t]+{expType}[ \t]*([^ \[]*)([ \[]+)([^\]]*)([\[\.\]]+)([^\]]*)", regOptns);
                            nMatches = matches.Count;
                        }

                        if(nMatches != 1)
                           Assertion(nMatches == 1, $"ScriptTransactionsHandleAlter: failed to get match for ^create");

                        // Plan is to add a go before the CREATE|ALTER|DROP statement
                        if(matches.Count>0)
                        {
                           action = $"scripting ALTER:[{_scripted_cnt}] {key}] stg 4";
                           // Got the Create mode: {CREATE|ALTER|DROP}
                           line = $"{matches[0].Groups[1].Value}";
                           var actType   = expType; //matches[0].Groups[1].Value;
                           var actSchema = matches[0].Groups[3].Value;
                           var actEntity = matches[0].Groups[5].Value;

                           // Signatures must have [] for this to work
                           if(expType.Equals(actType, StringComparison.OrdinalIgnoreCase))
                           {
                              action = $"scripting ALTER:[{_scripted_cnt}] {key}] stg 5";

                              if(expSchema.Equals(actSchema, StringComparison.OrdinalIgnoreCase))
                              {
                                 action = $"scripting ALTER:[{_scripted_cnt}] {key}] stg 5";

                                 if(expEntity.Equals(actEntity, StringComparison.OrdinalIgnoreCase))
                                 {
                                    action = $"scripting ALTER:[{_scripted_cnt}] {key}] stg 6 modifying";
                                    // Add a go after the set ansi nulls on etc but before the alter statement
                                    ScriptGo(sb);
                                    // Replace the first occurrence of of ^[ \t*]Create case insensitive"
                                    //var matches2 = Regex.Match(transaction,"^[ \t]*(CREATE)", RegexOptions.IgnoreCase | RegexOptions.Multiline);
                                    var ndx = matches[0].Index;

                                    if(ndx == -1)
                                       Assertion(ndx>-1);

                                    // Fianlly we can do the 'CREATE' -> 'ALTER' substitution
                                    transaction = transaction.Substring(0, ndx) + "ALTER" + transaction.Substring(ndx+6);
                                    action = $"scripting ALTER:[{_scripted_cnt}] {key}] stg 7 modified at ndx:{ndx}";
                                    LogDirect($"{action}:\r\n{transaction}");
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
                             continue;//Sometimes there is a ^ *Create etc in the block comments AssertFail($"oops Type mismatch, key: {key}");
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

               if(!found)
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
      /// 
      /// When exporting a schema we should be able to specift which types are exported
      /// the default should be all types
      /// but if we define a set of types then that should take precidence
      /// PRE: Init called
      /// 
      /// POST: 
      /// sb
      /// </summary>
      public bool ExportSchemas(StringBuilder sb, out string script, out string msg)
      {
         LogC("DbScripter.ExportSchemas starting...");
         bool   ret  = false;
         string key  = "";
         string type = "";
         string op   = P.CreateMode.GetAlias();

         try
         {
            do
            {
               Precondition(IsValid(out msg), msg);
               // determine id schema is a test
               // Specialise the Options config for this op
               LogC("DbScripter.Export Stage 1: init...");
               ExportSchemaScriptInit();
               List<Schema> schemas = new List<Schema>();

               foreach( var schemaName in P.RequiredSchemas)
               {
                  LogDirect($"Adding {schemaName} to the schema list");
                  schemas.Add(Database.Schemas[schemaName]);
               }

               LogC("DbScripter.Export Stage 2: Get Schema Dependencies Walk...");

               // This can fail if thre are references to non existent procedures in the stored procedure definitions
               // if MS dependency code fails then we need to do it without the dependency tree
               if(!GetSchemaDependencyWalk( P.RequiredSchemas, (P.CreateMode == CreateModeEnum.Create || P.CreateMode == CreateModeEnum.Alter), out List<Urn> walk))
                  Assertion(GetSchemaChildren( P.RequiredSchemas, out walk) == true);

               // Assertion we have a list of children
               if(P.ScriptUseDb ?? false)
                  ScriptUse(sb);

               // If creating then create the schemas now
               // test schemas need to be registerd with the tSQLt framework
               // if altering dont create the schemas
               if(P.CreateMode == CreateModeEnum.Create)
               {
                  LogC("DbScripter.Export Stage 3: scripting schema create sql...");

                  foreach(var schema in schemas)
                  {
                     if(IsTestSchema(schema.Name))
                        ScriptLine( $"EXEC tSQLt.NewTestClass '{schema.Name}';", sb);
                     else
                        ExportSchemaStatement(schema, sb);
                  }
               }

               int i = 0;
               LogDirect($"Stage 4: scripting the schema objects");
               LogC("DbScripter.Export Stage 4: scripting schema objects");

               foreach(Urn urn in walk)
               {
                  i++;

                  if(urn.Type == "UnresolvedEntity")
                  {
                     Logger.LogDirect($"Not Scripting [{i}]: {key}");
                     continue;
                  }

                  key = GetUrnKeyFromUrn(urn, out var ty, out var dbName, out var schemaName, out var entityName);
                  type = MapSmoTypeToSqlType(ty);

                  SqlSmoObject smo = Server.GetSmoObject(urn);

                  // If the database and the schema is required then script 
                  if(P.DatabaseName.Equals(dbName, StringComparison.OrdinalIgnoreCase) && P.RequiredSchemas.Contains(schemaName))
                  {
                     // Handle alter
                     LogDirect($"Scripting handling alter [{i}]: {key}");
                     ScriptTransactionsHandleAlter(smo, ScriptOptions, sb, op: op, type, name: entityName);
                  }
                  else
                  {
                     LogDirect($"Not Scripting [{i}]: {key}");
                  }
               }

               // If dropping then drop schemas now
               if(P.CreateMode == CreateModeEnum.Drop)
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

               ret = true;
               LogDirect($"Stage 6: all completed successfully");
            }
            while(false);
         }
         catch(Exception e)
         {
            msg = e.Message;
            LogC($"DbScripter.Export caught exception {e}");
            LogException(e, $"key: {key}");
         }

         LogC("DbScripter.Export completed");
         script = sb.ToString();
         LogL($"ret: {ret}");
         return ret;
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
         LogS();
         bool ret = false;
         string key, type, dbNm, schemaNm, entityNm;
         Schema schema = Database.Schemas[schemaName];
         Dictionary<string, Dictionary<string, Urn> > mn_map = new Dictionary<string, Dictionary<string, Urn>>();

         // Since we cant get proper dependnecy order then we will script in type order
         List<string> order = new List<string>(){ "Table", "UserDefinedFunction","StoredProcedure","Data type"};
         //walk.Clear();

         Urn[] urns = schema.EnumOwnedObjects();
         Dictionary<string, Urn> map;

         foreach(Urn urn in urns)
         {
            key = GetUrnKeyFromUrn(urn, out type, out dbNm, out schemaNm, out entityNm);

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

         ret = (walk.Count > 0);
         LogL($"ret: {ret} count: {walk.Count}");
         return ret;
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
      public bool ExportDatabase(StringBuilder sb, out string script, out string msg)
      {
         Logger.LogS();
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

         Logger.LogL($"ret: {ret}");
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
         Logger.LogS();
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

         LogL($"ret={ret}");
         return ret;
      }

      /// <summary>
      /// Main entry point to create the "Export Static Data Script"
      /// 
      /// </summary>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath"></param>
      protected bool ScriptDataExport( Params p, out string msg)
      {
         LogS();
         //bool ret = false;
         msg = "";

         try
         {
            Init(p, out msg);
            throw new NotImplementedException("ScriptDataExport()");
         }
         catch(Exception e)
         { 
            Logger.LogException(e);
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
         Logger.LogS();
         StringBuilder sb = new StringBuilder();
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
            Logger.LogException(e);
            msg = e.Message;
         }

         Logger.LogL($"ret:{ret}");
         return ret;
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
      public bool ExportTables(StringBuilder sb, out string script, out string msg)
      {
         Logger.LogS();
         bool ret = false;
         script   = "";
         StringBuilder sb_ = new();

         try
         {
            do
            {
               if(!IsValid(out msg))
                  break;

               ScriptingOptions? so = InitTableExport();

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

         Logger.LogL($"ret: {ret}");
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
      public bool ExportTable( string? tableName, Params p, StringBuilder sb, out string msg)
      {
         Logger.LogS();
         bool ret = false;

         try
         {
            do
            { 
               if(!Init(p, out msg))
                  break;

               ScriptingOptions so = Utils.ShallowClone(ScriptOptions) ?? new ();

               var table = Database.Tables[tableName];
               Utils.Assertion(table != null, $"Attempting to Export non existent table: [{tableName}]");
               ExportTable(table, so, sb);
            } while(false);
         }
         catch(Exception e)
         { 
            Logger.LogException(e);
            msg = e.Message;
         }

         Logger.LogL($"ret: {ret}");
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
      protected bool ExportProcedures(StringBuilder sb, out string script, out string msg)
      { 
         Logger.LogS();
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

         LogL($"ret: {ret}");
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
         Logger.LogS();
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

         LogL($"ret: {ret}");
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
            LogException(e);
            throw;
         }

         LogL();
      }

      protected void ExportFunction( UserDefinedFunction function, StringBuilder sb )
      {
         LogS();

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

      LogL();
     }

      /// <summary>
      /// Main entry point for exporting procedures
      /// </summary>
      /// <param name="sb"></param>
      /// <param name="required_schemas"></param>
      protected bool ExportProcedures( Params p, out string script, out string msg)
      {
         Logger.LogS();
         bool ret = false;
         script   = "";

         try
         {
            do
            {
               if(!Init(p, out msg))
                  break;

               StringBuilder sb = new StringBuilder();

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
      /// Remove any duplicate dependencies.
      /// 
      /// DependencyTree.DiscoverDependencies() can fail in MS code if there is more than 1 reference to a an unresolved item like a missing stored procedure
      /// as was the case in ut / when commonly used sp name was changed and not all references were updated
      /// {"Item has already been added. Key in dictionary:
      /// 'Server[@Name='DESKTOP-UAULS0U\\SQLEXPRESS']/Database[@Name='ut']
      /// /UnresolvedEntity[@Name='sp_tst_hlpr_chk' and @Schema='test']'
      /// Key being added: 'Server[@Name='DESKTOP-UAULS0U\\SQLEXPRESS']/Database[@Name='ut']/UnresolvedEntity[@Name='sp_tst_hlpr_chk' and @Schema='test']'"}
      /// 1 public DependencyTree DiscoverDependencies( Urn[] urns, DependencyType dependencyType );
      ///
      // in which case this rtn will return false and we do it without using MS dependencies
      /// </summary>
      /// <param name="schemas"></param>
      /// <param name="mostDependentFirst"></param>
      /// <returns></returns>
      public bool GetSchemaDependencyWalk( IEnumerable<string> schemaNames, bool mostDependentFirst, out List<Urn> walk)
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
         var sb               = new StringBuilder("\r\n\r\nItems to be scripted:\r\n");
         Dictionary<string, Urn> map = new();
         walk = new List<Urn>();
         Urn[] child_ary      = GetFilteredItems(schemaNames);
         DependencyTree? depTree = null;
         bool ret = false;
         DependencyType depTy = mostDependentFirst ? DependencyType.Parents : DependencyType.Children;
         UrnCollection urnCollList = new();
         SqlSmoObject[] smos = new SqlSmoObject[child_ary.Length];

         try
         {
            // DependencyTree.DiscoverDependencies() can fail in MS code if there is more than 1 reference to a an unresolved item
            // like a missing stored procedure
            depTree = dw.DiscoverDependencies(child_ary, depTy);
            var walk1 = dw.WalkDependencies(depTree);

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
                  Assertion(!string.IsNullOrEmpty(schemaName));
                  sb.AppendLine($"{ty}: {schemaName}.{name}");
                  walk.Add(node.Urn);
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

            ret = true;
         }
         catch(Exception e)
         {
            LogException(e, $"{ty}: {name}");
            return false;
         }

         LogDirect($"{sb.ToString()}");
         Log($"{cnsidrd_cnt} deps considrd, {selctd_cnt} selctd, {nw_cnt} not wanted: {nw_dup_dep_cnt} dups, {nw_unres_cnt} unres ents {nw_alien_cnt} aliens {nw_sch_cnt} nwntd schemas");
         LogL($"ret: {ret}");
         return ret;
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

         bool chk = map.Values.Any(x=>x.ToString().IndexOf("Unresolved", StringComparison.OrdinalIgnoreCase) > -1);
         Assertion(chk == false);
              chk = map.Values.Any(x=>x.ToString().IndexOf("sp_tst_hlpr_chk", StringComparison.OrdinalIgnoreCase) > -1);
         Assertion(chk == false);
         Logger.LogS($"returning {map.Count} items, {cnsidrd_cnt} items considered, {sel_cnt} items selected, {duplicateCount} duplicates, {sysObjCount} system objects");

         // chk using a back map
         var map2 = new Dictionary<string, string>();
         foreach(var item in map)
            map2.Add(item.Value, item.Key);


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
