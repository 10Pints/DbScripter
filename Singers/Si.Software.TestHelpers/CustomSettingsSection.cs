using System;
using System.Configuration;

namespace SI.Software.TestHelpers
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

        public T GetAttributeRecursive<T>(string name)  => (T)base[name];
        public T? GetAttributeRecursive2<T>(string name) where T : struct => (T)base[name];

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
        public IElement Parent => null;
        #endregion
    }

}
