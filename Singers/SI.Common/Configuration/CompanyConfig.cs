namespace SI.Common.Configuration
{
    /// <summary>
    /// Provides common information on the company.
    /// </summary>
    public static class CompanyConfig
    {
        /// <summary>
        /// Get the company name.
        /// </summary>
        public const string CompanyName = "Singer Instruments";

        /// <summary>
        /// Get the formal company name.
        /// </summary>
        public const string CompanyNameLtd = "Singer Instrument Company Limited";

        /// <summary>
        /// Get a short version of the formal company name.
        /// </summary>
        public const string CompanyNameLtdShort = "Singer Instrument Co. Ltd.";

        /// <summary>
        /// Get the year.
        /// </summary>
        public const string Year = "2018";

        /// <summary>
        /// Get the company copyright.
        /// </summary>
        public const string Copyright = "Copyright © " + Year + " " + CompanyNameLtd;

        /// <summary>
        /// Get the company trademark.
        /// </summary>
        public const string Trademark = "";

        /// <summary>
        /// Get the company Uri.
        /// </summary>
        public const string CompanyUri = "http://www.singerinstruments.com";
    }
}
