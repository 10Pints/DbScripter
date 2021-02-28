namespace SI.Logging
{
    /// <summary>
    /// Represents any object that can act as a feedback log.
    /// </summary>
    /// <typeparam name="T">The type of feedback to log.</typeparam>
    public interface IFeedbackLog<T>
    {
        /// <summary>
        /// Occurs when a new entry is added.
        /// </summary>
        event FeedbackLogEntryAddedEventHandler<T> EntryAdded;

        /// <summary>
        /// Get or set if incoming entries are rejected.
        /// </summary>
        bool RejectIncomingEntries { get; set; }

        /// <summary>
        /// Get or set the maximum capacity of the log. If this is exceeded the oldest item is discarded to make room for the newest.
        /// </summary>
        int MaximumCapacity { get; set; }

        /// <summary>
        /// Get the number of items in the log.
        /// </summary>
        int Count { get; }

        /// <summary>
        /// Get an array of applicable file type filters.
        /// </summary>
        FileTypeFilter[] ApplicableFileFilters { get; }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="entry">The entry to add.</param>
        void Append(T entry);

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        void Append(object sender, object context, T entry);

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        void Append(object sender, object context, object entry);

        /// <summary>
        /// Export this log to a file.
        /// </summary>
        /// <param name="path">The path of the file.</param>
        /// <returns>True if the operation completed, else false.</returns>
        bool ExportToFile(string path);

        /// <summary>
        /// Clear this log.
        /// </summary>
        void Clear();
    }
}
