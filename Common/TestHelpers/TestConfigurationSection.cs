
#nullable enable

using System.Configuration;
using C5;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace RSS.Test
{
    public class TestConfigurationSection : CustomSettingsSection, IDatabaseElement
    {
        #region public properties
        #region IDatabaseElement interface implementation

        [ConfigurationProperty("database", IsRequired = false, DefaultValue = null)]
        public string Database => (string)base["database"];

        [ConfigurationProperty("check_db_state", IsRequired = false, DefaultValue = null)]
        public bool? CheckDbState
        {
            get
            {
                var x = base.Properties;

                if (x.Contains("check_db_state"))
                    return (bool?)base["check_db_state"];
                else
                    return null;
            }

            set => base["check_db_state"] = value;
        }

        #endregion IDatabaseElement interface implementation
        #endregion public properties

        #region public methods
        #region public static methods

        public static TestConfigurationSection GetConfig()
        {
            return (ConfigurationManager.GetSection("testConfiguration") as TestConfigurationSection)?? new TestConfigurationSection();
        }

        #endregion public static methods
        #region public instance methods

        [ConfigurationProperty("testClasses", IsDefaultCollection = true, IsRequired = false)]
        [ConfigurationCollection(typeof(TestClassCollection),
            AddItemName    = "testClass",
            ClearItemsName = "clear",
            RemoveItemName = "remove")]
        public TestClassCollection? TestClasses
        {
            get
            {
                var testClasses = base["testClasses"] as TestClassCollection; 

                if (testClasses != null)
                {
                    if (testClasses.Parent == null)
                        testClasses.Parent = this;

                    Assert.AreEqual(this, testClasses.Parent);
                }

                return testClasses;
            }
        }
        
        public void GetDatabases( TreeSet<string> set)
        {
            if (!string.IsNullOrEmpty(Database))
                set.Add(Database);

            if(TestClasses != null)
               foreach (TestClassElement testClass in TestClasses)
                   testClass.GetDatabases(set);
        }

        #endregion public instance methods
        #endregion public methods
    }
}
