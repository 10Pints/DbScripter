using System.Configuration;
using System.Diagnostics;

namespace SI.Software.Tools.CustomConfiguration.TestConfiguration
{
    public class TestClassConfigurationElement : RecursiveDatabaseConfigurationElement
    {
        public TestClassConfigurationElement()
          : base("methods")
        {
        }

        [ConfigurationProperty("methods", IsDefaultCollection = true, IsRequired = false)]
        [ConfigurationCollection(typeof(MethodConfigurationElementCollection),
            AddItemName    = "method",
            ClearItemsName = "clear",
            RemoveItemName = "remove")]
        public MethodConfigurationElementCollection Methods
        {
            get
            {
                var methods = base["methods"] as MethodConfigurationElementCollection;

                if (methods != null)
                {
                    if (methods.Parent == null)
                        methods.Parent = this;

                    // ReSharper disable once PossibleUnintendedReferenceComparison
                    Debug.Assert(this == methods.Parent);
                }

                return methods;
            }
        }
    }
}
