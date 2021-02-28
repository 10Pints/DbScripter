using System.Text;

namespace SI.Logging
{
    /// <summary>
    /// Represents a filter for a file type.
    /// </summary>
    public struct FileTypeFilter
    {
        /// <summary>
        /// Get or set the extension for the file type.
        /// </summary>
        public string Extension { get; set; }

        /// <summary>
        /// Get or set the description of the file type.
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// Initializes a new instance of the FileTypeFilter struct.
        /// </summary>
        /// <param name="extension">The extension for the file type.</param>
        /// <param name="description">The description of the file type.</param>
        public FileTypeFilter(string extension, string description)
        {
            if (!extension.StartsWith("."))
                extension = "." + extension; 

            Extension = extension;
            Description = description;
        }

        /// <summary>
        /// Generate a string filter.
        /// </summary>
        /// <param name="filters">The filters to use in the filter generation.</param>
        /// <returns>A filter string compilied from the specified filters.</returns>
        public static string GenerateFilterString(params FileTypeFilter[] filters)
        {
            var filterBuilder = new StringBuilder();

            if (filters?.Length > 0)
            {
                foreach (var filter in filters)
                {
                    if (!string.IsNullOrEmpty(filterBuilder.ToString()))
                        filterBuilder.Append("|");

                    filterBuilder.Append($"{filter.Description} (*{filter.Extension})|*{filter.Extension}");
                }
            }
            else
            {
                filterBuilder.Append("All files (*.*)|*.*");
            }


            return filterBuilder.ToString();
        }
    }
}
