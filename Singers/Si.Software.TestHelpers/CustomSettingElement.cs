using System;
using System.Configuration;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace SI.Software.TestHelpers
{
    public class CustomSettingElement : ConfigurationElement, IElement
    {
        private IElement _parent;
        public virtual IElement Parent
        {
            get
            {
                Assert.IsNotNull(_parent);
                return _parent;
            }
            internal set
            {
                Assert.IsNotNull(value);
                _parent = value;
            }
        }

        public T GetAttributeRecursive<T>(string name)
        {
            var x = base[name];

            if((x != null) && (!string.IsNullOrEmpty(x.ToString())))
                return (T)x;

            var parent = Parent as IDatabaseElement;

            if (parent == null)
                return default(T);

            return parent.GetAttributeRecursive<T>(name);
        }

        public T? GetAttributeRecursive2<T>(string name) where T : struct
        {
            var x = base[name];
            var t = (T?)x;

            if (t == null)
            {
                var parent = Parent as IDatabaseElement;

                if (parent == null)
                    return default(T);
                else
                {
                    return parent.GetAttributeRecursive2<T>(name);
                }
            }

            return (T)t;
        }

        [ConfigurationProperty("name", IsRequired = false)] // , IsKey = true
        public string Name
        {
            get { return (string) base["name"]; }
            set { base["name"] = value; }
        }

        #region IElement

        //public virtual IElement[] GetChildren()
        //{
        //    throw new NotImplementedException();
        //}

        public virtual IElementCollection GetChildCollection()
        {
            //return this;
            throw new NotImplementedException();
        }


        public virtual IElement[] GetChildren()
        {
            throw new NotImplementedException(); //return BaseGetAllKeys() as IElement[];//GetChildCollection().BaseGetAllKeys() as IElement[];
        }

        #endregion IElement
    }
}
