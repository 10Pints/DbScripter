using System;

namespace SI.Logging
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
        void Log(string message);
        /// <summary>
        /// Log a message.
        /// </summary>
        /// <param name="message">The message to log.</param>
        /// <param name="logType">The type of log.</param>
        void Log(string message, LogType logType);
        /// <summary>
        /// Log an exception.
        /// </summary>
        /// <param name="exception">The exception to log.</param>
        /// <param name="logType">The type of log.</param>
        void Log(Exception exception, LogType logType);
    }
}
