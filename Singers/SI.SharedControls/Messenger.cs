using System.ComponentModel.Composition;
using Prism.Events;

namespace SI.Software.SharedControls
{
    /// <summary>
    /// Event aggregator is used intercommunication of components.
    /// </summary>
    [Export(typeof(IEventAggregator))]
    public class Messenger : EventAggregator
    {
    }
}
