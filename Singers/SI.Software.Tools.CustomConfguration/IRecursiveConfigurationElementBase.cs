using System.Collections.Generic;

namespace SI.Software.Tools.CustomConfiguration
{
   public interface IRecursiveConfigurationElementBase : IConfigurationElementBase
   {
      /// <summary>
      /// Generic handling of get children
      /// </summary>
      string ChildrenPropertyName { get; }

      /// <summary>
      /// Parent node
      /// </summary>
      IRecursiveConfigurationElement Parent { get; set; }

      /// <summary>
      /// This can be a list of 0 or more elements
      /// or a list of 0 or more collections - usually 1 because elements and collections can have attributes
      /// </summary>
      List<IRecursiveConfigurationElement> Children { get; }

      /// <summary>
      /// If this node does not contain in the attribute then search the ancestors
      /// in order parent, grandparent... order till we find the first match (or null) if not found
      /// </summary>
      /// <param name="name"></param>
      /// <returns></returns>
      object GetAttributeRecursive(string name);
   }
}