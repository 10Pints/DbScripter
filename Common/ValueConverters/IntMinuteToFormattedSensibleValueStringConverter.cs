using System;
using System.Globalization;
using System.Windows.Data;

namespace RSS
{
    public class IntMinuteToFormattedSensibleValueStringConverter : IValueConverter
    {
        #region Implementation of IValueConverter

        /// <summary>
        /// Converts a value. 
        /// </summary>
        /// <returns>
        /// A converted value. If the method returns null, the valid null value is used.
        /// </returns>
        /// <param name="value">The value produced by the binding source.</param><param name="targetType">The type of the binding target property.</param><param name="parameter">The converter parameter to use.</param><param name="culture">The culture to use in the converter.</param>
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            int i;
            if (!int.TryParse(value?.ToString() ?? string.Empty, out i))
                return value;

            var timeSpan = TimeSpan.FromMinutes(i);

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

        /// <summary>
        /// Converts a value. 
        /// </summary>
        /// <returns>
        /// A converted value. If the method returns null, the valid null value is used.
        /// </returns>
        /// <param name="value">The value that is produced by the binding target.</param><param name="targetType">The type to convert to.</param><param name="parameter">The converter parameter to use.</param><param name="culture">The culture to use in the converter.</param>
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }

        #endregion
    }
}
