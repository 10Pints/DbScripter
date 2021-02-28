using System.Runtime.InteropServices;

namespace SI.Logging.Avi
{
    /// <summary>
    /// Represents a structure for a bitmap file header.
    /// </summary>
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    internal struct BitmapFileHeader
    {
        internal short bfType; //"magic cookie" - must be "BM"
        internal int bfSize;
        internal short bfReserved1;
        internal short bfReserved2;
        internal int bfOffBits;
    }
}
