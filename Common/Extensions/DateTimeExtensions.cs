using System;
using System.Globalization;

namespace RSS
{
    /// <summary>
    /// Extension methods for DateTime.
    /// </summary>
    public static class DateTimeExtensions
    {
        /// <summary>
        /// Get the serialization format for DateTime string representation.
        /// </summary>
        public const string SerializationFormat = "MM/dd/yyyy HH:mm:ss";

        /// <summary>
        /// Get the file safe format for DateTime string representation.
        /// </summary>
        public const string FileSafeFormat = "MM_dd_yyyy_HH_mm_ss";

        /// <summary>
        /// Get the Sql safe format for DateTime string representation.
        /// </summary>
        public const string SqlSafeFormat = "yyyy-MM-dd HH:mm:ss.fff";

        /// <summary>
        /// Parse a DateTime to a serialization format string, MM/DD/YYYY HH:MM:SS.
        /// </summary>
        /// <param name="dateTime">The DateTime to parse.</param>
        /// <returns>A string representation of the DateTime in the format MM/DD/YYYY HH:MM:SS.</returns>
        public static string ToSerializationFormatString(this DateTime dateTime)
        {
            return dateTime.ToString(SerializationFormat, CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// Parse a DateTime to a file name safe format string, MM_DD_YYYY_HH_MM_SS.
        /// </summary>
        /// <param name="dateTime">The DateTime to parse.</param>
        /// <returns>A string representation of the DateTime in the format MM_DD_YYYY_HH_MM_SS.</returns>
        public static string ToFileNameSafeString(this DateTime dateTime)
        {
            return dateTime.ToString(FileSafeFormat, CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// Parse a DateTime to a Sql safe format string, YYYY-MM-DD HH:MM:SS.FFF.
        /// </summary>
        /// <param name="dateTime">The DateTime to parse.</param>
        /// <returns>A string representation of the DateTime in the format YYYY-MM-DD HH:MM:SS.FFF.</returns>
        public static string ToSqlSafeString(this DateTime dateTime)
        {
            return dateTime.ToString(SqlSafeFormat, CultureInfo.InvariantCulture);
        }
    }
}
