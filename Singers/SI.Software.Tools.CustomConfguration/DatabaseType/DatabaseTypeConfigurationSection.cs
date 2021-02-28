using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using SI.Software.Tools.CustomConfiguration.DatabaseType;

namespace SI.Software.Tools.CustomConfiguration.DatabaseType
{
    public class DatabaseTypeConfigurationSection : CustomConfigurationSection
    {
        #region Constants

        private const string NameAttributeName = "name";
        private const string StaticDataTablesAttributeName = "static_data_tables";

        #endregion Constants
        #region Properties
        #region Public Properties

        public static DatabaseTypeConfigurationSection Config => (ConfigurationManager.GetSection("databaseConfigurations") as DatabaseTypeConfigurationSection) ?? new DatabaseTypeConfigurationSection();

        /// <summary>
        /// Top level child node
        /// </summary>
        [ConfigurationProperty("databaseConfigurations", IsDefaultCollection = true, IsRequired = false)]
        [ConfigurationCollection(typeof(DatabaseTypeConfigurationCollection),
            AddItemName    = "databaseConfiguration",
            ClearItemsName = "clear",
            RemoveItemName = "remove")]
        public DatabaseTypeConfigurationCollection DatabaseTypeConfigurations => base["databaseConfigurations"] as DatabaseTypeConfigurationCollection;


/*        [ConfigurationProperty("name", IsRequired = false)]
        public string Name
        {
            get
            {
                var b = Properties.Contains("name");

                if (!b)
                    return null;

                var x = this["name"];
                x = base["name"];
                x= this["name"];
                var a = this["name"];
                var c = base["name"];
                return x as string;
            }
        }*/

        [TypeConverter(typeof(CommaSeparatedStringToEnumerableTypeConverter))]
        [ConfigurationProperty(StaticDataTablesAttributeName, IsRequired = false, DefaultValue = null)]
        public IEnumerable<string> StaticDataTables => (Properties.Contains(StaticDataTablesAttributeName) ? this[StaticDataTablesAttributeName] : null) as IEnumerable<string>;

        #endregion Public Properties
        #endregion Properties
        #region public static methods
        #endregion public static methods

        #region private instance methods

        private DatabaseTypeConfigurationSection()
        {
        }

        #endregion private instance methods
    }
}
