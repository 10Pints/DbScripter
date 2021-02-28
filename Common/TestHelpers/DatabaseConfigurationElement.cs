
#nullable enable 

using System.Configuration;
using C5;
using Microsoft.VisualStudio.TestTools.UnitTesting;
#pragma warning disable 

namespace RSS.Test
{
    public abstract class DatabaseConfigurationElement : CustomSettingElement, IDatabaseElement
    {
        [ConfigurationProperty("database", IsRequired = false, DefaultValue = null)]
        public string? Database => GetAttributeRecursiveR<string>("database");

        [ConfigurationProperty("check_db_state", IsRequired = false, DefaultValue = null)]
        public bool? CheckDbState
        {
            get
            {
                var x = GetAttributeRecursiveV<bool>("check_db_state");
                return (bool?)x;
            }

            set => base["check_db_state"] = value;
        }

        /// <summary>
        /// Recursive
        /// </summary>
        /// <param name="set"></param>
        public virtual void GetDatabases(TreeSet<string> set)
        {
            var database = Database;

            if (!string.IsNullOrEmpty(database))
                set.Add(database);

            foreach (var el in GetChildren())
            {
                var child = el as IDatabaseElement;
                Assert.IsNotNull(child);
                child.GetDatabases(set);
            }
        }

      }
}