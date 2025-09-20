using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestPlatform.Utilities;
using Serilog;
using Serilog.Debugging;
using Serilog.Events;
using Serilog.Sinks.TestCorrelator;

using Xunit;
using Xunit.Abstractions;

namespace DbScripterTests;


/// <summary>
/// https://xunit.net/docs/capturing-output
/// </summary>
[Collection("SMOSequential")]
public partial class SMOScriptingTests
{

   [Fact]
   public void CheckBasicLoggingTest()
   {
      // Enable Serilog SelfLog
      SelfLog.Enable(Console.Error.WriteLine);

      var config =new ConfigurationBuilder()
                        .AddJsonFile("./Config/CheckBasicLoggingTest.json")
                        .Build()
               ;

      // Configure Serilog with XUnitOutputSink
      var serilogger = new LoggerConfiguration()
          .MinimumLevel.Verbose()
          .WriteTo.Sink(new XUnitOutputSink(Output))
          .WriteTo.File("d:/logs/log.txt", rollingInterval: RollingInterval.Day, restrictedToMinimumLevel: LogEventLevel.Verbose)
          .ReadFrom.Configuration(config)
          .CreateLogger();

      Log.Logger = serilogger;
      CommonLib.Logger.SetLogger(serilogger);

      using (TestCorrelator.CreateContext())
      {
         Console.WriteLine($"Verbose:     { serilogger.IsEnabled(LogEventLevel.Verbose)}");
         Console.WriteLine($"Debug:       { serilogger.IsEnabled(LogEventLevel.Debug)}");
         Console.WriteLine($"Information: { serilogger.IsEnabled(LogEventLevel.Information)}");
         Console.WriteLine($"Warning:     { serilogger.IsEnabled(LogEventLevel.Warning)}");
         Console.WriteLine($"Error:       { serilogger.IsEnabled(LogEventLevel.Error)}");
         Console.WriteLine($"Fatal:       { serilogger.IsEnabled(LogEventLevel.Fatal)}");

         Log.Verbose("Verbose log for SMO operation");
         Log.Debug("Debug log for SMO operation");
         Log.Information("Information log for SMO operation");
         Log.Warning("Warning log for SMO operation");
         Log.Error("Error log for SMO operation");
         Log.Fatal("Fatal log for SMO operation");

         Log.Information("Information log for SMO operation");
         List<LogEvent>? logEvents = TestCorrelator.GetLogEventsFromCurrentContext().ToList();
         //Assert.Contains(logEvents, e => e.MessageTemplate.Text == "Verbose log for SMO operation");
      }
   }

/*   public SerilogTests(ITestOutputHelper output)
   : base(output)
   {
   }*/
}
/*


   public class ConsoleWriter : StringWriter
   {
      private ITestOutputHelper output;
      public ConsoleWriter(ITestOutputHelper output)
      {
         this.output = output;
      }

      public override void WriteLine(string? m)
      {
         output.WriteLine(m);
      }
   }
}
*/
