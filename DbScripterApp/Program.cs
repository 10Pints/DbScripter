using CommonLib;

using DbScripterLibNS;

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.Json; // Add this using directive for AddJsonFile extension method
using Newtonsoft.Json;
using Serilog;
using Serilog.Templates;
using System.Configuration;
using System.Diagnostics;
using static Azure.Core.HttpHeader;
using static CommonLib.Logger;
using static CommonLib.Utils;

namespace DbScripterApp
{
   /// <summary>
   /// Console class: the main routine console interface
   /// </summary>
   public class Program
   {
      static DbScripter Scripter {get;set;} = new DbScripter();

      /// <summary>
      /// Main entry point
      /// Loads the json configuration and inits the Logger as early as possible
      /// </summary>
      /// <param name="args"></param>
      /// <returns></returns>
      public static int Main(string[] args)
      {
         int ret = 1; // error
         string args_str = string.Join("\r\n ", args);
         Console.WriteLine(args_str);
         string configFile = args.Length>0 ? args[0] : "Appsettings.json";
         string? msg = File.Exists(configFile) ? "exists" : " does not exist";
         Console.WriteLine($"configFile:[{configFile}] {msg}");

         try
         {
            do
            {
               //----------------------------------------------
               // Process
               //----------------------------------------------
               // Init scripter
               if (!Scripter.Init(configFile, out msg))
               {
                  PrintHelp(msg);
                  break;
               }

               if(!Scripter.Export(out msg))
               {
                  LogE($"Scripter.Export returned the following error: {msg}");
                  break;
               }

               ret = 0; // success
            } while (false);
         }
         catch (Exception e)
         {
            ret = 1;
            LogException(e);
         }

         return LogRN(ret, msg);
      }

      /// <summary>
      /// Usage: 
      ///  -S:       server                                                        default: DevI9\SQLEXPRESS
      ///  -i:       instance                                                      default: SQLEXPRESS
      ///  -d:       database                                                      default: none
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
      ///  -use:     scripts the use database command at the start of the script   default: FALSE
      ///  -ts       adds a timestamp to the specified export file path           default: FALSE
      ///  -log      sets the log file path                                       default: not set - use default path
      ///  -disp_log control whether or not to display the log file after         default: FALSE: dont display
      ///  
      /// E.G.  DbScripter -S DevI9\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
      /// </summary>
      /// <param name="e"></param>
      protected static void PrintHelp(string? msg = null)
      {
         Console.WriteLine(Params.GetHelpString(msg));
      }
   }
}
