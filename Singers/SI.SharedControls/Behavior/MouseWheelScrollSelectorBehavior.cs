using System;
using System.Windows;
using System.Windows.Controls.Primitives;
using System.Windows.Input;

namespace SI.Software.SharedControls.Behavior
{
    /// <summary>
    /// Provides a behavior for scrolling on MouseWheel events on a Selector.
    /// </summary>
    public static class MouseWheelScrollSelectorBehavior
    {
        #region DependencyProperties

        /// <summary>
        /// Registers the MouseWheelScrollListBoxBehavior.IsScrollOnMouseWheel property.
        /// </summary>
        public static readonly DependencyProperty IsScrollOnMouseWheelProperty = DependencyProperty.RegisterAttached("IsScrollOnMouseWheel", typeof(bool), typeof(MouseWheelScrollSelectorBehavior), new UIPropertyMetadata(OnIsScrollOnMouseWheelPropertyChanged));

        #endregion

        #region StaticMethods

        /// <summary>
        /// Get the IsScrollOnMouseWheel for a Selector.
        /// </summary>
        /// <param name="o">The Selector to get the property for.</param>
        /// <returns>True if the property is enabled, else false.</returns>
        public static bool GetIsScrollOnMouseWheel(Selector o)
        {
            return (bool)o.GetValue(IsScrollOnMouseWheelProperty);
        }

        /// <summary>
        /// Get the IsScrollOnMouseWheel for a Selector.
        /// </summary>
        /// <param name="o">The Selector to set the property on.</param>
        /// <param name="value">True to enable the property, else false.</param>
        public static void SetIsScrollOnMouseWheel(Selector o, bool value)
        {
            o.SetValue(IsScrollOnMouseWheelProperty, value);
        }

        #endregion

        #region PropertyChangedCallbacks

        private static void OnIsScrollOnMouseWheelPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var selector = o as Selector;
            if (selector == null)
                return;

            var value = (bool)e.NewValue;

            if (value)
                selector.MouseWheel += Selector_MouseWheel;
            else
                selector.MouseWheel -= Selector_MouseWheel;
        }

        #endregion

        #region EventHandlers

        private static void Selector_MouseWheel(object sender, MouseWheelEventArgs e)
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
