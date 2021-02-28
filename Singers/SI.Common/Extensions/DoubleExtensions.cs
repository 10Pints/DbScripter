using System;

namespace SI.Common.Extensions
{
    /// <summary>
    /// Extension methods for double.
    /// </summary>
    public static class DoubleExtensions
    {
        /// <summary>
        /// Determine if two doubles are about equal.
        /// </summary>
        /// <param name="x">This double floating point number.</param>
        /// <param name="y">The double floating point number to compare to.</param>
        /// <returns>True if the numbers are about equal, else false.</returns>
        public static bool AboutEqual(this double x, double y)
        {
            var epsilon = Math.Max(Math.Abs(x), Math.Abs(y)) * 1E-15;
            return Math.Abs(x - y) <= epsilon;
        }

        /// <summary>
        /// Determine if two doubles are within a tolerance of each other.
        /// </summary>
        /// <param name="x">This double floating point number.</param>
        /// <param name="y">The double floating point number to compare to.</param>
        /// <param name="tolerance">The tolerance that determines the range of acceptance.</param>
        /// <returns>True if the numbers are about equal, else false.</returns>
        public static bool AreWithinTolerance(this double x, double y, double tolerance)
        {
            return Math.Abs(x - y) <= tolerance;
        }

        /// <summary>
        /// Determine if two doubles are about equal.
        /// </summary>
        /// <param name="x">This double floating point number.</param>
        /// <param name="minimum">The minimum inclusive value in the range.</param>
        /// <param name="maximum">The maximum inclusive value in the range.</param>
        /// <returns>True if the numbers is in the specified range, else false.</returns>
        public static bool IsInRange(this double x, double minimum, double maximum)
        {
            return ((x >= minimum) && (x <= maximum));
        }
    }
}
