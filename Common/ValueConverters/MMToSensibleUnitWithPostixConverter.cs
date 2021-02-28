using System;
using System.Globalization;
using System.Windows.Data;

namespace RSS
{
    public class MMToSensibleUnitWithPostixConverter : IValueConverter
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
            double v;
            if (!double.TryParse(value?.ToString() ?? string.Empty, out v))
                return value;

            var absValue = Math.Abs(v);
            if (absValue < 10)
                return $"{Math.Round(v, 1)}mm";
            if (absValue < 1000)
                return $"{Math.Round(v / 10, 1)}cm";

            return $"{Math.Round(v / 1000, 1)}m";
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
