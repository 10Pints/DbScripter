using System;
using PostSharp.Aspects;
using SI.Logging.Providers.log4net;

namespace SI.Logging.LogUtilities
{
    /// <summary>
    /// Provides an aspect for wrapping LogS and LogL functionality.
    /// </summary>
    [Serializable]
    public sealed class LogStartingLogLeavingAspect : OnMethodBoundaryAspect
    {
        /* Notes:
         * 
         * This attribute can be used to log information about a method using the SI.Logging.LogUtilities.LogUtils class.
         * Add it above a method to wrap the method in a LogS and LogL methods.
         * 
         * [LogStartingLogLeavingAttribute]
         * public void TestMethod()
         * 
         * Just remember to Enable PostSharp for the current configuration on any project that uses it.
         */

        #region Properties

        /// <summary>
        /// Get the log type.
        /// </summary>
        public LogType LogType { get; }

        /// <summary>
        /// Get the starting message.
        /// </summary>
        public string StartingMessage { get; }

        /// <summary>
        /// Get the leaving message.
        /// </summary>
        public string LeavingMessageMessage { get; }

        /// <summary>
        /// Get the level.
        /// </summary>
        public int Level { get; } = 3;

        #endregion

        #region Constructors

        /// <summary>
        /// Initialises a new instance of the LogStartingLogLeavingAspect class.
        /// </summary>
        public LogStartingLogLeavingAspect()
        {
        }

        /// <summary>
        /// Initialises a new instance of the LogStartingLogLeavingAspect class.
        /// </summary>
        /// <param name="logType">The log type.</param>
        public LogStartingLogLeavingAspect(LogType logType)
        {
            LogType = logType;
        }

        /// <summary>
        /// Initialises a new instance of the LogStartingLogLeavingAspect class.
        /// </summary>
        /// <param name="logType">The log type.</param>
        /// <param name="startingMessage">The starting message.</param>
        /// <param name="leavingMessage">The leaving message.</param>
        public LogStartingLogLeavingAspect(LogType logType, string startingMessage, string leavingMessage)
        {
            LogType = logType;
            StartingMessage = startingMessage;
            LeavingMessageMessage = leavingMessage;
        }

        /// <summary>
        /// Initialises a new instance of the LogStartingLogLeavingAspect class.
        /// </summary>
        /// <param name="logType">The log type.</param>
        /// <param name="startingMessage">The starting message.</param>
        /// <param name="leavingMessage">The leaving message.</param>
        /// <param name="level">The log level.</param>
        public LogStartingLogLeavingAspect(LogType logType, string startingMessage, string leavingMessage, int level)
        {
            LogType = logType;
            StartingMessage = startingMessage;
            LeavingMessageMessage = leavingMessage;
            Level = level;
            LogUtils.InitLogger();//new Log4NetLogProvider());
        }

        #endregion

        #region Overrides of MethodLevelAspect

        /// <summary>
        /// Method executed before the body of methods to which this aspect is applied.
        /// </summary>
        /// <param name="args">Event arguments specifying which method is being executed, which are its arguments, and how should the execution continue after the execution of PostSharp.Aspects.IOnMethodBoundaryAspect.OnEntry(PostSharp.Aspects.MethodExecutionArgs).</param>
        public override void OnEntry(MethodExecutionArgs args)
        {
            LogUtils.LogS(LogType, StartingMessage, Level);
        }

        /// <summary>
        /// Method executed after the body of methods to which this aspect is applied, even when the method exists with an exception (this method is invoked from the finally block).
        /// </summary>
        /// <param name="args">Event arguments specifying which method is being executed and which are its arguments.</param>
        public override void OnExit(MethodExecutionArgs args)
        {
            LogUtils.LogL(LogType, LeavingMessageMessage, Level);
        }

        #endregion
    }
}
