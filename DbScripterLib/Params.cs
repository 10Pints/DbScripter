
#nullable enable 
#pragma warning disable CS8604//	Possible null reference argument for parameter 'rs' in 'SqlTypeEnum[]? Params.ParseRequiredTypes(string rs)'.	DbScripterLib	D:\Dev\C#\Db\Ut\DbScriptExporter\DbScripterLib\Params.cs	263	Active
#pragma warning disable CS8602// Dereference of a possibly null reference.

using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using RSS.Common;
using static RSS.Common.Utils;
using static RSS.Common.Logger;
using System.Configuration;
using System.IO;

namespace DbScripterLibNS
{
   /// <summary>
   /// class to simplify the passing of a number of scripter config parameters
   /// </summary>
   public class Params
   {
      public string Name { get; set; }
      public string? LogFile { get; set; }
      // Export flags
      private bool ? _isExprtngData   = null;
      public bool ? IsExprtngData
      {
         get => _isExprtngData;
         set => _isExprtngData = value;
      }

      private bool ? _isExprtngDb     = null;
      public bool ? IsExprtngDb 
      {
         get => _isExprtngDb;
         set => _isExprtngDb = value;
      }

      private bool ? _isExprtngFKeys  = null;
      public bool ? IsExprtngFKeys 
      {
         get => _isExprtngFKeys;
         set => _isExprtngFKeys = value;
      }

      private bool ? _isExprtngFns    = null;
      public bool ? IsExprtngFns
      {
         get => _isExprtngFns;
         set => _isExprtngFns = value;
      }

      private bool ? _isExprtngProcs  = null;
      public bool ? IsExprtngProcs
      {
         get => _isExprtngProcs;
         set => _isExprtngProcs = value;
      }

      private bool ? _isExprtngSchema = null;
      public bool ? IsExprtngSchema
      {
         get => _isExprtngSchema;
         set => _isExprtngSchema = value;
      }

      private bool ? _isExprtngTbls   = null;
      public bool ? IsExprtngTbls
      {
         get => _isExprtngTbls;
         set => _isExprtngTbls= value;
      }

      private bool ? _isExprtngTTys   = null;
      public bool ? IsExprtngTTys 
      {
         get => _isExprtngTTys;
         set => _isExprtngTTys = value;
      }

      private bool ? _isExprtngVws    = null;
      public bool ? IsExprtngVws 
      {
         get => _isExprtngVws;
         set => _isExprtngVws = value;
      }

      private string? _server = null;
      public string? Server
      {
         get => _server;
         set => _server = value;
      }

      private string? _instance = null;
      public string? Instance
      {
         get => _instance;
         set => _instance= value;
      }

      private string? _database = null;
      public string? Database
      {
         get => _database;
         set => _database = value?.Trim(new [] { '[',']'});
      }

      private string? _exportScriptPath = null;
      public string? ScriptPath
      {
         get => _exportScriptPath;
         set => _exportScriptPath = value;
      }
 
      private string? _newSchema = null;
      public string? NewSchema
      {
         get => _newSchema;
         set => _newSchema = value;
      }

      private bool? _displayScript = null;
      public bool? DisplayScript
      {
         get => _displayScript;
         set => _displayScript = value;
      }

      private List<string>? _requiredSchemas = null;
      public List<string>? RequiredSchemas
      {
         get => _requiredSchemas;
         set => _requiredSchemas = value;// ?? (new());
      }

      public static string DefaultLogFile {get; protected set;} = @"D:\Logs\DbScripter.log";

      public static string DefaultScriptDir {get; protected set;} = @"D:\Dev\Repos\C#\Db\Scripts";

      /// <summary>
      /// There is only 1 root type
      /// which is the parent of the required child TargetChildTypes 
      /// Can only be Database or schema
      /// </summary>
      public SqlTypeEnum? RootType
      {
         get => _rootType;

         set
         {
            _rootType = value;
            SetExportFlagsFromRootType();
         }
      }
      private SqlTypeEnum? _rootType = null;


      /// <summary>
      /// the target types are 1 or more required child types
      /// under the root
      /// 
      /// INVARIANT: cannot be empty after init
      /// </summary>
      public List<SqlTypeEnum>? TargetChildTypes
      {
         get => _targetTypes;
         set => _targetTypes = value; // ?? (new());
      }
      private List<SqlTypeEnum>? _targetTypes = null;//new();

      public CreateModeEnum? CreateMode
      {
         get => _createMode;
         set => _createMode = value;
      }
      private CreateModeEnum? _createMode =null;

      public bool? ScriptUseDb
      {
         get => _scriptUseDb;
         set => _scriptUseDb = value;
      }
      private bool? _scriptUseDb = null;

      public bool? AddTimestamp
      {
         get => _addTimestamp;
         set => _addTimestamp = value;
      }
      private bool? _addTimestamp = null;

      /// <summary>
      /// Checks the general criteria first like: server, instance, create type, sql type
      /// Returns true if the necessary state is set to do the required Export, false otherewise
      ///
      /// Utils.PreconditionS:
      ///
      /// POSTCONDITIONS: Returns true if the necessary state is set to do the required Export, false otherewise
      /// POST 1: server   name specified
      /// POST 2: instance name specified
      /// POST 3: database name specified
      /// POST 4: create type   specified
      /// POST 5: sql type      specified
      /// POST 6: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
      /// 
      /// </summary>
      /// <returns></returns>
      public bool IsValid(out string msg)
      {
         msg = "";
         bool ret = false;

         // -------------------------
         // Validate Utils.Preconditions
         // -------------------------
 
         // -----------------------------------------
         // ASSERTION: postconditions validated
         // -----------------------------------------

         do
         {
            // POST 1: server   name specified
            if(string.IsNullOrEmpty(Server))
            {
               msg = "Server Name";
               break;
            }

            // POST 2: instance name specified
            if(string.IsNullOrEmpty(Instance))
            {
               msg = "Instance Name";
               break;
            }

            // POST 3: database name specified
            if(string.IsNullOrEmpty(Database))
            {
               msg = "Database Name";
               break;
            }
/*
            // POST 4: create type   specified
            if(CreateMode?.Equals(CreateModeEnum.Undefined) ?? false)
            {
               msg = "Create Mode";
               break;
            }

            // POST 5: sql type      specified
            if(RootType?.Equals(SqlTypeEnum.Undefined) ?? false)
            {
               msg = "Sql Type";
               break;
            }
*/
            // POST 6: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
            if((RootType == SqlTypeEnum.Table && CreateMode == CreateModeEnum.Alter))
            {
               msg = "if exporting tables dont specify alter";//  POST 1: 
               break;
            }

            if(string.IsNullOrEmpty(LogFile))
            {
               msg = "Log File";
               break;
            }

            // ASSERTION:     conditions validated
            ret = true;
         } while(false);

         // -------------------------
         // Validate postconditions
         // -------------------------
         // POST 1: server   name specified
         Utils.Postcondition((ret == false) || (!string.IsNullOrEmpty(Server)));
         // POST 2: instance name specified
         Utils.Postcondition((ret == false) || (!string.IsNullOrEmpty(Instance)));
         // POST 3: database name specified
         Utils.Postcondition((ret == false) || (!string.IsNullOrEmpty(Database)));
         // POST 4: create   type specified
         Utils.Postcondition((ret == false) || (!(CreateMode?.Equals(CreateModeEnum.Error) ?? true)));
         // POST 5: sql      type specified
         Utils.Postcondition((ret == false) || (!(RootType  ?.Equals(SqlTypeEnum.Error   ) ?? true)));

         // -----------------------------------------
         // ASSERTION: postconditions validated
         // -----------------------------------------

         return ret;
      }

      /// <summary>
      /// Dafualts map
      /// </summary>
      protected static Dictionary<string, string?> PropertyDefaultMap
      { get;set;} = new ()
      {
         { "Server"          , "DESKTOP-UAULS0U\\SQLEXPRESS"},
         { "Instance"        , "SQLEXPRESS"},
         { "RequiredSchemas" , "dbo"},
         { "RootType"        , "schema"},
         { "TargetChildTypes", "F,P"},
         { "CreateMode"      , "ALTER"},
         { "ScriptUseDb"     , "false"},
         { "AddTimestamp"    , "false"},
         { "DisplayScript"   , "false"}
      };

      protected static Dictionary<string, string?> SwitchToPropertyMap
      { get;set;} = new ()
      {
         { "-s"            , "Server"           },
         { "-i"            , "Instance"         },
         { "-d"            , "Database"         },
         { "-e"            , "ScriptPath"       },
         { "-log"          , "LogFile"          },
         { "-rs"           , "RequiredSchemas"  },
         { "-rt"           , "RootType"         },
         { "-tct"          , "TargetChildTypes" },
         { "-cm"           , "CreateMode"       },
         { "-use"          , "ScriptUseDb"      },
         { "-ts"           , "AddTimestamp"     },
         { "-disp_script"  , "DisplayScript"    }
      };


      /// <summary>
      /// Gets the default for a commandline switch 
      /// or null if it does not have a default
      /// </summary>
      /// <param name="key"></param>
      /// <returns></returns>
      public string? GetDefaultForSwitch(string key)
      {
         string? value = null;
         key = key.ToLower();

         if( SwitchToPropertyMap.ContainsKey(key))
            value = GetDefaultForProperty(SwitchToPropertyMap[key]);

         return value;
      }

      /// <summary>
      /// Returns the default for a switch based on the current switch state and the app settings
      /// Only call this if needed
      /// </summary>
      /// <param name="key"></param>
      /// <param name="p"></param>
      /// <returns></returns>
      public string? GetDefaultForProperty(string propNm)
      {
         string? value = null;

         if( PropertyDefaultMap.ContainsKey(propNm))
         {
            value = PropertyDefaultMap[propNm];
         }
         else
         { 
            var schemas    = string.Join("_", RequiredSchemas);
            var script_dir = ConfigurationManager.AppSettings.Get("Script Dir") ?? @"D:\Scripts";

            switch(propNm)
            {
            case "Database": // no default
               value = null;
               break;

            case "ScriptPath":
               // must be called after p.DatabaseName specified
               //Assertion(!string.IsNullOrEmpty(Database), "-d database must be specified");
               value = @$"{script_dir}\{Database}_{schemas}_{Utils.GetTimestamp()}.sql";
               break;

            case "LogFile":
               //Assertion(!string.IsNullOrEmpty(Database), "-d database must be specified");
               var log_dir = ConfigurationManager.AppSettings.Get("Log Dir") ?? script_dir;
               value = @$"{log_dir}\{Database}_{schemas}_{Utils.GetTimestamp()}.log";
               break;

            default:
               value = null;
               break;
            }
         }

         return value;
      }

      /// <summary>
      /// If neccessary use defaults for ScriptPath, LogFile, UseDb, Timestamp
      /// Design: Model.Activity Model.Init.Init
      /// </summary>
      protected void SetDefaults()
      {
         int i = 0;
         int j = 0;
         // Get the property from name, if null: set the property default
         foreach(var tuple in PropertyDefaultMap)
         {
            if(i == 4)
               j= i;

            this.UpdatePropertyIfNeccessary(tuple.Key, tuple.Value);
            i++;
         }

         Database    ??= GetDefaultForProperty("Database");
         ScriptPath  ??= GetDefaultForProperty("ScriptPath");
         LogFile     ??= GetDefaultForProperty("LogFile");
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
      public static string GetScriptDirFromConfig()
      {
         return ConfigurationManager.AppSettings.Get("Script Dir") ?? DefaultScriptDir;
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
      public bool Normalise( out string msg)
      {
         LogS();
         bool ret = true;
         msg      = "";
         SetDefaults();

         switch(RootType)
         {
          case SqlTypeEnum.Database:
            IsExprtngDb     ??= true;
            IsExprtngSchema ??= false;
            IsExprtngProcs  ??= false;
            IsExprtngFns    ??= false;
            IsExprtngVws    ??= false;
            IsExprtngTbls   ??= false;
            IsExprtngTTys   ??= false;
            IsExprtngFKeys  ??= false;
            IsExprtngData   ??= false;
            break;

        case SqlTypeEnum.Schema:
            IsExprtngDb     ??= false;
            IsExprtngSchema ??= true;
            IsExprtngProcs  ??= true;
            IsExprtngFns    ??= true;
            IsExprtngVws    ??= true;
            IsExprtngTbls   ??= false;
            IsExprtngTTys   ??= false;
            IsExprtngFKeys  ??= false;
            IsExprtngData   ??= false;
            break;

         case SqlTypeEnum.Procedure:
            IsExprtngDb     ??= false;
            IsExprtngSchema ??= false;
            IsExprtngProcs  ??= true;
            IsExprtngFns    ??= false;
            IsExprtngVws    ??= false;
            IsExprtngTbls   ??= false;
            IsExprtngTTys   ??= false;
            IsExprtngFKeys  ??= false;
            IsExprtngData   ??= false;
            break;

         case SqlTypeEnum.Function:
            IsExprtngDb     ??= false;
            IsExprtngSchema ??= false;
            IsExprtngProcs  ??= false;
            IsExprtngFns    ??= true;
            IsExprtngVws    ??= false;
            IsExprtngTbls   ??= false;
            IsExprtngTTys   ??= false;
            IsExprtngFKeys  ??= false;
            IsExprtngData   ??= false;
            break;

         case SqlTypeEnum.View:
            IsExprtngDb     ??= false;
            IsExprtngSchema ??= false;
            IsExprtngProcs  ??= false;
            IsExprtngFns    ??= false;
            IsExprtngVws    ??= true;
            IsExprtngTbls   ??= false;
            IsExprtngTTys   ??= false;
            IsExprtngFKeys  ??= false;
            IsExprtngData   ??= false;
            break;

         case SqlTypeEnum.Table:
            IsExprtngDb     ??= false;
            IsExprtngSchema ??= false;
            IsExprtngProcs  ??= false;
            IsExprtngFns    ??= false;
            IsExprtngVws    ??= false;
            IsExprtngTbls   ??= true;
            IsExprtngTTys   ??= false;
            IsExprtngFKeys  ??= true;
            IsExprtngData   ??= false;
            break;

         case SqlTypeEnum.TableType:
            IsExprtngDb     ??= false;
            IsExprtngSchema ??= false;
            IsExprtngProcs  ??= false;
            IsExprtngFns    ??= false;
            IsExprtngVws    ??= false;
            IsExprtngTbls   ??= false;
            IsExprtngTTys   ??= true;
            IsExprtngFKeys  ??= false;
            IsExprtngData   ??= false;
            break;

         default:
            msg = $"Unrecognised export type: {RootType.GetAlias()}";
            ret = false;
            break;
         }

         LogL($"ret: {ret}");
         return ret;
      }


      public override bool Equals( object obj )
      {
         Params? b = obj as Params;
         Utils.Assertion(b != null);
         string msg = "";

         do
         {
            if(Server        != b.Server      ) { msg = $"a ServerName      :{Server      } b servername      :{b.Server      }"; break; }
            if(Instance      != b.Instance    ) { msg = $"a InstanceName    :{Instance    } b InstanceName    :{b.Instance    }"; break; }
            if(Database      != b.Database    ) { msg = $"a DatabaseName    :{Database    } b DatabaseName    :{b.Database    }"; break; }
            if(ScriptPath  != b.ScriptPath) { msg = $"a ExportScriptPath:{ScriptPath} b ExportScriptPath:{b.ScriptPath}"; break; }
            if(NewSchema     != b.NewSchema   ) { msg = $"a NewSchemaName   :{NewSchema   } b NewSchemaName   :{b.NewSchema   }"; break; }

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

            if((TargetChildTypes == null) && (b.TargetChildTypes != null) ||
               (TargetChildTypes != null) && (b.TargetChildTypes == null)) { msg = $"a TargetChildTypes   :{TargetChildTypes   } b TargetChildTypes   :{b.TargetChildTypes   }"; break; }

            if((TargetChildTypes != null) && (b.TargetChildTypes != null))
            {
               if(TargetChildTypes.Count != b.TargetChildTypes.Count) { msg = $"a TargetChildTypes   :{TargetChildTypes   } b TargetChildTypes   :{b.TargetChildTypes   }"; break; }

               foreach(var item in TargetChildTypes)
                  if(!b.TargetChildTypes.Contains(item)) { msg = $"a TargetChildTypes   :{TargetChildTypes   } b TargetChildTypes   :{b.TargetChildTypes   }"; break; }
            }

            if(RootType     != b.RootType)    { msg = $"a RootType     :{RootType     } b RootType     :{b.RootType    }"; break; }
            if(CreateMode   != b.CreateMode)  { msg = $"a CreateMode   :{CreateMode   } b CreateMode   :{b.CreateMode  }"; break; }
            if(ScriptUseDb  != b.ScriptUseDb) { msg = $"a ScriptUseDb  :{ScriptUseDb  } b ScriptUseDb  :{b.ScriptUseDb }"; break; }
            if(AddTimestamp != b.AddTimestamp){ msg = $"a AddTimestamp :{AddTimestamp } b AddTimestamp :{b.AddTimestamp}"; break; }

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
         s.AppendLine($" Type            : {GetType().Name  }");
         s.AppendLine($" Name            : {Name            }");
         s.AppendLine(Line);
         s.AppendLine($" Server          : {Server          }");
         s.AppendLine($" Instance        : {Instance        }");
         s.AppendLine($" DatabaseN       : {Database        }");
         s.AppendLine($" ScriptPath      : {ScriptPath      }");
         s.AppendLine();
         string txt = RequiredSchemas?.Count.ToString() ?? "<null>";
         s.AppendLine($" RequiredSchemas : {txt}");

         if(RequiredSchemas != null)
            foreach(var item in RequiredSchemas)
               s.AppendLine($"\t{item}"); 

         s.AppendLine();

         txt = TargetChildTypes?.Count.ToString() ?? "<null>";
         s.AppendLine($" TargetChildTypes : {txt}");

         if(TargetChildTypes != null)
            foreach(var item in TargetChildTypes)
               s.AppendLine($"\t{item}"); 

         s.AppendLine();
         s.AppendLine($" RootType        : {RootType        }");
         s.AppendLine($" CreateMode      : {CreateMode      }");
         s.AppendLine($" ScriptUseDb     : {ScriptUseDb     }");
         s.AppendLine($" AddTimestamp    : {AddTimestamp    }");
         s.AppendLine($" LogFile         : {LogFile         }");
         s.AppendLine($" IsExprtngData   : {IsExprtngData   }");
         s.AppendLine($" IsExprtngDb     : {IsExprtngDb     }");
         s.AppendLine($" IsExprtngSchema : {IsExprtngSchema }");
         s.AppendLine($" IsExprtngProcs  : {IsExprtngProcs  }");
         s.AppendLine($" IsExprtngFns    : {IsExprtngFns    }");
         s.AppendLine($" IsExprtngTbls   : {IsExprtngTbls   }");
         s.AppendLine($" IsExprtngFKeys  : {IsExprtngFKeys  }");
         s.AppendLine($" IsExprtngVws    : {IsExprtngVws    }");
         s.AppendLine($" IsExprtngTTys   : {IsExprtngTTys   }");
         s.AppendLine($" NewSchemaName   : {NewSchema       }");
         s.AppendLine(Line);
         return s.ToString();
      }

      // Warning	CS0659	'Params' overrides Object.Equals(object o) but does not override Object.GetHashCode()	DbScripterLib	D:\Dev\Db\Ut\DbScriptExporter\DbScripterLib\Params.cs	11	Active

      public override int GetHashCode()
      {
         return base.GetHashCode();
      }

      public Params
      (
          string           name            = ""
         ,Params?          prms            = null // Use this initial state to start with 
         ,string?          serverName      = null // and update with the subsequent parameters
         ,string?          instanceName    = null 
         ,string?          databaseName    = null 
         ,string?          exportScript    = null 
         ,string?          newSchemaName   = null 
         ,string?          requiredSchemas = null 
         ,string?          requiredTypes   = null 
         ,SqlTypeEnum?     rootType        = null // SqlTypeEnum    .Undefined
         ,CreateModeEnum?  createMode      = null //CreateModeEnum .Undefined
         ,bool?            scriptUseDb     = null
         ,bool?            addTimestamp    = null
         ,string?          logFile         = null
         ,bool?            isExprtngData   = null
         ,bool?            isExprtngDb     = null
         ,bool?            isExprtngFKeys  = null
         ,bool?            isExprtngFns    = null
         ,bool?            isExprtngProcs  = null
         ,bool?            isExprtngSchema = null
         ,bool?            isExprtngTbls   = null
         ,bool?            isExprtngTTys   = null
         ,bool?            isExprtngVws    = null
      )
      {
         Name = name;
         
         // if prms specified then start with prms state
         if(prms != null)
            CopyFrom(prms);   // force copy

         // Only append if specified not null
         PopFrom
         (
             serverName       : serverName
            ,instanceName     : instanceName
            ,databaseName     : databaseName
            ,exportScriptPath : exportScript
            ,newSchemaName    : newSchemaName
            ,requiredSchemas  : requiredSchemas
            ,requiredTypes    : requiredTypes
            ,rootType         : rootType
            ,createMode       : createMode
            ,scriptUseDb      : scriptUseDb
            ,addTimestamp     : addTimestamp
            ,logFile          : logFile
            ,isExprtngData    : isExprtngData
            ,isExprtngDb      : isExprtngDb
            ,isExprtngFKeys   : isExprtngFKeys
            ,isExprtngFns     : isExprtngFns
            ,isExprtngProcs   : isExprtngProcs
            ,isExprtngSchema  : isExprtngSchema
            ,isExprtngTbls    : isExprtngTbls
            ,isExprtngTTys    : isExprtngTTys
            ,isExprtngVws     : isExprtngVws
         );
      }


      public void ClearState()
      {
         Server            = null;
         Instance          = null;
         Database          = null;
         ScriptPath        = null;
         NewSchema         = null;
         RequiredSchemas   = null;
         TargetChildTypes  = null;
         RootType          = null;
         CreateMode        = null;
         ScriptUseDb       = false;
         AddTimestamp      = false;
         IsExprtngData     = false;
         IsExprtngDb       = false;
         IsExprtngFKeys    = false;
         IsExprtngFns      = false;
         IsExprtngProcs    = false;
         IsExprtngSchema   = false;
         IsExprtngTbls     = false;
         IsExprtngTTys     = false;
         IsExprtngVws      = false;
         LogFile           = null;
         DisplayScript     = null;
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
      /// Utils.PreconditionS:
      /// none
      /// POSTCONDITIONS:
      /// Returns an array of SqlTypeEnum based on  the characters in 
      /// the supplied string.
      /// Each characters is a key to th etype as defined in the map spec'd below
      /// asserts that all characters in the string are legal types
      /// </summary>
      /// <param name="rs">like:  'FTPV'</param>
      /// <returns></returns>
      public List<SqlTypeEnum>? ParseRequiredTypes( string? rts )
      {
        LogS();

        if(string.IsNullOrEmpty(rts))
            return null;

         rts = rts.ToUpper();

         // trim and remove surrounding {}
         rts = rts.Trim(new[] { ' ', '{', '}' });
         var reqTypes = rts.Split(new [] {','}, StringSplitOptions.RemoveEmptyEntries);
         
         // Trim each item
         for(int i=0; i<reqTypes.Length; i++)
            reqTypes[i] = reqTypes[i].Trim();

         List<SqlTypeEnum> list = new List<SqlTypeEnum>();

         // get the types, throw if not found
         foreach (var item in reqTypes)
            list.Add(item.FindEnumByAliasExact<SqlTypeEnum>( true));

         LogL($"Found {list.Count} items");
         return list;
      }


      /// <summary>
      /// Handles strings like:
      ///   "{test, [dbo]", "dbo",  "", null}
      ///   "   {   dbo    }   ", "" null
      /// 
      /// Utils.PreconditionS: 
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
      public List<string>? ParseRequiredSchemas( string? rs )
      {
         Utils.Precondition<ArgumentException>(!string.IsNullOrEmpty(Server  ), "Server must be specified");
         Utils.Precondition<ArgumentException>(!string.IsNullOrEmpty(Instance), "instance must be specified");

         //   POST 1: returns null if rs is null, empty
         if(string.IsNullOrEmpty(rs))
            return null;

         // trim and remove surrounding {}
         rs = rs.Trim(new[] { ' ', '{', '}' });

         // split on ,
         var rschemasNames = rs.Split(new []{ ',', '[', ']'}, StringSplitOptions.RemoveEmptyEntries);
         var requiredSchemaList    = new List<string>();

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
         foreach(var item in requiredSchemaList)
            Utils.Postcondition<ArgumentException>(string.IsNullOrEmpty(item) == false, "POST 4: should contain no empty schemas");

         // POST 5: Server, Instance Database exist
         // Currently: OpenServer throws this:
         // Microsoft.Data.SqlClient.resources, Version=2.0.20168.4, Culture=en-GB, PublicKeyToken=23ec7fc2d6eaa4a5' or one of its dependencies. 
         // The system cannot find the file specified."
         //Server? svr = Utils.CreateAndOpenServer( Server, Instance);
         //Utils.Assertion(svr != null);
         //? db = svr?.Databases["Covid_T1"];
         //Utils.Assertion(db != null);
         //SchemaCollection? actSchemas = db?.Schemas;
         //int cnt = actSchemas?.Count ?? 0;
         //Utils.Assertion((cnt != 0));

         // POST 6: the schemas found should exist in the database
         //         AND match the Case of the Db Schema name
         //List<string> actDbSchemaNames = new List<string>();

         // Get a list of exisitng schema names
         //foreach(Schema item in actSchemas)
         //   actDbSchemaNames.Add(item.Name);

         // try to match the schema names - if found use the actuak schema name (case correct)
         //for( int i = 0; i< requiredSchemaList.Count; i++)//dbSchemaName in dbSchemas)
         //{
         //   var reqSchemaName = requiredSchemaList[i];
         //   var ndx = actDbSchemaNames.FindIndex(x => x.Equals(reqSchemaName, StringComparison.OrdinalIgnoreCase));
         //
         //   if(ndx>-1)
         //      requiredSchemaList[i] = actDbSchemaNames[ndx];
         //   else
         //      Utils.Assertion( false, $"Schema {reqSchemaName} does not exist in the database");
         //}

         // POST 6: asserted: the required schemas do exist in the database
         //         AND they match the case of the Db Schema name
         return requiredSchemaList;
      }

      public static Params PopParams
         (
             string           name              = ""
            ,Params?          prms              = null // Use this state to start with and update with the subsequent parameters
            ,string?          serverName        = null
            ,string?          instanceName      = null
            ,string?          databaseName      = null
            ,string?          exportScriptPath  = null
            ,string?          newSchemaName     = null
            ,string?          requiredSchemas   = null
            ,string?          requiredTypes     = null
            ,SqlTypeEnum?     rootType          = null //SqlTypeEnum     .Undefined
            ,CreateModeEnum?  createMode        = null// CreateModeEnum  .Undefined
            ,bool?            scriptUseDb       = null
            ,bool?            addTimestamp      = null
            ,string?          logFile           = null

            ,bool?            isExprtngData     = null
            ,bool?            isExprtngDb       = null
            ,bool?            isExprtngFKeys    = null
            ,bool?            isExprtngFns      = null
            ,bool?            isExprtngProcs    = null
            ,bool?            isExprtngSchema   = null
            ,bool?            isExprtngTbls     = null
            ,bool?            isExprtngTTys     = null
            ,bool?            isExprtngVws      = null
         )
      {
         Params p = new Params();

         p.PopFrom(
             prms:            prms
            ,serverName:      serverName
            ,instanceName:    instanceName
            ,databaseName:    databaseName
            ,exportScriptPath:exportScriptPath
            ,newSchemaName:   newSchemaName
            ,requiredSchemas: requiredSchemas
            ,requiredTypes:   requiredTypes
            ,rootType:        rootType
            ,createMode:      createMode
            ,scriptUseDb:     scriptUseDb
            ,addTimestamp:    addTimestamp
            ,logFile:         logFile
            ,isExprtngData  : isExprtngData  
            ,isExprtngDb    : isExprtngDb    
            ,isExprtngFKeys : isExprtngFKeys 
            ,isExprtngFns   : isExprtngFns   
            ,isExprtngProcs : isExprtngProcs 
            ,isExprtngSchema: isExprtngSchema
            ,isExprtngTbls  : isExprtngTbls  
            ,isExprtngTTys  : isExprtngTTys  
            ,isExprtngVws   : isExprtngVws 
         );

         p.Name = name;
         return p;
      }


      /// <summary>
      /// This copies state from prams if and only if the current property is null
      /// </summary>
      /// <param name="prms"></param>
      /// <param name="serverName"></param>
      /// <param name="instanceName"></param>
      /// <param name="databaseName"></param>
      /// <param name="exportScriptPath"></param>
      /// <param name="newSchemaName"></param>
      /// <param name="requiredSchemas"></param>
      /// <param name="requiredTypes"></param>
      /// <param name="rootType"></param>
      /// <param name="createMode"></param>
      /// <param name="scriptUseDb"></param>
      /// <param name="addTimestamp"></param>
      /// <param name="logFile"></param>
      /// <param name="isExprtngData"></param>
      /// <param name="isExprtngDb"></param>
      /// <param name="isExprtngFKeys"></param>
      /// <param name="isExprtngFns"></param>
      /// <param name="isExprtngProcs"></param>
      /// <param name="isExprtngSchema"></param>
      /// <param name="isExprtngTbls"></param>
      /// <param name="isExprtngTTys"></param>
      /// <param name="isExprtngVws"></param>
      public void PopFrom
          (
              Params?         prms              = null // Use this state to start with and update with the subsequent parameters
             ,string?         serverName        = null
             ,string?         instanceName      = null
             ,string?         databaseName      = null
             ,string?         exportScriptPath  = null
             ,string?         newSchemaName     = null
             ,string?         requiredSchemas   = null
             ,string?         requiredTypes     = null
             ,SqlTypeEnum?    rootType          = null // must be null to avoid overwriting prms if set
             ,CreateModeEnum? createMode        = null // must be null to avoid overwriting prms if set
             ,bool?           scriptUseDb       = null
             ,bool?           addTimestamp      = null
             ,string?         logFile           = null
             ,bool?           isExprtngData     = null
             ,bool?           isExprtngDb       = null
             ,bool?           isExprtngFKeys    = null
             ,bool?           isExprtngFns      = null
             ,bool?           isExprtngProcs    = null
             ,bool?           isExprtngSchema   = null
             ,bool?           isExprtngTbls     = null
             ,bool?           isExprtngTTys     = null
             ,bool?           isExprtngVws      = null
          )
      {
         // overwite 
         // overwrite specified parameters if not null
         // If prms is supplied use it as the default configuration
         if(prms != null)
            CopyFrom(prms);

         // Update state if overwrite or param is defined
         // if (over write and not yet updated) OR (append and (param not null OR not already updated)


         this.UpdatePropertyIfNeccessary( "Server",         serverName        , true);
         this.UpdatePropertyIfNeccessary("Instance",        instanceName      , true);
         this.UpdatePropertyIfNeccessary("Database",        databaseName      , true);
         this.UpdatePropertyIfNeccessary("ScriptPath",      exportScriptPath  , true);
         this.UpdatePropertyIfNeccessary("NewSchema",       newSchemaName     , true);
         this.UpdatePropertyIfNeccessary("RequiredSchemas", requiredSchemas   , true);
         this.UpdatePropertyIfNeccessary("TargetChildTypes",requiredTypes     , true);
         this.UpdatePropertyIfNeccessary("RootType",        rootType          , true); 
         this.UpdatePropertyIfNeccessary("CreateMode",      createMode        , true);
         this.UpdatePropertyIfNeccessary("ScriptUseDb",     scriptUseDb       , true); 
         this.UpdatePropertyIfNeccessary("AddTimestamp",    addTimestamp      , true);
         this.UpdatePropertyIfNeccessary("LogFile",         logFile           , true);
         this.UpdatePropertyIfNeccessary("IsExprtngData",   isExprtngData     , true);
         this.UpdatePropertyIfNeccessary("IsExprtngDb",     isExprtngDb       , true);
         this.UpdatePropertyIfNeccessary("IsExprtngFKeys",  isExprtngFKeys    , true);
         this.UpdatePropertyIfNeccessary("IsExprtngFns",    isExprtngFns      , true);
         this.UpdatePropertyIfNeccessary("IsExprtngProcs",  isExprtngProcs    , true);
         this.UpdatePropertyIfNeccessary("IsExprtngSchema", isExprtngSchema   , true);
         this.UpdatePropertyIfNeccessary("IsExprtngTbls",   isExprtngTbls     , true);
         this.UpdatePropertyIfNeccessary("IsExprtngTTys",   isExprtngTTys     , true);
         this.UpdatePropertyIfNeccessary("IsExprtngVws",    isExprtngVws      , true);

         // Only Get the schemas once we have the svr name and db
         if(!string.IsNullOrEmpty(requiredSchemas))
            RequiredSchemas = ParseRequiredSchemas(requiredSchemas) ?? null;

         if(!string.IsNullOrEmpty(requiredTypes))
            TargetChildTypes   = ParseRequiredTypes  (requiredTypes)   ?? null;

         SetExportFlagsFromRootType();
      }

      /// <summary>
      /// Full copy all state from p bar status
      /// </summary>
      /// <param name="p"></param>
      public void CopyFrom( Params p )
      {
         Server            = p.Server;
         Instance          = p.Instance;
         Database          = p.Database;
         ScriptPath        = p.ScriptPath;
         NewSchema         = p.NewSchema;
         RequiredSchemas   = p.RequiredSchemas;
         TargetChildTypes  = p.TargetChildTypes;
         RootType          = p.RootType;
         CreateMode        = p.CreateMode;
         ScriptUseDb       = p.ScriptUseDb;
         AddTimestamp      = p.AddTimestamp;
         DisplayScript     = p.DisplayScript;
         LogFile           = p.LogFile;
         IsExprtngData     = p.IsExprtngData;
         IsExprtngDb       = p.IsExprtngDb;
         IsExprtngFKeys    = p.IsExprtngFKeys;
         IsExprtngFns      = p.IsExprtngFns;
         IsExprtngProcs    = p.IsExprtngProcs;
         IsExprtngSchema   = p.IsExprtngSchema;
         IsExprtngTbls     = p.IsExprtngTbls;
         IsExprtngTTys     = p.IsExprtngTTys;
         IsExprtngVws      = p.IsExprtngVws;

         SetExportFlagsFromRootType();
     }

      /// <summary>
      /// Configures the IsExporting flags basedon the SQL Expoty type
      /// </summary>
      protected void SetExportFlagsFromRootType()
      {
         // set the is exporting flags based on the type
         if(RootType == SqlTypeEnum.Database)  IsExprtngDb     = true;
         if(RootType == SqlTypeEnum.Schema)    IsExprtngSchema = true;
         if(RootType == SqlTypeEnum.Function)  IsExprtngFns    = true;
         if(RootType == SqlTypeEnum.Procedure) IsExprtngProcs  = true;
         if(RootType == SqlTypeEnum.Table)    {IsExprtngTbls   = true; IsExprtngTTys   = true;}
         if(RootType == SqlTypeEnum.TableType) IsExprtngTTys   = true;
         if(RootType == SqlTypeEnum.View)      IsExprtngVws    = true;
      }

      /// <summary>
      /// Configures the IsExporting flags basedon the SQL Expoty type
      /// </summary>
      protected void SetExportFlagState(bool? st = null)
      {
         // set the is exporting flags based on the type
         IsExprtngDb     = st;
         IsExprtngSchema = st;
         IsExprtngFns    = st;
         IsExprtngProcs  = st;
         IsExprtngTbls   = st;
         IsExprtngTTys   = st;
         IsExprtngVws    = st;
         IsExprtngData   = st;
      }
   }
}
