using System;

namespace RSS.Common
{
   /// <summary>
   /// Represents any object that provides logging functionality.
   /// </summary>
   public interface ILogProvider
   {
      /// <summary>
      /// Log a message.
      /// </summary>
      /// <param name="message">The message to log.</param>
      void Log( string message );
      /// <summary>
      /// Log a message.
      /// </summary>
      /// <param name="message">The message to log.</param>
      /// <param name="logType">The type of log.</param>
      void Log( string message, LogType logType );
      /// <summary>
      /// Log an exception.
      /// </summary>
      /// <param name="exception">The exception to log.</param>
      /// <param name="logType">The type of log.</param>
      void Log( Exception exception, LogType logType );

      /// <summary>
      /// Logs string without any frills like Log level timestamp thread
      /// </summary>
      /// <param name="msg"></param>
      /// <param name="logType"></param>
      void LogDirect( string msg, LogType logType = LogType.Info );

      /// <summary>
      /// <summary>
      /// Flush the buffers to log file
      /// </summary>
      /// <param name="timeout"> in mill secs - needed just icase</param>
      void Flush( int timeout = 3000);

      /// <summary>
      /// return the file path to the log
      /// </summary>
      string LogFile { get; }
   }
}
