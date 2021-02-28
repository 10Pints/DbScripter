using System;
using System.Globalization;
using System.Windows.Data;

namespace RSS
{
    public class TimeSpanToHHMMSSConverter : IValueConverter
    {
        #region Implementation of IValueConverter

        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            TimeSpan t;
            if (!TimeSpan.TryParse(value?.ToString() ?? string.Empty, out t))
                return value;

            return $"{(t.Hours < 10 ? "0" : string.Empty)}{t.Hours}:{(t.Minutes < 10 ? "0" : string.Empty)}{t.Minutes}:{(t.Seconds < 10 ? "0" : string.Empty)}{t.Seconds}";
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }

        #endregion
    }
}
