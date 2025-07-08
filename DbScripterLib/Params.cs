#pragma warning disable CS8604//	Possible null reference argument for parameter 'rs' in 'SqlTypeEnum[]? Params.ParseRequiredTypes(string rs)'.	DbScripterLib	D:\Dev\C#\Db\Ut\DbScriptExporter\DbScripterLib\Params.cs	263	Active
using System.Text;
using CommonLib;
using static CommonLib.Utils;
using static CommonLib.Logger;
using Microsoft.Extensions.Configuration;
//using Microsoft.SqlServer.Management.Smo;
//using Microsoft.IdentityModel.Tokens;

namespace DbScripterLibNS
{
   /// <summary>
   /// class to simplify the passing of a number of scripter config parameters
   /// </summary>
   public class Params
   {
      private static IConfigurationRoot? _config = null;

      public static IConfigurationRoot? Config 
      { 
         get{ return _config; }
         set { _config = value;} 
      }

      public string FilePath { get; private set; } = "";
      public string Name { get; private set; } = "";

      public string LogFile { get; private set; } = "";

      public string Timestamp
      { 
         get; 
         private set; 
      } = "";

      public bool IndividualFiles { get; private set; } = true;

      public string? Server { get; private set; } = "";

      public string Instance{ get; private set; } = "";

      public string Database { get; private set; } = "";

      public string ScriptFile { get; private set; } = "";

      public string ScriptDir
      {
         get; 
         private set; 
      } = "";

      public bool? DisplayScript { get; private set; } = false;

      public bool DisplayLog { get; private set; } = false;

      public LogLevel LogLevel { get; private set; } = LogLevel.Undefined;

      public List<string> RequiredSchemas { get; private set; } = new List<string>();

      public static string DefaultLogFile { get; private set; } = @"D:\Logs\DbScripter.log";

      /// <summary>
      /// the target types are 1 or more required child types
      /// under the root
      /// 
      /// INVARIANT: cannot be empty after init
      /// </summary>
      public List<SqlTypeEnum> RequiredTypes {get; private set; } = new List<SqlTypeEnum>();

      public CreateModeEnum CreateMode { get; set; } = CreateModeEnum.Undefined;
      
      public bool ScriptUseDb { get; private set; } = false;
      
      public bool AddTimestamp { get; private set; } = false;

      // Export flags
      public bool IsExportingData { get; private set; } = false;

      public bool IsExportingDb => RequiredTypes.Contains(SqlTypeEnum.Database);

      public bool IsExportingFns=> RequiredTypes.Contains(SqlTypeEnum.Function);

      public bool IsExportingProcs => RequiredTypes.Contains(SqlTypeEnum.Procedure);

      /// <summary>
      /// Export the create/drop schema if CreateMode != altering
      /// </summary>
      public bool IsExportingSchema => CreateMode != CreateModeEnum.Alter;

      public bool IsExportingTbls => RequiredTypes.Contains(SqlTypeEnum.Table);

      public bool IsExportingTriggers => RequiredTypes.Contains(SqlTypeEnum.Trigger);

      public bool IsExportingTTys => RequiredTypes.Contains(SqlTypeEnum.TableType);

      /// <summary>
      /// Scrting handles USERDEFINEDTYPE, USERDEFINEDDATATYPE and USERDEFINEDTABLETYPE the same
      /// </summary>
      public bool IsExportingUsrDefTys => RequiredTypes.Contains(SqlTypeEnum.UserDefinedDataType);

      public bool IsExportingVws => RequiredTypes.Contains(SqlTypeEnum.View);

      public bool IsExportingAssemblies => RequiredTypes.Contains(SqlTypeEnum.Assembly);

      /// <summary>
      /// Validates the params configuration
      /// 
      /// Changes:
      /// 240922: now throws exception if validation failed.
      /// </summary>
      /// <param name="p"></param>
      /// <param name="msg"></param>
      /// <returns></returns>
      public bool Validate(out string msg)
      {
         bool ret = false;
         msg = "";

         //----------------------------------------------
         //  Chk that all mandatory fields are spec'd
         //----------------------------------------------

         do
         {
            var spec_msg = " must be specified";

            //if( AddTimestamp        == null) { msg = "add timestamp)"            + spec_msg; break;}
            //if( DisplayScript       == null) { msg = "DisplayScript"             + spec_msg; break;}
            //if( string.IsNullOrEmpty(IndividualFiles) { msg = "Individual Files"          + spec_msg; break; }
            //if( IsExportingData     == null)     { msg = "IsExportingData"       + spec_msg; break; }
            //if( IsExportingDb       == null){ msg = "-export_database"           + spec_msg; break;}
            //if( IsExportingFns      == null){ msg = "IsExprtngFns   "            + spec_msg; break;}
            //if( IsExportingProcs    == null){ msg = "IsExprtngProcs "            + spec_msg; break;}
            //if( IsExportingSchema   == null){ msg = "IsExprtngSchema"            + spec_msg; break;}
            //if( IsExportingTbls     == null){ msg = "IsExprtngTbls  "            + spec_msg; break;}
            //if( IsExportingTTys     == null){ msg = "IsExprtngTTys  "            + spec_msg; break;}
            //if( IsExportingVws      == null){ msg = "IsExprtngVws   "            + spec_msg; break;}
            //if( ScriptUseDb         == null){ msg = "script usedb)"              + spec_msg; break;}
            if ( CreateMode          == CreateModeEnum.Undefined) { msg = "create mode"               + spec_msg; break;}
            if( string.IsNullOrEmpty(Database)){ msg = "database"                  + spec_msg; break;}
            if( string.IsNullOrEmpty(FilePath)) { msg = "configurataion file path" + spec_msg; break; }
            //if( string.IsNullOrEmpty(Instance)) { msg = "Instance"                  + spec_msg; break; }
            if ( string.IsNullOrEmpty(LogFile)){ msg = "log file"                   + spec_msg; break;}
            if( LogLevel            == LogLevel.Undefined){ msg = "log level"                  + spec_msg; break;}
            if( String.IsNullOrEmpty(Name))    { msg = "configurataion name"+ spec_msg; break; }
            if( RequiredSchemas.Count == 0){ msg = "required schemas"           + spec_msg; break; }
            if( RequiredTypes.Count   == 0){ msg = "required types"             + spec_msg; break;}
            if( string.IsNullOrEmpty(Server)){ msg = "server name)"               + spec_msg; break;}
            if(string.IsNullOrEmpty(ScriptFile)){ msg = "export Script Path)"        + spec_msg; break;}

            //  POST 2: if timestamp is specified the logfile and script file sould contain the timestamp
            if (AddTimestamp == true)
            {
               if(ScriptFile?.IndexOf(Timestamp) == 0) { msg = "Script file name does not contain timestamp but AddTimestamp is specified"; break; }
               if(LogFile   ?.IndexOf(Timestamp) == 0) { msg = "Log file name does not contain timestamp but AddTimestamp is specified"; break; }
            }

            ret = true;
         } while (false);

         if(ret == false)
            LogE($"Params validation failed: {msg}");

         Assertion(ret == true, $"Params validation failed: {msg}");
         // ASSERTION: all fields of P are specified
         return LogRT(ret, msg);
      }

      /// <summary>
      /// 1 Main accessor to the configuration
      /// </summary>
      /// <param name="key"></param>
      /// <param name="_default"></param>
      /// <returns></returns>
      static string? GetAppSettingAsString(string key, string? _default = null)
      {
         return Config.GetValue<string>($"appSettings:{key}");
      }

      /// <summary>
      /// 1 Main accessor to the configuration
      /// </summary>
      /// <typeparam name="T"></typeparam>
      /// <param name="key"></param>
      /// <param name="_default"></param>
      /// <returns></returns>
      static T? GetAppSetting<T>(string key, T? _default = default(T))
      {
         T? t =  Config.GetValue<T>($"appSettings:{key}");

         if (t==null)
            t= _default;

         return t;
      }

      /// <summary>
      /// Tables and Table types cannot be modified using alter xx like Procedures and functions can.
      /// So if we aer altering and tables or tables types are spec'd then remove them
      /// </summary>
      protected void EnsureCreateModeAndReqTypesConsistent()
      {
         if(CreateMode == CreateModeEnum.Alter)
         {
            // Remove RequiredTypes table and table type for alter
            if(RequiredTypes?.Contains(SqlTypeEnum.Table) ?? false)
               LogI($"Not Removing Table from RequiredTypes because of ALTER mode");
            //   RequiredTypes.Remove(SqlTypeEnum.Table);

            if(RequiredTypes?.Contains(SqlTypeEnum.TableType) ?? false)
               RequiredTypes.Remove(SqlTypeEnum.TableType);
         }
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
      public static string GetLogFileFromConfig()
      {
         return GetAppSetting<string>("Log File") ?? DefaultLogFile;
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
      public static string GetScriptDirFromConfig()
      {
         return GetAppSetting<string>("Script Dir") ?? DefaultLogFile;
      }

      /// <summary>
      /// Description:
      /// Makes params secondary state consistent 
      /// with the primary (user set) state
      /// especially the IsExporting flags
      /// Based on the Create Mode type
      /// 
      /// </summary>
      /// <param name="p"></param>
      public bool Normalise( out string msg)
      {
         LogST();
         bool ret = true;
         msg      = "";
         IsExportingData = false;

         // Modify for alter
         EnsureCreateModeAndReqTypesConsistent();
         return LogRT(ret, msg);
      }

      /// <summary>
      /// Updates both the log file and the script file with timestamp
      /// if AddTimestamp true and not already timestamped
      ///
      /// POST
      /// If the log file was changed then this will update the Logger log file path
      ///
      /// </summary>
      /// <returns>true if either file was changed</returns>
      public bool UpdateFileNamesWithTimestamp()
      {
         LogST();
         bool ret = false;

         if(AddTimestamp == true)
         {
            string tmp;

            if(AddTimestampToFileName( LogFile, out tmp))
            {
               ret = true;
               LogFile = tmp;
               // If changed update the Logger ASAP
               Logger.LogFile = LogFile;
            }

            if(!(Logger.LogFile?.Equals(LogFile) ?? false))
               Logger.LogFile = LogFile;

             if (AddTimestampToFileName( ScriptFile, out tmp))
            {
               ret = true;
               ScriptFile = tmp;
            }
         }

         return LogRT(ret);
      }

      public override bool Equals( object? obj )
      {
         Params? b = obj as Params;
         Assertion(b != null);
         string msg = "";

         if(b != null)

         do
         {
            if(Server      != b.Server    ) { msg = $"a ServerName   :{Server    } b servername   :{b.Server    }"; break; }
            if(Instance    != b.Instance  ) { msg = $"a InstanceName :{Instance  } b InstanceName :{b.Instance  }"; break; }
            if(Database    != b.Database  ) { msg = $"a DatabaseName :{Database  } b DatabaseName :{b.Database  }"; break; }
            if(ScriptFile  != b.ScriptFile) { msg = $"a ScriptFile   :{ScriptFile} b ScriptFile   :{b.ScriptFile}"; break; }

            if((RequiredSchemas == null) && (b.RequiredSchemas != null) ||
               (RequiredSchemas != null) && (b.RequiredSchemas == null)) { msg = $"a RequiredSchemas :{RequiredSchemas   } b RequiredSchemas   :{b.RequiredSchemas   }"; break; }

            // Assertion: either both are null or both are not null
            if((RequiredSchemas != null) && (b.RequiredSchemas != null))
            {
               if(RequiredSchemas.Count != b.RequiredSchemas.Count) { msg = $"a RequiredSchemas :{RequiredSchemas   } b RequiredSchemas   :{b.RequiredSchemas   }"; break; }

               foreach(var item in RequiredSchemas)
               {
                  if(!b.RequiredSchemas.Contains(item)) 
                  {
                     msg = $"a RequiredSchemas :{RequiredSchemas   } b RequiredSchemas   :{b.RequiredSchemas   }"; 
                     break; 
                  }
               }
            }

            if((RequiredTypes == null) && (b.RequiredTypes != null) ||
               (RequiredTypes != null) && (b.RequiredTypes == null)) { msg = $"a RequiredTypes   :{RequiredTypes   } b RequiredTypes   :{b.RequiredTypes   }"; break; }

            if((RequiredTypes != null) && (b.RequiredTypes != null))
            {
               if(RequiredTypes.Count != b.RequiredTypes.Count) { msg = $"a RequiredTypes   :{RequiredTypes   } b RequiredTypes   :{b.RequiredTypes   }"; break; }

               foreach(var item in RequiredTypes)
                  if(!b.RequiredTypes.Contains(item)) { msg = $"a RequiredTypes   :{RequiredTypes   } b RequiredTypes   :{b.RequiredTypes   }"; break; }
            }

            if(CreateMode   != b.CreateMode)   { msg = $"a CreateMode    :{CreateMode   } b CreateMode   : {b.CreateMode   }"; break; }
            if(ScriptUseDb  != b.ScriptUseDb)  { msg = $"a ScriptUseDb   :{ScriptUseDb  } b ScriptUseDb  : {b.ScriptUseDb  }"; break; }
            if(AddTimestamp != b.AddTimestamp) { msg = $"a AddTimestamp  :{AddTimestamp } b AddTimestamp : {b.AddTimestamp }"; break; }
            if(DisplayScript!= b.DisplayScript){ msg = $"a DisplayScript :{DisplayScript} b DisplayScript: {b.DisplayScript}"; break; }
            if(DisplayLog   != b.DisplayLog)   { msg = $"a DisplayLog    :{DisplayLog   } b DisplayLog   : {b.DisplayLog   }"; break; }
            if(LogLevel     != b.LogLevel)     { msg = $"a DisplayLog    :{LogLevel     } b DisplayLog   : {b.LogLevel     }"; break; }

            // Assertion if here then all equality tests passeds
            return true;
         } while(false);

         Logger.Log($"Params Equals failed: { msg}");
         //Assertion if here then a check failed
         return false;
      }

      public override string ToString()
      {
         string Line = new string('-', 80);
         StringBuilder s = new StringBuilder();

         s.Append("\r\n");
         s.AppendLine(Line);
         s.AppendLine($" Type            : {GetType().Name}");
         s.AppendLine(Line);

         s.AppendLine($" CreateMode      : {CreateMode}");
         s.AppendLine($" Database        : {Database}");
         s.AppendLine($" DisplayLog      : {DisplayLog}");
         s.AppendLine($" DisplayScript   : {DisplayScript}");
         s.AppendLine($" FilePath        : {FilePath}");
         s.AppendLine($" IndividualFiles : {IndividualFiles}");
         s.AppendLine($" Instance        : {Instance}");
         s.AppendLine($" IsExprtngData   : {IsExportingData}");
         s.AppendLine($" LogFile         : {LogFile}");
         s.AppendLine($" LogLevel        : {LogLevel}");
         s.AppendLine($" Name            : {Name}");
         s.AppendLine($" RequiredSchemas : {RequiredSchemas}");
         s.AppendLine($" RequiredTypes   : {RequiredTypes}");
         s.AppendLine($" Script Dir      : {ScriptDir}");
         s.AppendLine($" Script File     : {ScriptFile}");
         s.AppendLine($" ScriptUseDb     : {ScriptUseDb}");
         s.AppendLine($" Server          : {Server}");
         s.AppendLine($" AddTimestamp    : {AddTimestamp}");
         s.AppendLine($" Timestamp       : {Timestamp}");

         s.AppendLine();

         // Required Schemas
         string txt = RequiredSchemas?.Count.ToString() ?? "<null>";
         s.AppendLine($" RequiredSchemas : {txt}");

         if(RequiredSchemas != null)
            foreach(var item in RequiredSchemas)
               s.AppendLine($"\t{item}"); 

         s.AppendLine();

         // RequiredTypes
         txt = RequiredTypes?.Count.ToString() ?? "<null>";
         s.AppendLine($" RequiredTypes : {txt}");

         if(RequiredTypes != null)
            foreach(var item in RequiredTypes)
               s.AppendLine($"\t{item}"); 

//         s.AppendLine();
//         s.AppendLine(Line);
//         s.AppendLine();
         return s.ToString();
      }

      // Warning	CS0659	'Params' overrides Object.Equals(object o) but does not override Object.GetHashCode()	DbScripterLib	D:\Dev\Db\Ut\DbScriptExporter\DbScripterLib\Params.cs	11	Active

      public override int GetHashCode()
      {
         return base.GetHashCode();
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="name"></param>
      /// <param name="prms"></param>
      /// <param name="serverName"></param>
      /// <param name="instanceName"></param>
      /// <param name="databaseName"></param>
      /// <param name="scriptFile"></param>
      /// <param name="requiredSchemas"></param>
      /// <param name="requiredTypes"></param>
      /// <param name="createMode"></param>
      /// <param name="useDb"></param>
      /// <param name="addTs"></param>
      /// <param name="logFile"></param>
      /// <param name="isXprtDta"></param>
      /// <param name="displayScript"></param>
      public Params
      (
      )
      {
      }
      public void ClearState()
      {
         AddTimestamp      = false;
         CreateMode        = CreateModeEnum.Undefined;
         LogLevel = LogLevel.Undefined;

         Database          = "";
         DisplayLog        = false;
         DisplayScript     = false;
         IndividualFiles   = false;
         Instance          = "";
         LogFile           = "";
         RequiredSchemas   = new List<string>();
         RequiredTypes     = new List<SqlTypeEnum>();
         ScriptFile        = "";
         Server            = "";

         IsExportingData = false;
         ScriptUseDb     = false;
      }

      /// <summary>
      /// Description takes a comma separated list of type codes
      /// e.g.: F,P,TTy
      /// 
      ///   F : function
      ///   P : procedure
      ///   T : table
      ///   V : view
      ///   TTy: Table type
      ///
      /// PRECONDITIONS:
      /// none
      /// POSTCONDITIONS:
      /// Returns an array of SqlTypeEnum based on  the characters in 
      /// the supplied string.
      /// Each characters is a key to th etype as defined in the map spec'd below
      /// asserts that all characters in the string are legal types
      /// </summary>
      /// <param name="rs">like:  'FTPV'</param>
      /// <returns></returns>
      public List<SqlTypeEnum>? PrsReqTypes( string? requiredTypes )
      {
        LogS();

        if(string.IsNullOrEmpty(requiredTypes))
            return null;

         requiredTypes = requiredTypes?.ToUpper();

         // trim and remove surrounding {}
         requiredTypes = requiredTypes?.Trim(new[] { ' ', '{', '}' });
         string[] reqTypes = requiredTypes?.Split(new [] {','}, StringSplitOptions.RemoveEmptyEntries) ?? new string[0];
         
         // Trim each item
         for(int i=0; i<reqTypes.Length; i++)
            reqTypes[i] = reqTypes[i].Trim();

         List<SqlTypeEnum> list = new List<SqlTypeEnum>();

         // get the types, throw if not found
         foreach (string? item in reqTypes)
            list.Add(item.FindEnumByAliasExact<SqlTypeEnum>( true));

         LogL($"Found {list.Count} items");
         return list;
      }


      /// <summary>
      /// Handles strings like:
      ///   "{test, [dbo]", "dbo",  "", null}
      ///   "   {   dbo    }   ", "" null
      ///
      /// PRECONDITIONS: 
      ///   PRE 1: Server must be specified
      ///   PRE 2: instance must be specified
      ///
      /// POSTCONDITIONS: 
      ///   POST 1: returns null if rs is null, empty
      ///   POST 2: returns null if rs contains no schemas
      ///   POST 3: returns all the required schemas in rs in the returned collection
      ///   POST 4: contains no empty schemas
      ///   POST 5: *Server, Instance Database exist              removed as they involve network - better do this validation at run time
      ///   POST 6: *required schemas do exist in the database
      ///           AND they match the Case of the Db Schema name
      ///
      /// Method:
      ///   trim
      ///   remove surrounding {}
      ///   split on ,
      ///   for each schema: remove any []and trim
      /// </summary>
      /// <param name="rs">required_schemas</param>
      /// <returns>string array of the unwrapped schemas in rs</returns>
      public List<string>? PrsRegSchema( string rs )
      {
         List<string>? requiredSchemaList = null;

         do
         {
            //  POST 1: returns null if rs is null, empty
            if (string.IsNullOrEmpty(rs))
               break;

            requiredSchemaList = new List<string>();

            // Trim and remove surrounding {}
            rs = rs.Trim(new[] { ' ', '{', '}' });

            // Split on ,
            string[] rschemasNames = rs.Split(new []{ ',', '[', ']'}, StringSplitOptions.RemoveEmptyEntries) ?? new string[0];

            // for each schema:  any [] and trim
            for(int i = 0; i < rschemasNames.Length; i++)
            {
               var rschemaName = rschemasNames[i];
               rschemaName = rschemaName.Trim(new[] { ' ', '[', ']' });
            
               if(!string.IsNullOrEmpty(rschemaName))
                  requiredSchemaList.Add(rschemaName);
            }

            // POST 2: returns null if rs contains no schemas
            if(requiredSchemaList.Count == 0)
               return null;

            // POST 3: returns all the required schemas in rs in the returned collection
            // POST 4: contains no empty schemas
            foreach (var item in requiredSchemaList)
               Postcondition<ArgumentException>(string.IsNullOrEmpty(item) == false, "POST 4: should contain no empty schemas");

         } while (false);

         return requiredSchemaList;
      }

      /*
      public static Params PopParams
         (
              string?         name              = null
             ,Params?         prms              = null // Use this state to start with and update with the subsequent parameters
             ,bool?           addTimestamp      = null
             ,CreateModeEnum? createMode        = null // must be null to avoid overwriting prms if set
             ,string?         databaseName      = null
             ,bool?           displayScript     = null
             ,bool?           displayLog        = null
             ,string?         filePath          = null
             ,bool?           isExportingData   = null
             ,string?         instanceName      = null
             ,string?         logFile           = null
             ,LogLevel?       logLevel          = null
             ,bool?           individualFiles   = null
             ,string?         requiredSchemas   = null
             ,string?         requiredTypes     = null
             ,string?         scriptDir         = null
             ,string?         scriptFile        = null
             ,string?         serverName        = null
             ,string?         timestamp         = null
             ,bool?           useDb             = null
         )
      {
         Params p = new Params();

         p.PopFrom(
              name             : name
            , prms             : prms
            , addTimestamp     : addTimestamp
            , createMode       : createMode
            , databaseName     : databaseName
            , displayLog       : displayLog
            , displayScript    : displayScript
            , filePath         : filePath
            , individualFiles  : individualFiles
            , instanceName     : instanceName
            , isExportingData  : isExportingData
            , logFile          : logFile
            , logLevel         : logLevel
            , requiredSchemas  : requiredSchemas
            , requiredTypes    : requiredTypes
            , useDb            : useDb
            , serverName       : serverName
         );

         p.FilePath = name;
         return p;
      }
      */

      /*
      /// <summary>
      /// 2 stages:
      ///   1: does copy of prms overwite mode
      ///   2:copies state from the other parameters if and only if the current property is null
      ///   
      /// To copy state from the prms if and only if the current property is null use PopFrom2
      /// </summary>
      /// <param name="prms"></param>
      /// <param name="serverName"></param>
      /// <param name="instanceName"></param>
      /// <param name="databaseName"></param>
      /// <param name="scriptFile"></param>
      /// <param name="newSchNm"></param>
      /// <param name="requiredSchemas"></param>
      /// <param name="requiredTypes"></param>
      /// <param name="createMode"></param>
      /// <param name="useDb"></param>
      /// <param name="addTs"></param>
      /// <param name="logFile"></param>
      /// <param name="isXprtDtangData"></param>
      /// <param name="displayScript"></param>
      public void PopFrom
          (
              string?         name              = null
             ,Params?         prms              = null // Use this state to start with and update with the subsequent parameters
             ,bool?           addTimestamp      = null
             ,CreateModeEnum? createMode        = null // must be null to avoid overwriting prms if set
             ,string?         databaseName      = null
             ,bool?           displayLog        = null
             ,bool?           displayScript     = null
             ,string?         filePath          = null
             ,bool?           individualFiles   = null
             ,string?         instanceName      = null
             ,bool?           isExportingData   = null
             ,string?         logFile           = null
             ,LogLevel?       logLevel          = null
             ,string?         requiredSchemas   = null
             ,string?         requiredTypes     = null
             ,string?         scriptDir         = null
             ,string?         scriptFile        = null
             ,string?         serverName        = null
             ,string?         timestamp         = null
             ,bool?           useDb             = null
         )
      {
         // overwite 
         // overwrite specified parameters if not null
         // If prms is supplied use it as the default configuration
         if(prms != null)
            CopyFrom(prms);

         // Update state if overwrite or param is defined
         if(requiredSchemas != null)
            RequiredSchemas = PrsRegSchema(requiredSchemas);

         if(requiredTypes != null)
            RequiredTypes= PrsReqTypes  (requiredTypes);

         this.UpdatePropertyIfNeccessary("AddTimestamp",    addTimestamp);
         this.UpdatePropertyIfNeccessary("CreateMode",      createMode);
         this.UpdatePropertyIfNeccessary("Database",        databaseName); 
         this.UpdatePropertyIfNeccessary("DisplayLog",      displayLog);
         this.UpdatePropertyIfNeccessary("DisplayScript",   displayScript);
         this.UpdatePropertyIfNeccessary("FilePath",        filePath);
         this.UpdatePropertyIfNeccessary("IndividualFiles", individualFiles);
         this.UpdatePropertyIfNeccessary("Instance",        instanceName);
         this.UpdatePropertyIfNeccessary("IsExprtngData",   isExportingData);
         this.UpdatePropertyIfNeccessary("LogFile",         logFile);
         this.UpdatePropertyIfNeccessary("LogLevel",        logLevel);
         this.UpdatePropertyIfNeccessary("Name",            name);
         this.UpdatePropertyIfNeccessary("RequiredSchemas", requiredSchemas); // *
         this.UpdatePropertyIfNeccessary("RequiredTypes",   requiredTypes);   // *
         this.UpdatePropertyIfNeccessary("ScriptDir",       scriptDir);
         this.UpdatePropertyIfNeccessary("ScriptFile",      scriptFile);
         this.UpdatePropertyIfNeccessary("ScriptUseDb",     useDb);
         this.UpdatePropertyIfNeccessary("Server",          serverName);
         this.UpdatePropertyIfNeccessary("Timestamp",       timestamp);
      }
      */
      /*
      /// <summary>
      /// This copies state from prams if and only if the current property is null
      /// </summary>
      /// <param name="prms"></param>
      public void PopFrom2( Params p)
      {
         // Update state if param is defined
         // Update state if overwrite or param is defined
         if(p.RequiredSchemas != null)
            RequiredSchemas   = new List<string>(p.RequiredSchemas);       // copy not ref

         if(p.RequiredTypes != null)
            RequiredTypes  = new List<SqlTypeEnum>(p.RequiredTypes); // copy not ref

         this.UpdatePropertyIfNeccessary("AddTimestamp",    p.AddTimestamp    );
         this.UpdatePropertyIfNeccessary("CreateMode",      p.CreateMode      );
         this.UpdatePropertyIfNeccessary("Database",        p.Database        );
         this.UpdatePropertyIfNeccessary("DisplayLog",      p.DisplayLog      );
         this.UpdatePropertyIfNeccessary("DisplayScript",   p.DisplayScript   );
         this.UpdatePropertyIfNeccessary("FilePath",        p.FilePath        );
         this.UpdatePropertyIfNeccessary("IndividualFiles", p.IndividualFiles );
         this.UpdatePropertyIfNeccessary("Instance",        p.Instance        );
         this.UpdatePropertyIfNeccessary("IsExportingData", p.IsExportingData );
         this.UpdatePropertyIfNeccessary("LogFile",         p.LogFile         );
         this.UpdatePropertyIfNeccessary("LogLevel",        p.LogLevel        );
         this.UpdatePropertyIfNeccessary("Name",            p.Name            );
         this.UpdatePropertyIfNeccessary("RequiredSchemas", p.RequiredSchemas );
         this.UpdatePropertyIfNeccessary("RequiredTypes",   p.RequiredTypes   );
         this.UpdatePropertyIfNeccessary("ScriptDir",       p.ScriptDir       );
         this.UpdatePropertyIfNeccessary("ScriptFile",      p.ScriptFile      );
         this.UpdatePropertyIfNeccessary("ScriptUseDb",     p.ScriptUseDb     ); 
         this.UpdatePropertyIfNeccessary("Server",          p.Server          );
         this.UpdatePropertyIfNeccessary("Timestamp",       p.Timestamp       );
      }
      */
      /*
      /// <summary>
      ///   Full copy allways of all state from p other than status
      /// </summary>
      /// <param name="p"></param>
      public void CopyFrom( Params p )
      {
         AddTimestamp      = p.AddTimestamp;
         CreateMode        = p.CreateMode;
         Database          = p.Database;
         DisplayLog        = p.DisplayLog;
         DisplayScript     = p.DisplayScript;
         FilePath          = p.FilePath;
         IndividualFiles   = p.IndividualFiles;
         Instance          = p.Instance;
         IsExportingData   = p.IsExportingData;
         LogFile           = p.LogFile;
         LogLevel          = p.LogLevel;
         Name              = p.Name;
         RequiredSchemas   = (p.RequiredSchemas  != null) ? new List<string>     (p.RequiredSchemas): null; // copy not ref
         RequiredTypes     = (p.RequiredTypes    != null) ? new List<SqlTypeEnum>(p.RequiredTypes)  : null; // copy not ref
         ScriptDir         = p._scriptDir;
         ScriptFile        = p.ScriptFile;
         ScriptUseDb       = p.ScriptUseDb;
         Server            = p.Server;
         Timestamp         = p.Timestamp;
      }
      */

      /// <summary>
      /// Adds the timestamp to the file path like 
      /// dir\fileName_ts.ext"
      /// </summary>
      /// <param name="filePath"></param>
      /// <returns></returns>
      public bool AddTimestampToFileName(string filePath, out string newFilePath)
      {
         bool ret = false;
         Assertion(Timestamp.Length > 0, "Params.AddTimestampToFileName failed: timestamp not set");

         if(filePath.IndexOf(Timestamp) == -1)
         { 
            var dir  = Path.GetDirectoryName(filePath);
            var file = Path.GetFileNameWithoutExtension(filePath);
            var ext  = Path.GetExtension(filePath);
            newFilePath =  $@"{dir}\{file}_{Timestamp}{ext}";
            ret = true;
         }
         else
         {
            newFilePath = filePath;
         }

         return ret;
      }

      /// <summary>
      /// Usage: E.G.DbScripter [-c config file]
      /// Where:
      /// -c:        standard XML config file                                       default: the local App.config
      ///
      /// PRECONDITIONS:
      ///  PRE 1: timestamp is set (by cstr)
      ///
      /// RESPONSIBILITIES and POSTCONDITIONS
      /// POST 1: valid state for export
      /// POST 2: all fields of P are specified (not null)
      ///      ServerName
      ///      InstanceName
      ///      DatabaseName
      ///      ExportScriptPath
      ///      RequiredSchemas
      ///      RequiredTypes
      ///      CreateMode
      ///      ScriptUseDb
      ///      AddTimestamp
      ///
      /// POST 3: if timestamp is specified the logfile and script file contain the timestamp
      ///  
      /// POST 4: no invalid args
      ///  
      /// Changes
      /// 240401: added check for empty args, parameter p is now ref and not nulled in this process
      /// 240922: E84500: as of 240922: Command line args are other than the configuration file are no longer supported
      ///  
      /// Tests
      ///  null args: DbScripterAppTests.App_Minimal_paramsTest
      /// </summary>
      /// <param name="args"></param>
      public static bool ParseArgs( string[] args, ref Params p, out string msg) // -M create|alter
      {
         LogST();
         //bool ret = false;
         //string? configFile = null;
         msg = "";
         // 240922: E84500: as of 240922: Command line args are other than the configuration file are no longer supported
         throw new NotSupportedException("E84500: as of 24109022: Command line args are other than the configuration file are no longer supported");
      }
      

      /// <summary>
      /// Gets the default config from app settings json
      /// 
      /// Changes:
      /// 240922: now updates the files with the timestamp, if the add timestamp is flag set
      /// </summary>
      /// <param name="p"></param>
      public static void LoadFromConfig(Params p)
      {
         var config_nm   = GetAppSettingAsString("Name");
         var config_file = GetAppSettingAsString("FilePath");
         LogI($"LoadFromConfig(): config_nm [{config_nm}], config_file: [{config_file}]");
         string scriptDir  = GetAppSettingAsString("Script Dir") ?? "" ;

         p.Name            = GetAppSettingAsString("Name", "") ?? "";
         p.FilePath        = GetAppSettingAsString("FilePath", "") ?? "";
         p.Server          = GetAppSettingAsString("Server");
         p.Instance        = GetAppSettingAsString("Instance", "SqlExpress") ?? "";
         p.Database        = GetAppSettingAsString("Database") ?? "";
         p.AddTimestamp    = GetAppSetting<bool>  ("AddTimestamp", false);
         p.Timestamp       = GetTimestamp(fine: false);
         p.ScriptDir       = p.AddTimestamp ? $"{scriptDir}\\{p.Timestamp}" : scriptDir;
         p.ScriptFile      = @$"{p.ScriptDir}\{GetAppSettingAsString("Script File")}";
         p.CreateMode      = GetAppSettingAsString("CreateMode").FindEnumByAliasExact<CreateModeEnum>();
         p.ScriptUseDb     = GetAppSetting<bool>("ScriptUseDb", _default: false);
         p.DisplayScript   = GetAppSetting<bool>("DisplayScript", true);
         p.DisplayLog      = GetAppSetting<bool> ("DisplayLog", false);
         p.LogFile         = GetAppSettingAsString("LogFile", "DbScripter.logFile") ?? "";
         p.LogLevel        = GetAppSettingAsString("LogLevel", "Info").FindEnumByAliasExact<LogLevel>();
         p.RequiredSchemas = GetAppSettingAsString("RequiredSchemas")?.Split(',')?.ToList() ?? new List<string>();
         p.RequiredTypes   = GetRequiredTypesFromConfig() ?? new List<SqlTypeEnum>();
         p.IsExportingData = GetAppSetting<bool>("IsExportingData", false);
         p.IndividualFiles = GetAppSetting<bool>("IndividualFiles", false);

         p.UpdateFileNamesWithTimestamp();

         LogI($"Param.LoadFromConfig: {p.ToString()}");
         Assertion(p.Validate(out string msg), "Params.LoadFromConfig failed");
      }

      private static List<SqlTypeEnum>? GetRequiredTypesFromConfig()
      {
         // Get the comma separated values
         string s = GetAppSetting("RequiredTypes", "") ?? "";
         var items = s.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

         // Parse the enums using the Alias attribute
         List<SqlTypeEnum> ? types = new();

         foreach(string item in items)
         {
            string itm = item;
            itm = (itm.ToLower() == "assemblies") ? "Assembly" : itm.TrimEnd('s');
            types.Add(itm.FindEnumByAliasExact<SqlTypeEnum>());
         }
         
         return types;
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="args"></param>
      /// <param name="p"></param>
      /// <param name="msg"></param>
      /// <returns></returns>
      public bool IsValid( out string msg) // -M create|alter
      {
         LogST();
         bool ret = false;

         do
         {
            //----------------------------------------------
            //  Chk that all mandatory fields are spec'd
            //----------------------------------------------
            var spec_msg = " must be specified";
            if (string.IsNullOrWhiteSpace(Database))  { msg = "database"       + spec_msg; break; }
            if (string.IsNullOrWhiteSpace(ScriptFile)){ msg = "instance name"  + spec_msg; break; }
            if (string.IsNullOrWhiteSpace(Server))    { msg = "server name"    + spec_msg; break; }
            if (string.IsNullOrWhiteSpace(LogFile))   { msg = "logFile file"+ spec_msg; break; }

            if (CreateMode       == CreateModeEnum.Undefined) { msg = "create mode"           + spec_msg; break; }
//            if (DisplayScript    == false) { msg = "display script"    + spec_msg; break; }
            if (RequiredSchemas.Count==0) { msg = "required schemas"      + spec_msg; break; }
            if (RequiredTypes.Count == 0) { msg = "target child types"    + spec_msg; break; }
 //           if (AddTimestamp     == null) { msg = "add timestamp to SFN"  + spec_msg; break; }
//            if (ScriptUseDb      == null) { msg = "script usedb"          + spec_msg; break; }
            if (LogLevel         == LogLevel.Undefined) { msg = "LogLevel Error, Warning, Notice, Info, Debug, Trace" + spec_msg; break; }
//            if (IsExportingData  == null) { msg = "-export_data (Export Data)"   + spec_msg; break; }
//            if (IsExportingDb    == null) { msg = "-export_database (Export Database)" + spec_msg; break; }
//            if (IsExportingFns   == null) { msg = " (IsExprtngFns   )          " + spec_msg; break; }
//            if (IsExportingProcs == null) { msg = " (IsExprtngProcs )          " + spec_msg; break; }
//            if (IsExportingSchema== null) { msg = " (IsExprtngSchema)          " + spec_msg; break; }
//            if (IsExportingTbls  == null) { msg = " (IsExprtngTbls  )          " + spec_msg; break; }
//            if (IsExportingTTys  == null) { msg = " (IsExprtngTTys  )          " + spec_msg; break; }
//            if (IsExportingVws   == null) { msg = " (IsExprtngVws   )          " + spec_msg; break; }
//            if (AddTimestamp     == null) { msg = " (AddTimestamp   )          " + spec_msg; break; }

            // ASSERTION: all ok so return true
            ret = true;
            msg = "";
         } while (false);

         if (!ret)
            msg = $"Error parsing args: {msg}";

         return LogRI(ret, msg);
      }



      /*
      /// <summary>
      /// This returns the value if a switch with no args is set
      /// 
      /// Preconditions:
      ///  PRE 1: arg is not supposed to have a value 
      /// 
      /// Method:
      ///   get the default if not set
      ///   then get the type
      ///   map type to standard 'set' default value
      ///   if mapping not found throw not implmented exception
      /// </summary>
      /// <returns>the  value if set for a switch with no args</returns>
      protected static object GetDefaultValueIfSwitchSet(string key, Params p)
      {
         // Precondition:
         Precondition(!ArgHasValue(key), $"Error: GetDefaultValueIfSwitchSet({key}): trying to get a default value if set of a switch that takes a parameter");

         // get the default if not set
         object? val = p.GetDefaultForSwitch(key);

         if(val == null)
            throw new ArgumentException(key, $"Params.GetDefaultValueIfSwitchSet() - bad key value [{key}]");

         // get the type from the 'unset' default value
         var ty = val.GetType();

         // map type to standard 'set' default value
         switch (ty.Name)
         {
            case "Boolean":
               val = true;
               break;

            default:
               // if mapping not found throw not implmented exception
               throw new NotImplementedException($"GetArg() get value if set unhandled type: {ty.FullName} handler is not implemented");
         }

         return val;
      }
      */

      /*
      /// <summary>
      /// Templated version of the above non templated GetArg()
      /// </summary>
      /// <typeparam name="T"></typeparam>
      /// <param name="args"></param>
      /// <param name="argsU"></param>
      /// <param name="key"></param>
      /// <param name="p"></param>
      /// <param name="get_value"></param>
      /// <returns></returns>
      protected static T? GetArgT<T>(string[] args, string[] argsU, string key, Params p)// where T: struct
      {
         // if arg does not have a value and exists
         var s = GetArg(args, argsU, key, p);
         T?  t = default(T); 

         if(s != null)
            t = (T)Convert.ChangeType(s, typeof(T));

         return t;
      }
      */
      /*
      /// <summary>
      /// gets the Log level from params, or the default
      /// </summary>
      /// <param name=""></param>
      /// <param name=""></param>
      /// <param name=""></param>
      /// <param name=""></param>
      /// <returns></returns>
      protected static LogLevel GetLogLevel(string[] args, string[] argsU, Params p)
      {
         var s = GetArgT<string>(args, argsU, "-log_level", p);
         var ret = CommonLib.LogLevel.Info;

         if(!Enum.TryParse<CommonLib.LogLevel>(s, out ret))
            ret = GetDefaultForPropertyT<LogLevel>("LogLevel", p);//Common.LogLevel.Info;

         return ret;
      }
      */
      /*
      /// <summary>
      /// Utils.Precondition args not null
      /// </summary>
      /// <param name="args"></param>
      /// <returns></returns>
      protected static string[] GetArgAsArray(string[] args, string[] argsU, string key, Params p)
      {
         // get the {}
         string str = GetArgT<string>( args, argsU, key, p) ?? "";
         str = str.Replace("{", "").Replace("}", "");
         return str.Split();
      }
      */

      /*
      /// <summary>
      /// Logs the arguments
      /// PRECONDITIONS
      ///   Expects ags to have 0 or 1 value
      ///   
      /// POSTCONDITIONS:
      ///   if args is populated then this rtn returns a string describing them: 1 line per switch and its [value] if any
      ///   else "No args ????"
      /// </summary>
      /// <param name="args"></param>
      protected static void LogArgs(string []? args)
      {
         LogC($"\nArgs:\n{ArgsToString(args)}\n");
      }
      */

      /*
      /// <summary>
      /// Logs the arguments
      /// PRECONDITIONS
      ///   Expects ags to have 0 or 1 value
      ///   
      /// POSTCONDITIONS:
      ///   if args is populated then this rtn returns a string describing them: 1 line per switch and its [value] if any
      ///   else "No args ????"
      /// </summary>
      /// <param name="args"></param>
      protected static string ArgsToString(string []? args)
      {
         StringBuilder sb = new();

         // PRE 1
         if((args == null) || args.Length==0)
            return "";

         int i = 0;
         int len = args.Length;
         string arg;
         bool isValue = false;
         string[] hasParam = new []{ "-S", "-I","-D","-disp_log","-disp_script","-RS","-TCT","-E","-CM", "-TS", "-USE"};

         do
         {
            arg = args[i];
            var f = Logger.LogFile;

            // if switch has a value then dont add nl at the end of the msg
            if((isValue == false) && hasParam.Any(s => s.Equals(arg, StringComparison.OrdinalIgnoreCase)))
            {
               sb.Append($"{arg, -12} : [");
               isValue = true;
            }
            else
            {
               sb.AppendLine($"{arg}]");
               isValue = false;
            }
         }while(++i < len);

         return sb.ToString();
      }
      */

      /*
      /// <summary>
      /// Validate args
      /// </summary>
      /// <param name="args"></param>
      /// <returns>true if all args are valid args, false otherwise</returns>
      public static bool ValidateArgs( string[] args, out string msg)
      {
         LogST();
         bool is_valid = true;
         var len = args.Length;
         int i = 0; // 240631: first arg is now the dbscripter app name?? no
         msg = "";

         if(args.Length == 0)
         {
            is_valid = true;
            return LogRT(is_valid, msg); ;
         }

         do
         {
            var arg = args[i];
            string previous_arg = i>0 ? args[i-1] : "no previous arg";
            var argL= arg.ToLower();

            if (IsValidArg(argL))
            {
               // Skip forward over value if it has one
               if(ArgHasValue(argL))
                  i++;
            }
            else
            {
               // Invalid arg
               msg = $"unrecognised argument [i]: [{arg}] previous arg:[{previous_arg}]";
               is_valid = false;
               break;
            }
         } while((++i < len) && (is_valid == true));

         if(is_valid)
            LogD($"valid: {is_valid} msg: {msg}");
         else
            LogE($"validation failed, msg: {msg}");

         return LogRT(is_valid, msg);
      }
      */

      /// <summary>
      /// Determines if scripter should display the script
      /// Override in the testable scripter so that this can be turned off in tests
      /// </summary>
      /// <returns></returns>
      public virtual bool ShoulDisplayScript()
      {
         return DisplayScript ?? false;
      }

      /// <summary>
      /// Determines if scripter should display the logFile
      /// Override in the testable scripter so that this can be turned off in tests
      /// </summary>
      /// <returns></returns>
      public virtual bool ShoulDisplayLog()
      {
         return DisplayLog;
      }

      /// <summary>
      /// Desc: returns the help string to be displayed in the console in the event of a parameter error
      /// 
      /// Usage: 
      /// DbScripter [json configuration file path]
      ///  
      /// E.G.  DbScripter "D:\Dev\DbScripter\DbScripterApp\AppSettings.json"
      /// </summary>
      /// <param name="e"></param>
      public static string GetHelpString(string? msg = null)
      {
         LogST();
         LogLT();

         return @"
Usage: DbScripter [json configuration file path]
E.G.  DbScripter [D:\Dev\DbScripter\DbScripterApp\AppSettings.json]";
      }
   }
}
