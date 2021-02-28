using System.Runtime.InteropServices;

namespace SI.Logging.Avi
{
    /// <summary>
    /// A rectangle described in unsigned integers.
    /// </summary>
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    internal struct UInt32Rect
    {
        internal uint Left;
        internal uint Top;
        internal uint Right;
        internal uint Bottom;
    }
}
