using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Text;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Media;
using Brushes = System.Drawing.Brushes;
using FontFamily = System.Windows.Media.FontFamily;
using PixelFormat = System.Drawing.Imaging.PixelFormat;

namespace SI.Logging.Avi
{
    /// <summary>
    /// Represents a class for writing Avi files.
    /// </summary>
    public sealed class AviWriter : IDisposable
    {
        #region StaticProperties

        /// <summary>
        /// Get or set the default Avi encoding quality.
        /// </summary>
        public static uint DefaultEncodingQuality
        {
            get { return defaultEncodingQuality; }
            set
            {
                if (value <= MaximumEncodingQuality)
                    defaultEncodingQuality = value >= MinimumEncodingQuality ? value : MinimumEncodingQuality;
                else
                    defaultEncodingQuality = MaximumEncodingQuality;
            }
        }

        /// <summary>
        /// Get or set the default Avi encoding quality.
        /// </summary>
        private static uint defaultEncodingQuality = MaximumEncodingQuality;

        /// <summary>
        /// Get the maximum encoding quality - (highest quality, compression destroys the hidden message).
        /// </summary>
        public const uint MaximumEncodingQuality = 10000;

        /// <summary>
        /// Get the minimum encoding quality.
        /// </summary>
        public const uint MinimumEncodingQuality = 100;

        #endregion

        #region Properties

        /// <summary>
        /// Get the amount of frames this writer contains.
        /// </summary>
        public int Frames { get; private set; }

        /// <summary>
        /// Get the output path of this writer.
        /// </summary>
        public string Path { get; }

        /// <summary>
        /// Get or set the output frames per second of this writer.
        /// </summary>
        public uint FramesPerSecond { get; set; }

        /// <summary>
        /// Get or set the font size.
        /// </summary>
        public double FontSize { get; set; } = 10;

        /// <summary>
        /// Get or set the font family.
        /// </summary>
        public FontFamily FontFamily { get; set; } = new FontFamily("Tahoma");

        /// <summary>
        /// Get or set the default avi encoding quality.
        /// </summary>
        public uint EncodingQuality { get; set; } = DefaultEncodingQuality;

        /// <summary>
        /// Get or set the handle of the file.
        /// </summary>
        private int aviFile;

        /// <summary>
        /// Get or set a pointer to the avi stream.
        /// </summary>
        private IntPtr aviStream = IntPtr.Zero;

        /// <summary>
        /// Get or set the type of the avi.
        /// </summary>
        private readonly uint fccType = AviFile.StreamTypeVideo;

        /// <summary>
        /// Get or set the codec handler.
        /// </summary>
        private readonly uint fccHandler = 1668707181; //"Microsoft Video 1" - Use CVID for default codec: (UInt32)Avi.mmioStringToFOURCC("CVID", 0);

        #endregion

        #region Methods

        /// <summary>
        /// Initializes a new instance of the AviWriter class.
        /// </summary>
        /// <param name="path">The output path of the Avi.</param>
        /// <param name="framesPerSecond">The frames per second of the Avi.</param>
        public AviWriter(string path, uint framesPerSecond)
        {
            Path = path;
            FramesPerSecond = framesPerSecond;
            OpenStream();
        }

        /// <summary>
        /// Open the Avi stream for editing.
        /// </summary>
        private void OpenStream()
        {
            AviFile.AVIFileInit();

            // get a handle result for opening the file
            var result = AviFile.AVIFileOpen(ref aviFile, Path, 4097 /* OF_WRITE | OF_CREATE (winbase.h) */, 0);
            if (result != 0)
                throw new Exception($"Error opening Avi file: {result}.");
        }

        /// <summary>
        /// Close the avi streamfrom editing.
        /// </summary>
        private void CloseStream()
        {
            if (aviStream != IntPtr.Zero)
            {
                AviFile.AVIStreamRelease(aviStream);
                aviStream = IntPtr.Zero;
            }

            if (aviFile != 0)
            {
                AviFile.AVIFileRelease(aviFile);
                aviFile = 0;
            }

            AviFile.AVIFileExit();
        }

        /// <summary>
        /// Add a frame to the Avi. No timestamp will be used.
        /// </summary>
        /// <param name="frame">The frame to add.</param>
        public void AddFrame(Bitmap frame)
        {
            AddFrame(frame, null);
        }

        /// <summary>
        /// Add a frame to the Avi.
        /// </summary>
        /// <param name="frame">The frame to add.</param>
        /// <param name="dateTimeForTimestamp">A date and time to stamp onto the bitmap.</param>
        public void AddFrame(Bitmap frame, DateTime? dateTimeForTimestamp)
        {
            if (dateTimeForTimestamp.HasValue)
            {
                var graphics = Graphics.FromImage(frame);
                graphics.TextRenderingHint = TextRenderingHint.AntiAlias;
                var strFormat = new StringFormat
                {
                    Alignment = StringAlignment.Far,
                    LineAlignment = StringAlignment.Near
                };

                var text = dateTimeForTimestamp.Value.ToLongDateString() + " at " + dateTimeForTimestamp.Value.ToLongTimeString();
                var formattedText = new FormattedText(text, CultureInfo.GetCultureInfo("en-us"), FlowDirection.LeftToRight, new Typeface(this.FontFamily.ToString()), this.FontSize, System.Windows.Media.Brushes.Black);

                // the mysteryPixelScaleFactor is used with width and height converts between some kind of pixel format (dips > px?),
                // it is needed whatever because otherwise the measuring was all wrong

                // hold scale factor
                var mysteryPixelScaleFactor = 1.5;
                var width = (int)(formattedText.Width * mysteryPixelScaleFactor);
                var height = (int)(formattedText.Height * mysteryPixelScaleFactor);

                graphics.FillRectangle(Brushes.Black, new Rectangle(frame.Width - width, 0, width, height));
                graphics.DrawString(formattedText.Text, new Font(FontFamily.ToString(), (int)FontSize), Brushes.White, new RectangleF(frame.Width - width, 0, width, height), strFormat);
            }

            frame.RotateFlip(RotateFlipType.RotateNoneFlipY);

            // lock bits to prevent access errors or changes and get data
            var bmpData = frame.LockBits(new Rectangle(0, 0, frame.Width, frame.Height), ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);

            if (Frames == 0)
            {
                // create new stream info header
                var streamHeader = new AviStreamInfo
                {
                    fccType = fccType,
                    fccHandler = fccHandler,
                    dwScale = 1,
                    dwRate = FramesPerSecond,
                    dwSuggestedBufferSize = (uint)(frame.Height * (uint)bmpData.Stride),
                    dwQuality = EncodingQuality,
                    rcFrame =
                    {
                        Bottom = (uint)frame.Height,
                        Right = (uint)frame.Width
                    },
                    szName = new ushort[64] // not sure why we put it to +64...
                };

                var result = AviFile.AVIFileCreateStream(aviFile, out aviStream, ref streamHeader);
                if (result != 0)
                    throw new Exception("Error creating AVI stream: " + result.ToString());

                // create new bitmap info header
                var bitmapInfoHeader = new BitmapInfoHeader();
                bitmapInfoHeader.biSize = (uint)Marshal.SizeOf(bitmapInfoHeader);
                bitmapInfoHeader.biWidth = frame.Width;
                bitmapInfoHeader.biHeight = frame.Height;
                bitmapInfoHeader.biPlanes = 1;
                bitmapInfoHeader.biBitCount = 24;
                bitmapInfoHeader.biSizeImage = (uint)(bmpData.Stride * frame.Height);

                // set stream format
                result = AviFile.AVIStreamSetFormat(aviStream, 0, ref bitmapInfoHeader, Marshal.SizeOf(bitmapInfoHeader));

                if (result != 0)
                    throw new Exception($"Error setting stream format: {result}.");
            }

            // write to stream and get result
            var streamWriteResult = AviFile.AVIStreamWrite(aviStream, Frames, 1, bmpData.Scan0, bmpData.Stride * frame.Height, 0, 0, 0);
            if (streamWriteResult != 0)
                throw new Exception($"Error writing frame to avi {streamWriteResult}.");

            frame.UnlockBits(bmpData);
            Frames++;
        }

        #endregion

        #region IDisposable Members

        void IDisposable.Dispose()
        {
            CloseStream();
        }

        #endregion
    }
}
