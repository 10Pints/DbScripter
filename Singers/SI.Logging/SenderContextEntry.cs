using System;

namespace SI.Logging
{
    /// <summary>
    /// Represents a structure for holding a sender, cntext and an entry.
    /// </summary>
    public struct SenderContextEntry
    {
        #region Properties

        /// <summary>
        /// Get or set the date/time at which this struct was created.
        /// </summary>
        public DateTime DateTime { get; set; }

        /// <summary>
        /// Get or set the sending object.
        /// </summary>
        public object Sender { get; set; }

        /// <summary>
        /// Get or set the contextual object.
        /// </summary>
        public object Context { get; set; }

        /// <summary>
        /// Get or set the entry object.
        /// </summary>
        public object Entry { get; set; }

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the SenderContextEntry struct.
        /// </summary>
        /// <param name="entry">The entry object.</param>
        public SenderContextEntry(object entry)
        {
            DateTime = DateTime.Now;
            Sender = null;
            Context = null;
            Entry = entry;
        }

        /// <summary>
        /// Initializes a new instance of the SenderContextEntry struct.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The contextual object.</param>
        /// <param name="entry">The entry object.</param>
        public SenderContextEntry(object sender, object context, object entry)
        {
            DateTime = DateTime.Now;
            Sender = sender;
            Context = context;
            Entry = entry;
        }

        #endregion

        #region Overrides of ValueType

        /// <summary>
        /// Returns the fully qualified type name of this instance.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.String"/> containing a fully qualified type name.
        /// </returns>
        public override string ToString()
        {
            var padding = string.Empty;

            // ReSharper disable once UseStringInterpolation
            var dateTime = string.Format("{0}/{1}{2}/{3}{4} {5}{6}:{7}{8}:{9}{10}.{11}{12}{13}: ",
                DateTime.Year,
                DateTime.Month < 10 ? "0" : padding,
                DateTime.Month,
                DateTime.Day < 10 ? "0" : padding,
                DateTime.Day,
                DateTime.Hour < 10 ? "0" : padding,
                DateTime.Hour,
                DateTime.Minute < 10 ? "0" : padding,
                DateTime.Minute,
                DateTime.Second < 10 ? "0" : padding,
                DateTime.Second,
                DateTime.Millisecond < 100 ? "0" : padding,
                DateTime.Millisecond < 10 ? "0" : padding,
                DateTime.Millisecond);

            return $"{dateTime}: {Sender}{(Sender != null ? ": " : string.Empty)}{Context}{(Context != null ? ": " : string.Empty)}{Entry}";
        }

        #endregion
    }
}
