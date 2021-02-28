using System.Collections.Generic;
using C5;

namespace SI.Software.Tools.CustomConfiguration.TestConfiguration
{
    public interface IDatabaseConfigurationElement : IConfigurationElement
    {
        /// <summary>
        /// The SQL Server machine
        /// </summary>
        string Server                { get; }
        /// <summary>
        /// The SQL Server instance running on the Server - this is a service, 1 machine can have many instances,
        /// running different versions of software and hosting a set of databases
        /// </summary>
        string Instance              { get; }
        /// <summary>
        /// The database name, a SQL Server instance can run many databases
        /// </summary>
        string Database              { get; }
        /// <summary>
        /// The database type, e.g. 'Data Logging' or 'Pixl Tracking'
        /// </summary>
        string DatabaseType          { get; }
        /// <summary>
        /// Check the database state has not been changed by the test.
        /// </summary>
        bool? CheckDbState          { get; }
        /// <summary>
        /// Don't pre create in the test setup - this is relevant for method specific databases
        /// </summary>
        bool? DontCreate            { get; }
        /// <summary>
        /// Guarantee a new clean database
        /// </summary>
        bool? DropFirst             { get; }
        /// <summary>
        /// Drop after the test - redundant now??
        /// </summary>
        bool? DropAfter             { get; }
        /// <summary>
        /// Use the next 2 to specify the level of database data population
        /// control if the test db is to be populated with static test - default = true
        /// </summary>
        bool? PopulateStaticData    { get; }
        /// <summary>
        /// control if the test db is to be populated with dynamic test - default = true
        /// N.B. Cannot populate dynamic data if the static data has not been populated first (referential integrity)
        /// </summary>
        bool? PopulateDynamicData   { get; }
        /// <summary>
        /// Optional: a sequence of SQL script files used to create and or populate a database
        /// </summary>
        IEnumerable< string> ScriptFiles{ get; }
        /// <summary>
        /// Optional list of static data tables
        /// </summary>
        IEnumerable<string> StaticDataTables { get; }

        // Methods
        void GetDatabases(TreeSet<string> set);
    }
}