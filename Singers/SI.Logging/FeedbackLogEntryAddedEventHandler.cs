namespace SI.Logging
{
    /// <summary>
    /// Represents a method that handles the IFeedbackLog.EntryAdded event.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    /// <typeparam name="T">The type of feedback to log.</typeparam>
    public delegate void FeedbackLogEntryAddedEventHandler<T>(object sender, FeedbackLogEntryAddedEventArgs<T> e);
}
