using SI.Software.Tools.CustomConfiguration.TestConfiguration;

namespace SI.Software.Tools.CustomConfiguration
{
    /// <summary>
    /// This interface specifies all database element collection functionality
    /// Which is the sum of Collection and Database elements
    /// </summary>
    public interface IDatabaseConfigurationElementCollection : IConfigurationElementCollection, IDatabaseConfigurationElement
    {
    }
}