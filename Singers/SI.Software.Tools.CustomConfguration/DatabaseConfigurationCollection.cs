using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Linq;
using C5;
//using SI.Common.Helpers;
using SI.Software.Tools.CustomConfiguration.TestConfiguration;

namespace SI.Software.Tools.CustomConfiguration
{
    public class RecursiveDatabaseConfigurationElementCollection<T> : RecursiveConfigurationElementCollection<T>, IDatabaseConfigurationElement where T : RecursiveDatabaseConfigurationElement, new()
    {
        protected RecursiveDatabaseConfigurationElementCollection(string elementName, string childrenPropertyName)
        : base(elementName, childrenPropertyName)
        {
        }
        
        #region Implementation of IDatabaseConfigurationElement

        /// <inheritdoc />
        [ConfigurationProperty("server", DefaultValue = null, IsRequired = false, IsKey = false)]
        public string Server => GetAttributeRecursive("server") as string;

        /// <inheritdoc />
        [TypeConverter(typeof(CommaSeparatedStringToEnumerableTypeConverter))]
        [ConfigurationProperty("script_files", IsRequired = false, DefaultValue = null)]
        public IEnumerable<string> ScriptFiles => (GetAttributeRecursive("script_files") as string)?.Split(',').Select((s, i) => $"{"C:\\tmp"/*CommonHelper.ScriptDir*/}\\{s}");

        /// <inheritdoc />
        [ConfigurationProperty("instance", DefaultValue = null, IsRequired = false, IsKey = false)]
        public string Instance => GetAttributeRecursive("instance") as string;

        [ConfigurationProperty("database", DefaultValue = null, IsRequired = false, IsKey = false)]
        public string Database => GetAttributeRecursive("database") as string;

        /// <inheritdoc />
        [ConfigurationProperty("database_type", DefaultValue = null, IsRequired = false, IsKey = false)]
        public string DatabaseType => (GetAttributeRecursive("database_type") as string);

        [ConfigurationProperty("check_db_state", DefaultValue = null, IsRequired = false, IsKey = false)]
        public bool? CheckDbState => GetAttributeRecursive("check_db_state") as bool?;

        [ConfigurationProperty("dont_create", DefaultValue = null, IsRequired = false, IsKey = false)]
        public bool? DontCreate => GetAttributeRecursive("dont_create") as bool?;

        [ConfigurationProperty("drop_first", DefaultValue = null, IsRequired = false, IsKey = false)]
        public bool? DropFirst => GetAttributeRecursive("drop_first") as bool?;

        [ConfigurationProperty("drop_after", DefaultValue = null, IsRequired = false, IsKey = false)]
        public bool? DropAfter => GetAttributeRecursive("drop_after") as bool?;

        [ConfigurationProperty("populate_dynamic_data", DefaultValue = null, IsRequired = false, IsKey = false)]
        public bool? PopulateStaticData => GetAttributeRecursive("populate_static_data") as bool?;

        [ConfigurationProperty("populate_dynamic_data", DefaultValue = null, IsRequired = false, IsKey = false)]
        public bool? PopulateDynamicData => GetAttributeRecursive("populate_dynamic_data") as bool?;

        /// <inheritdoc />
        public virtual void GetDatabases(TreeSet<string> set)
        {
            if ((!string.IsNullOrEmpty(Database)) && (!set.Contains(Database)))
                set.Add(Database);

            foreach (T t in this)
                t.GetDatabases(set);
        }

        /// <inheritdoc />
        [TypeConverter(typeof(CommaSeparatedStringToEnumerableTypeConverter))]
        [ConfigurationProperty("static_data_tables", IsRequired = false, DefaultValue = null)]
        public IEnumerable<string> StaticDataTables
        {
            get
            {
                var obj = GetAttributeRecursive("static_data_tables");
                var seq = obj as IEnumerable<string>;
                // Prepend script directory
                var ret = seq?.Select((s, i) => $"{"C:\\tmp"/*CommonHelper.ScriptDir*/}\\{s}");
                return ret;
            }
        }

        #endregion
    }
}
