using SI.Software.Tools.CustomConfiguration.TestConfiguration;

namespace SI.Software.Tools.CustomConfiguration
{
    /// <inheritdoc cref="IRecursiveConfigurationElement" />
    /// <inheritdoc cref="IDatabaseConfigurationElement" />
    /// <summary>
    /// Interface for recursive elements with database properties
    /// </summary>
    public interface IRecursiveDatabaseConfigurationElement : IRecursiveConfigurationElement, IDatabaseConfigurationElement
    {
    }
}