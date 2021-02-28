

namespace SI.Software.Tools.CustomConfiguration.TestConfiguration
{
    /// <summary>
    /// https://stackoverflow.com/questions/3935331/how-to-implement-a-configurationsection-with-a-configurationelementcollection
    /// This class encapsulates the TestClassConfigurationCollection Element Collection
    /// </summary>
    public class TestClassConfigurationCollection : RecursiveDatabaseConfigurationElementCollection<TestClassConfigurationElement>, IRecursiveDatabaseConfigurationElement, IConfigurationElementCollection
   {
        #region Construction

        public TestClassConfigurationCollection()
        : base("testClass", "testClasses")
        {
        }

        #endregion 
    }
}
