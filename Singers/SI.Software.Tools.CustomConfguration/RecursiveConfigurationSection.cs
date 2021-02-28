using System.Collections.Generic;

namespace SI.Software.Tools.CustomConfiguration
{
   public class RecursiveConfigurationSection : CustomConfigurationSection, IRecursiveConfigurationElement
   {
      protected RecursiveConfigurationSection(string childPropertyName)
      {
      }

      #region Properties

      internal IRecursiveConfigurationElementBase RecursiveAggregatedConfigurationElement => AggregatedElement as IRecursiveConfigurationElementBase;

      #endregion Properties

      #region Implementation of IRecursiveConfigurationElement

      /// <inheritdoc />
      public string ChildrenPropertyName => RecursiveAggregatedConfigurationElement.ChildrenPropertyName;

      public IRecursiveConfigurationElement Parent => RecursiveAggregatedConfigurationElement.Parent;

      /// <inheritdoc />
      public List<IRecursiveConfigurationElement> Children => RecursiveAggregatedConfigurationElement.Children;

      IRecursiveConfigurationElement IRecursiveConfigurationElement.Parent
      {
         get => Parent.Parent;
         set => Parent.Parent = value;
      }

      /// <inheritdoc />
      public object GetAttributeRecursive(string name)
      {
         return RecursiveAggregatedConfigurationElement.GetAttributeRecursive(name);
      }

      #endregion
   }
}