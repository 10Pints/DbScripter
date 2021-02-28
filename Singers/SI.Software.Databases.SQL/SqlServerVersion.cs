using SI.Common;

namespace SI.Software.Databases.SQL
{
    public enum SqlServerVersion
    {
        /// <summary>
        /// None.
        /// </summary>
        [EnumAlias("Undefined")]
        Undefined = 0,

        /// <summary>
        /// version 2016 13.0.4210.6
        /// </summary>
        [EnumAlias("13.0.4210.6")]
        Sql2016,

        /// <summary>
        /// version 2017 14.0.1000.169
        /// </summary>
        [EnumAlias("14.0.1000.169")]
        Sql2017,

        /// <summary>
        /// version 2017 14.0.1000.169
        /// </summary>
        [EnumAlias("14.0.2002.14")]
        Sql2017_9,
    }
}
