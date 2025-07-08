#pragma warning disable CS8604//	Possible null reference argument for parameter 'rs' in 'SqlTypeEnum[]? Params.ParseRequiredTypes(string rs)'.	DbScripterLib	D:\Dev\C#\Db\Ut\DbScriptExporter\DbScripterLib\Params.cs	263	Active
using CommonLib;

using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

using System.Text;

using static CommonLib.Logger;
using static CommonLib.Utils;

namespace DbScripterLibNS
{
   /// <summary>
   /// class to simplify the passing of a number of scripter config parameters
   /// </summary>
   public class Params
   {
      private static IConfigurationRoot? _config = null;

      /// <summary>
      /// Main configuration - set by Program.Main()
      /// </summary>
      public static IConfigurationRoot? Config 
      { 
         get{ return _config; }
         set { _config = value;} 
      }

      //public property call Name with a getter and a setter ;
      public string Name { get; private set; } = "";

      //public property
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

      public static string DefaultLogFile { get; private set; } = @"D:\Logs\DbScripter.log";


      public CreateModeEnum CreateMode { get; set; } = CreateModeEnum.Undefined;
      
      private Dictionary<SqlTypeEnum, List<string>> _requiredItemMap = new Dictionary<SqlTypeEnum, List<string>>();
      public Dictionary<SqlTypeEnum, List<string>> RequiredItemMap { get => _requiredItemMap;}

      public List<string> RequiredAssemblies           => RequiredItemMap[key: SqlTypeEnum.Assembly];
      public List<string> RequiredSchemas              => RequiredItemMap[key: SqlTypeEnum.Schema];
      public List<string> RequiredFunctions            => RequiredItemMap[key: SqlTypeEnum.Function];
      public List<string> RequiredProcedures           => RequiredItemMap[key: SqlTypeEnum.StoredProcedure];
      public List<string> RequiredTables               => RequiredItemMap[key: SqlTypeEnum.Table];
      public List<string> RequiredViews                => RequiredItemMap[key: SqlTypeEnum.View];
      public List<string> RequiredUserDefinedTypes     => RequiredItemMap[key: SqlTypeEnum.UserDefinedType];
      public List<string> RequiredUserDefinedDataTypes => RequiredItemMap[key: SqlTypeEnum.UserDefinedDataType];
      public List<string> RequiredUserDefinedTableTypes=> RequiredItemMap[key: SqlTypeEnum.UserDefinedTableType];

      /// <summary>
      /// the target types are 1 or more required child types
      /// under the root
      /// 
      /// INVARIANT: cannot be empty after init
      /// </summary>
      private List<SqlTypeEnum> _requiredTypes = new();
      //public ref List<SqlTypeEnum> RequiredTypes { get => ref _requiredTypes; }

      /*
      private List<string> _requiredSchemas = new();
      public ref List<string> RequiredSchemas { get => ref  _requiredSchemas; }// private set => _schemas = value; }
      private List<string> _requiredAssemblies = new();
      public ref List<string> RequiredAssemblies { get => ref _requiredAssemblies; }
      private List<string> _requiredFunctions = new();
      public ref List<string> RequiredFunctions { get => ref _requiredFunctions; }
      private List<string> _requiredProcedures = new();
      public ref List<string> RequiredProcedures { get => ref _requiredProcedures; }
      private List<string> _requiredTables = new();
      public ref List<string> RequiredTables { get => ref _requiredTables; }
      private List<string> _requiredViews = new();
      public ref List<string> RequiredViews { get => ref _requiredViews; }
      private List<string> _userDefinedTypes = new(); 
      public ref List<string> RequiredUserDefinedTypes    { get => ref _userDefinedTypes; }
      private List<string> _userDefinedDataTypes = new(); 
      public ref List<string> RequiredUserDefinedDataTypes { get => ref _userDefinedDataTypes; }
      private List<string> _userDefinedTableTypes = new(); 
      public ref List<string> RequiredUserDefinedTableTypes { get => ref _userDefinedTableTypes; }
      */
      public bool ScriptUseDb { get; private set; } = false;
      
      public bool AddTimestamp { get; private set; } = false;

      // Export flags
      public bool WantAll(SqlTypeEnum ty)
      {
         if(!WantAllMap.TryGetValue(ty, out bool v))
            return false;

         return v;
      }
      /*
         return ty == SqlTypeEnum.Assembly                 ? WantAllAssemblies               :
                ty == SqlTypeEnum.Schema                   ? WantAllSchemas                  :
                ty == SqlTypeEnum.Table                    ? WantAllTables                   :
                ty == SqlTypeEnum.View                     ? WantAllViews                    :
                ty == SqlTypeEnum.Function                 ? WantAllFunctions                :
                ty == SqlTypeEnum.StoredProcedure          ? WantAllStoredProcedures         :
                ty == SqlTypeEnum.UserDefinedType          ? WantAllUserDefinedTypes         :
                ty == SqlTypeEnum.UserDefinedDataType      ? WantAllUserDefinedDataTypes     : false
         ;
      }*/

      // public bool WantAllAssemblies { get; set; }
      // public bool WantAllSchemas { get; set; }
      // public bool WantAllTables { get; set; }
      // public bool WantAllFunctions { get; set; }
      // public bool WantAllStoredProcedures { get; set; }
      // public bool WantAllUserDefinedTypes { get; set; }
      // public bool WantAllUserDefinedDataTypes { get; set; }
      // public bool WantAllUserDefinedTableTypes { get; set; }
      // public bool WantAllTableTypes { get; set; }
      // public bool WantAllViews { get; set; }
      public Dictionary<SqlTypeEnum, bool> WantAllMap { get; } = new Dictionary<SqlTypeEnum, bool> ();

      public bool IsExportingType(SqlTypeEnum type) //=> RequiredTypes.Contains(type);
      {
         // Check if want all of this type
         if (WantAllMap.TryGetValue(type, out var ret))
            if(ret)
               return ret;

         // no, check if want any of this type
         if (!RequiredItemMap.TryGetValue(type, out var required_items))
            return false;

         // any
         return required_items.Count()>1;
      }

      /// <summary>
      /// Clears the export flag for a given type
      /// used when scripting config contains alter and table
      /// </summary>
      /// <param name="type"></param>
      protected void ClearExportType(SqlTypeEnum type)
      {
         if (WantAllMap.ContainsKey(type))
            WantAllMap.Remove(type);

         if(RequiredItemMap.ContainsKey(type))
            RequiredItemMap.Remove(type);
      }

      public bool IsExportingAssemblies => IsExportingType(SqlTypeEnum.Assembly);

      public bool IsExportingTables => IsExportingType(SqlTypeEnum.Table);

      public bool IsExportingDb => IsExportingType(SqlTypeEnum.Database);

      public bool IsExportingFunctions => IsExportingType(SqlTypeEnum.Function);

      public bool IsExportingStoredProcedures => IsExportingType(SqlTypeEnum.StoredProcedure);

      public bool IsExportingSchema => IsExportingType(SqlTypeEnum.Schema); //CreateMode != CreateModeEnum.Alter;

      public bool IsExportingTableTys => IsExportingType(SqlTypeEnum.UserDefinedTableType);

      public bool IsExportingUserDefinedTypes => IsExportingType(SqlTypeEnum.UserDefinedDataType);

      public bool IsExportingVws => IsExportingType(SqlTypeEnum.View);

      public bool IsExportingData { get; private set; } = false;

      /// <summary>
      /// Loads the configuration from configFile 
      /// default: Appsettings.json
      /// uses the absolute path
      /// PRE01: (checked) All config files should have the "Name" setting set
      /// </summary>
      /// <param name="configFile"></param>
      /// <param name="msg"></param>
      /// <returns>true if loaded ok, false otherwise</returns>
      public bool Init(string? configFile, out string msg)
      {
         //var config_path = Path.GetFullPath(configFile.IsNullOrEmpty() ? "Appsettings.json" : configFile);
         var config_path = Path.GetFullPath(configFile);
         LogS($"config_file: {configFile} config_path: {config_path}");

         // pop all types bar database
         var types = Enum.GetValues<SqlTypeEnum>().Where(e => e!=SqlTypeEnum.Database);
         // Setup the type lists in the RequiredItemMap
         foreach (var e in types)
            RequiredItemMap[e] = new List<string>();

         bool ret = LoadConfigFromFile(config_path, out msg);
         return LogR(ret);
      }

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

            if ( CreateMode          == CreateModeEnum.Undefined) { msg = "create mode"               + spec_msg; break;}
            if( string.IsNullOrEmpty(Database)){ msg = "database"                  + spec_msg; break;}
            //if( string.IsNullOrEmpty(FilePath)) { msg = "configurataion file path" + spec_msg; break; }
            if ( string.IsNullOrEmpty(LogFile)){ msg = "log file"                   + spec_msg; break;}
            if( LogLevel            == LogLevel.Undefined){ msg = "log level"                  + spec_msg; break;}
            if( String.IsNullOrEmpty(Name))    { msg = "configurataion name"+ spec_msg; break; }
            //if( RequiredSchemas.Count == 0){ msg = "schemas"           + spec_msg; break; }
            //if( RequiredTypes.Count   == 0){ msg = "required types"             + spec_msg; break;}
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
            ClearExportType(SqlTypeEnum.Table);
            ClearExportType(SqlTypeEnum.UserDefinedTableType);
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
         throw new NotSupportedException("Params == is no longer supported");
      }
      /*
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
      */
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
         //s.AppendLine($" FilePath        : {FilePath}");
         s.AppendLine($" IndividualFiles              : {IndividualFiles}");
         s.AppendLine($" Instance                     : {Instance}");
         s.AppendLine($" IsExprtngData                : {IsExportingData}");
         s.AppendLine($" LogFile                      : {LogFile}");
         s.AppendLine($" LogLevel                     : {LogLevel}");
         s.AppendLine($" Name                         : {Name}");
         s.AppendLine($" RequiredAssemblies           : {RequiredAssemblies}");
         s.AppendLine($" RequiredSchemas              : {RequiredSchemas}");
         s.AppendLine($" RequiredFunctions            : {RequiredFunctions}");
         s.AppendLine($" RequiredProcedures           : {RequiredProcedures}");
         s.AppendLine($" RequiredTables               : {RequiredTables}");
         s.AppendLine($" RequiredViews                : {RequiredViews}");
         s.AppendLine($" RequiredUserDefinedTypes     : {RequiredUserDefinedTypes}");
         s.AppendLine($" RequiredUserDefinedDataTypes : {RequiredUserDefinedDataTypes}");
         s.AppendLine($" RequiredUserDefinedTableTypes: {RequiredUserDefinedTableTypes}");

         // Want all flags
         foreach (SqlTypeEnum e in Enum.GetValues(typeof(SqlTypeEnum)))
            s.AppendLine($" Want All:                  : {e.GetAlias()}");

         s.AppendLine($" Script Dir                   : {ScriptDir}");
         s.AppendLine($" Script File                  : {ScriptFile}");
         s.AppendLine($" ScriptUseDb                  : {ScriptUseDb}");
         s.AppendLine($" Server                       : {Server}");
         s.AppendLine($" AddTimestamp                 : {AddTimestamp}");
         s.AppendLine($" Timestamp                    : {Timestamp}");

         s.AppendLine();

         // Required Schemas
         string txt = RequiredSchemas?.Count.ToString() ?? "<null>";
         s.AppendLine($" RequiredSchemas : {txt}");

         if(RequiredSchemas != null)
            foreach(var item in RequiredSchemas)
               s.AppendLine($"\t{item}"); 

         s.AppendLine();

         // RequiredTypes
        // txt = RequiredTypes?.Count.ToString() ?? "<null>";
         //s.AppendLine($" RequiredTypes : {txt}");

         //if(RequiredTypes != null)
         //   foreach(var item in RequiredTypes)
         //      s.AppendLine($"\t{item}"); 

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
      public Params()
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
         /*
         RequiredSchemas   = new List<string>();

         RequiredTypes.Clear();
         RequiredAssemblies.Clear();
         RequiredFunctions.Clear();
         RequiredProcedures.Clear();
         RequiredTables.Clear();
         RequiredTypes.Clear();
         RequiredUserDefinedTableTypes.Clear();
         RequiredUserDefinedDataTypes.Clear();
         RequiredUserDefinedTypes.Clear();
         RequiredViews.Clear();
         */
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
      /// Gets the default config from app settings json
      /// updates the files with the timestamp, if the add timestamp is flag set
      /// Changes:
      /// 240922: now updates the files with the timestamp, if the add timestamp is flag set
      /// </summary>
      /// <param name="p"></param>
      public bool LoadConfigFromFile(string config_file, out string msg)
      {
         bool ret = false;
         msg = "";

         Config = new ConfigurationBuilder()
                  .AddJsonFile(config_file)
                  .Build()
         ;

         var config_nm = GetAppSettingAsString("Name");
         LogI($"LoadFromConfig(): config_nm [{config_nm}], config_file: [{config_file}]");
         string scriptDir = GetAppSettingAsString("Script Dir") ?? "";

         Name = GetAppSettingAsString("Name", "") ?? "";
         //FilePath          = GetAppSettingAsString("FilePath", "") ?? "";
         Server = GetAppSettingAsString("Server");
         Instance = GetAppSettingAsString("Instance", "SqlExpress") ?? "";
         Database = GetAppSettingAsString("Database") ?? "";
         AddTimestamp = GetAppSetting<bool>("AddTimestamp", false);
         Timestamp = GetTimestamp(fine: false);
         ScriptDir = AddTimestamp ? $"{scriptDir}\\{Timestamp}" : scriptDir;
         ScriptFile = @$"{ScriptDir}\{GetAppSettingAsString("Script File")}";
         CreateMode = GetAppSettingAsString("CreateMode").FindEnumByAliasExact<CreateModeEnum>();
         ScriptUseDb = GetAppSetting<bool>("ScriptUseDb", _default: false);
         DisplayScript = GetAppSetting<bool>("DisplayScript", true);
         DisplayLog = GetAppSetting<bool>("DisplayLog", false);
         LogFile = GetAppSettingAsString("LogFile", "DbScripter.logFile") ?? "";
         LogLevel = GetAppSettingAsString("LogLevel", "Info").FindEnumByAliasExact<LogLevel>();

          _requiredItemMap[SqlTypeEnum.Schema]              = GetAppSettingsAsList("RequiredSchemas");
          _requiredItemMap[SqlTypeEnum.Assembly]            = GetAppSettingsAsList("RequiredAssemblies");
          _requiredItemMap[SqlTypeEnum.Function]            = GetAppSettingsAsList("RequiredFunctions");
          _requiredItemMap[SqlTypeEnum.StoredProcedure]     = GetAppSettingsAsList("RequiredProcedures");
          _requiredItemMap[SqlTypeEnum.Table ]              = GetAppSettingsAsList("RequiredTables");
          _requiredItemMap[SqlTypeEnum.View ]               = GetAppSettingsAsList("RequiredViews");
          _requiredItemMap[SqlTypeEnum.UserDefinedType ]    = GetAppSettingsAsList("RequiredUserDefinedTypes");
          _requiredItemMap[SqlTypeEnum.UserDefinedDataType] = GetAppSettingsAsList("RequiredUserDefinedDataTypes");
          _requiredItemMap[SqlTypeEnum.UserDefinedTableType]= GetAppSettingsAsList("RequiredUserDefinedTableTypes");

         //RequiredTypes   = GetRequiredTypesFromConfig() ?? new List<SqlTypeEnum>();
         IsExportingData = GetAppSetting<bool>("IsExportingData", false);
         IndividualFiles = GetAppSetting<bool>("IndividualFiles", false);

         // Set the want all flags if any wildcards are set
         WantAllMap[SqlTypeEnum.Assembly]             = RequiredAssemblies.Count == 1 ? RequiredAssemblies[0] == "*" : false;
         WantAllMap[SqlTypeEnum.Schema]               = RequiredSchemas.Count    == 1 ? RequiredSchemas   [0] == "*" : false;
         WantAllMap[SqlTypeEnum.Table]                = RequiredTables.Count     == 1 ? RequiredTables    [0] == "*" : false;
         WantAllMap[SqlTypeEnum.Function]             = RequiredFunctions.Count  == 1 ? RequiredFunctions [0] == "*" : false;
         WantAllMap[SqlTypeEnum.StoredProcedure]      = RequiredProcedures.Count == 1 ? RequiredProcedures[0] == "*" : false;
         WantAllMap[SqlTypeEnum.UserDefinedTableType] = RequiredAssemblies.Count == 1 ? RequiredUserDefinedTableTypes[0] == "*" : false;
         WantAllMap[SqlTypeEnum.View]                 = RequiredAssemblies.Count == 1 ? RequiredAssemblies[0] == "*" : false;

         // Clear any wildcards
         foreach(KeyValuePair<SqlTypeEnum, List<string>> pr in RequiredItemMap)
            if(WantAll(pr.Key))
               pr.Value.Clear();

         UpdateFileNamesWithTimestamp();
         LogI($"Param.LoadFromConfig: {ToString()}");
         //Assertion(Validate(out msg), "Params.LoadFromConfig failed");
         ret = Validate(out msg);
         return LogR(ret, msg);
      }

      private List<string> GetAppSettingsAsList(string listName)
      {
         return GetAppSettingAsString(listName)?.Split(',')?.ToList() ?? new List<string>();
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
            if (RequiredSchemas.Count==0) { msg = "required schemas"      + spec_msg; break; }
            //if (RequiredTypes.Count == 0) { msg = "target child types"    + spec_msg; break; }
            if (LogLevel         == LogLevel.Undefined) { msg = "LogLevel Error, Warning, Notice, Info, Debug, Trace" + spec_msg; break; }

            // ASSERTION: all ok so return true
            ret = true;
            msg = "";
         } while (false);

         if (!ret)
            msg = $"Error parsing args: {msg}";

         return LogRI(ret, msg);
      }

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
