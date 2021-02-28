using System.Configuration;

namespace SI.Software.Tools.CustomConfiguration.TestConfiguration
{
    public class ResultElement : System.Configuration.ConfigurationElement
    {
        // Make sure to set IsKey=true for property exposed as the GetElementKey above
        [ConfigurationProperty("name", IsKey = true, IsRequired = false)]
        public string Name
        {
            get => (string)base["name"];
            set => base["name"] = value;
        }

        [ConfigurationProperty("result", IsRequired = true)]
        public string Result
        {
            get => (string)base["result"];
            set => base["result"] = value;
        }
    }
}