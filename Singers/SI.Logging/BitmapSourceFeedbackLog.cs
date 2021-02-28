using System;
using System.ComponentModel.Composition;
using System.Drawing;
using System.IO;
using System.Windows.Media.Imaging;
using SI.Logging.Avi;

namespace SI.Logging
{
    /// <summary>
    /// Represents an object for logging BitmapSource feedback.
    /// </summary>
    [Export(typeof(IFeedbackLog<BitmapSource>))]
    public class BitmapSourceFeedbackLog : FeedbackLog<BitmapSource>
    {
        #region Constructors

        /// <summary>
        /// Initializes a new instance of the BitmapSourceFeedbackLog class.
        /// </summary>
        public BitmapSourceFeedbackLog()
        {
            ApplicableFileFilters = new[] { new FileTypeFilter(".bmp", "Windows Bitmap"), new FileTypeFilter(".avi", "Audio Video Interleave") };
        }

        #endregion
        
        #region Overrides of FeedbackLog<BitmapSource>

        /// <summary>
        /// Export this log to a file.
        /// </summary>
        /// <param name="path">The path of the file.</param>
        /// <returns>True if the operation completed, else false.</returns>
        protected override bool OnExportToFile(string path)
        {
            try
            {
                BitmapSource[] log;

                lock (Log)
                {
                    log = new BitmapSource[Log.Count];
                    Log.CopyTo(log, 0);
                }

                if (path.EndsWith(".avi"))
                {
                    FeedbackComponentProvider.Append(this, "Export", "Creating Avi stream...");
                    using (var writer = new AviWriter(path, 1))
                    {
                        writer.EncodingQuality = 10000;

                        for (var i = 0; i < log.Length; i++)
                        {
                            var frame = log[i];
                            FeedbackComponentProvider.Append(this, "Export", $"Adding frame {i} of {log.Length} to Avi stream...");
                            Bitmap bitmap;
                            using (var outStream = new MemoryStream())
                            {
                                BitmapEncoder enc = new BmpBitmapEncoder();
                                enc.Frames.Add(BitmapFrame.Create(frame));
                                enc.Save(outStream);
                                bitmap = new Bitmap(outStream);
                            }

                            writer.AddFrame(bitmap, null);
                        }
                    }

                    FeedbackComponentProvider.Append(this, "Export", "Created Avi stream.");
                }
                else if (path.EndsWith(".bmp"))
                {   
                    for (var i = 0; i < log.Length; i++)
                    {
                        FeedbackComponentProvider.Append(this, "Export", $"Exporting image {i + 1} of {log.Length}...");
                        var bitmapEncoder = new BmpBitmapEncoder();
                        bitmapEncoder.Frames.Add(BitmapFrame.Create(log[i]));
                        bitmapEncoder.Save(new FileStream(path.Replace(".bmp", $"{i + 1}.bmp"), FileMode.OpenOrCreate));
                        bitmapEncoder.Frames.Clear();
                        FeedbackComponentProvider.Append(this, "Export", $"Exported image {i + 1} of {log.Length}.");
                    }
                }
                else
                {
                    throw new NotImplementedException();
                }

                return true;
            }
            catch (Exception e)
            {
                FeedbackComponentProvider.Append(this, "Export", $"Exception caught exporting to file: {e.Message}");
                return false;
            }
        }

        #endregion
    }
}
