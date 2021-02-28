using System;
using System.Globalization;
using System.Windows.Data;

namespace RSS
{
    public class DoubleTemperatureToFormattedStringConverter : IValueConverter
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
            double d;
            if (!double.TryParse(value?.ToString() ?? string.Empty, out d))
                return value;

            int places;
            if (!int.TryParse(parameter?.ToString() ?? string.Empty, out places))
                places = 1;

            var rounded = Math.Round(d, places);

            if ((places > 0) && ((rounded % 1).AboutEqual(0d)))
                return rounded + ".0 °C";

            return rounded + " °C";
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
