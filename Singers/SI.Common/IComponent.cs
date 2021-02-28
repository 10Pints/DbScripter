namespace SI.Common
{
    /// <summary>
    /// Represents any component.
    /// </summary>
    public interface IComponent
    {
        /// <summary>
        /// Try and get a property value.
        /// </summary>
        /// <param name="propertyName">The properties name.</param>
        /// <param name="propertyValue">The properties value.</param>
        /// <returns>True if the property could be retrieved, else false.</returns>
        bool TryGetProperty(string propertyName, out string propertyValue);
    }
}
