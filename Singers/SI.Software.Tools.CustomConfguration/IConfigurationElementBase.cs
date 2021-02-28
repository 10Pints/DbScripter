using System.Configuration;

namespace SI.Software.Tools.CustomConfiguration
{
   /// <summary>
   /// Interface specifying common se element functionality
   /// The Base element hierarchy does the end work </summary>
   public interface IConfigurationElementBase
   {
      string Name { get; }

      /// <summary>
      /// Gets the attribute directly associated with this node in the XML hierarchy
      /// </summary>
      /// <param name="name"></param>
      /// <returns></returns>
      object GetAttribute(string name);

      /// <summary>
      /// returns true if the child element exists in the collection
      /// </summary>
      /// <param name="name"></param>
      /// <returns></returns>
      bool HasProperty(string name);

      /// <summary>
      /// This is needed after creation and population of this object
      /// </summary>
      void Init_();

      /// <summary>
      /// Make the protected public
      /// </summary>
      /// <param name="that"></param>
      void Reset_(ConfigurationElement that);
   }
}