namespace SI.Logging
{
    /// <summary>
    /// Provides data for IFeedbackLog.EntryAdded events.
    /// </summary>
    /// <typeparam name="T">The type of feedback to log.</typeparam>
    public class FeedbackLogEntryAddedEventArgs<T>
    {
        #region Properties

        /// <summary>
        /// The added entry.
        /// </summary>
        public T Entry { get; protected set; }

        #endregion

        #region Methods

        /// <summary>
        /// Initializes a new instance of the FeedbackLogEntryAddedEventArgs class.
        /// </summary>
        protected FeedbackLogEntryAddedEventArgs()
        {
        }

        /// <summary>
        /// Initializes a new instance of the FeedbackLogEntryAddedEventArgs class.
        /// </summary>
        /// <param name="entry">The entry added.</param>
        public FeedbackLogEntryAddedEventArgs(T entry)
        {
            Entry = entry;
        }

        #endregion
    }
}
