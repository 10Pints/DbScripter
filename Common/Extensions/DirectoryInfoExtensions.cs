using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace RSS
{
    /// <summary>
    /// Extension methods for DirectoryInfo.
    /// </summary>
    public static class DirectoryInfoExtensions
    {
        /// <summary>
        /// Get the youngest file in a directory.
        /// </summary>
        /// <param name="x">This DirectoryInfo.</param>
        /// <param name="extensions">The extensions of the files that should be checked.</param>
        /// <returns>The FileInfo for the youngest file in the directory.</returns>
        public static FileInfo GetYoungestFile(this DirectoryInfo x, params string[] extensions)
        {
            var allFiles = GetFiles(x, extensions, SearchOption.TopDirectoryOnly);
            return allFiles.Length > 0 ? allFiles.OrderBy(y => y.LastWriteTime).ElementAt(allFiles.Length - 1) : null;
        }

        /// <summary>
        /// Get the oldest file in a directory.
        /// </summary>
        /// <param name="x">This DirectoryInfo.</param>
        /// <param name="extensions">The extensions of the files that should be checked.</param>
        /// <returns>The FileInfo for the oldest file in the directory.</returns>
        public static FileInfo GetOldestFile(this DirectoryInfo x, params string[] extensions)
        {
            var allFiles = GetFiles(x, extensions, SearchOption.TopDirectoryOnly);
            return allFiles.Length > 0 ? allFiles.OrderBy(y => y.LastWriteTime).ElementAt(0) : null;
        }

        /// <summary>
        /// Returns a file list from the current directory matching the given search pattern and using a value to determine whether to search subdirectories.
        /// </summary>
        /// <param name="x">This irectoryInfo.</param>
        /// <param name="searchPatterns">The search strings to match against the names of files. This parameter can contain a combination of valid literal path and wildcard (* and ?) characters (see Remarks), but doesn't support regular expressions. The default pattern is "*", which returns all files.</param>
        /// <param name="searchOption">One of the enumeration values that specifies whether the search operation should include only the current directory or all subdirectories.</param>
        /// <returns>An array of type System.IO.FileInfo.</returns>
        public static FileInfo[] GetFiles(this DirectoryInfo x, string[] searchPatterns, SearchOption searchOption)
        {
            var allFiles = new List<FileInfo>();
            foreach (var extension in searchPatterns)
            {
                var formattedExtension = extension;

                if (!formattedExtension.StartsWith("*"))
                    formattedExtension = "*" + formattedExtension;

                allFiles.AddRange(x.GetFiles(formattedExtension, searchOption));
            }

            return allFiles.ToArray();
        }
    }
}
