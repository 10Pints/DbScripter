#nullable enable
using static CommonLib.Utils;
using static CommonLib.Logger;
using System.Diagnostics;
using DbScripterLibNS;
using Microsoft.Extensions.Configuration;
using NLog;
using NLog.Targets;

namespace DbScripterAppNS
{
   public class Program
   {
      /// <summary>
      /// Usage: 
      /// -config <config file path> use this config
      ///  -S:       server                                                        default: DevI9\SQLEXPRESS
      ///  -i:       instance                                                      default: SQLEXPRESS
      ///  -d:       database                                                      default: none
      ///  -rs:      required schemas like {dbo,test}, optional surrounding { }    default: dbo
      ///  -tct:     target child types, optional surrounding { } comma separated list of 1 or more typecodes: like {F,P}
      ///    valid   types: {F,P,S,T,TTY,V}                                       default: all ??
      ///      F:    user defined function
      ///      P:    stored procedure
      ///      S:    schema
      ///      T:    table
      ///      TTY:  user defined table type
      ///      V     view
      /// 
      ///  -E:       export file path (timestamp and mode will be added)          default: %TempPath%\DbName_schemas_tmstmp_export.sql
      ///  -cm:      create mode: create|alter|drop                               default: ALTER
      ///  -use:     scripts the use database command at the start of the script   default: FALSE
      ///  -ts       adds a timestamp to the specified export file path           default: FALSE
      ///  -log      sets the log file path                                       default: not set - use default path
      ///  -disp_log control whether or not to display the log file after         default: FALSE: dont display
      ///
      /// E.G.  DbScripter -S DevI9\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
      /// E.G.  DbScripter -S DevI9\SQLEXPRESS -i SQLEXPRESS -d farming_dev -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M alter
      /// </summary>
      /// <param name="args"></param>
      public static int Main( string[] args )
      {
         LogSN("000");
         string? msg = "";
         int ret = 1; // error
         Params? p = null;

         try 
         {
            do
            {
               LogN("010: initialising (main)");

               if(!Init(args, out p, out msg))
               {
                  LogE($"Stage 1: initialising (main)failed: {msg}");
                  break;
               }

               LogN("020: exporting schama items");

               if (!DoWork( p, out msg))
               {
                  LogE($"030: export failed: {msg}");
                  break;
               }

               LogN("040: ");
               // Display the script, default: yes
               if (p?.DisplayScript ?? true)
               {
                  LogN("050: displaying the script in notepad++");
                  Process.Start("C:\\Program Files\\Notepad++\\notepad++.exe", $"\"{p?.ScriptFile ?? "error"}\"");
               }

               LogN("060: ");

               // Display the script, default: no
               if (p?.DisplayLog ?? false)
               {
                  LogN("050: displaying the log in notepad++");
                  Process.Start("C:\\Program Files\\Notepad++\\notepad++.exe", "\"D:\\Logs\\DbScripter.log\"");// p?.LogFile ?? "");
               }

               ret = 0; // success
            } while(false);

         }
         catch(Exception e)
         {
            if(ret==0)
               ret = 1;

            LogException(e);
         }

         if(ret != 0)
         {
            LogC($"Error: {msg}");
            PrintHelp(msg);

            if ((p?.LogFile == null) || (p?.ScriptFile==null))
            {
               LogE("Either the log file or the script file is not specified");
            }

            //Process.Start("notepad++.exe", p?.LogFile   ?? "Ooops!");
            //Process.Start("notepad++.exe", p?.ScriptFile?? "Ooops!");
         }

         return LogRN(ret, msg);
      }

      /// <summary>
      /// Use this to open the log 
      /// 210627: put the log file in the archive in case of error in a big batch.
      /// This will make it easier to chase errors
      /// </summary>
      public static void InitLogger()
      {

         //ExpressionTemplate fmt = new ExpressionTemplate("[{@t:yyMMdd-HHmmss} {@l:u3} {SourceContext}] {@m}\n{@x}");

         //LoggerConfiguration? config = new LoggerConfiguration();
         //config.ReadFrom.Configuration(Params.Config);
         //config.WriteTo.Console(fmt);   // add console as logging target
         // config.WriteTo.File(@"D:\logs\DbScripter.log", outputTemplate: "{Timestamp:yyMMdd-HHmmss} [{Level:u4}] {Message}{NewLine}{Exception}", flushToDiskInterval: TimeSpan.FromMilliseconds(100));
         //config.MinimumLevel.Debug();            // set default minimum level

         //Serilog.Log.Logger = config.CreateLogger();
         //AssertionNotNull(Serilog.Log.Logger);
      }


      private static void PrintArgs(string[] args)
      {
         LogC("-----------------------------");
         LogC("Scripter args:");
         LogC("-----------------------------");

         if(args != null)
         {
            foreach(var arg in args)
               LogC($"{arg}");
         }

         LogC("-----------------------------");
      }

      /// <summary>
      /// The testable part of the main functionality
      /// 
      /// Post conditions:
      /// if error then msg must be specified
      /// if no error them msg must be empty
      ///   Post 1 ((ret== false) && (msg.Length > 0));
      ///   Post 2 ((ret== true ) && (msg.Length ==0));
      ///
      /// </summary>
      /// <param name="args"></param>
      /// <returns></returns>
      public static bool DoWork( Params p/*, out string script*/, out string msg)
      {
         LogSN("Export starting ...");
         bool ret = false;

         do
         {
            DbScripter scripter = new DbScripter();

            if (!scripter.Export(p, out msg))
               break;

            if(!File.Exists(p.ScriptFile))
            {   
               msg = $"Failed to create export file: {p.ScriptFile}";
               break;
            }

            ret = true;
         } while(false);

         if(!ret)
            msg = $"{msg} - check log: {LogFile}";

         // Post 1, 2
         Postcondition( (ret== false) && (msg.Length > 0) ||
                        (ret== true ) && (msg.Length ==0));

         return LogRN(ret,msg);
      }

      /// <summary>
      /// 1 off initialisation
      /// Gets the configuration
      /// Checks and parses the parameters for a configurtion file
      /// If found then loads it
      /// Returns true if init ok false otherwise
      /// 
      /// Changes:
      /// 240922: look for configuration file in params, if found load it
      ///         otherwise load the local appsettings.json file
      ///         expect first [optional] param to be the app settings file
      ///         Do not expect any args on command line other than the config location
      /// 240922: E84500: as of 240922: Command line args are other than the configuration file are no longer supported
      /// </summary>
      /// <param name="args">optional json configuration file path</param>
      /// <returns></returns>
      public static bool Init(string[] args, out Params p, out string? msg)
      {
         LogSN("DbScripter Initialisation starting ...");
         // Initially set the rc flag false
         bool ret = false;
         msg = "";

         do
         {
            // Load configuration
            // 240922: look for configuration file in params, if found load it
            //         otherwise load the local appsettings.json file
            //         expect first [optional] param to be the app settings file
            string configurationFile = (args.Length > 0) ? args[0] : "appsettings.json";

            // D:\Dev\DbScripter\DbScripterApp\AppSettings.json
            // Load the configuration from settings json file

            Params.Config = new ConfigurationBuilder()
           .AddJsonFile(configurationFile)
           .Build();

            PrintArgs(args);

            if(LogManager.Configuration == null)
               throw new Exception("NLog not configured");

            NLog.Layouts.Layout logFile = (LogManager.Configuration?.FindTargetByName("all_logs_file") as FileTarget)?.FileName ?? "File not found ***";
            LogN($"Log File: {logFile}");

            // Set the default configuration
            // Get the default config from app settings.json
            p = new Params();
            Params.LoadFromConfig(p);

            // Display the resultant configuration
            var s = p.ToString();
            LogC(s);

            // Validate params again??
            Assertion(p.Validate(out msg), "Program.Init failed to set parameters correctly " + msg);

            // Finally set rc true
            ret = true;
         } while(false);

         LogRN(ret, $"DbScripter Initialisation completed, ret: {ret}");
         return ret;
      }

      /// <summary>
      /// Prints the following help string:
      /// 
      /// Usage: 
      /// DbScripter [json configuration file path]
      ///  
      /// E.G.  DbScripter "D:\Dev\DbScripter\DbScripterApp\AppSettings.json"
      /// </summary>
      /// <param name="e"></param>
      protected static void PrintHelp(string? msg = null)
      {
         if(msg != null)
            LogE($"\n\n*** Error: {msg}\n");

         Console.WriteLine(Params.GetHelpString());
      }

      private static NLog.Logger logger = LogManager.GetCurrentClassLogger();
   }
}

