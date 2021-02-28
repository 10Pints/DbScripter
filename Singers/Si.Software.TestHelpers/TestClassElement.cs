using System.Configuration;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace SI.Software.TestHelpers
{
    public class TestClassElement : DatabaseConfigurationElement
    {
        [ConfigurationProperty("methods", IsRequired = false)]
        public MethodCollection Methods
        {
            get
            {
                // PRE
                Assert.IsNotNull(Parent);

                // A collection is stored in base[], for recursion we just need to know the 'property' name
                var methods = base["methods"] as MethodCollection;

                if (methods != null)
                {
                    if(methods.Parent == null)
                        methods.Parent = this; // don't want this
                }

                return methods;
            }
        }
    }
}
