using System.Collections.Generic;
using System.Configuration;

namespace SI.Software.Tools.CustomConfiguration
{
    internal class RecursiveConfigurationElementBase : ConfigurationElementBase, IRecursiveConfigurationElementBase
   {
        #region Properties


        #endregion Properties
        #region Construction
        internal RecursiveConfigurationElementBase(string childrenPropertyName)
        {
           ChildrenPropertyName = childrenPropertyName;
           //RecursiveConfigurationElement = new RecursiveConfigurationElementBase();//that);that;
        }

        #endregion
        #region Implementation of IRecursiveConfigurationElement

        /// <inheritdoc />
        public string ChildrenPropertyName { get; }


        /// <inheritdoc />
        public IRecursiveConfigurationElement Parent
        {
            get;set;
        }

        /// <inheritdoc />
        public List<IRecursiveConfigurationElement> Children { get; set; }

        /// <inheritdoc />
        public object GetAttributeRecursive(string name)
        {
            //return RecursiveConfigurationElement.GetAttributeRecursive(name);
            return null;
        }

        #endregion
    }
}