using System.Data.SqlClient;
using System.Linq;

namespace SI.Software.Databases.SQL
{
    /// <summary>
    /// Provides extension methods for the SqlConnectionStringBuilder class.
    /// </summary>
    public static class SqlConnectionStringBuilderExtentsions
    {
        /// <summary>
        /// Get the server.
        /// </summary>
        /// <param name="builder">The builder.</param>
        /// <returns>The server.</returns>
        public static string GetServer(this SqlConnectionStringBuilder builder)
        {
            return builder.DataSource.Split("\\".ToCharArray()).FirstOrDefault();
        }

        /// <summary>
        /// Get the instance.
        /// </summary>
        /// <param name="builder">The builder.</param>
        /// <returns>The instance.</returns>
        public static string GetInstance(this SqlConnectionStringBuilder builder)
        {
            return builder.DataSource.Split("\\".ToCharArray()).LastOrDefault();
        }
    }
}
