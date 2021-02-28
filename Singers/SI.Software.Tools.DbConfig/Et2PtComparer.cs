using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SI.DataLogging;

namespace DbConfig
{
    /// <summary>
    /// Sort class used by the framework to order the EP2PT list in the view
    /// </summary>
    class Et2PtComparer : IComparer<ET2PT>
    {
        //
        // Summary:
        //     Compares two objects and returns a value indicating whether one is less than,
        //     equal to, or greater than the other.
        //
        // Parameters:
        //   x:
        //     The first object to compare.
        //
        //   y:
        //     The second object to compare.
        //
        // Returns:
        //     A signed integer that indicates the relative values of x and y.
        public int Compare(ET2PT x, ET2PT y)
        {
            Debug.Assert(x != null);
            Debug.Assert(y != null);
            // ReSharper disable once StringCompareToIsCultureSpecific
            if ((x.EventType == null) || (y.EventType == null))
                Debug.WriteLine("oops!");

            Debug.Assert(x.EventType != null);
            Debug.Assert(y.EventType != null);
            // ReSharper disable once StringCompareToIsCultureSpecific
            var n = x.EventType.name.CompareTo(y.EventType.name);

            if (n != 0)
                return n;

            // ReSharper disable once StringCompareToIsCultureSpecific
            return x.PropertyType.name.CompareTo(y.PropertyType.name);
        }
    }
}
