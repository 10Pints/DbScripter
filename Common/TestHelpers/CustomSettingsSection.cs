#nullable enable 

using System;
using System.Configuration;

namespace RSS.Test
{
    public class CustomSettingsSection : ConfigurationSection, ISection, IElementCollection
    {
        [ConfigurationProperty("name", IsRequired = false)]
        public string Name
        {
            get
            {
                var x = (string)base["name"];
                return x;
            }
        }

        public T? GetAttributeRecursiveV<T>(string name) where T: struct => (T)base[name];
        public T  GetAttributeRecursiveR<T>(string name) where T : class => (T)base[name];

        #region IElement

        public virtual IElement[] GetChildren()
        {
            throw new NotImplementedException();
            //return null;
        }

        public virtual IElementCollection GetChildCollection()
        {
            return this;
            //throw new NotImplementedException();
        }

        #endregion
        #region ISection interface (includes IElement)
        public IElement? Parent => null;
        #endregion
    }

}
