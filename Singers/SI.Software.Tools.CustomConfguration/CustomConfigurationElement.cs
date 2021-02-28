using System.Configuration;
using System.Diagnostics;

namespace SI.Software.Tools.CustomConfiguration
{
   public class CustomConfigurationElement : ConfigurationElement, IConfigurationElement
   {
      protected bool Initialised {get; private set;}
      protected IConfigurationElementBase AggregatedElement { get; private set; }

      public CustomConfigurationElement()
      {
         Initialised = true;
      }

      /// <summary>
      /// Explicit initialisation
      /// </summary>
      public virtual void Init_()
      {
         Init_(this, new ConfigurationElementBase());
      }

      public void Init_(ConfigurationElement that, IConfigurationElementBase type)
      {
         Debug.Assert(!Initialised);
         AggregatedElement = type;
         AggregatedElement.Reset_(that);
         Initialised = true;
      }

      /// <inheritdoc />
      public void Reset_(ConfigurationElement that)
      {
         AggregatedElement.Reset_(that);
      }

      /// <summary>
      ///    Make the underlying call public
      /// </summary>
      /// <param name="propertyName"></param>
      /// <returns></returns>
      public new object this[string propertyName]
      {
         get
         {
            Debug.Assert(Initialised);
            return base[propertyName];
         }
         set
         {
            Debug.Assert(Initialised);
            base[propertyName] = value;
         }
      }

      /// <inheritdoc />
      /// <summary>
      ///    Returns true if the child element exists in the collection
      /// </summary>
      /// <param name="name"></param>
      /// <returns></returns>
      public bool HasProperty(string name)
      {
         Debug.Assert(Initialised);
         return Properties.Contains(name);
      }

      /// <inheritdoc />
      /// <summary>
      ///    Gets the attribute if it is directly attached to this node in the xml hierarchy
      /// </summary>
      /// <param name="name"></param>
      /// <returns></returns>
      public object GetAttribute(string name)
      {
            Debug.Assert(Initialised);
         return HasProperty(name) ? this[name] : null;
      }

      [ConfigurationProperty("name", IsRequired = false)]
      public string Name
      {
         get
         {
            Debug.Assert(Initialised);
            return (string) base["name"];
         }
      }
   }
}