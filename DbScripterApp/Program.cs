
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

namespace DbScripterLibNS
{
   public class Program
   {
      /// <summary>
      /// Usage: 
      ///  -S:     server                                                        default: "."
      ///  -i:     instance                                                      default: DESKTOP-UAULS0U\\SQLEXPRESS
      ///  -d:     database                                                      default: none
      ///  -rt:    root type, optional surrounding [ ]                           default: schema
      ///  -rs:    required schemas like {dbo,test}, optional surrounding { }    default: dbo
      ///
      ///  -tct:   target child types, optional surrounding { }                  default: "P,F"
      ///      comma separated list of 1 or more typecodes: like {F,P}
      ///    valid types: {F,P,S,T,TTY,V}
      ///      F:   user defined function
      ///      P:   stored procedure
      ///      S:   schema
      ///      T:   table
      ///      TTY: user defined table type
      ///      V    view
      /// 
      ///  -E:      export file path (timestamp and mode will be added)          default: %TempPath%\DbName_schemas_tcts_tmstmp_export.sql
      ///  -cm:     create mode: create|alter|drop                               default: ALTER
      ///  -use:    scripts the use datbase command at the start of the script   default: FALSE
      ///  -ts      adds a timestamp to the specified export file path           default: FALSE
      ///  -log     log file
      /// E.G.  DbScripter -S DESKTOP-UAULS0U\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
      /// </summary>
      /// <param name="args"></param>
      public static int Main( string[] args )
      {
         string script, msg = "";
         int ret = 1; // error

         try 
         {
            LogS();
            Init();

            do
            {
               if(!DoWork( args, out Params p, out script, out msg))
                  break;

               Console.WriteLine( $"Successfully exported to {p.ExportScriptPath}");

               // Launch notepad++
               Process.Start("notepad++.exe", p.ExportScriptPath);

               ret = 0; // success
            } while(false);

         }
         catch(Exception e)
         {
            LogException(e, msg);
            PrintHelp(e);
         }

         LogL($"ret: {ret}");
         return ret;
      }

      /// <summary>
      /// The testable aprt of the main functionality
      /// </summary>
      /// <param name="args"></param>
      /// <returns></returns>
      public static bool DoWork( string[] args, out Params p, out string script, out string msg)
      {
         LogS();
         bool ret = false;
         script = "";
         msg = "";

         do
         {
            if(!ParseArgs(args, out p, out msg))
               break;

            DbScripter scripter = new DbScripter();
            script = scripter?.Export(ref p) ?? "";

            if(string.IsNullOrEmpty(script))
            {
               msg = "no script generated";
               break;
            }

         if(!File.Exists(p.ExportScriptPath))
            throw new Exception($"Failed to create export file: {p.ExportScriptPath}");

            ret = true;
         } while(false);

         LogL($"ret: {ret}");
         return ret;
      }

      /// <summary>
      /// 1 off initialisation
      ///  log4net
      /// </summary>
      public static void Init()
      {
         LogS();
         ServiceLocator.Instance.Register(typeof(ILogProvider).Assembly);
         ServiceLocator.Instance.Register(typeof(Log4NetLogProvider).Assembly);
         Logger.LogProvider = ServiceLocator.Instance.ResolveByType<ILogProvider>();
         Logger.InitLogger();
         Console.WriteLine($"Log: {Logger.LogFile}");
         LogL();
      }

      /// <summary>
      /// Usage: 
      ///  -S:     server                                                        default: "."
      ///  -i:     instance                                                      default: DESKTOP-UAULS0U\\SQLEXPRESS
      ///  -d:     database                                                      default: none
      ///  -rt:    root type, optional surrounding [ ]                           default: none
      ///  -rs:    required schemas like {dbo,test}, optional surrounding { }    default: dbo
      ///  -tct:   target child types, optional surrounding { } comma separated list of 1 or more typecodes: like {F,P}
      ///    valid types: {F,P,S,T,TTY,V}
      ///      F:   user defined function
      ///      P:   stored procedure
      ///      S:   schema
      ///      T:   table
      ///      TTY: user defined table type
      ///      V    view
      /// 
      ///  -E:      export file path (timestamp and mode will be added)          default: %TempPath%\DbName_schemas_tcts_tmstmp_export.sql
      ///  -cm:     create mode: create|alter|drop                               default: ALTER
      ///  -use:    scripts the use datbase command at the start of the script   default: FALSE
      ///  -ts      adds a timestamp to the specified export file path           default: FALSE
      ///  -log     log file
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
         bool ret = false;
         p = new Params();

         try 
         {
            Utils.Precondition(args != null, "Args must be supplied");
            int len           = args?.Length ?? 0;
            var argsU         = args.Select(s => s.ToUpper()).ToArray();

            do
            {
               p.ServerName   = GetArg( args, argsU, "-S", "DESKTOP-UAULS0U\\SQLEXPRESS");
               p.InstanceName = GetArg( args, argsU, "-I", "SQLEXPRESS");
               p.DatabaseName = GetArg( args, argsU, "-D",  null);

               var types      = GetArg( args, argsU, "-rt", "schema");
               var rootTypes  = p.ParseRequiredTypes(types);
               var rootType   = rootTypes.FirstOrDefault();
               p.RootType     = rootType;

               p.RequiredSchemas = p.ParseRequiredSchemas( GetArg( args, argsU, "-rs", "dbo"));
               p.TargetChildTypes= p.ParseRequiredTypes  ( GetArg( args, argsU, "-tct", "P,F"));

               var strMode    = GetArg( args, argsU, "-cm", "ALTER");
               p.CreateMode   = strMode.FindEnumByAlias<CreateModeEnum>();

               var _schemas   = string.Join("_",p.RequiredSchemas);
               //         <add key="Script Dir" value="E:\Backups\iDrive\Dev\Db\Scripts" />

               // Try from cmd line, if not found get from Appconfig, if that no good then take default
               string default_file  = @$"{ConfigurationManager.AppSettings.Get("Script Dir") ?? @"D:\Scripts"}\{p.DatabaseName}_{_schemas}_{Utils.GetTimeStamp()}_export.sql";
               p.ExportScriptPath   =  GetArg( args, argsU, "-E",    default_file);
               p.ScriptUseDb        =  GetArg( args, argsU, "-use",  get_value: false).Equals("-use", StringComparison.OrdinalIgnoreCase);
               p.AddTimestamp       =  GetArg( args, argsU, "-ts" ,  get_value: false).Equals("-ts" , StringComparison.OrdinalIgnoreCase);

               //  -log     log file
               string default_log_file  = ConfigurationManager.AppSettings.Get("Log File") ??  @"D:\Logs\DbScripter.log";
               p.LogFile           =  GetArg( args, argsU, "-log" , default_log_file);

               //  POST 1: all fields of P are specified
               var spec_msg = "must be specified";
               if( p.ServerName       == null){ msg = $"-S (server name) {spec_msg}";                          break;}
               if( p.InstanceName     == null){ msg = $"-i (instance name) {spec_msg}";                        break;}
               if( p.DatabaseName     == null){ msg = $"-d (database) {spec_msg}";                             break;}
               if( p.ExportScriptPath == null){ msg = $"-E (Export Script Path) {spec_msg}";                   break;}
               if( p.RequiredSchemas  == null){ msg = $"-rs (required schemas) {spec_msg}";                    break;}
               if( p.RootType         == null){ msg = $"-rt (Root Type) {spec_msg}";                           break;}
               if( p.TargetChildTypes == null){ msg = $"-tct (target child types) {spec_msg}";                 break;}
               if( p.CreateMode       == null){ msg = $"-cm (create mode) {spec_msg}";                         break;}
               if( p.ScriptUseDb      == null){ msg = $"-use (script usedb) {spec_msg}";                       break;}
               if( p.AddTimestamp     == null){ msg = $"-ts (add timestamp to script file name) {spec_msg}";   break;}
               if( p.LogFile          == null){ msg = $"-ts (log file) {spec_msg}";                            break;}

               ret = true;
               msg = "";
            } while(false);
         }
         catch(Exception e)
         {
            msg = e.Message;
            LogException(e);
            //throw;
         }

         LogL($"ret: {ret}");
         return ret;
      }

      /// <summary>
      /// Utils.Precondition args not null
      /// </summary>
      /// <param name="args">args from command line</param>
      /// <param name="argsU">upper case version of args</param>
      /// <param name="key">command line switch like -F that has an associated value</param>
      /// <param name="get_value"> if true key has an associated value</param>
      /// <returns></returns>
      protected static string GetArg(string[]? args, string[]? argsU, string key, string? default_val = null, bool get_value = true)
      {
         int ndx = Array.IndexOf( argsU, key.ToUpper());
         int len = args?.Length ?? 0;
         string? str = default_val;

         if(ndx != -1)
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

         return str ?? "";
      }

      /// <summary>
      /// Utils.Precondition args not null
      /// </summary>
      /// <param name="args"></param>
      /// <returns></returns>
      protected static string[] GetArgAsArray(string[] args, string[] argsU, string key, string default_val)
      {
         // get the {}
         string str = GetArg( args, argsU, key, default_val);
         str = str.Replace("{", "").Replace("}", "");
         return str.Split();
      }

      /// <summary>
      /// Usage: 
      ///  -S:     server                                                        default: DESKTOP-UAULS0U\SQLEXPRESS
      ///  -i:     instance                                                      default: SQLEXPRESS
      ///  -d:     database                                                      default: none
      ///  -rt:    root type, optional surrounding [ ]                           default: SCHEMA
      ///  -rs:    required schemas like {dbo,test}, optional surrounding { }    default: dbo
      ///  -tct:   target child types, optional surrounding { } comma separated list of 1 or more typecodes: like {F,P}
      ///    valid types: {F,P,S,T,TTY,V}
      ///      F:   user defined function
      ///      P:   stored procedure
      ///      S:   schema
      ///      T:   table
      ///      TTY: user defined table type
      ///      V    view
      /// 
      ///  -E:      export file path (timestamp and mode will be added)          default: %TempPath%\DbName_schemas_tmstmp_export.sql
      ///  -cm:     create mode: create|alter|drop                               default: ALTER
      ///  -use:    scripts the use datbase command at the start of the script   default: FALSE
      ///  -ts      adds a timestamp to the specified export file path           default: FALSE
      ///  
      /// E.G.  DbScripter -S DESKTOP-UAULS0U\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
      /// </summary>
      /// <param name="e"></param>

      protected static void PrintHelp(Exception? e)
      {
         if(e != null)
            Console.WriteLine($"{e}");

         Console.WriteLine(@"
Usage: 
E.G.  DbScripter -S DESKTOP-UAULS0U\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
Where:
 -S:        server                                                      default: DESKTOP-UAULS0U\SQLEXPRESS
 -i:        instance                                                    default: SQLEXPRESS
 -d:        database                                                    default: none
 -rt:       root type, optional surrounding [ ]                         default: SCHEMA
 -rs:       required schemas like {dbo,test}, optional surrounding { }  default: dbo

 -tct:      target child types, optional surrounding { } comma separated list of 1 or more typecodes: like {P,F}
   valid types: {F,P,S,T,TTY,V,P}                                       default: P,F
      F:   user defined function
      P:   stored procedure
      S:   schema
      T:   table
      TTY: user defined table type
      V    view

-E:        export file path (timestamp and mode will be added)          default: %TempPath%\DbName_schemas_tmstmp_export.sql
-cm:       mode: create|alter|drop                                      default: ALTER
-use:      scripts the use datbase command at the start of the script   default: FALSE
-ts        adds a timestamp to the specified export file path           default: FALSE"
            );
      }
   }

}
