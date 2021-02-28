using System;
using System.Globalization;
using System.Windows.Data;

namespace RSS
{
    public class NormalisedDoubleConverter : IValueConverter
    {
        #region Implementation of IValueConverter

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            double v, p;

            if (!double.TryParse(value?.ToString() ?? string.Empty, out v))
                return value;

            if (!double.TryParse(parameter?.ToString() ?? string.Empty, out p))
                return value;

            return (1d / p) * v;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }

        #endregion
    }
}
