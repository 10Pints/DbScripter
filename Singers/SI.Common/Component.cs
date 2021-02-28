namespace SI.Common
{
    /// <summary>
    /// Represents a component.
    /// </summary>
    public abstract class Component : IComponent
    {
        #region Implementation of IComponent

        /// <summary>
        /// Try and get a property value.
        /// </summary>
        /// <param name="propertyName">The properties name.</param>
        /// <param name="propertyValue">The properties value.</param>
        /// <returns>True if the property could be retrieved, else false.</returns>
        public virtual bool TryGetProperty(string propertyName, out string propertyValue)
        {
            propertyValue = string.Empty;
            return false;
        }

        #endregion
    }
}
