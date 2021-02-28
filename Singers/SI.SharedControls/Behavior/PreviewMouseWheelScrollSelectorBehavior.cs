using System;
using System.Windows;
using System.Windows.Controls.Primitives;
using System.Windows.Input;

namespace SI.Software.SharedControls.Behavior
{
    /// <summary>
    /// Provides a behavior for scrolling on PreviewMouseWheel events on a Selector.
    /// </summary>
    public static class PreviewMouseWheelScrollSelectorBehavior
    {
        #region DependencyProperties

        /// <summary>
        /// Registers the PreviewMouseWheelScrollListBoxBehavior.IsScrollOnPreviewMouseWheel property.
        /// </summary>
        public static readonly DependencyProperty IsScrollOnPreviewMouseWheelProperty = DependencyProperty.RegisterAttached("IsScrollOnPreviewMouseWheel", typeof(bool), typeof(PreviewMouseWheelScrollSelectorBehavior), new UIPropertyMetadata(OnIsScrollOnPreviewMouseWheelPropertyChanged));

        #endregion

        #region StaticMethods

        /// <summary>
        /// Get the IsScrollOnMouseWheel property for a Selector.
        /// </summary>
        /// <param name="o">The Selector to get the property for.</param>
        /// <returns>True if the property is enabled, else false.</returns>
        public static bool GetIsScrollOnPreviewMouseWheel(Selector o)
        {
            return (bool)o.GetValue(IsScrollOnPreviewMouseWheelProperty);
        }

        /// <summary>
        /// Get the IsScrollOnMouseWheel property for a Selector.
        /// </summary>
        /// <param name="o">The Selector to set the property on.</param>
        /// <param name="value">True to enable the property, else false.</param>
        public static void SetIsScrollOnPreviewMouseWheel(Selector o, bool value)
        {
            o.SetValue(IsScrollOnPreviewMouseWheelProperty, value);
        }

        #endregion

        #region PropertyChangedCallbacks

        private static void OnIsScrollOnPreviewMouseWheelPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var selector = o as Selector;
            if (selector == null)
                return;

            var value = (bool)e.NewValue;

            if (value)
                selector.PreviewMouseWheel += Selector_PreviewMouseWheel;
            else
                selector.PreviewMouseWheel -= Selector_PreviewMouseWheel;
        }

        #endregion

        #region EventHandlers

        private static void Selector_PreviewMouseWheel(object sender, MouseWheelEventArgs e)
        {
            var selector = sender as Selector;

            if (selector == null)
                return;

            if (selector.Items.Count == 0)
                return;

            if (!selector.IsEnabled)
                return;

            int index;

            if (e.Delta > 0)
                index = Math.Max(0, selector.SelectedIndex - 1);
            else
                index = Math.Min(selector.Items.Count - 1, selector.SelectedIndex + 1);

            selector.SelectedItem = selector.Items[index];
        }

        #endregion
    }
}
