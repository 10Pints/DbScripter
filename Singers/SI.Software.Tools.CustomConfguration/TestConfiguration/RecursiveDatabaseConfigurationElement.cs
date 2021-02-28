﻿using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Linq;
using C5;
using SI.Common.Helpers;

namespace SI.Software.Tools.CustomConfiguration.TestConfiguration
{
    public abstract class RecursiveDatabaseConfigurationElement : RecursiveConfigurationElement, IRecursiveDatabaseConfigurationElement
    {
        protected RecursiveDatabaseConfigurationElement(string childrenPropertyName)
            : base(childrenPropertyName)
        { }

        /// <inheritdoc />
        [ConfigurationProperty("server", IsRequired = false, DefaultValue = null)]
        public string Server => GetAttributeRecursive("server") as string;

        /// <inheritdoc />
        [ConfigurationProperty("instance", IsRequired = false, DefaultValue = null)]
        public virtual string Instance => GetAttributeRecursive("instance") as string;

        /// <inheritdoc />
        [ConfigurationProperty("database", IsRequired = false, DefaultValue = null)]
        public virtual string Database => GetAttributeRecursive("database") as string;

        /// <inheritdoc />
        [ConfigurationProperty("database_type", DefaultValue = null, IsRequired = false, IsKey = false)]
        public virtual string DatabaseType => (GetAttributeRecursive("database_type") as string);

        /// <inheritdoc />
        [ConfigurationProperty("check_db_state", IsRequired = false, DefaultValue = null)]
        public bool? CheckDbState => GetAttributeRecursive("check_db_state") as bool?;

        /// <inheritdoc />
        [ConfigurationProperty("dont_create", IsRequired = false, DefaultValue = null)]
        // ReSharper disable once IdentifierTypo
        public virtual bool? DontCreate => GetAttributeRecursive("dont_create") as bool?;

        /// <inheritdoc />
        [ConfigurationProperty("drop_first", IsRequired = false, DefaultValue = null)]
        public virtual bool? DropFirst => GetAttributeRecursive("drop_first") as bool?;

        /// <inheritdoc />
        [ConfigurationProperty("drop_after", IsRequired = false, DefaultValue = null)]
        public virtual bool? DropAfter => GetAttributeRecursive("drop_after") as bool?;

        /// <inheritdoc />
        [ConfigurationProperty("populate_static_data", IsRequired = false, DefaultValue = null)]
        public virtual bool? PopulateStaticData => GetAttributeRecursive("populate_static_data") as bool?;

        /// <inheritdoc />
        [ConfigurationProperty("populate_dynamic_data", IsRequired = false, DefaultValue = null)]
        public bool? PopulateDynamicData => GetAttributeRecursive("populate_dynamic_data") as bool?;

        /// <inheritdoc />
        [TypeConverter(typeof(CommaSeparatedStringToEnumerableTypeConverter))]
        [ConfigurationProperty("script_files", IsRequired = false, DefaultValue = null)]
        public virtual IEnumerable<string> ScriptFiles
        {
            get
            {
                var obj = GetAttributeRecursive("script_files");
                var seq = obj as IEnumerable<string>;
                // Prepend script directory
                var ret = seq?.Select((s, i) => $"{CommonHelper.ScriptDir}\\{s}");
                return ret;
            }
        }

        /// <inheritdoc />
        [TypeConverter(typeof(CommaSeparatedStringToEnumerableTypeConverter))]
        [ConfigurationProperty("static_data_tables", IsRequired = false, DefaultValue = null)]
        public virtual IEnumerable<string> StaticDataTables => GetAttribute("static_data_tables") as IEnumerable<string>;

        /// <inheritdoc />
        public virtual void GetDatabases(TreeSet<string> set)
        {
            if ((!string.IsNullOrEmpty(Database)) && (!set.Contains(Database)))
                set.Add(Database);

            foreach (var p in Properties)
            {
                if (p is ConfigurationProperty x)
                {
                    var v = base[x.Name];

                    if (v is IDatabaseConfigurationElement configuration)
                        configuration.GetDatabases(set);
                }
            }
        }
    }
}