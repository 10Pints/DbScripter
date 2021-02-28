
namespace SI.Software.TestHelpers.Database.SQL
{
    /// <summary>
    /// Represents a basic type for most tables - as most data requires a unique computer friendly id and human friendly name.
    /// This type is intended to be used in generic test solutions using reflection and database tables.
    /// </summary>
    public class BasicDbTable
    {
        /// <summary>
        /// Get or set the ID.
        /// </summary>
        public int      id   { get; set; }
        /// <summary>
        /// Get or set the name.
        /// </summary>
        public string   name { get; set; }
    }
}
