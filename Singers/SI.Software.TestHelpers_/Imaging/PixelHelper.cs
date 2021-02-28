using System.Windows;

namespace SI.Software.TestHelpers.Imaging
{
    /// <summary>
    /// Provides pixel help functionality.
    /// </summary>
    public static class PixelHelper
    {
        /// <summary>
        /// Get the start index of a pixel.
        /// </summary>
        /// <param name="column">The column.</param>
        /// <param name="row">The row.</param>
        /// <param name="stride">The stride of the pixel data.</param>
        /// <returns>The pixel index.</returns>
        public static int GetPixelStartIndex(int column, int row, int stride)
        {
            return GetPixelStartIndex(column, row, stride, 3);
        }

        /// <summary>
        /// Get the start index of a pixel.
        /// </summary>
        /// <param name="column">The column.</param>
        /// <param name="row">The row.</param>
        /// <param name="stride">The stride of the pixel data.</param>
        /// <param name="bytesPerPixel">The bytes per pixel.</param>
        /// <returns>The pixel index.</returns>
        public static int GetPixelStartIndex(int column, int row, int stride, int bytesPerPixel)
        {
            return (row * stride) + (column * bytesPerPixel);
        }

        /// <summary>
        /// Set a pixel white.
        /// </summary>
        /// <param name="column">The column.</param>
        /// <param name="row">The row.</param>
        /// <param name="pixels">The pixel data.</param>
        /// <param name="stride">The stride of the pixel data.</param>
        /// <param name="bytesPerPixel">The bytes per pixel.</param>
        public static void SetPixelWhite(int column, int row, ref byte[] pixels, int stride, int bytesPerPixel)
        {
            var index = GetPixelStartIndex(column, row, stride, bytesPerPixel);

            for (var i = 0; i < bytesPerPixel; i++)
            {
                pixels[index + i] = byte.MaxValue;
            }
        }

        /// <summary>
        /// Set a group of pixels white.
        /// </summary>
        /// <param name="region">The region of pixels to set white.</param>
        /// <param name="pixels">The pixel data.</param>
        /// <param name="stride">The stride of the pixel data.</param>
        /// <param name="bytesPerPixel">The bytes per pixel.</param>
        public static void SetPixelsWhite(Int32Rect region, ref byte[] pixels, int stride, int bytesPerPixel)
        {
            for (var column = 0; column < region.Width; column++)
            {
                for (var row = 0; row < region.Height; row++)
                {
                    SetPixelWhite(column + region.X, row + region.Y, ref pixels, stride, bytesPerPixel);
                }
            }
        }

        /// <summary>
        /// Set a pixel black.
        /// </summary>
        /// <param name="column">The column.</param>
        /// <param name="row">The row.</param>
        /// <param name="pixels">The pixel data.</param>
        /// <param name="stride">The stride of the pixel data.</param>
        /// <param name="bytesPerPixel">The bytes per pixel.</param>
        public static void SetPixelBlack(int column, int row, ref byte[] pixels, int stride, int bytesPerPixel)
        {
            var index = GetPixelStartIndex(column, row, stride, bytesPerPixel);

            for (var i = 0; i < bytesPerPixel; i++)
            {
                pixels[index + i] = byte.MinValue;
            }
        }

        /// <summary>
        /// Set a group of pixels black.
        /// </summary>
        /// <param name="region">The region of pixels to set white.</param>
        /// <param name="pixels">The pixel data.</param>
        /// <param name="stride">The stride of the pixel data.</param>
        /// <param name="bytesPerPixel">The bytes per pixel.</param>
        public static void SetPixelsBlack(Int32Rect region, ref byte[] pixels, int stride, int bytesPerPixel)
        {
            for (var column = 0; column < region.Width; column++)
            {
                for (var row = 0; row < region.Height; row++)
                {
                    SetPixelBlack(column + region.X, row + region.Y, ref pixels, stride, bytesPerPixel);
                }
            }
        }

        /// <summary>
        /// Set a pixel to a RGB colour.
        /// </summary>
        /// <param name="column">The column.</param>
        /// <param name="row">The row.</param>
        /// <param name="pixels">The pixel data.</param>
        /// <param name="stride">The stride of the pixel data.</param>
        /// <param name="bytesPerPixel">The bytes per pixel.</param>
        /// <param name="rgbColor">The color to set the pixel to in the format RGB.</param>
        public static void SetPixelToRGBColor(int column, int row, ref byte[] pixels, int stride, int bytesPerPixel, byte[] rgbColor)
        {
            var index = GetPixelStartIndex(column, row, stride, bytesPerPixel);

            for (var i = 0; i < bytesPerPixel; i++)
            {
                pixels[index + i] = rgbColor[i];
            }
        }

        /// <summary>
        /// Set a group of pixels to a RGB colour.
        /// </summary>
        /// <param name="region">The region of pixels to set white.</param>
        /// <param name="pixels">The pixel data.</param>
        /// <param name="stride">The stride of the pixel data.</param>
        /// <param name="bytesPerPixel">The bytes per pixel.</param>
        /// <param name="rgbColor">The color to set the pixel to in the format RGB.</param>
        public static void SetPixelsToRGBColor(Int32Rect region, ref byte[] pixels, int stride, int bytesPerPixel, byte[] rgbColor)
        {
            for (var column = 0; column < region.Width; column++)
            {
                for (var row = 0; row < region.Height; row++)
                {
                    SetPixelToRGBColor(column + region.X, row + region.Y, ref pixels, stride, bytesPerPixel, rgbColor);
                }
            }
        }
    }
}
