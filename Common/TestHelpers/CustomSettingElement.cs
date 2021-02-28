#nullable enable 
using System;
using System.Configuration;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace RSS.Test
{
    public class CustomSettingElement : ConfigurationElement, IElement
    {
        private IElement? _parent;
        public virtual IElement? Parent
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

        public T? GetAttributeRecursiveV<T>(string name) where T: struct
        {
            var x = base[name];

            if((x != null) && (!string.IsNullOrEmpty(x.ToString())))
                return (T)x;

            var parent = Parent as IDatabaseElement;

            if (parent == null)
                return default(T);

            return parent.GetAttributeRecursiveV<T>(name);
        }

        public T? GetAttributeRecursiveR<T>(string name) where T: class
        {
            var x = base[name];

            if((x != null) && (!string.IsNullOrEmpty(x.ToString())))
                return (T)x;

            var parent = Parent as IDatabaseElement;

            if (parent == null)
                return default(T);

            return parent.GetAttributeRecursiveR<T>(name);
        }
/*
        public T? GetAttributeRecursiveR<T>(string name) where T : class
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
                    return parent.GetAttributeRecursiveR<T>(name);
                }
            }

            return (T)t;
        }
*/
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
