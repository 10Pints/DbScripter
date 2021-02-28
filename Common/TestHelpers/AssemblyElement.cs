
#nullable enable 

using System.Configuration;
using Microsoft.VisualStudio.TestTools.UnitTesting;
//using static SI.Logging.LogUtilities.LogUtils;

namespace RSS.Test
{
    public class AssemblyElement : DatabaseConfigurationElement
    {
        [ConfigurationProperty("testClasses", IsRequired = false)]
        public TestClassCollection? TestClasses
        {
            get
            {
                var x = this["testClasses"] as TestClassCollection;
                return x;
            }

            set
            {
                var x = value;// as TestClassCollection;
                Assert.IsNotNull(x?.Parent);
                //Assert.IsNotNull(x.Section);
                this["testClasses"] = value;
            }
        }
    }
}
