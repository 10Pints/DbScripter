using Serilog;
using Serilog.Core;
using Serilog.Debugging;
using Serilog.Events;
using System.Diagnostics;
using System.Text;

using Assert = Xunit.Assert;

namespace DbScripterTests;

// Custom sink for xUnit test output
public class XunitTestBase : IDisposable
{
   protected readonly ITestOutputHelper Output;//OutputHelper;
   protected readonly Logger SerilogLogger;

   public XunitTestBase(ITestOutputHelper outputHelper)
   {
      Output = outputHelper;

      // Redirect Console to Debug and Test output
      Console.SetOut(new DebugTextWriter(outputHelper));

      // Enable SelfLog for diagnostics
      SelfLog.Enable(msg => Output.WriteLine($"[SELFLOG] {msg}"));

      // Load configuration
      var config = new ConfigurationBuilder()
          .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
          .AddJsonFile("Config/CheckBasicLoggingTest.json")
          .Build();

      // Configure Serilog
      SerilogLogger = new LoggerConfiguration()
          .MinimumLevel.Verbose()
          .WriteTo.Sink(new XUnitOutputSink(outputHelper)) // For Test Explorer output
          //.WriteTo.Debug(restrictedToMinimumLevel: LogEventLevel.Verbose) // For Debug window
          .WriteTo.File("d:/logs/log.txt", rollingInterval: RollingInterval.Day, restrictedToMinimumLevel: LogEventLevel.Verbose)
          .ReadFrom.Configuration(config)
          .CreateLogger();

      Log.Logger = SerilogLogger;
   }

   public virtual void Dispose()
   {
      //SerilogLogger.Dispose();
      Log.CloseAndFlush();
   }

   /// <summary>
   /// This checks the folder structure and file counts in each subfolder folder.
   ///
   /// </summary>
   /// <param name="folder"></param>
   /// <param name="expFolderCntMap"></param>
   public void CheckScriptOutputFoldersHelper(string folder, Dictionary<string, int> expFolderCntMap)
   {
      Assert.True(Directory.Exists(folder));
      string msg;

      foreach (KeyValuePair<string, int> pr in expFolderCntMap)
         Assert.True(CheckScriptFolderItemCountHelper(folder, pr.Key, pr.Value, out msg), msg);
   }

   /// <summary>
   /// This checks the file count of the folder rootFolder\folder is >= minCnt
   /// </summary>
   /// <param name="rootFolder"></param>
   /// <param name="folder"></param>
   /// <param name="minCnt"></param>
   /// <returns>true if check passed false otherwise</returns>
   /// <exception cref="NotImplementedException"></exception>
   protected bool CheckScriptFolderItemCountHelper(string rootFolder, string folder, int minCnt, out string msg)
   {
      bool ret = false;
      var fullPath = Path.Combine(rootFolder, folder);

      do
      {
         Assert.True(Directory.Exists(fullPath));
         var files = Directory.GetFiles(fullPath);
         ret = files.Length >= minCnt;
         msg = ret ? "OK" : $"Expected at least {minCnt} files in {fullPath}, found {files.Length}";

         if (!ret) 
            break;

         //files = Directory.GetFiles(fullPath, "tSQLt.*");
         //ret = (files.Count() == 0);

         //if(!ret) 
         //   msg = "tSQLt items exist, but should not";

      } while (false);

      return ret;
   }
}

/// <summary>
/// Custom sink class for XUnit output
/// </summary>
public class XUnitOutputSink : ILogEventSink
{
   private readonly ITestOutputHelper _outputHelper;

   public XUnitOutputSink(ITestOutputHelper outputHelper)
   {
      _outputHelper = outputHelper;
   }

   public void Emit(LogEvent logEvent)
   {
      var message = logEvent.RenderMessage();
      if (logEvent.Exception != null)
      {
         message += $"\nException: {logEvent.Exception}";
      }
      var formattedMessage = $"[{logEvent.Timestamp:yyyy-MM-dd HH:mm:ss.fff} {logEvent.Level}] {message}";
      _outputHelper.WriteLine(formattedMessage); // For Test window
      Debug.WriteLine(formattedMessage); // For Debug window during debugging
   }
}

/// <summary>
/// 
/// </summary>
public class DebugTextWriter : TextWriter
{
   private readonly ITestOutputHelper _outputHelper;

   public DebugTextWriter(ITestOutputHelper outputHelper)
   {
      _outputHelper = outputHelper;
   }

   public override Encoding Encoding => Encoding.UTF8;

   public override void WriteLine(string? value)
   {
      Debug.WriteLine(value); // Real-time in Debug window
      _outputHelper.WriteLine(value); // Test window after test completes
   }

   public override void Write(string? value)
   {
      Debug.Write(value);
      _outputHelper.WriteLine(value);
   }
}