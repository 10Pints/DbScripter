namespace SI.Software.Tools.CustomConfiguration
{
    /// <summary>
    /// This interface specifies the standard functionality for sections - which is essentially the same as any database element
    ///
    /// IConfigurationElement:
    ///   Name
    ///   GetAttribute
    ///   GetAttributeRecursive
    ///   HasProperty
    /// </summary>
    public interface ICustomConfigurationSection : IConfigurationElement
    {

    }
}