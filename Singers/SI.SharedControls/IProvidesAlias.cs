namespace SI.Software.SharedControls
{
    /// <summary>
    /// Represents any object that can provide an alias.
    /// </summary>
    public interface IProvidesAlias
    {
        /// <summary>
        /// Get the alias.
        /// </summary>
        string Alias { get; }
    }
}
