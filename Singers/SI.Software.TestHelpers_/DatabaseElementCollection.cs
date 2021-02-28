using System;
using System.Configuration;
using C5;

namespace SI.Software.TestHelpers
{
    // https://stackoverflow.com/questions/7044871/how-do-i-use-net-custom-configurationelement-properties-on-descendent-elements
    public abstract class DatabaseElementCollection : ConfigurationElementCollection, IDatabaseElement
    {
        #region INamedElement

        [ConfigurationProperty("name", IsRequired = false)]
        public string Name => (string) base["name"];

        #endregion INamedElement
        #region IElement

        public IElement Parent{get;internal set;}

        public T GetAttributeRecursive<T>(string name)
        {
            var x = base[name];

            if (x == null)
                return GetParentAttributeRecursive<T>(name);

            var t = (T) x;

            // XML sometines returns ""
            if (!string.IsNullOrEmpty(t.ToString()))
                return (T)t;

            return GetParentAttributeRecursive<T>( name);
        }

        private T GetParentAttributeRecursive<T>(string name)
        {
            var parent = Parent as IDatabaseElement;

            if (parent == null)
                return default(T);

            return parent.GetAttributeRecursive<T>(name);
        }

        public T? GetAttributeRecursive2<T>(string name) where T : struct
            {
                var t = (T?)base[name];

                // XML has no null - just ""
                if ((t != null) && (!string.IsNullOrEmpty(t.ToString())))
                    return (T)t;

                var parent = Parent as IDatabaseElement;
                return parent?.GetAttributeRecursive<T>(name) ?? default(T);
            }


        public virtual IElement[] GetChildren()
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
        public string Database => GetAttributeRecursive<string>("database");

        [ConfigurationProperty("check_db_state", IsRequired = false, DefaultValue = null)]
        public bool? CheckDbState => GetAttributeRecursive<bool>("check_db_state");
        #endregion IElement

        public new CustomSettingElement this[string key] => BaseGet(key) as CustomSettingElement;

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

