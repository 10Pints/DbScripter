using System;
using System.ComponentModel.Composition;
using log4net;

namespace SI.Logging.Providers.log4net
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
        public void Log(string message)
        {
            if (Logger.IsInfoEnabled)
                Logger.Info(message);

            Console.WriteLine(message);
        }

        /// <summary>
        /// Log a message.
        /// </summary>
        /// <param name="message">The message to log.</param>
        /// <param name="logType">The type of log.</param>
        public void Log(string message, LogType logType)
        {
            switch (logType)
            {
                case LogType.Debug:
                    if (Logger.IsDebugEnabled)
                        Logger.Debug(message);

                    break;
                case LogType.Info:
                    if (Logger.IsInfoEnabled)
                        Logger.Info(message);

                    break;
                case LogType.Warning:
                    if (Logger.IsWarnEnabled)
                        Logger.Warn(message);

                    break;
                case LogType.Error:
                    if (Logger.IsErrorEnabled)
                        Logger.Error(message);

                    break;
                case LogType.Fatal:
                    if (Logger.IsFatalEnabled)
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
        public void Log(Exception exception, LogType logType)
        {
            Log(exception.ToString(), logType);
        }

        #endregion
    }
}
