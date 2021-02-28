using System;
using System.Configuration;
using System.Linq;
using System.Reflection;

namespace SI.Software.TestHelpers.Application
{
    /// <summary>
    /// Represents a base class that can be used to change the application configuration at run time, typically for testing functionality that uses the application configuration.
    /// PRE: path should be absolute.
    /// </summary>
    public abstract class TestAppConfig : IDisposable
    {
        /// <summary>
        /// This is the main entry point.
        /// Use this method in a using block so that its Dispose is called at the end of the block to replace the old configuration.
        /// It performs the application configuration cache refresh that is necessary and not normally done by existing framework code.
        /// </summary>
        /// <param name="absoluteConfigPath">Path should be absolute.</param>
        /// <returns>A ChangeAppConfig configuration object.</returns>
        public static TestAppConfig Change(string absoluteConfigPath)
        {
            // PRE: absoluteConfigPath should be absolute
            return new ChangeAppConfig(absoluteConfigPath);
        }

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public abstract void Dispose();

        /// <summary>
        /// Worker class to change the application configuration at runtime. This is very useful for testing functionality that uses application configuration.
        /// </summary>
        private class ChangeAppConfig : TestAppConfig
        {
            // caches the current configuration to be replaced by Dispose
            private readonly string oldConfig = AppDomain.CurrentDomain.GetData("APP_CONFIG_FILE").ToString();

            private bool disposedValue;

            /// <summary>
            /// Initializes a new instance of the ChangeAppConfig class. This constructor saves the current configuration and then replaces it with the new one specified by absoluteConfigPath.
            /// </summary>
            /// <param name="absoluteConfigPath">Should be the absolute path to the configuration file.</param>
            public ChangeAppConfig(string absoluteConfigPath)
            {
                AppDomain.CurrentDomain.SetData("APP_CONFIG_FILE", absoluteConfigPath);
                ResetConfigMechanism();
            }

            /// <summary>
            /// This is used to restore the original configuration after the (test) run.
            /// </summary>
            public override void Dispose()
            {
                if (!disposedValue)
                {
                    AppDomain.CurrentDomain.SetData("APP_CONFIG_FILE", oldConfig);
                    ResetConfigMechanism();
                    disposedValue = true;
                }

                GC.SuppressFinalize(this);
            }

            /// <summary>
            /// Replaces the original application configuration Called from Dispose().
            /// </summary>
            private static void ResetConfigMechanism()
            {
                var configurationManagerType = typeof(ConfigurationManager);
                var fieldInfo = configurationManagerType.GetField("s_initState", BindingFlags.NonPublic | BindingFlags.Static);
                fieldInfo?.SetValue(null, 0);
                fieldInfo = configurationManagerType.GetField("s_configSystem", BindingFlags.NonPublic | BindingFlags.Static);
                fieldInfo?.SetValue(null, null);
                var types = configurationManagerType.Assembly.GetTypes();
                var types2= types.Where(x => x.FullName == "System.Configuration.ClientConfigPaths");
                var type = types2.First();
                fieldInfo = type.GetField("s_current", BindingFlags.NonPublic | BindingFlags.Static);
                fieldInfo?.SetValue(null, null);
            }
        }
    }
}
