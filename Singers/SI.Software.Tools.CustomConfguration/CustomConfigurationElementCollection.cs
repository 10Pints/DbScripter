using System.Configuration;
using System.Diagnostics;

namespace SI.Software.Tools.CustomConfiguration
{
   /// <summary>
   /// </summary>
   public abstract class CustomConfigurationElementCollection : ConfigurationElementCollection, IConfigurationElement
   {
      protected ConfigurationElementBase AggregatedElement { get; set; }// = new CustomConfigurationElement();
      protected bool Initialised { get; private set; }

      #region construction

      /// <summary>
      /// 
      /// </summary>
      internal CustomConfigurationElementCollection()
      {
         //AggregatedConfigurationElementElement = new ConfigurationElementBase(this);
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="elementName"></param>
      protected CustomConfigurationElementCollection(string elementName)
      {
         //AggregatedConfigurationElementElement = new ConfigurationElementBase(this);
         //            ElementName = elementName;
         ElementName = elementName;
      }

      #endregion construction

      protected ConfigurationElementBase AggregatedConfigurationElementElement { get; set; }
      protected override string ElementName { get; }

      /// <summary>
      /// Call this once that is populated
      /// </summary>
      public void Init_()
      {
         Init_(this);
      }

      /// <inheritdoc />
      public void Init_(ConfigurationElement that)
      {
         Debug.Assert(!Initialised);
         AggregatedElement = new ConfigurationElementBase();
         AggregatedElement.Reset_(that);
         Initialised = true;
      }

      /// <inheritdoc />
      public void Reset_(ConfigurationElement that)
      {
         AggregatedElement.Reset_(that);
      }

      #region Implementation of IConfigurationElement

      [ConfigurationProperty("name", IsRequired = false, DefaultValue = null)]
      public string Name
      {
         get
         {
            return (string)GetAttribute("name");
         }
      }

      public object GetAttribute(string name) => HasProperty(name) ? this[name] : null;

      public bool HasProperty(string name)
      {
         return false; // AggregatedConfigurationElementElement.HasProperty(name);
      }

      #endregion IConfigurationElement
   }
}