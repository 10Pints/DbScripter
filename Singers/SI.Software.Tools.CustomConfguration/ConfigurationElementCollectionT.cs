using System.Configuration;

namespace SI.Software.Tools.CustomConfiguration
{
   public abstract class ConfigurationElementCollection<T> : CustomConfigurationElementCollection, IConfigurationElementCollection, IIndexable<T> where T: CustomConfigurationElement, new()
   {

      /// <inheritdoc />
      public IConfigurationElement this[int index] => throw new System.NotImplementedException();

      /// <inheritdoc />
      T IIndexable<T>.this[int index] => throw new System.NotImplementedException();

      /// <inheritdoc />
      public new IConfigurationElement this[string key] => throw new System.NotImplementedException();

      T IIndexable<T>.this[string key] => throw new System.NotImplementedException();

      #region Implementation of IConfigurationElementCollection

      /// <inheritdoc />
      public ConfigurationElement CreateNewElement_()
      {
         var e =  new T();
         //e.Init()
         return e;
      }

      protected override ConfigurationElement CreateNewElement() => CreateNewElement_();

      /// <inheritdoc />
      public void Add(ConfigurationElement el)
      {
         throw new System.NotImplementedException();
      }

      /// <inheritdoc />
      public void Clear()
      {
         throw new System.NotImplementedException();
      }

      #endregion
   }
}