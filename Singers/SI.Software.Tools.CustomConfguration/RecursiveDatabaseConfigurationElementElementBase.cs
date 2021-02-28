using System.Collections.Generic;

namespace SI.Software.Tools.CustomConfiguration
{
    /// <inheritdoc cref="DatabaseConfigurationElementElementBase"/>
    /// <inheritdoc cref="IRecursiveDatabaseConfigurationElement"/>
    /// <summary>
    /// </summary>
    internal class RecursiveDatabaseConfigurationElementElementBase : DatabaseConfigurationElementElementBase, IRecursiveDatabaseConfigurationElement
    {
        #region Properties
        private IRecursiveConfigurationElement RecursiveConfigurationElement { get; }

        #endregion
        #region Construction
        public RecursiveDatabaseConfigurationElementElementBase(IRecursiveDatabaseConfigurationElement databaseConfigurationElement)
        {
            RecursiveConfigurationElement = databaseConfigurationElement;
        }

        #endregion
        #region Implementation of IRecursiveConfigurationElement

        /// <inheritdoc />
        public string ChildrenPropertyName => RecursiveConfigurationElement.ChildrenPropertyName;

        /// <inheritdoc />
        public IRecursiveConfigurationElement Parent
        {
            get => RecursiveConfigurationElement.Parent;
            set => RecursiveConfigurationElement.Parent = Parent;
        }

        /// <inheritdoc />
        public List<IRecursiveConfigurationElement> Children => RecursiveConfigurationElement.Children;

        /// <inheritdoc />
        public object GetAttributeRecursive(string name) => RecursiveConfigurationElement.GetAttributeRecursive(name);
        #endregion
    }
}