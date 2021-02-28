namespace SI.Software.Tools.CustomConfiguration
{
   // ReSharper disable once IdentifierTypo
   // ReSharper disable once InconsistentNaming
   public interface IIndexable
   {
      IConfigurationElement this[int index] { get; }
      IConfigurationElement this[string key] { get; }
   }
}