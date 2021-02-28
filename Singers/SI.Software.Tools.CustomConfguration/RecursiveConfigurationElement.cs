using System.Collections.Generic;
using System.Diagnostics;

namespace SI.Software.Tools.CustomConfiguration
{
    public class RecursiveConfigurationElement : CustomConfigurationElement, IRecursiveConfigurationElement
    {
        private IRecursiveConfigurationElement parent;

        public virtual IRecursiveConfigurationElement Parent
        {
            get => parent;
            set
            {
                Debug.Assert(value != null);
                parent = value;
            }
        }

        public string ChildrenPropertyName
        {
            get;
        }

        /// <inheritdoc />
        public virtual List<IRecursiveConfigurationElement> Children
        {
            get
            {
                // An elements children is always 1 collection - a property named as ChildrenPropertyName
                var children = new List<IRecursiveConfigurationElement>();

                if (!Properties.Contains(ChildrenPropertyName))
                    return children;

                // Utils.Assertion: if here then we have the default property which is supposed to be the children collection 
                // return the collection - in the list not its children as it might have attributes
                var childCollection = this[ChildrenPropertyName] as IRecursiveConfigurationElement;
                Debug.Assert(childCollection != null);
                children.Add(childCollection);
                return children;
            }
        }

        public RecursiveConfigurationElement( string childrenPropertyName)
        {
            ChildrenPropertyName = childrenPropertyName;
        }

        /// <inheritdoc />
        public object GetAttributeRecursive(string name)
        {
            // Get the direct attribute for this node
            var v = GetAttribute(name);
            var s = v as string;

            if (((v != null) && (s==null)))
                return v;

            if((s != null) && (!string.IsNullOrEmpty(s)))
                return v;

            // If here then go up the hierarchy
            var ret = Parent?.GetAttributeRecursive(name);
            return ret;
        }
    }
}
