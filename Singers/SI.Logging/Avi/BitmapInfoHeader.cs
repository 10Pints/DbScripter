using System.Runtime.InteropServices;

namespace SI.Logging.Avi
{
    /// <summary>
    /// Represents a structure for bitmap info header for Avi files.
    /// </summary>
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    internal struct BitmapInfoHeader
    {
        internal uint biSize;
        internal int biWidth;
        internal int biHeight;
        internal short biPlanes;
        internal short biBitCount;
        internal uint biCompression;
        internal uint biSizeImage;
        internal int biXPelsPerMeter;
        internal int biYPelsPerMeter;
        internal uint biClrUsed;
        internal uint biClrImportant;
    }
}
