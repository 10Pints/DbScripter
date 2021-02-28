using System.Windows.Controls;
using System.Windows.Input;

namespace SI.Software.SharedControls.Validation
{
    /// <summary>
    /// Static class for processing input validation for hex input textboxes.
    /// </summary>
    public static class HexTextBoxValidation
    {
        /// <summary>
        /// Handle previewing text input events.
        /// </summary>
        /// <param name="textBox">The sending TextBox.</param>
        /// <param name="e">TextCompositionEventArgs event args generated for the PreviewTextInput event.</param>
        public static void OnPreviewTextInput(TextBox textBox, ref TextCompositionEventArgs e)
        {
            // validate - get binding expression
            var bE = textBox?.GetBindingExpression(TextBox.TextProperty);

            // if no binding expression then return
            if (bE == null) return;

            // check for error
            if (bE.HasError)
            {
                // handled - stop input
                e.Handled = true;
            }
        }

        /// <summary>
        /// Handle text changed events.
        /// </summary>
        /// <param name="textBox">The sending TextBox.</param>
        /// <param name="e">TextCompositionEventArgs event args generated for the PreviewTextInput event.</param>
        public static void OnTextChanged(TextBox textBox, ref TextChangedEventArgs e)
        {
            // validate - get binding expression
            var bE = textBox?.GetBindingExpression(TextBox.TextProperty);

            // if a binding expression then update binding
            bE?.UpdateSource();
        }
    }
}
