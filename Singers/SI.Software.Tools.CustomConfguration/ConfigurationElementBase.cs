using System.Configuration;
using System.Diagnostics;

namespace SI.Software.Tools.CustomConfiguration
{
   /// <inheritdoc cref="ConfigurationElement" />
   /// <inheritdoc cref="IConfigurationElement" />
   /// <summary>
   ///    This class does the work
   ///    Because we cant use multiple inheritance in C# but we need to
   ///    We can use an aggregate model as next best in accordance with the4 separation of concerns principle of Solid OO
   ///    Calls that would use normally use Multi[ple concrete inheritance can own an instance of this as a property and
   ///    delegate the calls to this as a property
   ///    That will alleviate code duplication, but is not as clean as multiple inheritance
   /// </summary>
   public class ConfigurationElementBase : ConfigurationElement, IConfigurationElementBase
   {
      internal ConfigurationElementBase()
      {
         // Need to call Init after this
         Initialised = false;
      }

      protected bool Initialised { get; private set; }

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
         Reset_(that);
         Initialised = true;
      }

      /// <inheritdoc />
      public void Reset_(ConfigurationElement that)
      {
         Reset(that);
      }


      #region IConfigurationElement
      [ConfigurationProperty("name", IsRequired = false)]
      public string Name
      {
         get
         {
            Debug.Assert(Initialised);
            return (string)base["name"];
         }
      }

      /// <summary>
      ///    public object GetAttribute(string name) => HasProperty(name) ? this[name] : null;
      /// </summary>
      /// <param name="name"></param>
      /// <returns></returns>
      public object GetAttribute(string name)
      {
         Debug.Assert(Initialised);
         return HasProperty(name) ? this[name] : null;
         // return null;//AggregatedConfigurationElementElement.GetAttribute(name);
      }

      /// <summary>
      ///    public bool HasProperty(string name) => Properties.Contains(name);
      /// </summary>
      /// <param name="name"></param>
      /// <returns></returns>
      public bool HasProperty(string name)
      {
         Debug.Assert(Initialised);
         return Properties.Contains(name);
      }

      // protected internal new object this[string propertyName]{ get { return (AggregatedConfigurationElementElement as ConfigurationElement)[propertyName]; } }

      #endregion IConfigurationElement
   }
}