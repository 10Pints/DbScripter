using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace SI.Software.SharedControls.Behavior
{
    /// <summary>
    /// Provides behavior for touch focus text boxes.
    /// </summary>
    public static class TouchFocusTextBoxBehavior
    {
        #region DependencyProperties

        /// <summary>
        /// Registers the TouchFocusTextBoxBehaviour.IsSelectAllWhenGotFocus property.
        /// </summary>
        public static readonly DependencyProperty IsSelectAllWhenGotFocusProperty = DependencyProperty.RegisterAttached("IsSelectAllWhenGotFocus", typeof(bool), typeof(TouchFocusTextBoxBehavior), new UIPropertyMetadata(OnIsSelectAllWhenGotFocusPropertyChanged));

        #endregion

        #region StaticMethods

        /// <summary>
        /// Get the IsSelectAllWhenGotFocus property for a TextBox.
        /// </summary>
        /// <param name="o">The TextBox to get the property for.</param>
        /// <returns>True if the property is enabled, else false.</returns>
        public static bool GetIsSelectAllWhenGotFocus(TextBox o)
        {
            return (bool)o.GetValue(IsSelectAllWhenGotFocusProperty);
        }

        /// <summary>
        /// Get the IsSelectAllWhenGotFocus property for a TextBox.
        /// </summary>
        /// <param name="o">The TextBox to set the property on.</param>
        /// <param name="value">True to enable the property, else false.</param>
        public static void SetIsSelectAllWhenGotFocus(TextBox o, bool value)
        {
            o.SetValue(IsSelectAllWhenGotFocusProperty, value);
        }

        #endregion

        #region PropertyChangedCallbacks

        private static void OnIsSelectAllWhenGotFocusPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var textBox = o as TextBox;
            if (textBox == null)
                return;

            var value = (bool)e.NewValue;

            if (value)
            {
                textBox.GotFocus += TextBox_GotFocus;
                textBox.PreviewMouseDown += TextBox_PreviewMouseDown;
            }
            else
            {
                textBox.GotFocus -= TextBox_GotFocus;
                textBox.PreviewMouseDown -= TextBox_PreviewMouseDown;
            }
        }

        #endregion

        #region EventHandlers

        private static void TextBox_GotFocus(object sender, RoutedEventArgs e)
        {
            ((TextBox)sender).SelectAll();
        }

        private static void TextBox_PreviewMouseDown(object sender, MouseButtonEventArgs e)
        {
            var textBox = (TextBox)sender;
            if (!textBox.IsKeyboardFocusWithin)
            {
                textBox.Focus();
                e.Handled = true;
            }
        }

        #endregion
    }
}
