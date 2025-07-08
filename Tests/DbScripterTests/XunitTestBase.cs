using DbScripterTests;

using Serilog;
using Serilog.Core;
using Serilog.Events;
using Serilog.Formatting.Display;
using Serilog.Sinks.XUnit;

namespace DbScripterTests;

// Custom sink for xUnit test output
public class XunitTestBase : IDisposable
{
   protected readonly ITestOutputHelper Output;
   protected readonly Logger SerilogLogger;

   public XunitTestBase(ITestOutputHelper output)
   {
      Output = output;

      // Configure Serilog with both console and test output
      SerilogLogger = new LoggerConfiguration()
            .MinimumLevel.Debug()
            .WriteTo.Console()
            .WriteTo.File("D:/logs/DbScripterTests.log", rollingInterval: RollingInterval.Day)
            .WriteTo.Sink(new TestOutputSink(output))
             // Add to your LoggerConfiguration for even better test logs
            .Enrich.WithProperty("TestClass", GetType().Name)
//            .Enrich.WithProperty("TestName", TestContext.CurrentContext.Test.Name)
            .CreateLogger();

      Log.Logger = SerilogLogger;
   }

   public void Dispose()
   {
      SerilogLogger.Dispose();
   }
}


// Custom sink class for xUnit test output
public class TestOutputSink : ILogEventSink
{
   private readonly ITestOutputHelper _output;
   private readonly MessageTemplateTextFormatter _formatter;

   public TestOutputSink(ITestOutputHelper output)
   {
      _output = output;
      _formatter = new MessageTemplateTextFormatter(
          "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj}{NewLine}{Exception}",
          null);
   }

   public void Emit(LogEvent logEvent)
   {
      var writer = new StringWriter();
      _formatter.Format(logEvent, writer);
      _output.WriteLine(writer.ToString());
   }
}

/*
public class TestFixture : IDisposable
{
   public TestFixture()
   {
      Serilog.Log.Logger = new LoggerConfiguration()
          .MinimumLevel.Debug()
          .WriteTo.Console() // Still include for CLI runs
          .WriteTo.File("logs/testlog.txt", rollingInterval: RollingInterval.Day)
          .WriteTo.Sink(new TestOutputSink(_output ))
          .CreateLogger();

      Serilog.Log.Information("Test fixture initialized.");
   }

   public void Dispose() 
   {
      Serilog.Log.CloseAndFlush();
   }
}
*/
