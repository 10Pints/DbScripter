using System;
using System.ComponentModel.Composition;
using System.IO;

namespace SI.Logging
{
    /// <summary>
    /// Represents an object for logging object feedback.
    /// </summary>
    [Export(typeof(IFeedbackLog<object>))]
    public class ObjectFeedbackLog : FeedbackLog<object>
    {
        #region Overrides of FeedbackLog<object>

        /// <summary>
        /// Export this log to a file.
        /// </summary>
        /// <param name="path">The path of the file.</param>
        /// <returns>True if the operation completed, else false.</returns>
        protected override bool OnExportToFile(string path)
        {
            try
            {
                object[] log;

                lock (Log)
                {
                    log = new object[Log.Count];
                    Log.CopyTo(log, 0);
                }

                using (var writer = new StreamWriter(path, false))
                {
                    foreach (var t in log)
                        writer.WriteLine(t);
                }

                return true;
            }
            catch (Exception e)
            {
                FeedbackComponentProvider.Append(this, "Export", $"Exception caught exporting to file: {e.Message}");
                return false;
            }
        }

        #endregion
    }
}