using System;
using System.Configuration;
using System.Linq;
using SI.Common;

namespace SI.Software.Tools.CustomConfiguration
{
   public class RecursiveConfigurationElementCollection<T> : RecursiveConfigurationElementCollection, IConfigurationElementCollection<T> where T : RecursiveConfigurationElement, new()
   {
      #region Construction

      protected RecursiveConfigurationElementCollection(string elementName, string childrenPropertyName)
         : base(elementName, childrenPropertyName)
      {
      }

      #endregion Construction

      #region Implementation of IConfigurationElementCollection

      /// <inheritdoc />
      public ConfigurationElement CreateNewElement_()
      {
         return new T {Parent = this};
      }

      public new T this[int idx]
      {
         get
         {
            Utils.Assertion<ArgumentOutOfRangeException>(idx >= 0 && idx < Count);
            // Gets 1 of the set of child configuration elements - not properties
            return ConvertAndCheck(BaseGet(idx));
         }
      }

      /// <summary>
      ///    Helper to check convert and validate the item
      /// </summary>
      /// <param name="el"></param>
      /// <returns></returns>
      private T ConvertAndCheck(ConfigurationElement el)
      {
         Utils.Assertion(el != null, "null item");
         var icl = el as T;
         Utils.Assertion(icl != null, $"item is not a {typeof(T).Name}");
         return icl;
      }

      public new T this[string name]
      {
         get
         {
            var keys = BaseGetAllKeys().Select(i => i.ToString()).ToDictionary(x => x, x => x);
            return keys.ContainsKey(name) ? ConvertAndCheck(BaseGet(keys[name])) : null;
         }
      }

      #endregion Implementation of IConfigurationElementCollection

      #region Overrides of ConfigurationElementCollection

      /// <inheritdoc />
      protected override ConfigurationElement CreateNewElement()
      {
         return new T();
      }

      #endregion
   }
}