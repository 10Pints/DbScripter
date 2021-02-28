using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using SI.Common;

namespace SI.Software.Tools.CustomConfiguration
{
    /// <inheritdoc cref="CustomConfigurationElementCollection"/>
    /// <summary>
    /// Implementation of IRecursiveConfigurationElement
    /// </summary>
    public abstract class RecursiveConfigurationElementCollection : CustomConfigurationElementCollection, IRecursiveConfigurationElement
    {
        #region Properties
        //private RecursiveConfigurationElementBase RecursiveAggregatedConfigurationElement { get; }
        
        #endregion Properties
        #region Construction
        protected RecursiveConfigurationElementCollection(string elementName, string childrenPropertyName)
        : base (elementName)
        {
           ChildrenPropertyName = childrenPropertyName;
           //RecursiveAggregatedConfigurationElement = new RecursiveConfigurationElementBase(childrenPropertyName);
           //RecursiveAggregatedConfigurationElement.Init(this);
        }

        #endregion Construction
        #region Implementation of IRecursiveConfigurationElement

        public string ChildrenPropertyName { get; }

        public IRecursiveConfigurationElement Parent{get;set;}

        /*       /// <inheritdoc />
               public IRecursiveConfigurationElement Parent
               {
                   get => parent;

                   set
                   {
                       Utils.Assertion<ArgumentNullException>(value != null, "Parent cannot be null");
                       parent = value;
                   }
               }*/

        /// <inheritdoc />
        /// <summary>
        /// This will be the collection of the top level child elements that are children
        /// </summary>
        public virtual List<IRecursiveConfigurationElement> Children
        {
            get
            {
                var children = new List<IRecursiveConfigurationElement>();

                for (var i = 0; i < Count; i++)
                {
                    var x = this[i];
                    var y = x ;

                    if (y != null)
                        children.Add(y as IRecursiveConfigurationElement);
                }

                return children;
            }
        }

        /// <inheritdoc />
        /// <summary>
        /// IF not NULL or is a string and not "" then return immediate attribute
        /// Else return parent value
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public virtual object GetAttributeRecursive(string name)
        {
            var attr = GetAttribute(name);

            if (attr != null)
                return attr;

            // If here then need to recurse up the tree
            var ret =  Parent?.GetAttributeRecursive(name);
            return ret;
        }

        #endregion ICustomConfigurationElement
        #region Implementation of IConfigurationElementCollection

        /// <inheritdoc />
        protected override object GetElementKey(ConfigurationElement element)
        {
            return ((IConfigurationElement) element)?.Name ?? "<null>";
        }

        public void Add(ConfigurationElement el)
        {
            BaseAdd(el);
        }

        /// <summary>
        /// Removes all configuration element objects from the collection.
        /// </summary>
        public void Clear()
        {
            BaseClear();
        }

        #endregion

        public IConfigurationElement this[int idx]
        {
            get
            {
                Utils.Assertion<ArgumentOutOfRangeException>((idx >= 0) && (idx < Count));
                // Gets 1 of the set of child configuration elements - not properties
                return ConvertAndCheck(BaseGet(idx));
            }
        }

        /// <summary>
        /// Helper to check convert and validate the item
        /// </summary>
        /// <param name="el"></param>
        /// <returns></returns>
        private static IConfigurationElement ConvertAndCheck(ConfigurationElement el)
        {
            Utils.Assertion(el != null, "null property");
            var icl = el as IConfigurationElement;
            Utils.Assertion(icl != null, "item is not a IConfigurationElement");
            return icl;
        }

        public new IConfigurationElement this[string name]
        {
            get
            {
                var keys = BaseGetAllKeys().Select(i => i.ToString()).ToDictionary(x => x, x => x);
                return keys.ContainsKey(name) ? ConvertAndCheck(BaseGet(keys[name])) : null;
            }
        }

        /*// <inheritdoc />
        /// <summary>
        /// returns true if the child element exists in the collection
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public bool HasProperty(string name)
        {
            return Properties.Contains(name);
        }*/
    }

}
