using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;

namespace SI.Common.Helpers
{
    /// <summary>
    /// Provides helper functionality for Ftp.
    /// </summary>
    public static class FtpHelper
    {
        /// <summary>
        /// Get a list of a list of all files in a remote directory.
        /// </summary>
        /// <param name="remoteDriectory">The remote directory.</param>
        /// <param name="credentials">The credentials.</param>
        /// <returns>The files in the remote directory.</returns>
        public static string[] GetFiles(string remoteDriectory, NetworkCredential credentials)
        {
            return GetFiles(remoteDriectory, credentials, null);
        }

        /// <summary>
        /// Get a list of a list of all files in a remote directory.
        /// </summary>
        /// <param name="remoteDriectory">The remote directory.</param>
        /// <param name="credentials">The credentials.</param>
        /// <param name="extensions">The extensions of the files to return.</param>
        /// <returns>The files in the remote directory.</returns>
        public static string[] GetFiles(string remoteDriectory, NetworkCredential credentials, params string[] extensions)
        {
            // create ftp request
            var request = (FtpWebRequest)WebRequest.Create(remoteDriectory);
            request.Method = WebRequestMethods.Ftp.ListDirectoryDetails;
            request.Credentials = credentials;
            request.UsePassive = true;
            request.UseBinary = true;
            request.KeepAlive = false;

            var data = string.Empty;

            using (var response = (FtpWebResponse)request.GetResponse())
            {
                var stream = response.GetResponseStream();
                if (stream != null)
                {
                    using (var reader = new StreamReader(stream))
                        data = reader.ReadToEnd();
                }
            }

            if (string.IsNullOrEmpty(data))
                throw new InvalidOperationException("File list was empty.");

            var files = data.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
            var fileNames = new List<string>();

            foreach (var file in files)
            {
                // date, directory etc is before filename which is last, separated by at-least one space
                if (!file.Contains(" "))
                    continue;

                var truncatedFileName = file.Substring(file.LastIndexOf(" ", StringComparison.Ordinal)).Trim();
                
                // check extension
                if ((extensions == null) || (extensions.Length ==0) || (extensions.Any(x=> truncatedFileName.EndsWith(x))))
                    fileNames.Add(truncatedFileName);
            }

            return fileNames.ToArray();
        }

        /// <summary>
        /// Get the size, in bytes, of a remote file.
        /// </summary>
        /// <param name="remoteFile">The remote file.</param>
        /// <param name="credentials">The credentials.</param>
        /// <returns>The size, in bytes, of a remote file.</returns>
        public static long GetFileSize(string remoteFile, NetworkCredential credentials)
        {
            var request = (FtpWebRequest)WebRequest.Create(remoteFile);
            request.Method = WebRequestMethods.Ftp.GetFileSize;
            request.Credentials = credentials;

            long fileLengthInBytes;

            using (var response = (FtpWebResponse)request.GetResponse())
                fileLengthInBytes = response.ContentLength;

            return fileLengthInBytes;
        }

        /// <summary>
        /// Scale a memory size.
        /// </summary>
        /// <param name="size">The size to scale.</param>
        /// <param name="scale">The amount of steps to scale by. For example B->KB = 1, B->MB = 2, B->GB = 3.</param>
        /// <returns>The scaled size.</returns>
        private static double ScaleMemorySize(double size, int scale)
        {
            return size / (1024 * scale);
        }

        /// <summary>
        /// Convert a size in bytes to size in KB.
        /// </summary>
        /// <param name="size">The size, in bytes, to convert.</param>
        /// <returns>The size in KB.</returns>
        public static double ConvertSizeInBToSizeInKB(double size)
        {
            return ScaleMemorySize(size, 1);
        }

        /// <summary>
        /// Convert a size in KB to size in MB.
        /// </summary>
        /// <param name="size">The size, in KB, to convert.</param>
        /// <returns>The size in MB.</returns>
        public static double ConvertSizeInKBToSizeInMB(double size)
        {
            return ScaleMemorySize(size, 1);
        }

        /// <summary>
        /// Convert a size in B to size in MB.
        /// </summary>
        /// <param name="size">The size, in B, to convert.</param>
        /// <returns>The size in MB.</returns>
        public static double ConvertSizeInBToSizeInMB(double size)
        {
            var kbSize = ScaleMemorySize(size, 1);
            return ScaleMemorySize(kbSize, 1);
        }
    }
}
