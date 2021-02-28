using System;
using System.Globalization;
using System.Windows.Data;

namespace SI.Software.SharedControls.ValueConverters
{
    /// <summary>
    /// Converts between a double and a double in a rounded form. The precision can be specified as the parameter, else 3 is used.
    /// </summary>
    [ValueConversion(typeof(double), typeof(double))]
    public class DoubleRoundingConverter : IValueConverter
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
            double val;

            if (!double.TryParse(value?.ToString() ?? string.Empty, out val))
                return 0d;

            int param;

            if ((parameter == null) || (!int.TryParse(parameter.ToString(), out param)))
                param = 3;

            return Math.Round(val, param);
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
            double val;
            return double.TryParse(value?.ToString() ?? string.Empty, out val) ? val : value;
        }

        #endregion
    }
}
