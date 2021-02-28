#nullable enable 
#pragma warning disable CS8603

using System;
using System.Configuration;
using C5;

namespace RSS.Test
{
    // https://stackoverflow.com/questions/7044871/how-do-i-use-net-custom-configurationelement-properties-on-descendent-elements
    public abstract class DatabaseElementCollection : ConfigurationElementCollection, IDatabaseElement
    {
        #region INamedElement

        [ConfigurationProperty("name", IsRequired = false)]
        public string Name => (string) base["name"];

        #endregion INamedElement
        #region IElement

        public IElement? Parent{get;internal set;}

        public T? GetAttributeRecursiveV<T>(string name) where T: struct
        {
            var x = base[name];

            if (x == null)
                return GetParentAttributeRecursiveV<T>(name);

            var t = (T) x;

            // XML sometines returns ""
            if (!string.IsNullOrEmpty(t.ToString()))
                return (T)t;

            return GetParentAttributeRecursiveV<T>( name);
        }

        public T? GetAttributeRecursiveR<T>(string name) where T: class
        {
            var x = base[name];

            if (x == null)
                return GetParentAttributeRecursiveR<T>(name);

            var t = (T) x;

            // XML sometines returns ""
            if (!string.IsNullOrEmpty(t.ToString()))
                return (T)t;

            return GetParentAttributeRecursiveR<T>( name);
        }

        private T? GetParentAttributeRecursiveV<T>(string name) where T: struct
        {
            var parent = Parent as IDatabaseElement;

            if (parent == null)
                return default(T);

            return parent.GetAttributeRecursiveV<T>(name);
        }

        private T? GetParentAttributeRecursiveR<T>(string name) where T: class
        {
            var parent = Parent as IDatabaseElement;

            if (parent == null)
                return default(T);

            return parent.GetAttributeRecursiveR<T>(name);
        }

        public virtual IElement[]? GetChildren()
        {
            throw new NotImplementedException();
        }

        public virtual IElementCollection GetChildCollection()
        {
            //return this;
            throw new NotImplementedException();
        }

        #endregion IElement
        #region IElement

        [ConfigurationProperty("database", IsRequired = false, DefaultValue = null)]
        public string? Database => GetAttributeRecursiveR<string>("database");

        [ConfigurationProperty("check_db_state", IsRequired = false, DefaultValue = null)]
        public bool? CheckDbState => GetAttributeRecursiveV<bool>("check_db_state");
        #endregion IElement

        public new CustomSettingElement? this[string key] => BaseGet(key) as CustomSettingElement;

        public override ConfigurationElementCollectionType CollectionType => ConfigurationElementCollectionType.BasicMap;


        public virtual void GetDatabases(TreeSet<string> set)
        {
           throw new NotImplementedException();
        }

        #region protected methods

        protected override string ElementName => "customSetting";

        protected override ConfigurationElement CreateNewElement()
        {
            return new CustomSettingElement { Parent = this };
        }

        /// <summary>
        /// Gets the element key for a specified configuration element when overridden in a derived class.
        /// </summary>
        /// <param name="element"></param>
        /// <returns></returns>
        protected override object GetElementKey(ConfigurationElement element) => ((CustomSettingElement)element)?.Name;

        #endregion protected methods
    }
}

