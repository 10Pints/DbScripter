using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace SI.Software.SharedControls.ValueConverters
{
    /// <summary>
    /// Converter for converting between a Boolean value and a System.Windows.Visibility. If the value is true Visibility.Visible is returned, else Visibility.Collapsed, unless a boolean is provided as the parameter - if it is and its value matches the value argument Visibility.Visible is returned, else Visibility.Collapsed
    /// </summary>
    [ValueConversion(typeof(bool), typeof(Visibility))]
    public class BooleanToVisibilityCollapsedConverter : IValueConverter
    {
        #region IValueConverter Members

        /// <summary>
        /// Converts a value. 
        /// </summary>
        /// <returns>
        /// A converted value. If the method returns null, the valid null value is used.
        /// </returns>
        /// <param name="value">The value produced by the binding source.</param><param name="targetType">The type of the binding target property.</param><param name="parameter">The converter parameter to use.</param><param name="culture">The culture to use in the converter.</param>
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            bool val;
            if (!bool.TryParse(value?.ToString() ?? string.Empty, out val))
                return value;

            bool param;
            if (!bool.TryParse(parameter?.ToString() ?? string.Empty, out param))
                return val ? Visibility.Visible : Visibility.Collapsed;

            return val == param ? Visibility.Visible : Visibility.Collapsed;
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
            try
            {
                if (value == null) return false;

                var v = (Visibility)Enum.Parse(typeof(Visibility), value.ToString());

                bool param;
                if ((parameter != null) && (bool.TryParse(parameter.ToString(), out param)))
                    return v == Visibility.Visible ? param : !param;

                return v == Visibility.Visible;
            }
            catch (Exception)
            {
                return false;
            }
        }

        #endregion
    }
}
