
using System.Configuration;

namespace SI.Software.Tools.CustomConfiguration.TestConfiguration
{
    public class MethodConfigurationElement : RecursiveDatabaseConfigurationElement
    {
        public MethodConfigurationElement()
            : base(null)
        {
        }

        // https://stackoverflow.com/questions/2718095/custom-app-config-section-with-a-simple-list-of-add-elements
        [ConfigurationProperty("expected_results", IsRequired = false, IsDefaultCollection = true)]
        public ResultCollection expected_results
        {
            get => (ResultCollection)this["expected_results"];
            set => this["expected_results"] = value;
        }
    }


}