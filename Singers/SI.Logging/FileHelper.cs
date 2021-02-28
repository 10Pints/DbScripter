using System;
using System.Text;

namespace SI.Logging
{
    /// <summary>
    /// A helper class for File operations.
    /// </summary>
    public static class FileHelper
    {
        #region StaticMethods

        /// <summary>
        /// Format a DateTime to a string in the format YYYY_MM_DD_HH_MM_SS_MMM.
        /// </summary>
        /// <param name="dateTime">The DateTime to format.</param>
        /// <returns>The formatted string.</returns>
        public static string FormatDateTimeToString(DateTime dateTime)
        {
            var padChars = "0".ToCharArray();
            var padChar = padChars[0];
            return $"{PadString(dateTime.Year.ToString(), 4, padChar)}_{PadString(dateTime.Month.ToString(), 2, padChar)}_{PadString(dateTime.Day.ToString(), 2, padChar)}_{PadString(dateTime.Hour.ToString(), 2, padChar)}_{PadString(dateTime.Minute.ToString(), 2, padChar)}_{PadString(dateTime.Second.ToString(), 2, padChar)}_{PadString(dateTime.Millisecond.ToString(), 3, padChar)}";
        }

        /// <summary>
        /// Format a DateTime to a string in the format YYYY_MM_DD
        /// </summary>
        /// <param name="dateTime">The DateTime to format.</param>
        /// <returns>The formatted string.</returns>
        public static string FormatDateToString(DateTime dateTime)
        {
            var padChars = "0".ToCharArray();
            var padChar = padChars[0];
            return $"{PadString(dateTime.Year.ToString(), 4, padChar)}_{PadString(dateTime.Month.ToString(), 2, padChar)}_{PadString(dateTime.Day.ToString(), 2, padChar)}";
        }

        /// <summary>
        /// Format a DateTime to a string in the format HH_MM_SS_MMM.
        /// </summary>
        /// <param name="dateTime">The DateTime to format.</param>
        /// <returns>The formatted string.</returns>
        public static string FormatTimeToString(DateTime dateTime)
        {
            return FormatTimeToString(dateTime, true);
        }

        /// <summary>
        /// Format a DateTime to a string in the format HH_MM_SS or HH_MM_SS_MMM.
        /// </summary>
        /// <param name="dateTime">The DateTime to format.</param>
        /// <param name="includeMilliseconds">When true milliseconds will be included, else they will be omitted.</param>
        /// <returns>The formatted string.</returns>
        public static string FormatTimeToString(DateTime dateTime, bool includeMilliseconds)
        {
            var padChars = "0".ToCharArray();
            var padChar = padChars[0];
            var hhMMSS = $"{PadString(dateTime.Hour.ToString(), 2, padChar)}_{PadString(dateTime.Minute.ToString(), 2, padChar)}_{PadString(dateTime.Second.ToString(), 2, padChar)}";
            return !includeMilliseconds ? hhMMSS : $"{hhMMSS}_{PadString(dateTime.Millisecond.ToString(), 3, padChar)}";
        }

        /// <summary>
        /// Pad a string.
        /// </summary>
        /// <param name="input">The string to pad.</param>
        /// <param name="digits">The amount of digits expected before padding.</param>
        /// <param name="padCharacter">The character to use for padding.</param>
        /// <returns>The padded string.</returns>
        public static string PadString(string input, int digits, char padCharacter)
        {
            if (input.Length >= digits)
                return input;

            var builder = new StringBuilder();
            for (var i = input.Length; i < digits; i++)
                builder.Append(padCharacter);

            builder.Append(input);
            return builder.ToString();
        }

        #endregion
    }
}
