﻿using System;
using System.Linq;

namespace SI.Common.Extensions
{
    /// <summary>
    /// Provides extension methods for strings.
    /// </summary>
    public static class StringExtensions
    {
        /// <summary>
        /// Returns a new string in which all occurrences of a specified string in the current instance are replaced with another specified string.
        /// </summary>
        /// <param name="originalString">The string holding the substring to be replaced.</param>
        /// <param name="oldValue">The substring to be replaced.</param>
        /// <param name="newValue">The new substring to substitute for the oldValue substring.</param>
        /// <param name="comparisonType">The comparison type.</param>
        /// <returns>The edited string.</returns>
        public static string Replace(this string originalString, string oldValue, string newValue, StringComparison comparisonType)
        {
            // from https://stackoverflow.com/questions/244531/is-there-an-alternative-to-string-replace-that-is-case-insensitive

            var startIndex = 0;

            while (true)
            {
                startIndex = originalString.IndexOf(oldValue, startIndex, comparisonType);
                if (startIndex == -1)
                    break;

                originalString = originalString.Substring(0, startIndex) + newValue + originalString.Substring(startIndex + oldValue.Length);
                startIndex += newValue.Length;
            }

            return originalString;
        }

        /// <summary>
        /// Returns the number of occurences of a string within a string, optional comparison allows case and culture control.
        /// </summary>
        /// <param name="input"></param>
        /// <param name="value"></param>
        /// <param name="stringComparisonType"></param>
        /// <returns></returns>
        public static int Occurrences(this string input, string value, StringComparison stringComparisonType = StringComparison.Ordinal)
        {
            if (String.IsNullOrEmpty(value))
                return 0;

            var count = 0;
            var position = 0;

            while ((position = input.IndexOf(value, position, stringComparisonType)) != -1)
            {
                position += value.Length;
                count += 1;
            }

            return count;
        }

        /// <summary>
        /// Returns the number of occurences of a single character within a string.
        /// </summary>
        /// <param name="input"></param>
        /// <param name="value"></param>
        /// <returns></returns>
        public static int Occurrences(this string input, char value)
        {
            return input.Count(c => c == value);
        }
    }
}

