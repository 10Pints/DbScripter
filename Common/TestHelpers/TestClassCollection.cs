using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace RSS.Test
{
    /// <summary>
    /// This class encapsulates the TestClassCollection Element Collection
    /// </summary>
    public class TestClassCollection : ConfigurationElementCollectionTemplate<TestClassElement>
    {
        public TestClassCollection() : base("testClass") {}
    }
}
