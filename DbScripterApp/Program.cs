
#nullable enable

using System;
using System.Linq;
using System.IO;
//using System.Diagnostics;
using RSS;
using static RSS.Common.Utils;
using static RSS.Common.Logger;
using RSS.Common;
using System.Diagnostics;
using System.Configuration;
using System.Collections.Generic;

namespace DbScripterLibNS
{
   public class Program
   {
      /// <summary>
      /// Usage: 
      ///  -S:       server                                                        default: DESKTOP-UAULS0U\SQLEXPRESS
      ///  -i:       instance                                                      default: SQLEXPRESS
      ///  -d:       database                                                      default: none
      ///  -rt:      root type, optional surrounding [ ]                           default: SCHEMA
      ///  -rs:      required schemas like {dbo,test}, optional surrounding { }    default: dbo
      ///  -tct:     target child types, optional surrounding { } comma separated list of 1 or more typecodes: like {F,P}
      ///    valid   types: {F,P,S,T,TTY,V}
      ///      F:    user defined function
      ///      P:    stored procedure
      ///      S:    schema
      ///      T:    table
      ///      TTY:  user defined table type
      ///      V     view
      /// 
      ///  -E:       export file path (timestamp and mode will be added)          default: %TempPath%\DbName_schemas_tmstmp_export.sql
      ///  -cm:      create mode: create|alter|drop                               default: ALTER
      ///  -use:     scripts the use datbase command at the start of the script   default: FALSE
      ///  -ts       adds a timestamp to the specified export file path           default: FALSE
      ///  -log      sets the log file path                                          default: not set - use default path
      ///  -disp_log control whether or not to display the log file after            default: FALSE: dont display
      ///
      /// E.G.  DbScripter -S DESKTOP-UAULS0U\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
      /// </summary>
      /// <param name="args"></param>
      public static int Main( string[] args )
      {
         string? script, msg = "", tmp;
         int ret = 1; // error

         try 
         {
            LogS();

            do
            {
               if(!Init(args, out Params p, out msg))
                  break;

               if(!DoWork( p, out script, out msg))
               {
                  tmp = $"Error {msg}";
                  LogC(tmp);
                  break;
               }

               tmp =  $"Successfully exported to {p.ExportScriptPath}";
               LogC(tmp);

               // Launch notepad++
               if(p.DisplayScript ?? true)
                  Process.Start("notepad++.exe", p.ExportScriptPath);

               ret = 0; // success
            } while(false);

            if(ret != 0)
            { 
               LogC($"Error: {msg}");
            }
         }
         catch(Exception e)
         {
            LogException(e, msg);
            PrintHelp(e);
         }

         LogL($"ret: {ret} {msg}");
         return ret;
      }

      /// <summary>
      /// The testable aprt of the main functionality
      /// </summary>
      /// <param name="args"></param>
      /// <returns></returns>
      public static bool DoWork( Params p, out string script, out string msg)
      {
         LogC("Export starting ...");
         bool ret = false;
         msg = "";
         string statusMsg = "failed ";

         do
         {
            DbScripter scripter = new DbScripter();

            if(!scripter.Export(ref p, out script, out msg))
            {
               msg = $"Export failed ";
               break;
            }

            if(string.IsNullOrEmpty(script))
            {
               msg = "no script generated";
               break;
            }

            if(!File.Exists(p.ExportScriptPath))
            {   
               msg = $"Failed to create export file: {p.ExportScriptPath}";
               break;
            }

            statusMsg = "succeeded";
            ret = true;
         } while(false);

         if(!ret)
            msg = $"{msg} - check log: {LogFile}";

         LogC($"Export {statusMsg}, ret: {ret} msgs: {msg}");
         return ret;
      }

      /// <summary>
      /// 1 off initialisation
      /// Checks and parses the parameters
      /// returns true if init ok false otherwise
      /// 
      /// if error iPrintHelp is called
      ///  log4net
      /// </summary>
      public static bool Init(string[] args, out Params p, out string? msg)
      {
         LogC("Initialising starting ...");
         bool ret = false;

         do
         {
            ServiceLocator.Instance.Register(typeof(ILogProvider).Assembly);
            ServiceLocator.Instance.Register(typeof(Log4NetLogProvider).Assembly);
            Logger.LogProvider = ServiceLocator.Instance.ResolveByType<ILogProvider>();
            Logger.InitLogger();
            LogC($"Log: {Logger.LogFile}");

            if(args == null || (args.Length<1))
            {
               msg = "no arguments specified";
               p = new Params();
               break;
            }

            if(!ParseArgs(args, out p, out msg))
            {
               PrintHelp();
               break;
            }

            LogC($"Log: {Logger.LogFile}");

            ret = true;
         } while(false);

         LogC($"Initialisation completed, ret: {ret} {msg}");
         return ret;
      }

      /// <summary>
      /// Usage: 
      ///  -S:       server                                                        default: DESKTOP-UAULS0U\SQLEXPRESS
      ///  -i:       instance                                                      default: SQLEXPRESS
      ///  -d:       database                                                      default: none
      ///  -rt:      root type, optional surrounding [ ]                           default: SCHEMA
      ///  -rs:      required schemas like {dbo,test}, optional surrounding { }    default: dbo
      ///  -tct:     target child types, optional surrounding { } comma separated list of 1 or more typecodes: like {F,P}
      ///    valid   types: {F,P,S,T,TTY,V}
      ///      F:    user defined function
      ///      P:    stored procedure
      ///      S:    schema
      ///      T:    table
      ///      TTY:  user defined table type
      ///      V     view
      ///
      ///  -E:       export file path (timestamp and mode will be added)          default: %TempPath%\DbName_schemas_tmstmp_export.sql
      ///  -cm:      create mode: create|alter|drop                               default: ALTER
      ///  -use:     scripts the use datbase command at the start of the script   default: FALSE
      ///  -ts       adds a timestamp to the specified export file path           default: FALSE
      ///  -log      sets the log file path                                       default: default path
      ///  -disp_log control whether or not to display the log file after         default: FALSE: dont display
      ///
      /// E.G.  DbScripter -S DESKTOP-UAULS0U\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
      ///
      /// PRECONDITIONS:
      ///   none
      ///
      /// POSTCONDITIONS
      ///  P: valid state for export
      ///  POST 1: all fields of P are specified (mot null)
      ///     ServerName
      ///     InstanceName
      ///     DatabaseName
      ///     ExportScriptPath
      ///     RequiredSchemas
      ///     RootType
      ///     TargetChildTypes
      ///     CreateMode
      ///     ScriptUseDb
      ///     AddTimestamp
      /// </summary>
      /// <param name="args"></param>
     public static bool ParseArgs( string[] args, out Params p, out string msg) // -M create|alter
     {
         LogS();
         LogC("App.ParseArgs starting");
         bool ret = false;
         p = new Params();

         try 
         {
            Utils.Precondition(args != null, "Args must be supplied");
            int len           = args?.Length ?? 0;
            var argsU         = args.Select(s => s.ToUpper()).ToArray();

            LogArgs(argsU);

            do
            {//                                                                                 //                default:
               p.ServerName         = GetArg( args, argsU,        "-S",  p);                    // -S             this machine
               p.InstanceName       = GetArg( args, argsU,        "-I",  p);                    // -I             SQLEXPRESS
               p.DatabaseName       = GetArg( args, argsU,        "-D",  p);                    // -d             no default
               p.RootType           = GetArg( args, argsU,        "-rt", p).FindEnumByAlias<SqlTypeEnum>();// -rt schema
               p.RequiredSchemas    = p.ParseRequiredSchemas( GetArg( args, argsU, "-rs", p));  // -rs            dbo
               p.TargetChildTypes   = p.ParseRequiredTypes  ( GetArg( args, argsU, "-tct", p)); // -tct           F,P
               p.CreateMode         = GetArg( args, argsU,        "-cm", p).FindEnumByAlias<CreateModeEnum>();//-cm  ALTER
               p.ExportScriptPath   = GetArg( args, argsU,        "-E",   p);                   // -E             app config / D:\Scripts
               p.ScriptUseDb        = GetArgT<bool>( args, argsU, "-USE", p);                   // -use           false
               p.AddTimestamp       = GetArgT<bool>( args, argsU, "-TS",  p);                   // -ts            false
               p.LogFile            = GetArg( args, argsU,        "-log", p);                   // -log           {app config/script_dir}\{DatabaseName}_{schemas}_{TimeStamp}_export.sql
               p.DisplayScript      = GetArgT<bool>( args, argsU, "-disp_script", p);           // -disp_script   {true|false} default: TRUE
  
               //  POST 1: all fields of P are specified
               var spec_msg = "must be specified";
               if( p.CreateMode       == null){ msg = "-cm  (create mode)"          + spec_msg; break;}
               if( p.DatabaseName     == null){ msg = "-d   (database)"             + spec_msg; break;}
               if( p.DisplayScript    == null){ msg = "-disp_script (true/false)"   + spec_msg; break;}
               if( p.ExportScriptPath == null){ msg = "-E   (Export Script Path)"   + spec_msg; break;}
               if( p.InstanceName     == null){ msg = "-i   (instance name)"        + spec_msg; break;}
               if( p.RequiredSchemas  == null){ msg = "-rs  (required schemas)"     + spec_msg; break;}
               if( p.RootType         == null){ msg = "-rt  (Root Type)"            + spec_msg; break;}
               if( p.ServerName       == null){ msg = "-S   (server name)"          + spec_msg; break;}
               if( p.TargetChildTypes == null){ msg = "-tct (target child types)"   + spec_msg; break;}
               if( p.AddTimestamp     == null){ msg = "-ts  (add timestamp to SFN)" + spec_msg; break;}
               if( p.LogFile          == null){ msg = "-log (log file)"             + spec_msg; break;}
               if( p.ScriptUseDb      == null){ msg = "-use (script usedb)"         + spec_msg; break;}

               ret = true;
               msg = "";
            } while(false);
         }
         catch(Exception e)
         {
            msg = e.Message;
            LogC($"App.ParseArgs caught exception {e}");
            LogException(e);
            //throw;
         }

         msg = $"error parsing args: {msg}";
         var msg2 = $"App.ParseArgs leaving ret: {ret} {msg}";
         LogC(msg2);
         LogL(msg2);
         return ret;
      }

      protected static Dictionary<string, string?> DefaultMap
      { get;set;} = new ()
      {
         { "-s"  , "DESKTOP-UAULS0U\\SQLEXPRESS"},
         { "-i"  , "SQLEXPRESS"},
         { "-rs" , "dbo"},
         { "-rt" , "schema"},
         { "-tct", "F,P"},
         { "-cm" , "ALTER"},
         { "-use", "false"},
         { "-ts" , "false"},
         { "-disp_script" , "false"},
      };

      /// <summary>
      /// Returns the default for a switch based on the current switch state and the app settings
      /// Only call this if needed
      /// </summary>
      /// <param name="key"></param>
      /// <param name="p"></param>
      /// <returns></returns>
      protected static string? GetDefault(string key, Params p)
      {
         string? value = null;
         key = key.ToLower();

         if( DefaultMap.ContainsKey(key))
         {
            value = DefaultMap[key];
         }
         else
         { 
            var schemas    = string.Join("_", p.RequiredSchemas);
            var script_dir = ConfigurationManager.AppSettings.Get("Script Dir") ?? @"D:\Scripts";
            var log_dir    = ConfigurationManager.AppSettings.Get("Log Dir") ?? script_dir;

            switch(key)
            {
            case "-d": // no default
               AssertFail("-d database must be specified");
               break;

            case "-e":
               // must be called after p.DatabaseName specified
               Assertion(!string.IsNullOrEmpty(p.DatabaseName), "-d database must be specified");
               value = @$"{script_dir}\{p.DatabaseName}_{schemas}_{Utils.GetTimeStamp()}.sql";
               break;

            case "-log":
               Assertion(!string.IsNullOrEmpty(p.DatabaseName), "-d database must be specified");
               value = @$"{log_dir}\{p.DatabaseName}_{schemas}_{Utils.GetTimeStamp()}.log";
               break;

            default:
               value = null;
               break;
            }
         }

         return value;
      }

      /// <summary>
      /// Logs the arguments
      /// Expectes ags to have 0 or 1 value
      /// </summary>
      /// <param name="args"></param>
      protected static void LogArgs(string []? args)
      {
         if(args == null)
            return;

         int i = 0;
         int len = args.Length;
         string arg;
         bool isValue = false;
         string[] hasParam = new []{ "-S", "-I","-D","-RT","-RS","-TCT","-E","-CM"};

         do
         {
            arg = args[i];
            var f = Logger.LogFile;

            // if switch has a value then dont add  nl at the end of the msg
            if((isValue == false) && hasParam.Any(s => s.Equals(arg, StringComparison.OrdinalIgnoreCase)))
            {
               LogC_($"{arg, -4}");
               isValue = true;
            }
            else
            {
               LogC(arg);
               isValue = false;
            }
         }while(++i < len);

      }

      /// <summary>
      /// Utils.Precondition args not null
      /// </summary>
      /// <param name="args">args from command line</param>
      /// <param name="argsU">upper case version of args</param>
      /// <param name="key">command line switch like -F that has an associated value</param>
      /// <param name="get_value"> if true key has an associated value</param>
      /// <returns></returns>
      protected static string? GetArg(string[]? args, string[]? argsU, string key, Params p, bool get_value = true)
      {
         int ndx = Array.IndexOf( argsU, key.ToUpper());
         int len = args?.Length ?? 0;
         string? str = null;

         if(ndx == -1)
         {
            str = GetDefault(key, p);
         }
         else
         { 
            if(get_value)
            { 
               Utils.Assertion(ndx< len-1, "Error parsing args");
               str = args?[ndx + 1];
            }
            else
            { 
               str = key; // eg use switch has no value associated with it as teh db is already known
            }
         }

         return str;
      }

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
      protected static T? GetArgT<T>(string[]? args, string[]? argsU, string key, Params p, bool get_value = true) where T: struct
      {
         var s = GetArg(args, argsU, key, p, get_value);
         T?  t = null; 

         if(s != null)
            t = (T)Convert.ChangeType(s, typeof(T));

         return t;
      }

      /// <summary>
      /// Utils.Precondition args not null
      /// </summary>
      /// <param name="args"></param>
      /// <returns></returns>
      protected static string[] GetArgAsArray(string[] args, string[] argsU, string key, Params p)
      {
         // get the {}
         string str = GetArg( args, argsU, key, p) ?? "";
         str = str.Replace("{", "").Replace("}", "");
         return str.Split();
      }

      /// <summary>
      /// Usage: 
      ///  -S:       server                                                        default: DESKTOP-UAULS0U\SQLEXPRESS
      ///  -i:       instance                                                      default: SQLEXPRESS
      ///  -d:       database                                                      default: none
      ///  -rt:      root type, optional surrounding [ ]                           default: SCHEMA
      ///  -rs:      required schemas like {dbo,test}, optional surrounding { }    default: dbo
      ///  -tct:     target child types, optional surrounding { } comma separated list of 1 or more typecodes: like {F,P}
      ///    valid   types: {F,P,S,T,TTY,V}
      ///      F:    user defined function
      ///      P:    stored procedure
      ///      S:    schema
      ///      T:    table
      ///      TTY:  user defined table type
      ///      V     view
      /// 
      ///  -E:       export file path (timestamp and mode will be added)          default: %TempPath%\DbName_schemas_tmstmp_export.sql
      ///  -cm:      create mode: create|alter|drop                               default: ALTER
      ///
      /// Declaritive flags: defined means true not defined means false
      /// 
      ///  -use:     scripts the use datbase command at the start of the script   default: FALSE
      ///  -ts       adds a timestamp to the specified export file path           default: FALSE
      ///  -log      sets the log file path                                       default: not set - use default path
      ///  -disp_log control whether or not to display the log file after         default: FALSE: dont display
      ///  
      /// E.G.  DbScripter -S DESKTOP-UAULS0U\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
      /// </summary>
      /// <param name="e"></param>
      protected static void PrintHelp(Exception? e = null)
      {
         if(e != null)
         {   Console.WriteLine($"{e}");
             LogException(e);
         }

         Console.WriteLine(@"
Usage: 
E.G.  DbScripter -S DESKTOP-UAULS0U\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
Where:
 -S:        server                                                         default: DESKTOP-UAULS0U\SQLEXPRESS
 -i:        instance                                                       default: SQLEXPRESS
 -d:        database                                                       default: none
 -rt:       root type, optional surrounding [ ]                            default: SCHEMA
 -rs:       required schemas like {dbo,test}, optional surrounding { }     default: dbo

 -tct:      target child types, optional surrounding { } comma separated list of 1 or more typecodes: like {P,F}
   valid types: {F,P,S,T,TTY,V,P}                                          default: P,F
      F:   user defined function
      P:   stored procedure
      S:   schema
      T:   table
      TTY: user defined table type
      V    view

-E:        export file path (timestamp and mode will be added)             default: %TempPath%\DbName_schemas_tmstmp_export.sql
-cm:       mode: create|alter|drop                                         default: ALTER
-use:      scripts the use datbase command at the start of the script      default: FALSE
-ts        adds a timestamp to the specified export file path              default: FALSE
-log       sets the log file path                                          default: not set - use default path
-disp_log  control whether or not to display the log file after            default: FALSE: dont display"
            );
      }
   }

}
