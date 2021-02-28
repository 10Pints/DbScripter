using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows;
using SI.Software.SharedControls.Annotations;

namespace SI.Software.SharedControls
{
    /// <summary>
    /// Represents a view model as part of the MVVM architectural pattern.
    /// </summary>
    public class ViewModel : DependencyObject, IViewModel, INotifyPropertyChanged
    {
        #region Fields

        private bool isBusy;

        #endregion

        #region Properties

        /// <summary>
        /// Get or set if this is busy.
        /// </summary>
        public bool IsBusy
        {
            get { return isBusy; }
            set
            {
                isBusy = value;
                OnPropertyChanged();
            }
        }

        /// <summary>
        /// Occurs when a property is changed.
        /// </summary>
        public event PropertyChangedEventHandler PropertyChanged;

        #endregion

        #region Methods

        /// <summary>
        /// Handle property changes.
        /// </summary>
        /// <param name="propertyName">The name of the property that changed.</param>
        [NotifyPropertyChangedInvocator]
        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        #endregion
    }
}
