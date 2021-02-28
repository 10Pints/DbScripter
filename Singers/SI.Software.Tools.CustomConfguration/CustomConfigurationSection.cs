using System.Configuration;
using System.Diagnostics;

namespace SI.Software.Tools.CustomConfiguration
{
   public class CustomConfigurationSection : ConfigurationSection, ICustomConfigurationSection
   {
      #region Properties

      private bool Initialised { get; set; }
      public ConfigurationElementBase AggregatedElement { get; protected set; }

      #endregion Properties

      #region Construction

      internal CustomConfigurationSection()
      {
      }

      public virtual void Init_()
      {
         Init_(this, new ConfigurationElementBase());
      }

/*      /// <inheritdoc />
      public virtual void Init_(ConfigurationElement that)
      {
         Debug.Assert(!Initialised);
         AggregatedElement = new ConfigurationElementBase();
         Reset_(that);
         Initialised = true;
      }*/

      /// <inheritdoc />
      public void Reset_(ConfigurationElement that)
      {
         Debug.Assert(!Initialised);
         AggregatedElement.Reset_(that);
      }

      #endregion Construction

      #region Implementation of IConfigurationElement
      [ConfigurationProperty("name", IsRequired = false)]
      public string Name => AggregatedElement.Name;

      public object GetAttribute(string name)
      {
         return AggregatedElement.GetAttribute(name);
      }

      public bool HasProperty(string name)
      {
         return AggregatedElement.HasProperty(name);
      }

      #endregion IConfigurationElement
   }
}

/*
        protected override string ElementName { get; }

        #region Implementation of ICustomConfigurationElement


        /// <inheritdoc />
        /// <summary>
        /// Gets the attribute if it is directly attached to this node in the xml hierarchy
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public object GetAttribute(string name)
        {
            if (Properties.Contains(name))
            {
                var attr = base[name];

                if (attr != null)
                {
                    var s = attr as string;

                    if (!string.IsNullOrEmpty(s))
                        return attr;
                }
            }

            // treat "" as null
            return null;
        }
*/