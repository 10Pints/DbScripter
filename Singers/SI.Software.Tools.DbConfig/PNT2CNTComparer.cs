using System.Collections.Generic;
using SI.DataLogging;


namespace DbConfig
{
    class PNT2CNTComparer : IComparer<PNT2CNT>
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
        public int Compare(PNT2CNT x, PNT2CNT y)
        {
            // ReSharper disable once StringCompareToIsCultureSpecific
            var n = x.NodeType1.name.CompareTo(y.NodeType1.name);

            if (n != 0)
                return n;

            // ReSharper disable once StringCompareToIsCultureSpecific
            return x.NodeType.name.CompareTo(y.NodeType.name);
        }
    }
}
