using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Windows;
using log4net;
using log4net.Appender;
using log4net.Config;
using log4net.Repository.Hierarchy;
using SI.Common;
using SI.Logging.Providers.log4net;

namespace SI.Logging.LogUtilities
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
   public static partial class LogUtils
    {

#region const values and enums

        #endregion const values and enums
        #region private Static fields

        private static Log4NetLogProvider _logProvider;

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
        private static List<LogInfo> LogLineCache { get; } = new List<LogInfo>();


        #endregion private proerties
        #region public properties
        #region public static properties
        /// <summary>
        /// This flag determines if a message box is displayed by LogAndMsg(...) methods.
        /// Turn off for Unit testing
        /// </summary>
        public static bool DisplayMessages { get; set; } = true;

        /// <summary>
        /// If true then log output is also sent to console
        /// </summary>
        public static bool ConsoleEnabled { get; set; } = true;

        /// <summary>
        /// Sets the log provider
        /// Logging can occur before the logger is instantiated because
        /// if the logger is not set then the log messages are cached in log cache instead of being logged immediately
        /// Once the logger is set then the log cache is dumped to the log and cleaned.
        /// </summary>
        public static Log4NetLogProvider LogProvider
        {
            get { return _logProvider; }

            set
            {
                Utils.Precondition(value != null, "Error: setting a null logProvider");
                _logProvider = value;
                SetMinLoggingLevel();
                LogCached();
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
        public static void LogD(string msg = null)
        {
            if (_minimumLoggingLevel <= LogType.Debug)
                Log_(LogMode.Message, LogType.Debug, msg, 2);
        }

        /// <summary>
        /// Information level logging
        /// </summary>
        /// <param name="msg">Optional message</param>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void LogI(string msg = null)
        {
            if (_minimumLoggingLevel <= LogType.Info)
                Log_(LogMode.Message, LogType.Info, msg, 2);
        }

        /// <summary>
        /// Error level logging
        /// </summary>
        /// <param name="msg">Optional message</param>
        /// <param name="skipFrames">number of stack fames to skip - e.g. 3 useful if called indirectly from a "wrapper" method
        /// making the method we want 1 frame lower in the call stack</param>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void LogW(string msg, int skipFrames = 2)
        {
            if (_minimumLoggingLevel <= LogType.Warning)
                Log_(LogMode.Message, LogType.Warning, msg, skipFrames);
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
        public static bool LogE(string msg, int skipFrames = 2)
        {
            LogProvider.Log("");
            Log_(LogMode.Message, LogType.Error, msg, skipFrames);
            LogProvider.Log("");
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
        public static void LogS(LogType logType, string msg = null, int frame = 2)
        {
            if (_minimumLoggingLevel <= logType)
                Log_(LogMode.Starting, logType, msg, frame);
        }

        /// <summary>
        /// Log helper to log a method is starting
        /// </summary>
        /// <param name="msg">Optional message</param>
        /// <param name="frame">Optional stack frame offset - normally this will log the calling function name and file, but if used in another logging method then 
        /// will need to modify this to get the correct calling method</param>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void LogS(string msg = null, int frame = 2)
        {
            if (_minimumLoggingLevel <= LogType.Debug)
                Log_(LogMode.Starting, LogType.Debug, msg, frame);
        }

        /// <summary>
        /// Log helper to log a method is leaving
        /// </summary>
        /// <param name="msg">Optional message</param>
        /// <param name="frame">Optional stack frame offset - normally this will log the calling function name and file, but if used in another logging method then 
        /// will need to modify this to get the correct calling method</param>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void LogL(string msg = null, int frame = 2) // 1: calling method
        {
            if (_minimumLoggingLevel <= LogType.Debug)
                Log_(LogMode.Leaving, LogType.Debug, msg, frame);
        }

        /// <summary>
        /// Log helper to log a method is leaving
        /// </summary>
        /// <param name="logType">Optional logType - default = Debug</param>
        /// <param name="msg">Optional message</param>
        /// <param name="frame">Optional stack frame offset - normally this will log the calling function name and file, but if used in another logging method then 
        /// will need to modify this to get the correct calling method</param>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void LogL(LogType logType, string msg = null, int frame = 2) // 1: calling method
        {
            if (_minimumLoggingLevel <= logType)
                Log_(LogMode.Leaving, logType, msg, frame);
        }

        // PRE: current directory set
        /// <summary>
        /// Encapsulates the logging initialisation - e.g. for unit tests.
        /// </summary>
        /// <param name="provider">The log provider.</param>
        /// <param name="path">The path to log all data to - if null use the configured value.</param>
        public static void InitLogger(Log4NetLogProvider provider = null, string path=null)
        {
            LogS($"Configuring the Logger, App.config name: {ConfigurationManager.AppSettings["Config Name"]} log path: [{path}]");

            if (LogProvider != null)
            {
                LogL("Logger already configured - ignoring this call");
                return;
            }

            if (provider == null)
                provider = new Log4NetLogProvider();

            XmlConfigurator.Configure();
            LogProvider = provider;
            DisplayMessages = false;

            // if a new path specified
            if (!string.IsNullOrEmpty(path))
            {
                GlobalContext.Properties["CommonApplicationData"] = Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData);
                XmlConfigurator.Configure();
                var hierarchy = (Hierarchy)LogManager.GetRepository();
/*
                foreach (var appender in hierarchy.Root.Appenders.ToArray().Where(x => x is FileAppender).Cast<FileAppender>())
                {
                    //appender.File = path;
                    appender.ActivateOptions();
                    break;
                }*/
            }

            LogL();
        }

        /// <summary>
        /// Logs the message and raises a message box
        /// if detailedLogMsg is null then userMsg is logged instead
        /// </summary>
        /// <param name="userMsg">the message to display to the user</param>
        /// <param name="detailedLogMsg">optional more detailed log message to log</param>
        public static void LogAndMsg(string userMsg, string detailedLogMsg = null)
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
        public static void LogAndMsg(LogType logType, string userMsg, string detailedLogMsg=null)
        {
            if (userMsg == null)
                userMsg = string.Empty;

            Log_(LogMode.Message, logType, $"{userMsg} {detailedLogMsg ?? "no detailed message"}", 2);

            if (DisplayMessages)
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
        public static string LogException(Exception e, string userMsg = null, string detailedLogMsg=null, int skipFrames = 2) 
        {
            if (userMsg == null)
                userMsg = string.Empty;

            Type type = e.GetType();
            var allMessages = e.GetAllMessages();
            LogE($"{type.FullName} thrown: {userMsg }  \nDetailed message: {detailedLogMsg ?? "none"}  \nException detail: {allMessages}", skipFrames + 1);

            if (DisplayMessages)
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
        public static void LogExceptionAndThrow<T>(T e, string userMsg, string detailedMsg = null) where T : Exception//, new()
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
        private static void Log_(LogMode logMode, LogType logType, string msg = null, int frameNum = 1) // frameNum = 1: means calling Method
        {
            // Don't waste time if configuration logging filter excludes this log level
            if (_minimumLoggingLevel <= logType)
            {
                var sf = new StackFrame(frameNum, true);
                var fileName = sf.GetFileName();
                fileName = Path.GetFileName(fileName);
                var method = sf.GetMethod();
                var clsName = method.ReflectedType?.Name;
                var lineNumber = sf.GetFileLineNumber();

                // If logger not initialised yet then 
                // - add the log to the cache, 
                // - later when logging is initialised can log the cache lines
                if (LogProvider == null)
                {
                    var logInfo = new LogInfo(fileName, lineNumber, logMode, clsName, method.Name, logType, msg);
                    LogLineCache.Add(logInfo);
#if DEBUG
                    Debug.WriteLine(logInfo); // Dump now - dont want the suspense of waiting till logger fully initialised!
#endif
                }
                else
                    LogData(new LogInfo(fileName, lineNumber, logMode, clsName, method.Name, logType, msg));
            }
        }

        /// <summary>
        /// Called by _Log to do the logging or by LogCached to log the cached log lines
        /// PRE: logger initialised
        /// POST: line logged
        /// </summary>
        /// <param name="li">log information</param>
        private static void LogData(LogInfo li)
        {
            // Initial blank line
            if (li.LogMode == LogMode.Starting)
                LogProvider.Log("");

            LogLine(li.ToString(), li.LogType);
        }

        /// <summary>
        /// Directly logs to logger - no buffering
        /// </summary>
        private static void LogLine(string line = "", LogType logType = LogType.Debug)
        {
            LogProvider.Log(line, logType);

            //if(ConsoleEnabled)
            //    Console.WriteLine(line);
#if DEBUG
            Debug.WriteLine(line);
#endif
        }

        /// <summary>
        /// Allows logging before logger is initialised
        /// 
        /// POST: LogLineCache items logged and cache clear
        /// </summary>
        private static void LogCached()
        {
            foreach (var item in LogLineCache.Where(item => _minimumLoggingLevel <= item.LogType))
                LogData(new LogInfo(item.FileName, item.LineNumber, item.LogMode, item.ClsName, item.Method, item.LogType, item.Msg));

            LogLineCache.Clear();
        }

        /// <summary>
        /// Caches the minimum logging level as it is tedious to get
        /// PRE logProvider != null
        /// </summary>
        private static void SetMinLoggingLevel()
        {
            var logger = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);

            _minimumLoggingLevel =
                logger.IsDebugEnabled ? LogType.Debug :
                    logger.IsInfoEnabled ? LogType.Info :
                        logger.IsWarnEnabled ? LogType.Warning : LogType.Error;
        }

        #endregion private methods
    }
}
