
using System.Configuration;

namespace SI.Software.Tools.CustomConfiguration.DatabaseType
{
    /// <summary>
    /// This class handles the databaseConfigurations/databaseType Configuration element in app config
    /// </summary>
    public class DatabaseTypeConfigurationElement : System.Configuration.ConfigurationElement
    {
        /// <summary>
        /// 
        /// </summary>
        [ConfigurationProperty("name", IsRequired = true, DefaultValue = null)]
        public string Name => (Properties.Contains("name") ? this["name"] : null) as string;

        /// <summary>
        /// 
        /// </summary>
        [ConfigurationProperty("static_data_tables", IsRequired = true, DefaultValue = null)]
        public string StaticDataTables => (Properties.Contains("name") ? this["name"] : null) as string;
    }
}
