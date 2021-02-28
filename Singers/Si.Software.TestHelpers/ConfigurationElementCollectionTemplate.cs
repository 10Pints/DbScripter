using System;
using System.Configuration;
using C5;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace SI.Software.TestHelpers
{
    public class ConfigurationElementCollectionTemplate<T> : DatabaseElementCollection, IDatabaseElement, IElementCollection where T : DatabaseConfigurationElement, new()
    {
        protected override string ElementName { get; }

        public override ConfigurationElementCollectionType CollectionType => ConfigurationElementCollectionType.BasicMapAlternate;

        protected ConfigurationElementCollectionTemplate(string elementName)
        {
            ElementName = elementName;
        }

        public T this[int idx]
        {
            get
            {
                var el = BaseGet(idx) as T;

                if ((el != null) && (el.Parent == null))
                    el.Parent = this;

                 return el;
            }
            set
            {
                if (base.BaseGet(idx) != null)
                {
                    base.BaseRemoveAt(idx);
                }
                this.BaseAdd(idx, value);
            }
        }

        public new T this[string key]
        {
            get
            {
                T el = BaseGet(key) as T;

                if ((el!= null) && (el.Parent == null))
                    el.Parent = this;

                return el;
            }
            set
            {
                if (BaseGet(key) != null)
                    BaseRemoveAt(BaseIndexOf(BaseGet(key)));

                BaseAdd(value);
            }
        }

        #region IElement  

        public override IElement[] GetChildren()
        {
            return BaseGetAllKeys() as IElement[];
        }

        public override IElementCollection GetChildCollection()
        {
            return this;
            //throw new NotImplementedException();
        }

        #endregion IElement  


        protected override System.Configuration.ConfigurationElement CreateNewElement()
        {
            return new T {Parent = this};
        }

        protected override object GetElementKey(System.Configuration.ConfigurationElement element)
        {
            return ((T)element).Name;
        }

        protected override bool IsElementName(string elementName)
        {
            return elementName.Equals(ElementName, StringComparison.InvariantCultureIgnoreCase);
        }

        public override bool IsReadOnly()
        {
            return false;
        }


        public override void GetDatabases(TreeSet<string> set)
        {
            var database = Database;

            if (!string.IsNullOrEmpty(database))
                set.Add(database);

            for (int i = 0; i < Count; i++)
                this[i].GetDatabases(set);

            foreach (var child in GetChildren())
            {
                (child as IDatabaseElement).GetDatabases(set);
            }


        }
   }
}
