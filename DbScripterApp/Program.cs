using System.Diagnostics;
using DbScripterLibNS;
using CommonLib;
using static CommonLib.Utils;
using static CommonLib.Logger;
using System.Configuration;
using Microsoft.Extensions.Configuration;
using Serilog;
using Serilog.Templates;

namespace DbScripterApp
{
   public class Program
   {
      static DbScripter Scripter {get;set;} = new DbScripter();

      public static int Main(string[] args)
      {
         LogSN();
         int ret = 1; // error
         string msg="";

         try
         {
            do
            {
               if (!Init(args, out msg))
               {
                  ret = 1;
                  PrintHelp(msg);
                  break;
               }

               LogN("Stage 1: initialising (main)");

               if(!Scripter.Export(out msg))
                  break;

               ret = 0; // success
            } while (false);
         }
         catch (Exception e)
         {
            if (ret == 0)
               ret = 1;

            LogException(e);
         }

         return LogRN(ret, msg);
      }

      /// <summary>
      /// Initializes logging, the scripter
      /// Loads the scripting config  
      /// </summary>
      public static bool Init(string[] args, out string msg)
      {
         LogSN();
         bool ret = false;
         msg = "";

         PrintArgs(args);
         string configFile = args.Length > 0 ? args[0] : "Appsettings.json";

         if (!Scripter.Init(configFile, out msg))
         {
            PrintHelp(msg);
            return false;
         }

         ExpressionTemplate fmt = new ExpressionTemplate("[{@t:yyMMdd-HHmmss} {@l:u3} {SourceContext}] {@m}\n{@x}");

         //if(Params.Config == null)
         //   throw new ConfigurationErrorsException("00014: Params.Config should not be null at this point");
         
         if(Params.Config == null)
            throw new ArgumentNullException("Params.Config is null");

         Serilog.Log.Logger = new LoggerConfiguration()
            .ReadFrom.Configuration(Params.Config)
            .WriteTo.Console(fmt)     // add console as logging target
            .WriteTo.File(@"D:\logs\DbScripter.log", outputTemplate: "{Timestamp:yyMMdd-HHmmss} [{Level:u4}] {Message}{NewLine}{Exception}", flushToDiskInterval: TimeSpan.FromMilliseconds(100))
            .MinimumLevel.Debug()             // set default minimum level
            .CreateLogger();


         ret = true;
         return LogR(ret);
      }

      private static void PrintArgs(string[] args)
      {
         LogC("-----------------------------");
         LogC("Scripter args:");
         LogC("-----------------------------");

         if (args != null)
         {
            foreach (var arg in args)
               LogC($"{arg}");
         }

         LogC("-----------------------------");
      }

      /*// <summary>
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
      public static bool DoWork(Params p, out string msg)
      {
         LogSN("Export starting ...");
         bool ret = false;

         do
         {
            DbScripter scripter = new DbScripter();

            if (!scripter.Export(/*ref* / p, out msg))
               break;

           /* if (string.IsNullOrEmpty(script))
            {
               msg = "no script generated";
               /

            if (!File.Exists(p.ScriptFile))
            {
               msg = $"Failed to create export file: {p.ScriptFile}";
               break;
            }

            ret = true;
         } while (false);

         if (!ret)
            msg = $"{msg} - check log: {LogFile}";

         // Post 1, 2
         Postcondition((ret == false) && (msg.Length > 0) ||
                        (ret == true) && (msg.Length == 0));

         return LogRN(ret, msg);
      }
      */

      /*// <summary>
      /// 1 off initialisation
      /// Gets the configuration
      /// Checks and parses the parameters for a configurtion file
      /// If found then loads it
      /// Returns true if init ok false otherwise
      /// 
      /// if error PrintHelp is called
      ///  log4net
      /// </summary>
      public static bool Init(string[] args, out Params p, out string? msg)
      {
         LogSN("DbScripter Initialisation starting ...");
         // Initially set the rc flag false
         bool ret = false;
         msg = "";

         do
         {
            InitLogger();
            PrintArgs(args);
            LogN($"Log: {Logger.LogFile}");

            // Load configuration
            // 240922: look for configuration file in params, if found load it
            //         otherwise load the local appsettings.json file
            //         expect first [optional] param to be the app settings file
            string configurationFile = (args.Length > 0) ? args[0] : "appsettings.json";

            // Set the default configuration
            // Get the default config from app settings.json
            p = new Params();
            p.Init(configurationFile);
            Params.LoadConfigFromFile(p);

            // Override the default values with the params that have been specified on the cmdline
            if (!Params.ParseArgs(args, ref p, out msg))
            {
               PrintHelp(msg);
               break;
            }

            // If a new config file is specified on the command line then load it
            Params.Config = new ConfigurationBuilder()
                  .AddJsonFile(configurationFile)
                  .Build();

            Params.LoadConfigFromFile(p);
            // Do not parse args again

            if (p.AddTimestamp == true)
               p.UpdateFileNamesWithTimestamp();

            // Display the resultant args
            var s = p.ToString();
            LogC(s);

            // Validate params again??
            Assertion(p.Validate(out msg), "Program.Init failed to set parameters correctly " + msg);
            LogC($"Log: {configurationFile}");

            // Finally set rc true
            ret = true;
         } while (false);

         LogRN(ret, $"DbScripter Initialisation completed, ret: {ret}");
         return ret;
      }
      */

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
         if (msg != null)
            LogE($"\n\n*** Error: {msg}\n");

         Console.WriteLine(Params.GetHelpString());
      }
   }
}
