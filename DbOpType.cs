/*
 This file contains the DbOpType enumeration used by the SqlTrackingProvider
 */

using SI.Common;

namespace SI.Software.Databases.SQL
{
    /// <summary>
    ///  script is used by the SqlTrackingProvider to determine the type of script to run
    /// </summary>
    public enum DbOpType
    {
        [EnumAlias("Undefined")]
        Undefined = 0,
        [EnumAlias("Drop Database")]
        DropDatabase,
        [EnumAlias("Drop Schema")]
        DropSchema,
        [EnumAlias("Drop Procedures")]
        DropProcedures,
        [EnumAlias("Drop Tables")]
        DropTables,
        [EnumAlias("Drop Static Data")]
        DropStaticData,

        [EnumAlias("Create Database")]
        CreateDatabase,
        [EnumAlias("Create Schema")]
        CreateSchema,
        [EnumAlias("Create Tables")]
        CreateTables,
        [EnumAlias("Create Procedures")]
        CreateProcedures,
        [EnumAlias("Create Static Data")]
        CreateStaticData,
//        [EnumAlias("Create All")]
//        CreateAll,
        [EnumAlias("Export Static Data")]
        ExportStaticData,
        [EnumAlias("Export Dynamic Data")]
        ExportDynamicData,
        [EnumAlias("Count of enumerations")]
        Count
    }
}
