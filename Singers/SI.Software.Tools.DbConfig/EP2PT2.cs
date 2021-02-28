using System.Diagnostics;


namespace DbConfig
{
    public partial class ET2PT
    {
        public override string ToString()
        {
            return $"{EventType.name}\t{PropertyType.name}";
        }
    }
}

/*        public int CompareTo(ET2PT t)
                {
                    // ReSharper disable once StringCompareToIsCultureSpecific
                    if((EventType == null) || (t.EventType == null))
                        Debug.WriteLine("oops!");

                    var n = ((EventType != null) && (t.EventType != null)) ? EventType.name.CompareTo(t.EventType.name) : 1;

                    if (n != 0)
                        return n;

                    // ReSharper disable once StringCompareToIsCultureSpecific
                    return PropertyType.name.CompareTo(t.PropertyType.name);
                }

                public bool Equals(ET2PT t)
                {
                    return (CompareTo(t) == 0);
                }
    }
}
*/

