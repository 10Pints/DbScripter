using System.Runtime.InteropServices;

namespace SI.Logging.Avi
{
    /// <summary>
    /// Represents a structure for Avi stream info.
    /// </summary>
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    internal struct AviStreamInfo
    {
        internal uint fccType;
        internal uint fccHandler;
        internal uint dwFlags;
        internal uint dwCaps;
        internal ushort wPriority;
        internal ushort wLanguage;
        internal uint dwScale;
        internal uint dwRate;
        internal uint dwStart;
        internal uint dwLength;
        internal uint dwInitialFrames;
        internal uint dwSuggestedBufferSize;
        internal uint dwQuality;
        internal uint dwSampleSize;
        internal UInt32Rect rcFrame;
        internal uint dwEditCount;
        internal uint dwFormatChangeCount;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 64)]
        internal ushort[] szName;
    }
}
