using System;
using System.Collections.Generic;
using System.Linq;

namespace SI.Logging
{
    /// <summary>
    /// Represents a class for logging feedback.
    /// </summary>
    /// <typeparam name="T">The type of feedback to log.</typeparam>
    public class FeedbackLog<T> : IFeedbackLog<T>
    {
        #region Properties

        /// <summary>
        /// Get or set the log queue.
        /// </summary>
        protected Queue<T> Log { get; set; } = new Queue<T>();

        /// <summary>
        /// Get the element at a known location.
        /// </summary>
        /// <param name="index">The index of the element.</param>
        /// <returns>The element.</returns>
        public T this[int index] => Log.ElementAt(index);

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the FeedbackLog class.
        /// </summary>
        public FeedbackLog()
        {
            ApplicableFileFilters = new[] { new FileTypeFilter(".txt", "Text File") };
        }

        #endregion

        #region Methods

        /// <summary>
        /// Dispatch the IFeedbackLog.EntryAdded event.
        /// </summary>
        protected virtual void OnDispatchEntryAdded(T entry)
        {
            EntryAdded?.Invoke(this, new FeedbackLogEntryAddedEventArgs<T>(entry));
        }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="entry">The entry to append.</param>
        protected virtual void OnAppend(T entry)
        {
            if (RejectIncomingEntries)
                return;

            lock (Log)
            {
                while (Log.Count >= MaximumCapacity)
                {
                    Log.Dequeue();
                }

                Log.Enqueue(entry);
            }

            OnDispatchEntryAdded(entry);
        }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        protected virtual void OnAppend(object sender, object context, T entry)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        protected virtual void OnAppend(object sender, object context, object entry)
        {
            //throw new NotImplementedException();
        }

        /// <summary>
        /// Export this log to a file.
        /// </summary>
        /// <param name="path">The path of the file.</param>
        /// <returns>True if the operation completed, else false.</returns>
        protected virtual bool OnExportToFile(string path)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Clear this log.
        /// </summary>
        protected virtual void OnClear()
        {
            lock (Log)
            {
                Log.Clear();
            }
        }

        #endregion

        #region Implementation of IFeedbackLog<string>

        /// <summary>
        /// Occurs when a new entry is added.
        /// </summary>
        public event FeedbackLogEntryAddedEventHandler<T> EntryAdded;

        /// <summary>
        /// Get or set if incoming entries are rejected.
        /// </summary>
        public bool RejectIncomingEntries { get; set; }

        /// <summary>
        /// Get or set the maximum capacity of the log. If this is exceeded the oldest item is discarded to make room for the newest.
        /// </summary>
        public int MaximumCapacity { get; set; } = 250;

        /// <summary>
        /// Get the number of items in the log.
        /// </summary>
        public int Count => Log.Count;

        /// <summary>
        /// Get an array of applicable file type filters.
        /// </summary>
        public FileTypeFilter[] ApplicableFileFilters { get; protected set; }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="entry">The entry to append.</param>
        public void Append(T entry)
        {
            OnAppend(entry);
        }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        public void Append(object sender, object context, T entry)
        {
            OnAppend(sender, context, entry);
        }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        public void Append(object sender, object context, object entry)
        {
            OnAppend(sender, context, entry);
        }

        /// <summary>
        /// Export this log to a file.
        /// </summary>
        /// <param name="path">The path of the file.</param>
        /// <returns>True if the operation completed, else false.</returns>
        public bool ExportToFile(string path)
        {
            return OnExportToFile(path);
        }

        /// <summary>
        /// Clear this log.
        /// </summary>
        public void Clear()
        {
            OnClear();
        }

        #endregion
    }
}
