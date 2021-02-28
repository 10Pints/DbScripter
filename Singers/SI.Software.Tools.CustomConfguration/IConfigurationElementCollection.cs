using System.Configuration;

namespace SI.Software.Tools.CustomConfiguration
{
   /// <inheritdoc cref="IIndexable" />
   /// <inheritdoc cref="IConfigurationElement" />
   /// <summary>
   ///    Interface specifying common Collection functionality
   /// </summary>
   public interface IConfigurationElementCollection : IIndexable, IConfigurationElement
   {
      /// <summary>
      /// public i/f for the protected method CreateNewElement()
      /// </summary>
      /// <returns></returns>
      ConfigurationElement CreateNewElement_();
      void Add(ConfigurationElement el);
      void Clear();
   }


   /// <summary>
   /// 
   /// </summary>
   /// <typeparam name="T"></typeparam>
   public interface IConfigurationElementCollection<T> : IConfigurationElementCollection
   {
   }
}