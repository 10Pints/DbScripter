using System;
using System.ComponentModel.Composition;
using System.IO;

namespace SI.Logging
{
    /// <summary>
    /// Represents an object for logging SenderContextEntry feedback.
    /// </summary>
    [Export(typeof(IFeedbackLog<SenderContextEntry>))]
    public class SenderContextEntryFeedbackLog : FeedbackLog<SenderContextEntry>
    {
        #region Constants

        /// <summary>
        /// Get delimiter used when exporting SenderContextEntryFeedbackLog.
        /// </summary>
        public const string ExportDelimiter = "\t";

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the SenderContextEntryFeedbackLog class.
        /// </summary>
        public SenderContextEntryFeedbackLog()
        {
            ApplicableFileFilters = new[] { new FileTypeFilter(".tsv", "Tab Separated Values") };
        }

        #endregion

        #region Overrides of FeedbackLog<SenderContextEntry>

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        protected override void OnAppend(object sender, object context, SenderContextEntry entry)
        {
            if (RejectIncomingEntries)
                return;

            Append(new SenderContextEntry(sender, context, entry));
        }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        protected override void OnAppend(object sender, object context, object entry)
        {
            if (RejectIncomingEntries)
                return;

            OnAppend(new SenderContextEntry(sender, context, entry?.ToString() ?? string.Empty));
        }

        /// <summary>
        /// Export this log to a file.
        /// </summary>
        /// <param name="path">The path of the file.</param>
        /// <returns>True if the operation completed, else false.</returns>
        protected override bool OnExportToFile(string path)
        {
            try
            {
                SenderContextEntry[] log;

                lock (Log)
                {
                    log = new SenderContextEntry[Log.Count];
                    Log.CopyTo(log, 0);
                }

                using (var writer = new StreamWriter(path, false))
                {
                    writer.WriteLine("Date\tTime\tSender\tContext\tEntry");

                    foreach (var t in log)
                        writer.WriteLine($"{t.DateTime.ToLongDateString()}{ExportDelimiter}{t.DateTime.ToLongTimeString()}{ExportDelimiter}{t.Sender?.ToString() ?? string.Empty}{ExportDelimiter}{t.Context?.ToString() ?? string.Empty}{ExportDelimiter}{t.Entry?.ToString() ?? string.Empty}");
                }

                return true;
            }
            catch (Exception e)
            {
                FeedbackComponentProvider.Append(this, "Export", $"Exception caught exporting to file: {e.Message}");
                return false;
            }
        }

        /// <summary>
        /// Clear this log.
        /// </summary>
        protected override void OnClear()
        {
            base.OnClear();
            Append(new SenderContextEntry(this, "Clear", "Feedback log cleared."));
        }

        #endregion
    }
}
