using System;
using System.Globalization;
using System.Windows.Data;

namespace RSS
{
    public class BuildServerVersionToStringConverterWithResolvedLeadingZeros : IValueConverter
    {
        #region Methods

        /// <summary>
        /// Get a zero padded int.
        /// </summary>
        /// <param name="i">The int.</param>
        /// <param name="length">The length.</param>
        /// <returns>The padded int.</returns>
        private string Get0PaddedInt(int i, int length)
        {
            var iAsString = i.ToString();

            for (var j = iAsString.Length; j < length; j++)
                iAsString = "0" + iAsString;

            return iAsString;
        }

        #endregion

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
            var version = value as Version;

            if (version == null)
                return value;

            // expected in x.x.MMDD.B
            return $"{Get0PaddedInt(version.Major, 1)}.{Get0PaddedInt(version.Minor, 1)}.{Get0PaddedInt(version.Build, 4)}.{Get0PaddedInt(version.Revision, 1)}";
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
