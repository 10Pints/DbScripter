using System;

namespace RSS
{
    /// <summary>
    /// Extension methods for float.
    /// </summary>
    public static class FloatExtensions
    {
        /// <summary>
        /// Determine if two floating point numbers are about equal.
        /// </summary>
        /// <param name="x">This floating point number.</param>
        /// <param name="y">The floating point number to compare to.</param>
        /// <returns>True if the numbers are about equal, else false.</returns>
        public static bool AboutEqual(this float x, float y)
        {
            var epsilon = Math.Max(Math.Abs(x), Math.Abs(y)) * 1E-15;
            return Math.Abs(x - y) <= epsilon;
        }

        /// <summary>
        /// Determine if two floating point numbers are within a tolerance of each other.
        /// </summary>
        /// <param name="x">This floating point number.</param>
        /// <param name="y">The floating point number to compare to.</param>
        /// <param name="tolerance">The tolerance that determines the range of acceptance.</param>
        /// <returns>True if the numbers are about equal, else false.</returns>
        public static bool AreWithinTolerance(this float x, float y, float tolerance)
        {
            return Math.Abs(x - y) <= tolerance;
        }

        /// <summary>
        /// Determine if two floats are about equal.
        /// </summary>
        /// <param name="x">This float floating point number.</param>
        /// <param name="minimum">The minimum inclusive value in the range.</param>
        /// <param name="maximum">The maximum inclusive value in the range.</param>
        /// <returns>True if the numbers is in the specified range, else false.</returns>
        public static bool IsInRange(this float x, float minimum, float maximum)
        {
            return ((x >= minimum) && (x <= maximum));
        }
    }
}
