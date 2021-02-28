
namespace SI.Software.TestHelpers.Tests
{
    /// <summary>
    /// This class exposes protected methods for testing
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class TestableConfigurationElementCollectionTemplate<T> : ConfigurationElementCollectionTemplate<T>
                where T : DatabaseConfigurationElement, new()
    {
        public TestableConfigurationElementCollectionTemplate(string elementName)
            : base(elementName)
        {
        }

        public string GetElementName()
        {
            return ElementName;
        }
    }
}
