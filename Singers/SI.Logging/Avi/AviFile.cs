using System;
using System.Runtime.InteropServices;

namespace SI.Logging.Avi
{
    /// <summary>
    /// Represnets a Avi file.
    /// </summary>
    internal class AviFile
    {
        #region Notes

        /*
         * AVI Write info can be found at:
         * http://www.codeproject.com/KB/security/steganodotnet4.aspx
         * By the author Corinna John.
         * This is an interpretation based on her AVI writer, and AVI classes
         */

        #endregion

        #region StaticFields

        /// <summary>
        /// Get the stream type vide for AVI files.
        /// </summary>
        public const int StreamTypeVideo = 1935960438; //mmioStringToFOURCC("vids", 0)

        #endregion

        #region DLLImports

        [DllImport("avifil32.dll")]
        internal static extern void AVIFileInit();

        [DllImport("avifil32.dll", PreserveSig = true)]
        internal static extern int AVIFileOpen(ref int ppfile, string szFile, int uMode, int pclsidHandler);

        [DllImport("avifil32.dll")]
        internal static extern int AVIFileCreateStream(int pfile, out IntPtr ppavi, ref AviStreamInfo ptr_streaminfo);

        [DllImport("avifil32.dll")]
        internal static extern int AVIStreamSetFormat(IntPtr aviStream, int lPos, ref BitmapInfoHeader lpFormat, int cbFormat);

        [DllImport("avifil32.dll")]
        internal static extern int AVIStreamWrite(IntPtr aviStream, int lStart, int lSamples, IntPtr lpBuffer, int cbBuffer, int dwFlags, int dummy1, int dummy2);

        [DllImport("avifil32.dll")]
        internal static extern int AVIStreamRelease(IntPtr aviStream);

        [DllImport("avifil32.dll")]
        internal static extern int AVIFileRelease(int pfile);

        [DllImport("avifil32.dll")]
        internal static extern void AVIFileExit();

        #endregion
    }
}
