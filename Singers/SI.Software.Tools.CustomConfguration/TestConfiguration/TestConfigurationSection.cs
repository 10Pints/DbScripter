using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using C5;
using SI.Common.Helpers;

namespace SI.Software.Tools.CustomConfiguration.TestConfiguration
{
    /// <summary>
    /// This class handles the top level section node of the configuration hierarchy
    /// </summary>
    // ReSharper disable once CommentTypo
    // ReSharper disable once InheritdocConsiderUsage multiple items to choose from
    public class TestConfigurationSection : DatabaseConfigurationSection, IRecursiveDatabaseConfigurationElement
    {
        #region Properties

        /// <summary>
        /// Top level child node
        /// </summary>
        [ConfigurationProperty("testClasses", IsDefaultCollection = true, IsRequired = false)]
        [ConfigurationCollection(typeof(TestClassConfigurationCollection),
            AddItemName = "testClass",
            ClearItemsName = "clear",
            RemoveItemName = "remove")]
        public TestClassConfigurationCollection TestClasses
        {
            get
            {
                var testClasses = base["testClasses"] as TestClassConfigurationCollection;

                if (testClasses != null)
                {
                    if (testClasses.Parent == null)
                        testClasses.Parent = this;

                    // ReSharper disable once PossibleUnintendedReferenceComparison
                    Debug.Assert(this == testClasses.Parent);
                }

                return testClasses;
            }
        }

        #endregion Properties
        #region Public Methods
        #region Construction

        private TestConfigurationSection()
        : base("testClasses")
        {
            //ChildrenPropertyName = "testClasses";
        }

        #endregion Construction

        /// <summary>
        /// Sections don't have a parent they are top level nodes in the hierarchy
        /// </summary>
        /// <returns></returns>
        public string Serialize()
        {
            return SerializeSection(null, Name, ConfigurationSaveMode.Full);
        }

        #region Public Static Methods

        public static TestConfigurationSection GetConfig()
        {
            var config = (ConfigurationManager.GetSection("testConfigurations") as TestConfigurationSection) ?? new TestConfigurationSection();
            return config;
        }

        #endregion Public Static Methods
        #endregion Public Methodss
    }
}
