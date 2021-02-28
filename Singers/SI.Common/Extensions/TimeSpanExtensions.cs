using System;

namespace SI.Common.Extensions
{
    /// <summary>
    /// Extension methods for TimeSpan.
    /// </summary>
    public static class TimeSpanExtensions
    {
        /// <summary>
        /// Format this value and return it as a string.
        /// </summary>
        /// <param name="timeSpan">The TimeSpan.</param>
        /// <returns>The formatted string.</returns>
        public static string ToFormattedString(this TimeSpan timeSpan)
        {
            var totalMinutes = (int)timeSpan.TotalMinutes;

            if (totalMinutes > 60)
            {
                var hours = (int)Math.Floor(timeSpan.TotalMinutes / 60d);
                var minutes = (int)(timeSpan.TotalMinutes % 60);

                if (minutes > 0)
                    return $"{hours} {(hours != 1 ? "hrs" : "hr")}, {minutes} {(minutes != 1 ? "mins" : "min")}";

                return $"{hours} {(hours != 1 ? "hrs" : "hr")}";
            }

            if (totalMinutes > 1)
                return totalMinutes + " mins";

            if (totalMinutes == 1)
                return "1 min";

            return "< 1 min";
        }
    }
}
