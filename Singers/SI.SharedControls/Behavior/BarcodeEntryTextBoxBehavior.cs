using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace SI.Software.SharedControls.Behavior
{
    /// <summary>
    /// Provides behavior for barcode entry text boxes.
    /// </summary>
    public static class BarcodeEntryTextBoxBehavior
    {
        #region StaticProperties

        /// <summary>
        /// Get the preamble (STX).
        /// </summary>
        private const char Preamble = (char)2;

        /// <summary>
        /// Get the postamble (EOT).
        /// </summary>
        private const char Postamble = (char)4;

        /// <summary>
        /// Occurs when barcode entry is finished.
        /// </summary>
        public static event RoutedEventHandler BarcodeEntryFinished;

        /// <summary>
        /// Occurs when barcode entry is started.
        /// </summary>
        public static event RoutedEventHandler BarcodeEntryStarted;

        /// <summary>
        /// Get or set a dictionary for containing the barcode receive states of text boxes.
        /// </summary>
        private static readonly Dictionary<TextBox, bool> IsReceivingBarcode = new Dictionary<TextBox, bool>(); 

        #endregion

        #region DependencyProperties

        /// <summary>
        /// Registers the BarcodeEntryTextBoxBehavior.ListenForBarcodeEntry property.
        /// </summary>
        public static readonly DependencyProperty ListenForBarcodeEntryProperty = DependencyProperty.RegisterAttached("ListenForBarcodeEntry", typeof(bool), typeof(BarcodeEntryTextBoxBehavior), new UIPropertyMetadata(OnListenForBarcodeEntryPropertyChanged));

        #endregion

        #region StaticMethods

        /// <summary>
        /// Get the ListenForBarcodeEntry property for a TextBox.
        /// </summary>
        /// <param name="o">The TextBox to get the property for.</param>
        /// <returns>True if the property is enabled, else false.</returns>
        public static bool GetListenForBarcodeEntry(TextBox o)
        {
            return (bool)o.GetValue(ListenForBarcodeEntryProperty);
        }

        /// <summary>
        /// Get the ListenForBarcodeEntry property for a TextBox.
        /// </summary>
        /// <param name="o">The TextBox to set the property on.</param>
        /// <param name="value">True to enable the property, else false.</param>
        public static void SetListenForBarcodeEntry(TextBox o, bool value)
        {
            o.SetValue(ListenForBarcodeEntryProperty, value);
        }

        #endregion

        #region PropertyChangedCallbacks

        private static void OnListenForBarcodeEntryPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var textBox = o as TextBox;
            if (textBox == null)
                return;

            var value = (bool)e.NewValue;

            if (value)
            {
                if (!IsReceivingBarcode.ContainsKey(textBox))
                    IsReceivingBarcode.Add(textBox, false);

                textBox.PreviewTextInput += TextBox_PreviewTextInput;
            }
            else
            {
                if (IsReceivingBarcode.ContainsKey(textBox))
                    IsReceivingBarcode.Remove(textBox);

                textBox.PreviewTextInput -= TextBox_PreviewTextInput;
            }
        }

        #endregion

        #region EventHandlers

        private static void TextBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            var key = ' ';

            if (e.Text.Length != 0)
                key = e.Text[0];
            else if (e.ControlText.Length != 0)
                key = e.ControlText[0];
            else if (e.SystemText.Length != 0)
                key = e.SystemText[0];

            var textBox = sender as TextBox;

            if (textBox == null)
                return;

            switch (key)
            {
                case (Preamble):

                    if (IsReceivingBarcode.ContainsKey(textBox))
                    {
                        IsReceivingBarcode[textBox] = true;
                        BarcodeEntryStarted?.Invoke(textBox, new RoutedEventArgs(e.RoutedEvent, textBox));
                    }

                    e.Handled = true;
                    break;

                case (Postamble):

                    if ((IsReceivingBarcode.ContainsKey(textBox)) && (IsReceivingBarcode[textBox]))
                    {
                        IsReceivingBarcode[textBox] = false;
                        BarcodeEntryFinished?.Invoke(textBox, new RoutedEventArgs(e.RoutedEvent, textBox));
                    }

                    e.Handled = true;
                    break;

                default:
                    break;
            }
        }

        #endregion
    }
}
