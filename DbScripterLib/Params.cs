#pragma warning disable CS8604//	Possible null reference argument for parameter 'rs' in 'SqlTypeEnum[]? Params.ParseRequiredTypes(string rs)'.	DbScripterLib	D:\Dev\C#\Db\Ut\DbScriptExporter\DbScripterLib\Params.cs	263	Active
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Text;

using CommonLib;
using static CommonLib.Logger;
using static CommonLib.Utils;

namespace DbScripterLibNS
{
   /// <summary>
   /// class to simplify the passing of a number of scripter config parameters
   /// </summary>
   public class Params
   {
      private /*static*/ IConfigurationRoot? _config = null;

      /// <summary>
      /// Main configuration - set by Program.Main()
      /// </summary>
      public /*static*/ IConfigurationRoot? Config 
      { 
         get{ return _config; }
         private set { _config = value;} 
      }

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

      public static string DefaultLogFile { get; private set; } = @"D:\Logs\DbScripter.log";


      public CreateModeEnum CreateMode { get; set; } = CreateModeEnum.Undefined;
      
      private Dictionary<SqlTypeEnum, List<string>> _requiredItemMap = new Dictionary<SqlTypeEnum, List<string>>();
      public Dictionary<SqlTypeEnum, List<string>> RequiredItemMap { get => _requiredItemMap;}

      private Dictionary<SqlTypeEnum, List<string>> _unwantedItemMap = new Dictionary<SqlTypeEnum, List<string>>();
      public Dictionary<SqlTypeEnum, List<string>> UnwantedItemMap { get => _unwantedItemMap; }

      public List<string> RequiredAssemblies           => RequiredItemMap[key: SqlTypeEnum.Assembly];
      public List<string> RequiredSchemas              => RequiredItemMap[key: SqlTypeEnum.Schema];
      public List<string> RequiredFunctions            => RequiredItemMap[key: SqlTypeEnum.Function];
      public List<string> RequiredProcedures           => RequiredItemMap[key: SqlTypeEnum.StoredProcedure];
      public List<string> RequiredTables               => RequiredItemMap[key: SqlTypeEnum.Table];
      public List<string> RequiredUserDefinedDataTypes => RequiredItemMap[key: SqlTypeEnum.UserDefinedDataType];
      public List<string> RequiredUserDefinedTableTypes=> RequiredItemMap[key: SqlTypeEnum.UserDefinedTableType];
      public List<string> RequiredUserDefinedTypes     => RequiredItemMap[key: SqlTypeEnum.UserDefinedType];
      public List<string> RequiredViews                => RequiredItemMap[key: SqlTypeEnum.View];

      public Dictionary<SqlTypeEnum, bool> WantAllMap { get; } = new Dictionary<SqlTypeEnum, bool>();

      public List<string> UnwantedAssemblies           => UnwantedItemMap[SqlTypeEnum.Assembly];            //;get; private set;}= new List<string>();
      public List<string> UnwantedSchemas              => UnwantedItemMap[SqlTypeEnum.Schema];              //get; private set;}= new List<string>();
      public List<string> UnwantedFunctions            => UnwantedItemMap[SqlTypeEnum.Function];            //get; private set;}= new List<string>();
      public List<string> UnwantedProcedures           => UnwantedItemMap[SqlTypeEnum.StoredProcedure];     //get; private set;}= new List<string>();
      public List<string> UnwantedTables               => UnwantedItemMap[SqlTypeEnum.Table];               //get; private set;}= new List<string>();
      public List<string> UnwantedTableTypes           => UnwantedItemMap[SqlTypeEnum.UserDefinedDataType]; //get; private set;}= new List<string>();
      public List<string> UnwantedDataTypes            => UnwantedItemMap[SqlTypeEnum.UserDefinedTableType];//get; private set;}= new List<string>();
      public List<string> UnwantedUserDefinedTypes     => UnwantedItemMap[SqlTypeEnum.UserDefinedType];     //get; private set;}= new List<string>();
      public List<string> UnwantedViews                => UnwantedItemMap[SqlTypeEnum.View];                //{ get; private set;} = new List<string>();

      /// <summary>
      /// the target types are 1 or more required child types
      /// under the root
      /// 
      /// INVARIANT: cannot be empty after init
      /// </summary>
      //private List<SqlTypeEnum> _requiredTypes = new();

      public bool ScriptUseDb { get; private set; } = false;
      
      public bool AddTimestamp { get; private set; } = false;

      // Export flags
      public bool WantAll(SqlTypeEnum ty)
      {
         if(!WantAllMap.TryGetValue(ty, out bool v))
            return false;

         return v;
      }

      public bool IsExportingType(SqlTypeEnum type)
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
         var config_path = Path.GetFullPath(configFile);
         LogS($"config_file: {configFile} config_path: {config_path}");
         Config = new ConfigurationBuilder()
         .AddJsonFile(configFile)
         .Build();
;

         msg = "";
         LogN(ConvertToJObject(/*Params.*/Config)?.ToString(Formatting.Indented) ?? "");

         // Pop all types bar database
         var types = Enum.GetValues<SqlTypeEnum>().Where(e => e!=SqlTypeEnum.Database);

         // Setup the type lists in the RequiredItemMap
         foreach (var e in types)
            RequiredItemMap[e] = new List<string>();

         // PRE01: Config already created and loaded (checked)
         bool ret = LoadConfigFromFile(config_path, out msg);
         return LogR(ret, msg);
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

            if (CreateMode == CreateModeEnum.Undefined) { msg = "create mode" + spec_msg; break; }
            if (string.IsNullOrEmpty(Database)) { msg = "database" + spec_msg; break; }
            if (string.IsNullOrEmpty(LogFile)) { msg = "log file" + spec_msg; break; }
            if (LogLevel == LogLevel.Undefined) { msg = "log level" + spec_msg; break; }
            if (String.IsNullOrEmpty(Name)) { msg = "configurataion name" + spec_msg; break; }
            if (string.IsNullOrEmpty(Server)) { msg = "server name)" + spec_msg; break; }
            if (string.IsNullOrEmpty(ScriptFile)) { msg = "export Script Path)" + spec_msg; break; }

            //  POST 2: if timestamp is specified the logfile and script file sould contain the timestamp
            if (AddTimestamp == true)
            {
               if (ScriptFile?.IndexOf(Timestamp) == 0) { msg = "Script file name does not contain timestamp but AddTimestamp is specified"; break; }
               if (LogFile?.IndexOf(Timestamp) == 0) { msg = "Log file name does not contain timestamp but AddTimestamp is specified"; break; }
            }

            // Check that no wanted items exist in the unwanted items list
            ret = ChkNowntdItmIsUnwnted(out msg);
         } while (false);

         if(ret == false)
            LogE($"Params validation failed: {msg}");

         Assertion(ret == true, $"Params validation failed: {msg}");
         // ASSERTION: all fields of P are specified
         return LogRT(ret, msg);
      }

      private bool ChkNowntdItmIsUnwnted(out string msg)
      {
         bool ret = true;
         msg = "";

         foreach (SqlTypeEnum ty in RequiredItemMap.Keys)
         {
            if (UnwantedItemMap.TryGetValue(ty, out var unwanted_items))
            {
               if (unwanted_items.Count > 0)
               {
                  // Check if any of the wanted items are in the unwanted items list
                  if (RequiredItemMap[ty].Any(item => unwanted_items.Contains(item)))
                  {
                     msg = $"The unwanted items list for {ty.GetAlias()} contains wanted items";
                     ret = false;
                     break;
                  }
               }
            }
         }

         return ret;
      }

      /// <summary>
      /// 1 Main accessor to the configuration
      /// </summary>
      /// <param name="key"></param>
      /// <param name="_default"></param>
      /// <returns></returns>
      string? GetAppSettingAsString(string key, string? _default = null)
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
      T? GetAppSetting<T>(string key, T? _default = default(T))
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
            // Remove table and UserDefinedTable types for alter
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
      public string GetLogFileFromConfig()
      {
         return GetAppSetting<string>("LogFile") ?? DefaultLogFile;
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
      public string GetScriptDirFromConfig()
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

      public override string ToString()
      {
         string Line = new string('-', 80);
         StringBuilder s = new StringBuilder();

         s.Append("\r\n");
         s.AppendLine(Line);
         s.AppendLine($" Type                         : {GetType().Name}");
         s.AppendLine(Line);

         s.AppendLine($" CreateMode                   : {CreateMode}");
         s.AppendLine($" Database                     : {Database}");
         s.AppendLine($" DisplayLog                   : {DisplayLog}");
         s.AppendLine($" DisplayScript                : {DisplayScript}");
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
         s.AppendLine($" RequiredUserDefinedDataTypes : {RequiredUserDefinedDataTypes}");
         s.AppendLine($" RequiredUserDefinedTableTypes: {RequiredUserDefinedTableTypes}");
         s.AppendLine($" RequiredUserDefinedTypes     : {RequiredUserDefinedTypes}");
         s.AppendLine($" RequiredViews                : {RequiredViews}");

         // Want all flags
         foreach (SqlTypeEnum ty in WantAllMap.Keys) //Enum.GetValues(typeof(SqlTypeEnum)))
            s.AppendLine($" Want All:                 : {ty.GetAlias()} {WantAllMap[key: ty]}");

         // Specific unwwanted items flags
         foreach (SqlTypeEnum ty in UnwantedItemMap.Keys) //(SqlTypeEnum ty in Enum.GetValues(typeof(SqlTypeEnum)))
            s.AppendLine($" Want All:                 : {ty.GetAlias()} {UnwantedItemMap[key: ty]}");

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
      public Params()
      {
      }

      public void ClearState()
      {
         AddTimestamp      = false;
         CreateMode        = CreateModeEnum.Undefined;
         LogLevel = LogLevel.Undefined;

         Database        = "";
         DisplayLog      = false;
         DisplayScript   = false;
         IndividualFiles = false;
         Instance        = "";
         LogFile         = "";
         ScriptFile      = "";
         Server          = "";
         IsExportingData = false;
         ScriptUseDb     = false;
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
      /// 
      /// 250721: now displays the config at the earliest oportunity
      /// Changes:
      /// 240922: now updates the files with the timestamp, if the add timestamp is flag set
      /// 250721: display the config at the earliest oportunity
      /// 
      /// Preconditions:
      /// PRE01: Config already created and loaded (checked)
      /// PRE02: if config_file does not exist then return false and msg = "config_file {f} not found" (checked)
      /// 
      /// Postconditions:
      /// POST 01: configuration loaded from Json to this Params instance
      /// </summary>
      /// <param name="p"></param>
      /// <returns></returns>
      public bool LoadConfigFromFile(string configFile, out string msg)
      {
         bool ret = false;
         LogS($"config_file: {configFile}");

         do
         { 
            try
            {
               msg = "";

               // Validation
               /*Params.*/Config = new ConfigurationBuilder()
                     .AddJsonFile(configFile)
                     .Build();

               // PRE02: if config_file does not exist then return false and msg = "config_file {f} not found" (checked)
               Precondition(File.Exists(configFile), "$config_file:[{config_file}] not found");

               //----------------------------------------------
               // Assertion: passed Validation checks
               //----------------------------------------------
               LogI("Assertion: passed Validation checks");

               //----------------------------------------------
               // Process
               //----------------------------------------------

               // 250721: display the config at the earliest oportunity
               Console.WriteLine(ConvertToJObject(Config)?.ToString(Formatting.Indented) ?? "");

               Name = GetAppSettingAsString("Name") ?? "";
               LogI($"LoadFromConfig(): config_nm [{Name}]");
               string scriptDir = GetAppSettingAsString("Script Dir") ?? "";

               Server = GetAppSettingAsString("Server");
               Instance = GetAppSettingAsString("Instance", "SqlExpress") ?? "";
               Database = GetAppSettingAsString("Database") ?? "";
               AddTimestamp = GetAppSetting<bool>("AddTimestamp", false);
               Timestamp = GetTimestamp(fine: false);
               ScriptDir = AddTimestamp ? $"{scriptDir}\\{Timestamp}" : scriptDir;
               ScriptFile = @$"{ScriptDir}\{GetAppSettingAsString("Script File")}";
               CreateMode    = GetAppSettingAsString("CreateMode").FindEnumByAliasExact<CreateModeEnum>();
               ScriptUseDb   = GetAppSetting<bool>  ("ScriptUseDb", _default: false);
               DisplayScript = GetAppSetting<bool>  ("DisplayScript", true);
               DisplayLog    = GetAppSetting<bool>  ("DisplayLog", false);
               LogFile       = GetAppSettingAsString("LogFile", "DbScripter.logFile") ?? "";
               LogLevel      = GetAppSettingAsString("LogLevel", "Info").FindEnumByAliasExact<LogLevel>();
               
               _requiredItemMap[SqlTypeEnum.Assembly]            = GetAppSettingsAsList("RequiredAssemblies");
               _requiredItemMap[SqlTypeEnum.Schema]              = GetAppSettingsAsList("RequiredSchemas");
               _requiredItemMap[SqlTypeEnum.Function]            = GetAppSettingsAsList("RequiredFunctions");
               _requiredItemMap[SqlTypeEnum.StoredProcedure]     = GetAppSettingsAsList("RequiredProcedures");
               _requiredItemMap[SqlTypeEnum.Table]               = GetAppSettingsAsList("RequiredTables");
               _requiredItemMap[SqlTypeEnum.UserDefinedDataType] = GetAppSettingsAsList("RequiredUserDefinedDataTypes");
               _requiredItemMap[SqlTypeEnum.UserDefinedTableType]= GetAppSettingsAsList("RequiredUserDefinedTableTypes");
               _requiredItemMap[SqlTypeEnum.UserDefinedType]     = GetAppSettingsAsList("RequiredUserDefinedTypes");
               _requiredItemMap[SqlTypeEnum.View]                = GetAppSettingsAsList("RequiredViews");

               _unwantedItemMap[SqlTypeEnum.Assembly            ] = GetAppSettingsAsList("UnwantedAssemblies");
               _unwantedItemMap[SqlTypeEnum.Schema              ] = GetAppSettingsAsList("UnwantedSchemas");
               _unwantedItemMap[SqlTypeEnum.Function            ] = GetAppSettingsAsList("UnwantedFunctions");
               _unwantedItemMap[SqlTypeEnum.StoredProcedure     ] = GetAppSettingsAsList("UnwantedProcedures");
               _unwantedItemMap[SqlTypeEnum.Table               ] = GetAppSettingsAsList("UnwantedTables");
               _unwantedItemMap[SqlTypeEnum.UserDefinedDataType ] = GetAppSettingsAsList("UnwantedUserDefinedDataTypes");
               _unwantedItemMap[SqlTypeEnum.UserDefinedTableType] = GetAppSettingsAsList("UnwantedUserDefinedTableTypes");
               _unwantedItemMap[SqlTypeEnum.UserDefinedType     ] = GetAppSettingsAsList("UnwantedUserDefinedTypes");
               _unwantedItemMap[SqlTypeEnum.View                ] = GetAppSettingsAsList("UnwantedViews");
               IsExportingData = GetAppSetting<bool>("IsExportingData", false);
               IndividualFiles = GetAppSetting<bool>("IndividualFiles", false);

               // Set the want all flags if any wildcards are set
               WantAllMap[SqlTypeEnum.Assembly]             = RequiredAssemblies           .Count == 1 ? RequiredAssemblies            [0] == "*" : false;
               WantAllMap[SqlTypeEnum.Schema]               = RequiredSchemas              .Count == 1 ? RequiredSchemas               [0] == "*" : false;
               WantAllMap[SqlTypeEnum.Function]             = RequiredFunctions            .Count == 1 ? RequiredFunctions             [0] == "*" : false;
               WantAllMap[SqlTypeEnum.StoredProcedure]      = RequiredProcedures           .Count == 1 ? RequiredProcedures            [0] == "*" : false;
               WantAllMap[SqlTypeEnum.Table]                = RequiredTables               .Count == 1 ? RequiredTables                [0] == "*" : false;
               WantAllMap[SqlTypeEnum.UserDefinedDataType]  = RequiredUserDefinedDataTypes .Count == 1 ? RequiredUserDefinedDataTypes  [0] == "*" : false;
               WantAllMap[SqlTypeEnum.UserDefinedTableType] = RequiredUserDefinedTableTypes.Count == 1 ? RequiredUserDefinedTableTypes [0] == "*" : false;
               WantAllMap[SqlTypeEnum.UserDefinedType]      = RequiredUserDefinedTypes     .Count == 1 ? RequiredUserDefinedTypes      [0] == "*" : false;
               WantAllMap[SqlTypeEnum.View]                 = RequiredAssemblies           .Count == 1 ? RequiredAssemblies            [0] == "*" : false;

               // Clear any wildcards
               foreach(KeyValuePair<SqlTypeEnum, List<string>> pr in RequiredItemMap)
                  if(WantAll(pr.Key))
                     pr.Value.Clear();

               UpdateFileNamesWithTimestamp();
               LogI($"Param.LoadFromConfig: {ToString()}");
               ret = Validate(out msg);
            }
            catch (Exception e)
            {
               LogException(e);
               msg = e.Message;
            }
         }while(false);

         //-----------------------------------------------------------------
         // POST 01: configuration loaded from Json to this Params instance
         // or (ret = false AND msg meaningful)
         //-----------------------------------------------------------------
         Postcondition(((ret == true) || (msg.Length>0)), "POST 01: configuration loaded from Json to this Params instance or (ret = false AND msg meaningful)");
         return LogR(ret, msg);
      }

      private List<string> GetAppSettingsAsList(string listName)
      {
         return GetAppSettingAsString(listName)?.Split(',', StringSplitOptions.RemoveEmptyEntries)?.ToList() ?? new List<string>();
      }

/*      private static List<SqlTypeEnum>? GetRequiredTypesFromConfig()
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
*/
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

         return @$"{msg}
Usage: DbScripter [json configuration file path]
E.G.  DbScripter [D:\Dev\DbScripter\DbScripterApp\AppSettings.json]";
      }

      static public JObject ConvertToJObject(IConfiguration config)
      {
         JObject obj = new JObject();

         foreach (var child in config.GetChildren())
         {
            if (child.Value == null)
            {
               obj.Add(child.Key, ConvertToJObject(child));
            }
            else
            {
               // Try to detect arrays
               if (child.Key.EndsWith(":0") || child.Key.EndsWith(":1"))
               {
                  string? arrayKey = child.Key.Substring(0, child.Key.LastIndexOf(':'));
                  if (!obj.ContainsKey(arrayKey))
                     obj.Add(arrayKey, new JArray());

                  //JArray? x = (JArray?)obj[arrayKey ?? ""]; x?.Add(child.Value);

                  ((JArray?)obj[arrayKey])?.Add(child.Value);
               }
               else
               {
                  obj.Add(child.Key, child.Value);
               }
            }
         }

         return obj;
      }

 /*     // Usage:
      var json = ConvertToJObject(configurationRoot);
      Console.WriteLine(json.ToString(Formatting.Indented));
Why Your Original Approach Didn't Work
The initial approach using ToDictionary() only captured the top-level keys with null values because:

IConfiguration is hierarchical

The values are actually stored in the child nodes

The simple dictionary conversion didn't recurse into the hierarchy

The new solutions properly traverse the entire configuration tree and preserve the structure in the JSON output.

Example Output
For your configuration, this will now properly output:

json
{
  "appSettings": {
    "Name": "Covid",
    "Server": "DevI9",
    "Instance": "",
    "Database": "Covid",
    "Script Dir": "D:\\Dev\\SqlDb\\Covid",
    "Script File": "Covid.sql",
    "CreateMode": "Create",
    "RequiredAssemblies": "*",
    "RequiredSchemas": "dbo,test",
    "RequiredFunctions": "*",
    "RequiredTables": "*",
    "RequiredViews": "*",
    "RequiredUserDefinedTypes": "*",
    "RequiredUserDefinedDataTypes": "*",
    "RequiredUserDefinedTableTypes": "*",
    "AddTimestamp": "false",
    "ScriptUseDb": "true",
    "DisplayScript": "true",
    "DisplayLog": "true",
    "LogFile": "D:\\SqlDb\\Logs\\Covid.log",
    "LogLevel": "INFO",
    "IsExportingData": "false"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "System": "Information",
      "Microsoft": "Information"
    }
  },
  "ThreadSettings": {
   "MaxThreads": "4"
  }
}
 */
   }
}
