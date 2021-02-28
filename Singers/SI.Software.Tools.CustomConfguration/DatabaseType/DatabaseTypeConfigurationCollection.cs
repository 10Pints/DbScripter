using System.Collections;
using System.Configuration;

namespace SI.Software.Tools.CustomConfiguration.DatabaseType
{
    /// <inheritdoc cref="IConfigurationElement"/>
    /// <inheritdoc cref="CustomConfigurationElementCollection"/>
    /// <summary>
    /// This class handles the create and find operations for
    /// the collection of databaseType nodes in app config: /configuration/databaseConfigurations
    /// </summary>
    public class DatabaseTypeConfigurationCollection : CustomConfigurationElementCollection, IConfigurationElement
    {
        public DatabaseTypeConfigurationCollection()
        {
        }

        protected DatabaseTypeConfigurationCollection(string elementName) : base(elementName)
        {
        }

        #region Properties

        [ConfigurationProperty("check_db_state", DefaultValue = null, IsRequired = false, IsKey = false)]
        public bool? CheckDbState => GetAttribute("check_db_state") as bool?;

        protected override string ElementName { get; } = "databaseConfiguration";

        #endregion Properties
        #region Overrides of IConfigurationElementCollection

        /// <inheritdoc />
        protected override ConfigurationElement CreateNewElement()
        {
            return new DatabaseTypeConfigurationElement();
        }

        /// <inheritdoc />
        protected override object GetElementKey(ConfigurationElement element)
        {
            return ((DatabaseTypeConfigurationElement)element)?.Name ?? "<null>";
        }

        #endregion
        /*#region Implementation of ICustomConfigurationElement

        /// <inheritdoc />
        [ConfigurationProperty("name", IsRequired = false)]
        public string Name => (string)base["name"];

        /// <inheritdoc />

        /// <inheritdoc />
        /// <summary>
        /// Gets the attribute if it is directly attached to this node in the xml hierarchy
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public object GetAttribute(string name) => HasProperty(name) ? this[name] : null;

        /// <inheritdoc />
        public bool HasProperty(string name) => Properties.Contains(name);

        #endregion*/
    }
}
