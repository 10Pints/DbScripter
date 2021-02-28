namespace SI.Software.SharedControls
{
    /// <summary>
    /// Represents any object that can provide a description of its identity.
    /// </summary>
    public interface IIdentityDescription
    {
        /// <summary>
        /// Get the name of this object.
        /// </summary>
        string Name { get; }
        /// <summary>
        /// Get the description of this object.
        /// </summary>
        string Description { get; }
    }
}
