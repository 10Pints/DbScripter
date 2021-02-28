using System;
using System.Globalization;
using System.Windows.Data;

namespace SI.Software.SharedControls.ValueConverters
{
    public class NormalisedDoubleToPercentageStringConverter : IValueConverter
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
            double normalised;
            if (!double.TryParse(value?.ToString() ?? string.Empty, out normalised))
                return 0d;

            int decimalPlaces;
            if (!int.TryParse(parameter?.ToString() ?? string.Empty, out decimalPlaces))
                decimalPlaces = 0;

            return Math.Round(normalised * 100d, decimalPlaces) + "%";
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
            var stringValue = value?.ToString() ?? string.Empty;

            stringValue = stringValue.Replace("%", string.Empty);

            double percentage;
            if (!double.TryParse(stringValue, out percentage))
                return 0d;

            return percentage / 100d;
        }

        #endregion
    }
}
