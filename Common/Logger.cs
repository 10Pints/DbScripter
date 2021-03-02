
#nullable enable

using log4net;
using log4net.Config;
using log4net.Repository.Hierarchy;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text;
using System.Windows;

namespace RSS.Common
{
   /// <summary>
   /// This static class implements the logging extension methods
   /// and GetUserAppDataPath which is a WPF replacement for the old Windows.Forms method to get the Users AppData path
   /// 
   /// Example usage:
   /// 
   /// protected Function()
   /// {
   /// 	LogS();  Log output                     e.g: 171102-125926	  8	DEBUG	App.xaml.cs(55)	App..ctor()	Starting 
   /// 	AssemblyUtils = new AssemblyUtils();
   /// 	FeatureUrl = string.Empty;
   /// 	LatestVersionProvider = new LatestVersionProvider();
   /// 	LogI("UpdaterConfig.Enabled = true");   e.g: 171117-153453	  8	INFO 	App.xaml.cs(174)	App.LaunchSplashScreenAndCheckForAndProcessUpdates()	Message 	UpdaterConfig.Enabled = true
   /// 	LogD($"status = {Status}");             e.g: 171117-153453	  8	DEBUG	Updater.cs(139)	Updater..ctor()	Message 	Status = Constructed 
   /// 	LogL();  // ->                          e.g: 171117-153456	  8	DEBUG	App.xaml.cs(102)	App..ctor()	Leaving 
   ///     LogE("Init failed")                     e.g: 171117-153453	  8	ERROR 	App.xaml.cs(210)	Init failed
   ///     LogW(string.Format("Status expected to be Constructed but is {0}" Status): 
   ///                                             e.g: 171117-153456	  8	WARNING Status expected to be Constructed but is INITIALISED
   /// }
   /// 
   /// If the logging settings are set in the application configuration like:
   ///  <log4net>]
   /// ..
   /// <appender name="RollingFileAppender">
   ///   <filter type = "log4net.Filter.LevelRangeFilter" >
   ///     <levelMin value="DEBUG" />
   ///     <levelMax value = "FATAL" />
   ///    </filter >
   /// ...
   ///   <layout type="log4net.Layout.PatternLayout">
   ///     <conversionPattern value = "%date{yyMMdd-HHmmss}	%03thread	%-5level	%message%newline" />
   ///   </layout >
   ///  </appender>
   /// </log4net>
   /// Would yield the log file snippet 
   /// 171019-155617	 15	DEBUG	Updater.cs(135)	Updater..ctor()	Starting 
   /// 171019-155617	 15	DEBUG Updater.cs(140) Updater..ctor()	Message Status = Constructed
   /// 171019-155617	 15	DEBUG Updater.cs(142) Updater..ctor()	Leaving
   /// 
   /// Could add milli-secs to the format if required
   /// 
   /// The logging methods have overrides to log a message
   /// e.g.
   /// LogS($"application configuration file was: name: \"{name}\" file: \"{file}\"");
   /// 
   /// NOTES:
   /// This logging uses the stack and the method gets from the stack frame
   /// This process is relatively slow so do not use these methods in inner time critical loops
   /// They are meant to be used at the start, end and critical points in non time critical code
   /// Most are set to debug level by default so that they can be easily turned off during normal run <levelMin value="INFO" />
   /// But when production code on site gives issue the log filter can be set to debug   <levelMin value="DEBUG"/> to get a detailed verbose log
   /// when bug hunting.
   /// </summary>
   public static class Logger
   {
      #region private Static fields


      /// <summary>
      /// If log level of a log call is below this threshold then it will not be logged 
      /// </summary>
      private static LogType _minimumLoggingLevel = LogType.Debug;

      #endregion  private Static fields

      #region properties
      #region private properties

      /// <summary>
      /// LogLineCache is used to hold the log lines before the logger is initialised
      /// </summary>
      private static List<string> LogLineCache { get; } = new List<string>();

      #endregion private proerties
      #region public properties
      #region public static properties
      /// <summary>
      /// This flag determines if a message box is displayed by LogAndMsg(...) methods.
      /// Turn off for Unit testing
      /// </summary>
      public static bool DisplayMessages { get; set; } = true;
      public static bool LogMethodInfo { get; set; } = true;

      /// <summary>
      /// If true then log output is also sent to console
      /// </summary>
      public static bool ConsoleEnabled { get; set; } = true;

      public static string? LogFile
      { 
         get
         {
            return  _logProvider?.LogFile;
         }
      }

      /// <summary>
      /// 
      /// </summary>
      public static void DisplayLog()
      { 
         Process.Start($"Notepad++.exe", LogFile);
      }

      /// <summary>
      /// Sets the log provider
      /// Logging can occur before the logger is instantiated because
      /// if the logger is not set then the log messages are cached in log cache instead of being logged immediately
      /// Once the logger is set then the log cache is dumped to the log and cleaned.
      /// </summary>
      private static ILogProvider? _logProvider = null;
      //private static Log4NetLogProvider _log4NetLogProvider = null;
      public static ILogProvider? LogProvider
      {
         get => _logProvider;

         set
         {
            //Utils.Precondition(value != null, "Error: setting a null logProvider");
            _logProvider = value;
            SetMinLoggingLevel(LogType.Debug);
         }
      }

      /// <summary>
      /// Flag to indicate if the logger is alreaady initialised - subsequent initialisation has not effect
      /// </summary>
      public static bool IsInitialised => LogProvider != null;

      #endregion public static properties
      #endregion public properties
      #endregion properties
      #region pubic methods

        /// <summary>
        /// Debug level logging
        /// </summary>
        /// <param name="msg">Optional message</param>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void LogD(string? msg = null)
        {
            if (_minimumLoggingLevel <= LogType.Debug)
                Log_(LogType.Debug, msg, 2);
        }

      // Write the string to a file.append mode is enabled so that the log
      // lines get appended to  test.txt than wiping content and writing the log

      //   writer.WriteLine(format, args);
      //   writer.Flush();
      //}

      public static void Log( params object[]? args )
      {
         StringBuilder sb = new();

         if(args != null)
            foreach(var arg in args)
               sb.AppendLine(arg.ToString());

            Log_(LogType.Info, sb.ToString(), 2);
      }

      /// <summary>
      /// Information level logging
      /// </summary>
      /// <param name="msg">Optional message</param>
      [MethodImpl(MethodImplOptions.NoInlining)]
      public static void LogI( string? msg = null )
      {
         if(_minimumLoggingLevel <= LogType.Info)
            Log_(LogType.Info, msg, 2);
      }

      /// <summary>
      /// Error level logging
      /// </summary>
      /// <param name="msg">Optional message</param>
      /// <param name="skipFrames">number of stack fames to skip - e.g. 3 useful if called indirectly from a "wrapper" method
      /// making the method we want 1 frame lower in the call stack</param>
      [MethodImpl(MethodImplOptions.NoInlining)]
      public static void LogW( string msg, int skipFrames = 2 )
      {
         if(_minimumLoggingLevel <= LogType.Warning)
            Log_(LogType.Warning, msg, skipFrames);
      }

      /// <summary>
      /// Error level logging
      /// N.B.: the method we want is 1 frame lower in the call stack
      /// Returns false for convenience e.g.:
      /// if error
      ///     return LogE("some useful message");
      /// </summary>
      /// <param name="msg">Optional message</param>
      /// <param name="skipFrames">number of stack fames to skip - e.g. 3 useful if called indirectly from a "wrapper" method</param>
      [MethodImpl(MethodImplOptions.NoInlining)]
      public static bool LogE( string msg, int skipFrames = 2 )
      {
         LogProvider?.Log("");
         Log_(LogType.Error, msg, skipFrames);
         LogProvider?.Log("");
         return false;
      }

      /// <summary>
      /// Log helper to log a method is starting
      /// </summary>
      /// <param name="logType">Optional logType - default = Debug</param>
      /// <param name="msg">Optional message</param>
      /// <param name="frame">Optional stack frame offset - normally this will log the calling function name and file, but if used in another logging method then 
      /// will need to modify this to get the correct calling method</param>
      [MethodImpl(MethodImplOptions.NoInlining)]
      public static void LogS( string? msg = null, LogType logType = LogType.Debug, int frame = 2 )
      {
         if(_minimumLoggingLevel <= logType)
            Log_(logType, msg, frame);
      }
/*
      /// <summary>
      /// Log helper to log a method is starting
      /// </summary>
      /// <param name="msg">Optional message</param>
      /// <param name="frame">Optional stack frame offset - normally this will log the calling function name and file, but if used in another logging method then 
      /// will need to modify this to get the correct calling method</param>
      [MethodImpl(MethodImplOptions.NoInlining)]
      public static void LogS( string msg = null, int frame = 2 )
      {
         if(_minimumLoggingLevel <= LogType.Debug)
            Log_(LogMode.Starting, LogType.Debug, msg, frame);
      }
*/
      /// <summary>
      /// Log helper to log a method is leaving
      /// </summary>
      /// <param name="msg">Optional message</param>
      /// <param name="frame">Optional stack frame offset - normally this will log the calling function name and file, but if used in another logging method then 
      /// will need to modify this to get the correct calling method</param>
      [MethodImpl(MethodImplOptions.NoInlining)]
      public static void LogL( string? msg = null, LogType logType = LogType.Debug, int frame = 2 ) // 1: calling method
      {
         if(_minimumLoggingLevel <= LogType.Debug)
            Log_(LogType.Debug, msg, frame);
      }
/*
      /// <summary>
      /// Log helper to log a method is leaving
      /// </summary>
      /// <param name="logType">Optional logType - default = Debug</param>
      /// <param name="msg">Optional message</param>
      /// <param name="frame">Optional stack frame offset - normally this will log the calling function name and file, but if used in another logging method then 
      /// will need to modify this to get the correct calling method</param>
      [MethodImpl(MethodImplOptions.NoInlining)]
      public static void LogL( LogType logType, string msg = null, int frame = 2 ) // 1: calling method
      {
         if(_minimumLoggingLevel <= logType)
            Log_(LogMode.Leaving, logType, msg, frame);
      }
*/
      // PRE: current directory set
      /// <summary>
      /// Encapsulates the logging initialisation - e.g. for unit tests.
      /// </summary>
      /// <param name="provider">The log provider.</param>
      /// <param name="path">The path to log all data to - if null use the configured value.</param>
      public static void InitLogger() // string path = null 
      {
         // ASSERTION: LogProvider not initialised
         LogProvider = new Log4NetLogProvider();

         XmlConfigurator.Configure();
         DisplayMessages = false;
         LogLine();
         LogCached();
         LogDirect($"App.config name: {ConfigurationManager.AppSettings["Config Name"]} ");
         LogDirect($"Log file: {LogFile}");
         LogLine();
      }

      /*// <summary>
      /// flush log messages and close the log file
      /// </summary>
      /// <param name="path"></param>
      public static void CloseLogger( string path = null )
      {
         //LogS($"closing the Logger");
         LogManager.Flush(3000);
      }*/

      /// <summary>
      /// Logs the message and raises a message box
      /// if detailedLogMsg is null then userMsg is logged instead
      /// </summary>
      /// <param name="userMsg">the message to display to the user</param>
      /// <param name="detailedLogMsg">optional more detailed log message to log</param>
      public static void LogAndMsg( string userMsg, string? detailedLogMsg = null )
      {
         LogAndMsg(LogType.Info, detailedLogMsg);
      }

      /// <summary>
      /// if detailedLogMsg is null then userMsg is logged instead
      /// Logs message at the log level provided and raises a message box if configured to do so
      /// </summary>
      /// <param name="logType">Debug, info warning or error</param>
      /// <param name="userMsg">the message to display to the user</param>
      /// <param name="detailedLogMsg">optional more detailed log message to log</param>
      public static void LogAndMsg( LogType logType, string? userMsg, string? detailedLogMsg = null )
      {
         if(userMsg == null)
            userMsg = string.Empty;

         Log_(logType, $"{userMsg} {detailedLogMsg}", 2);

         if(DisplayMessages)
            MessageBox.Show(userMsg);
      }

      /// <summary>
      /// Logs message and throws the error
      /// </summary>
      /// <param name="e">instance of Exception T</param>
      /// <param name="userMsg">the message to log and show</param>
      /// <param name="detailedLogMsg">optional more detailed log message to log</param>
      /// <param name="skipFrames">optional number of stack frames to skip - so if calling this from an intermediary function 
      /// then increment this value by 1 to reference the correct parent method stack frame</param>
      public static string LogException( Exception e, string? userMsg = null, string? detailedLogMsg = null, int skipFrames = 2 )
      {
         if(userMsg == null)
            userMsg = string.Empty;

         Type type = e.GetType();
         var allMessages = e.GetAllMessages();
         detailedLogMsg = "\r\n" + detailedLogMsg;
         LogE($"{type.FullName} thrown: {userMsg }{detailedLogMsg}  \r\nException detail: {allMessages}", skipFrames + 1);

         if(DisplayMessages)
            MessageBox.Show(userMsg);

         return allMessages;
      }

      /// <summary>
      /// Logs message and throws the error
      /// </summary>
      /// <typeparamref name="T">Exception Type</typeparamref>
      /// <param name="e">instance of Exception T</param>
      /// <param name="userMsg">the message to show the user</param>
      /// <param name="detailedMsg">the message to log for diagnostic purposes</param>
      public static void LogExceptionAndThrow<T>( T e, string userMsg, string? detailedMsg = null ) where T : Exception//, new()
      {
         LogException(e, userMsg, detailedMsg, 3);
         throw (T)Activator.CreateInstance(typeof(T), $"User message: {userMsg}");
      }
      #endregion public methods
      #region private methods

      /// <summary>
      /// Low level logging method used by all Logging methods (directly or indirectly)
      /// </summary>
      /// <param name="logMode"></param>
      /// <param name="logType"></param>
      /// <param name="msg"></param>
      /// <param name="frameNum"></param>
      [MethodImpl(MethodImplOptions.NoInlining)]
      private static void Log_( LogType logType, string? msg = null, int frameNum = 1 ) // frameNum = 1: means calling Method
      {
         // Don't waste time if configuration logging filter excludes this log level
         if(_minimumLoggingLevel <= logType)
         {
            string?  fileName   = null;
            string?  methodName = null;
            string?  className  = null;
            int?     lnNm       = null;

            if(LogMethodInfo)
            {
               var sf      = new StackFrame(frameNum, true);
               var method  = sf.GetMethod();
               fileName    = sf.GetFileName();
               fileName    = Path.GetFileName(fileName);
               methodName  = method?.Name; 
               className   = method?.ReflectedType?.Name;
               lnNm        = sf.GetFileLineNumber();
            }

            // If logger not initialised yet then 
            // - add the log to the cache, 
            // - later when logging is initialised can log the cache lines
            if(LogProvider == null)
            {
               //var logInfo = new LogInfo(fileName, lnNm, logMode, clsName, method.Name, logType, msg);
               var line = FormatLine( msg, fileName, lnNm, className, methodName);
               LogLineCache.Add(line);
#if DEBUG
               Debug.WriteLine(line); // Dump now - dont want the suspense of waiting till logger fully initialised!
#endif
            }
            else
            {
               LogProvider.Log(FormatLine( msg, fileName, lnNm, className, methodName));
            }
         }
      }

      private static string FormatLine( string? msg
                                       ,string? fileName
                                       ,int?    lineNumber
                                       ,string? className
                                       ,string? methodName)
      { 
         var filePart   = (!string.IsNullOrEmpty(fileName)) ? $"{fileName}({lineNumber})"    : "";
         var methodPart = (!string.IsNullOrEmpty(className))? $"\t{className}.{methodName}()": "";
         var msgPart    = (!string.IsNullOrEmpty(msg))      ? $"\t{msg}"                     : "";
         return $"{filePart}{methodPart}{msgPart}";
      }
         //var strLogType = (LogMode == LogMode.Message)  ? "Message"  :
         //                  (LogMode == LogMode.Starting) ? "Starting" :
         //                  (LogMode == LogMode.Leaving)  ? "Leaving"  : "???";


      /// <summary>
      /// Directly logs to logger - no buffering
      /// </summary>
      public static void LogLine( LogType logType = LogType.Debug )
      {
         var line = new string('-', 120);
         LogDirect(line, logType);
      }

      /// <summary>
      /// Directly logs to logger - no buffering
      /// </summary>
      public static void LogDirect( string msg, LogType logType = LogType.Debug )
      {
         LogProvider?.LogDirect(msg, logType);
      }

      public static void FlushLogger()
      {
         LogProvider?.Flush();
      }

      /// <summary>
      /// low level access to the Log4Net Logger wrapper
      /// </summary>
      //private static void Log_( string msg, LogType logType = LogType.Debug )
      //{
      //   LogProvider.Log(msg, logType);
      //}

      /// <summary>
      /// Allows logging before logger is initialised
      /// 
      /// POST: LogLineCache items logged and cache clear
      /// </summary>
      private static void LogCached()
      {
         foreach(var line in LogLineCache)//.Where(item => _minimumLoggingLevel <= item.LogType))
            LogProvider?.Log(line);

         LogLineCache.Clear();
      }

      /// <summary>
      /// Caches the minimum logging level as it is tedious to get
      /// PRE logProvider != null
      /// </summary>
      public static void SetMinLoggingLevel(LogType minimumLoggingLevel)
      {
         var logger = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
         _minimumLoggingLevel = minimumLoggingLevel;
      }
         
 /*        logger.Debug.
         logger.IsDebugEnabled ? LogType.Debug :
                 logger.IsInfoEnabled ? LogType.Info :
                     logger.IsWarnEnabled ? LogType.Warning : LogType.Error;
      }*/

      #endregion private methods
   }
}
