using System;
using System.Globalization;
using System.Windows.Data;

namespace SI.Software.SharedControls.ValueConverters
{
    public class DoubleToStringConverterWithPostfix : IValueConverter
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
            var s = value?.ToString() ?? string.Empty;
            if (parameter == null)
                return s;

            return s + parameter;
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
            var v = value?.ToString() ?? string.Empty;
            var p = parameter?.ToString() ?? string.Empty;
            double doubleValue;

            if ((!string.IsNullOrEmpty(p)) && (v.EndsWith(p)))
                v = v.Remove(v.Length - p.Length - 1);

            if (double.TryParse(v, out doubleValue))
                return doubleValue;

            return value;
        }

        #endregion
    }
}
