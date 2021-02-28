using System.Configuration;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace SI.Software.TestHelpers.Application
{
    /// <summary>
    /// Provides App config modification support for testing purposes.
    /// </summary>
    public static class AppConfigTestHelper
    {
        /// <summary>
        /// Changes the configuration dynamically at runtime and checks the "Config Name" value in the app settings dictionary.
        /// </summary>
        /// <param name="absoluteConfigPath">The absolute path to the configuration.</param>
        /// <param name="configName">The name of the configuration.</param>
        /// <returns>The config.</returns>
        public static TestAppConfig ChangeAppConfig(string absoluteConfigPath, string configName = null)
        {
            var testAppConfig = TestAppConfig.Change(absoluteConfigPath);
            var currentAppConfigName = GetConfigName();

            if (configName != null)
                Assert.IsTrue(string.Equals(currentAppConfigName, configName), $"ChangeAppConfig name test failed\nexpected '{configName}'\nactual: '{currentAppConfigName}' ");

            return testAppConfig;
        }

        /// <summary>
        /// Get a config name.
        /// </summary>
        /// <returns>The name.</returns>
        public static string GetConfigName()
        {
            return ConfigurationManager.AppSettings["Name"];
        }
    }
}
