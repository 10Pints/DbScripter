using System.ComponentModel;

namespace SI.Software.SharedControls
{
    /// <summary>
    /// Represents any object that provides view model functionality.
    /// </summary>
    public interface IViewModel
    {
        /// <summary>
        /// Get or set if this is busy.
        /// </summary>
        bool IsBusy { get; set; }

        /// <summary>
        /// Occurs when a property is changed.
        /// </summary>
        event PropertyChangedEventHandler PropertyChanged;
    }
}
