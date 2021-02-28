namespace SI.Software.SharedControls
{
    /// <summary>
    /// Represents any object that can subscribe to events.
    /// </summary>
    public interface ISubscribeToEvents
    {
        /// <summary>
        /// Get if events have active subscriptions.
        /// </summary>
        bool IsSubscribedToEvents { get; }
        /// <summary>
        /// Subscribe to events.
        /// </summary>
        void Subscribe();
        /// <summary>
        /// Unsubscribe from events.
        /// </summary>
        void Unsubscribe();
    }
}
