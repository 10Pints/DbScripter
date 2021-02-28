using System.Windows;

namespace SI.Software.SharedControls.Behavior
{
    /// <summary>
    /// Provides behavior for scene situations.
    /// </summary>
    public static class SceneSituationBehavior
    {
        #region DependencyProperties

        /// <summary>
        /// Registers the SceneSituationBehavior.Situation property.
        /// </summary>
        public static readonly DependencyProperty SituationProperty = DependencyProperty.RegisterAttached("Situation", typeof(SceneSituation), typeof(SceneSituationBehavior));

        #endregion

        #region StaticMethods

        /// <summary>
        /// Get the Situation property for a FrameworkElement.
        /// </summary>
        /// <param name="o">The FrameworkElement to get the property for.</param>
        /// <returns>The situation.</returns>
        public static SceneSituation GetSituation(FrameworkElement o)
        {
            return (SceneSituation)o.GetValue(SituationProperty);
        }

        /// <summary>
        /// Get the Situation property for a FrameworkElement.
        /// </summary>
        /// <param name="o">The FrameworkElement to set the property on.</param>
        /// <param name="value">The situation.</param>
        public static void SetSituation(FrameworkElement o, SceneSituation value)
        {
            o.SetValue(SituationProperty, value);
        }

        #endregion
    }
}
