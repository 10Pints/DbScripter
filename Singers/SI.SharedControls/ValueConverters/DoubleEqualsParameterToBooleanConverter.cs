﻿using System;
using System.Globalization;
using System.Windows.Data;

namespace SI.Software.SharedControls.ValueConverters
{
    /// <summary>
    /// Converts between a double and a boolean. If the double provided as the value argument is equal to the double provided as the parameter argument true is returned, else false.
    /// </summary>
    [ValueConversion(typeof(double), typeof(bool))]
    public class DoubleEqualsParameterToBooleanConverter : IValueConverter
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
            if (!double.TryParse(value?.ToString(), out v))
                return false;
            double p;
            if (!double.TryParse(parameter?.ToString(), out p))
                return false;

            return Math.Abs(v - p) < 0.000000000000001;
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
