using System;
using System.ComponentModel.Composition;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace SI.Logging
{
    /// <summary>
    /// Represents an object for logging string feedback.
    /// </summary>
    [Export(typeof(IFeedbackLog<string>))]
    public class StringFeedbackLog : FeedbackLog<string>
    {
        #region Properties

        /// <summary>
        /// Get or set if added log entries should be appended to standard output.
        /// </summary>
        public bool AppendToStandardOutput { get; set; } = true;

        /// <summary>
        /// Get or set if added log entries are prefixed with the date and time.
        /// </summary>
        public bool PrefixWithDateTime { get; set; } = true;

        /// <summary>
        /// Get or set if short type names are used for sender objects when appending.
        /// </summary>
        public bool UseShortTypeNamesForSender { get; set; } = true;

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the StringFeedbackLog class.
        /// </summary>
        public StringFeedbackLog()
        {
            ApplicableFileFilters = new[] { new FileTypeFilter(".txt", "Text File") };
        }

        #endregion

        #region Overrides of Object

        /// <summary>
        /// Returns a string that represents the current object.
        /// </summary>
        /// <returns>
        /// A string that represents the current object.
        /// </returns>
        public override string ToString()
        {
            var builder = new StringBuilder();

            string[] array;

            lock (Log)
            {
                array = new string[Log.Count];
                Log.CopyTo(array, 0);
            }

            foreach (var t in array)
                builder.AppendLine(t);

            return builder.ToString();
        }

        #endregion

        #region Overrides of FeedbackLog<string>

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="entry">The entry to append.</param>
        protected override void OnAppend(string entry)
        {
            if (RejectIncomingEntries)
                return;

            string entryToLog;
            if (PrefixWithDateTime)
            {
                var now = DateTime.Now;
                var padding = string.Empty;

                // ReSharper disable once UseStringInterpolation
                var dateTime = string.Format("{0}/{1}{2}/{3}{4} {5}{6}:{7}{8}:{9}{10}.{11}{12}{13}: ",
                    now.Year,
                    now.Month < 10 ? "0" : padding,
                    now.Month,
                    now.Day < 10 ? "0" : padding,
                    now.Day,
                    now.Hour < 10 ? "0" : padding,
                    now.Hour,
                    now.Minute < 10 ? "0" : padding,
                    now.Minute,
                    now.Second < 10 ? "0" : padding,
                    now.Second,
                    now.Millisecond < 100 ? "0" : padding,
                    now.Millisecond < 10 ? "0" : padding,
                    now.Millisecond);

                entryToLog = entry.Insert(0, dateTime);
            }
            else
                entryToLog = entry;

            if (AppendToStandardOutput)
                Debug.Print(entryToLog);

            base.OnAppend(entryToLog);
        }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        protected override void OnAppend(object sender, object context, string entry)
        {
            if (RejectIncomingEntries)
                return;

            string senderString;
            if (!(sender is string))
            {
                var type = sender.GetType();
                if ((UseShortTypeNamesForSender) && (sender.ToString() == type.FullName))
                    senderString = type.Name;
                else
                    senderString = string.Empty;
            }
            else
                senderString = (string)sender;

            Append($"{senderString}{(!string.IsNullOrEmpty(senderString) ? ": " : string.Empty)}{context}{(context != null ? ": " : string.Empty)}{entry}");
        }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        protected override void OnAppend(object sender, object context, object entry)
        {
            OnAppend(sender, context, entry?.ToString() ?? string.Empty);
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
                string[] log;

                lock (Log)
                {
                    log = new string[Log.Count];
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

        /// <summary>
        /// Clear this log.
        /// </summary>
        protected override void OnClear()
        {
            base.OnClear();
            Append("Feedback log cleared.");
        }

        #endregion
    }
}
