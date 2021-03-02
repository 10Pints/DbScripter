using log4net;
using log4net.Appender;
using log4net.Core;
using log4net.Layout;
using log4net.Repository;
using log4net.Repository.Hierarchy;
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.Linq;
using static RSS.Common.Utils;

namespace RSS.Common
{
   /// <summary>
   /// A log provider for log4net.
   /// </summary>
   [Export(typeof(ILogProvider))]
   public class Log4NetLogProvider : ILogProvider
   {
      #region StaticFields

      private static readonly ILog Logger = LogManager.GetLogger(typeof(ILogProvider));

      #endregion

      #region Implementation of ILogProvider

      /// <summary>
      /// Log a message.
      /// </summary>
      /// <param name="message">The message to log.</param>
      public void Log( string message )
      {
         if(Logger.IsInfoEnabled)
            Logger.Info(message);

         Console.WriteLine(message);
      }

      /// <summary>
      /// Log a message.
      /// </summary>
      /// <param name="message">The message to log.</param>
      /// <param name="logType">The type of log.</param>
      public void Log( string message, LogType logType )
      {
         switch(logType)
         {
         case LogType.Debug:
            if(Logger.IsDebugEnabled)
               Logger.Debug(message);

            break;
         case LogType.Info:
            if(Logger.IsInfoEnabled)
               Logger.Info(message);

            break;
         case LogType.Warning:
            if(Logger.IsWarnEnabled)
               Logger.Warn(message);

            break;
         case LogType.Error:
            if(Logger.IsErrorEnabled)
               Logger.Error(message);

            break;
         case LogType.Fatal:
            if(Logger.IsFatalEnabled)
               Logger.Fatal(message);

            break;

         default: throw new NotImplementedException();
         }

         Console.WriteLine(message);
      }

      /// <summary>
      /// Log an exception.
      /// </summary>
      /// <param name="exception">The exception to log.</param>
      /// <param name="logType">The type of log.</param>
      public void Log( Exception exception, LogType logType )
      {
         Log(exception.ToString(), logType);
      }

      /// <summary>
      /// Logs using none of the frills and patterns like timestamp thread etc
      /// </summary>
      /// <param name="msg"></param>
      /// <param name="logType"></param>
      public void LogDirect(string msg, LogType logType = LogType.Info)
      { 
         ILayout layout = FileAppender.Layout;
         // <conversionPattern value="%date{HH:mm:ss} [%thread] %-5level - %message%newline" />
         log4net.Layout.PatternLayout patternLayout = layout as log4net.Layout.PatternLayout;
         AssertNotNull(patternLayout);
         string oldConversionPattern = patternLayout.ConversionPattern;
         patternLayout.ConversionPattern = "%message%newline";
         patternLayout.ActivateOptions();
         Log( msg, logType);
         patternLayout.ConversionPattern = oldConversionPattern;
         patternLayout.ActivateOptions();
      }

      protected FileAppender FileAppender
      {
         get
         {
            ILoggerRepository repo        = LogManager.GetRepository();
            Hierarchy hierarchy           = repo as Hierarchy; // (Hierarchy)repo
            log4net.Repository.Hierarchy.Logger root = hierarchy.Root;
            AppenderCollection appenders  = root.Appenders;
            IEnumerable<FileAppender> fileAppenders = appenders.OfType<FileAppender>();
            FileAppender fileAppender     = fileAppenders.FirstOrDefault();
            AssertNotNull(fileAppender);
            return fileAppender;
         }
      }
      /// <summary>
      /// return the file path to the log
      /// </summary>
      public string LogFile
      {
         get
         {
            string filename = FileAppender.File;
            return filename;
         }
      }

      public void Flush( int timeout = 3000)
      {
         LogManager.Flush(3000);
      }
 /*         var repo = LogManager.GetRepository();
            var hierarchy = (Hierarchy)repo;
            var root = hierarchy.Root;
            var appenders = root.Appenders;
            var fileAppenders = appenders.OfType<FileAppender>();
            var fileAppender = fileAppenders.FirstOrDefault();
            var rootAppender = ((Hierarchy)LogManager.GetRepository())
                                         .Root.Appenders.OfType<FileAppender>()
                                         .FirstOrDefault();
 */

      #endregion
   }
}
