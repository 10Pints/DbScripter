
#nullable enable

using System;
using System.Linq;
using DbScripterLib;
using System.IO;
using System.Diagnostics;
using RSS;
using static RSS.Common.Utils;

namespace DbScriptr
{
   class Program
   {
      /// <summary>
      /// This rtn will launch the DbScriptor with the parameters provided
      /// If successful then it will lanch the exported file in notepad++
      /// 
      /// The parameters are map of key value pairs:
      /// Handles the following switches: e.g:
      /// -S DESKTOP-UAULS0U\SQLEXPRESS 
      /// -i SQLEXPRESS
      /// -d ut
      /// -schema {dbo, test}
      /// -E [D:\tmp\utExport.sql]  -O {fn}
      /// -use    scrip[ts the use database
      /// </summary>
      /// <param name="args"></param>
      static void Main( string[] args )
      {
         try 
         { 
            ParseArgs(args, out Params p);

            DbScripter scripter = new DbScripter();
            throw new NotImplementedException();
            // scripter.ExportRoutines(p);
            /*

            if(!File.Exists(p.ExportScriptPath))
               throw new Exception($"Failed to create export file: {p.ExportScriptPath}");

            Console.WriteLine( $"Successfully exported to {p.ExportScriptPath}");

            // Launch notepadd++
            Process.Start("notepad++.exe", p.ExportScriptPath);*/
         }
         catch
         {
            PrintHelp();
         }
      }

      /// <summary>
      /// Handles the followuing switches:
      /// -S DESKTOP-UAULS0U\SQLEXPRESS 
      /// -I SQLEXPRESS
      /// -D ut
      /// -SCHEMA {dbo, test}
      /// -E [D:\tmp\utExport.sql]
      /// -T {FP}
      /// -M {alter create}
      /// </summary>
      /// <param name="args"></param>
     protected static void ParseArgs( string[] args, out Params p) // -M create|alter
     {
         Precondition(args != null, "Args must be supplied");
         p = new Params();
         int len           = args?.Length ?? 0;
         var argsU         =  args.Select(s => s.ToUpper()).ToArray();
         p.ServerName      = GetArg( args, argsU, "-S", ".");
         p.InstanceName    = GetArg( args, argsU, "-I", "DESKTOP-UAULS0U\\SQLEXPRESS");
         p.DatabaseName    = GetArg( args, argsU, "-D", null);

         Assertion( p.DatabaseName != null, "database must be specified");

         p.RequiredSchemas = p.ParseRequiredSchemas( GetArg( args, argsU, "-SCHEMA", "."));
         p.RequiredTypes   = p.ParseRequiredTypes  ( GetArg( args, argsU, "-T", "PF"));
         // -M create|alter
         var strMode = GetArg( args, argsU, "-M", "ALTER");
         p.CreateMode = strMode.FindEnumByAlias<CreateModeEnum>();

         var _schemas = string.Join("_",p.RequiredSchemas);
         string default_file = $"{Path.GetTempPath()}{p.DatabaseName}_{_schemas}_{p.RequiredTypes}_{GetTimeStamp()}_export.sql";
         p.ExportScriptPath  = GetArg( args, argsU, "-E", default_file);
         p.ScriptUseDb  = (GetArg( args, argsU, "-use"      , null, get_value: false) != null );
         p.AddTimestamp = (GetArg( args, argsU, "-timestamp", null, get_value: false) != null );
      }

      /// <summary>
      /// PRECONDITION args not null
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
               Assertion(ndx< len-1, "Error parsing args");
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
      /// PRECONDITION args not null
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

      protected static void PrintHelp()
      { 
         var nl = "\r\n";
         Console.WriteLine("Usage: " + nl +
            @"DbScripter -S DESKTOP-UAULS0U\SQLEXPRESS  -i SQLEXPRESS -d ut -schema {dbo} -E D:\tmp\utExport.sql  -T F|P -M create|alter" + nl +
"-S:        server"     + nl +
"-i:        instance"   + nl +
"-d:        database"   + nl +
"-schema:   schema"     + nl +
"-E:        export file path (timestamp and mode will be added)"        + nl +
"-T:        type: F: functions, P Procedures FP both"                   + nl +
"-M:        mode: create|alter"                                         + nl +
"-use:      scripts the use datbase command at the start of the script" + nl +
"-timestamp adds a timestamp to the specified export file path (default export file paths are timestamped)"

            );
      }
   }
}
