namespace SI.Logging
{
    /// <summary>
    /// Enumeration of debugging retention modes.
    /// </summary>
    public enum DebugRetentionMode
    {
        /// <summary>
        /// Never.
        /// </summary>
        Never = 0,
        /// <summary>
        /// Always.
        /// </summary>
        Always,
        /// <summary>
        /// Only on error.
        /// </summary>
        OnlyOnError
    }
}
