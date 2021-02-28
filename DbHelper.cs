// required for: ServerConnection class:  Microsoft.SqlServer.ConnectionInfo v14.100.0.0
// Assembly Microsoft.SqlServer.Smo, Version=14.100.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91
// Required for Microsoft.SqlServer.Management.Smo.Server class

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.Composition;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;
using SI.Common;
using SI.Common.Extensions;
using SI.Logging;
using SI.Logging.LogUtilities;
using SI.Logging.Providers.log4net;
using SI.Software.SharedControls.MEF;
namespace SI.Software.Databases.SQL
{
    /// <summary>
    /// This class provides general DB support like create database
    /// See also DbContextExtions calss for EF support and DbTestHelper for test database support
    /// 
    /// It contains the following methods and support:
    /// Standard datbase error message strings
    /// Standard script file paths
    /// Standard App config database related key names
    /// Standard substitution tags like DB_NAME that are to be substiuted in SQL string with the real name before the SQL is executed
    /// 
    /// The common database name, instance as sever names
    /// ScriptMap                           A map of Db operation type to script file name used to perform the operation
    /// 
    /// Public methods:
    /// Constrcutor                         Registers the Logger and gets an instance of the logger and set the appconfig  EfConnectionStringConfigKey - used to determine whch connection string to use for the EF model
    /// CreateConnectionStringBuilder       Creates SqlConnectionStringBuilder from a connection string - handles (LocalDb)
    /// CreateDatabase                      Creates a new database
    /// CreateDatabaseAndPopulateStaticData Producing a "Good to go" database for use. Clean populated with the standard static data and no dynamic data
    /// DatabaseExists                      Checks the database exsists - returns boolean
    /// DropDatabase                        Drops the database
    /// EnsureDatabaseExists                Ensure the database exists optionally dropping it and recreating it first
    /// ExecuteScalarScript T               Executes the SQL and returns a single value - being the first column of the first row - Template defines the return type
    /// FindAndReplaceTagsInScript          Substitutes tags in script with values based on the expected set for the operation
    /// FindAndReplaceTagInScript           Called by the above to replace 1 tag/value pair
    /// GetAndSubstituteConnectionString    Returns the Standard connection string substituted with the database name, server, instance
    /// GetAndSubstituteEfConnectionString  Returns the Entitiy Framework connection string substituted with the database name, server, instance
    /// GetConnectionString                 Creates a connection string based on the supplied parameters and the configuration
    /// GetCountFromWhereClause                            Gets the row count from a table - can supply a filter
    /// GetConnectionStringBuilderFromConfig Creates an SqlConnectionStringBuilder from the application configuration and optional params
    /// GetDatabaseNameFromConfig           Gets the datbase name from configuration app settings section
    /// GetDatabaseRootDirFromConfig        Gets the directory for the database files like the .mdf from the configuration
    /// GetDbType                           Maps a .Net data type to the equivalent SqlDbType
    /// GetDbVersion                        Returns the SQL Server Database Engine product version as a string
    /// GetIndexes                          Returns set of indexes for 1 or more tables as specified
    /// GetIndexColumns                     Lists columns for 1 or more indexes of 1 or more tables
    /// GetInstanceNameFromConfig           Gets the instance name from the configuration app settings section
    /// GetServerNameFromConfig             Gets the server name from the configuration app settings section
    /// GetSimpleConnectionStringFromConfig Returns the "SqlConnectionString" connection string from app configuration
    /// GetScriptFileName                   returns the standard script for the operation type - may contain tags
    /// GetScriptText                       Returns the text from the scriptFileName file from the ScriptDir directory
    /// GetUniqueKey                        Returns the first Unique Key definition found that fits the  data as a Data Table
    /// IsDbStringType                      Checks if a DbType is a DbType
    /// ProcessScript(opType)               Runs the SQL script associated with the operation type
    /// ProcessScript(dbnm,filePath,tv map) Runs a SQL script file against the database, first replacing any supplied tag with thier assciated values
    /// RemoveComments                      Removes -- and /**/ type comments from SQL
    /// RunSqlScript                        Runs the supplied sql script text optionally taking db name (and the script file path for debugging purposes)
    /// RunStoredProcedure.                 Runs a stored procedure passing a set of parameters, returning a data set
    /// SubstituteDbNameTag                 Substitutes the DB_NAME tag in the supplied text
    /// SubstituteTags                      Replaces as sequence of tag->value pairs in order - allows tags to replaced by 1 or more other tags
    /// SwitchDatabase                      Changes the database context, even if already open, defaults taken from configuration
    /// </summary>
    public class DbHelper
    {
        #region private fields

        // Backing field
        private static string _databaseRootDir;
        #endregion

        #region protected properties

        public string DatabaseName
        {
            get;
            set;
        }

        #endregion

        #region public fields

        // Standard error messages
        public const string PkViolationMsg                          = "Violation of PRIMARY KEY constraint";
        public const string DuplicateKeyMsg                         = "Cannot insert duplicate key";
        public const string FkViolationMsg                          = "The INSERT statement conflicted with the FOREIGN KEY constraint";
        public const string CheckConstraintViolationMsg             = "The INSERT statement conflicted with the CHECK constraint";
        public const string NullColumnErrorMsg                      = "column does not allow nulls";
        public const string NullColumnError2Msg                     = "Cannot insert the value NULL into column";
        public const string RequiredFieldMissingMsg                 = "field is required";
        public const string TruncatedDataMsg                        = "String or binary data would be truncated";

        public const string RootDirNotDefinedErrorMsg               = "ProcessScript: root directory must be defined at this point";
        public const string ScriptFileNotFoundMsg                   = "Script file not found:";

        #region Script Template File Names
        public const string CreateDatabaseTemplateFileName          = "create database template.sql";
        public const string CreateSchemaTemplateFileName            = "create schema template.sql";
        public const string PopulateStaticDataFileName              = "populate static data template.sql";
        public const string CreateStandardStoredProceduresTemplateFileName = "create standard stored procedures template.sql";
        public const string CreateStoredProceduresTemplateFileName = "create stored procedures template.sql";
        public const string CreateTablesTemplateFileName            = "create tables template.sql";
        public const string DropDatabaseTemplateFileName            = "drop database template.sql";
        public const string DropStoredProceduresTemplateFileName    = "drop stored procedures template.sql";
        public const string DropTablesTemplateFileName              = "drop tables template.sql";
        #endregion

        public const string DataSourceNotFoundMsg                   = "Data Source not set";
        public const string DbNameNotSpecifiedMsg                   = "Database name not specified";
        public const string ServerNameNotSpecifiedMsg               = "Server name not specified";
        public const string InstanceNameNotSpecifiedMsg             = "Instance name not specified";
        public const string TrustedConnectionString                 = "Integrated Security=True";

        public static string CreateDatabaseTemplateFilePath         { get; set; } = $".\\Scripts\\{CreateDatabaseTemplateFileName}";

        public static string CreateStandardSchemaTemplateFilePath   { get; set; } = $".\\Scripts\\{CreateStandardStoredProceduresTemplateFileName}";
        public static string CreateSchemaTemplateFilePath           { get; set; } = $".\\Scripts\\{CreateSchemaTemplateFileName}";
        public static string CreateStaticDataTemplateFilePath       { get; set; } = $".\\Scripts\\{PopulateStaticDataFileName}";
        private static string DropDatabaseTemplateFilePath          { get; set; } = $".\\Scripts\\{DropDatabaseTemplateFileName}";
        //private static string CreateStandardStoredProceduresTemplateFilePath { get; set; } = $".\\Scripts\\{CreateStandardStoredProceduresTemplateFileName}";

        #region Configuration settings key names
        public const string EfConnectionStringKeyName     = "EFConnectionStringKey";
        public const string ServerKey                     = "Server";
        public const string InstanceKey                   = "Instance";
        public const string DatabaseNameKey               = "DatabaseName";
        public  const string SqlConnectionStringConfigKey = "SqlConnectionString";
        public static string EfConnectionStringConfigKey { get; set; } //this is specific to the EF entities model
        private const string DatabaseRootDirKey           = "DatabaseRootDir";
        #endregion
        /// <summary>
        /// Keys to replace with specifics in the generic script templates
        /// </summary>
        // ReSharper disable once InconsistentNaming
        public const string DbNameTag = "<DB_NAME>";

        // ReSharper disable once InconsistentNaming
        public const string DbPathTag = "<PATH_TAG>";

        #endregion

        #region public properties

        /// <summary>
        /// Get or set the log provider.
        /// </summary>
        [Import(typeof(ILogProvider))]
        public ILogProvider LogProvider { get; set; }

        // Used to ensure we dont delete the configuration dagtabase inadvertantly
        public static bool ChkDbNotTheConfigurationDb { get; set; } = false;

        /// <summary>
        /// Maps db operation type to script to run for this op type
        /// Used in Pixl as at 02-NOV-2018
        /// </summary>
        public Dictionary<DbOpType, Dictionary<string, string>> ScriptTags { get; set; } = new Dictionary<DbOpType, Dictionary<string, string>>();

        /// <summary>
        /// The SQL server data source like  ./SqlExpress OR {MACHINE NAME}\{INSTANCE NAME}
        /// 
        /// Is dependent on server name
        /// </summary>
        public static string DataSource => $"{ServerName}\\{Instance}";

        public static string Instance => GetInstanceNameFromConfig();

        // Backing field
        //private string _serverName;

        /// <summary>
        /// SQL Server (machine) hosting the instance of SQL server hosting the SQL database to connect to 
        /// </summary>
        public static string ServerName => GetServerNameFromConfig();

        /// <summary>
        /// Root directory - the database files will be placed here
        /// get POSTCONDITION: returns non empty string if intitially null sources fron AppConfig settings
        /// key="DatabaseRootDir"
        /// </summary>
        public static string DatabaseRootDir
        {
            get
            {
                if (string.IsNullOrEmpty(_databaseRootDir))
                    DatabaseRootDir =  GetDatabaseRootDirFromConfig();

                return _databaseRootDir;
            }

            set
            {
                if (value == null)
                {
                    _databaseRootDir = null;
                }
                else
                {
                    _databaseRootDir = Path.GetFullPath(value);
                    Utils.Assertion(Directory.Exists(_databaseRootDir), $"[{_databaseRootDir}] is not a valid directory");
                }
            }
        }

        /// <summary>
        /// Relative location of the SQL script files
        /// </summary>
        public static string ScriptDir => ".\\Scripts";

        /// <summary>
        /// Maps db operation type to script to run for this op type
        /// </summary>
        public Dictionary<DbOpType, string> ScriptMap { get; set; } = new Dictionary<DbOpType, string>()
        {
            { DbOpType.CreateDatabase,      CreateDatabaseTemplateFileName },
            { DbOpType.CreateSchema,        CreateSchemaTemplateFileName },
            { DbOpType.CreateTables,        CreateTablesTemplateFileName },
            { DbOpType.CreateProcedures,    CreateStoredProceduresTemplateFileName },
            { DbOpType.CreateStaticData,    PopulateStaticDataFileName },
            { DbOpType.DropDatabase,        DropDatabaseTemplateFileName },
            { DbOpType.DropProcedures,      DropStoredProceduresTemplateFileName },
            { DbOpType.DropTables,          DropTablesTemplateFileName },
        };

        #endregion


        #region public methods

        /// <summary>
        /// Standard constructor, ensures MEF components initialised and 
        /// gets the default Data Source from App
        /// </summary>
        public DbHelper()
        {
            ServiceLocator.Instance.Register(typeof(ILogProvider).Assembly);
            ServiceLocator.Instance.Register(typeof(Log4NetLogProvider).Assembly);

            // Get the MEF components: LogProvider
            LogProvider = ServiceLocator.Instance.ResolveByType<ILogProvider>();
            var configName = ConfigurationManager.AppSettings["Name"] ?? "Unnamed app config";
            EfConnectionStringConfigKey = ConfigurationManager.AppSettings[EfConnectionStringKeyName];
            Utils.Assertion(EfConnectionStringConfigKey != null, $"EFConnectionStringKey not found in app config Name={configName}");
        }

        /// <summary>
        /// Ensure the database exists
        /// if drop first is specified and the database exists it then will drop the existing database first
        /// if it does not exist then it is created and populated with schema and static data
        /// </summary>
        /// <param name="dbName">if name is null or empty then take from config</param>
        /// <param name="dropFirst"></param>
        /// <param name="scriptFilePaths">optional db creation scripts</param>
        public static void EnsureDatabaseExists(string dbName = null, bool dropFirst = false, params string[] scriptFilePaths)
        {
            LogUtils.LogS($"dbName: {dbName}, dropFirst: {false}");

            if (string.IsNullOrEmpty(dbName))
                dbName = GetDatabaseNameFromConfig();

            if (dropFirst && DatabaseExists(dbName))
                DropDatabase(dbName);

            if (!DatabaseExists(dbName))
                CreateDatabase(dbName, false, scriptFilePaths);

            LogUtils.LogL();
        }

        /// <summary>
        /// Checks if the database exists
        /// PRE1: ConnectionData valid
        /// PRE2: ConnectionStringMaster must be instantiated by now
        ///
        /// POST: Side effect: if it does exist then the connection is set
        /// ref: https://stackoverflow.com/questions/2232227/check-if-database-exists-before-creating
        /// </summary>
        /// 
        /// <param name="databaseName">database to check 
        /// if null then uses the DatabaseName property  </param>
        /// <exception cref="ArgumentException">Thrown with message if method fails to parse connection string</exception>
        /// <returns>true if database exists false otherwise</returns>
        public static bool DatabaseExists(string databaseName)
        {
            bool result;
            Utils.Precondition(!String.IsNullOrEmpty(databaseName), "DatabaseExists() - null database argument");

            try
            {
                // PRE2: ConnectionStringMaster must be instantiated by now
                var connectionStringMaster = $"Data Source={DataSource};Initial Catalog=master;Integrated Security=True";

                using (var Conn = new SqlConnection(connectionStringMaster))
                {
                    using (var command = new SqlCommand($"SELECT db_id('{databaseName}')", Conn))
                    {
                        try
                        {
                            Conn.Open();
                            result = (command.ExecuteScalar() != DBNull.Value);
                        }
                        catch (Exception e)
                        {
                            LogUtils.LogException(e, $"in DatabaseExists([{databaseName}])");
                            LogUtils.LogI($"Master Connection String: [{connectionStringMaster}]");
                            result = false;
                        }
                        finally
                        {
                            Conn.Close();
                        }
                    }
                }
            }
            catch (Exception e)
            {
                LogUtils.LogException(e, $"in DatabaseExists([{databaseName}]) 2");
                result = false;
            }

            return result;
        }

        /// <summary>
        /// Runs the supplied sql script text optioanlly taking db name (and the script file path for debugging purposes)
        /// This method does the work
        /// </summary>
        /// <param name="scriptText">script test to run</param>
        /// <param name="databaseName">connection string to use</param>
        /// <param name="filePath">file path to the script file - for debugging purposes</param>
        public static void RunSqlScript( string scriptText, string databaseName = null, string filePath = null)
        {
//            LogUtils.LogS($"Running {absFile} against {databaseName}");

            if (string.IsNullOrEmpty(databaseName))
                databaseName = GetDatabaseNameFromConfig();

            Utils.Assertion(!string.IsNullOrEmpty(databaseName));
            var connectionString = GetConnectionString(databaseName);

            if (string.IsNullOrEmpty(connectionString))
                connectionString = GetConnectionString(databaseName, null);

            var conn = new SqlConnection(connectionString);

            // ReSharper disable once PossibleNullReferenceException
            if (conn.State != ConnectionState.Open)
                conn.Open();

            var server = new Server(new ServerConnection(conn));
            // Remove any comments - just in case the contain a GO statement
            var scriptText2 = RemoveComments(scriptText);
            // Chunk the script to refine granularity useful if error
            var chunks = scriptText2.Split(new string[] { "\r\nGO\r\n" }, StringSplitOptions.None);
            int lineNo = 1;

            foreach (var chunk in chunks)
            {
                try
                {
                    var chunk2 = chunk + "\r\nGO\r\n";
                    server.ConnectionContext.ExecuteNonQuery(chunk2);
                    lineNo += chunk2.Occurrences('\n');
                }
                catch (Exception e)
                {
                    string absFile = filePath != null ? Path.GetFullPath(filePath) : "SQL file not supplied to fn";
                    LogUtils.LogE($"Error executing chunk starting at line {lineNo} SQL:\n{chunk}\n{e.GetAllMessages()}\nFile:     {absFile}\nDatabase: {databaseName}");
                    throw;
                }
            }

            server.ConnectionContext.Disconnect();
        }

        /// <summary>
        /// Executes the SQL returning the first column of the first row
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="sql"></param>
        /// <param name="connectionString"></param>
        /// <returns></returns>
        public static T ExecuteScalarScript<T>(string sql, string connectionString)
        {
            T result;// = default(T);

            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        conn.Open();
                        result = (T) cmd.ExecuteScalar();
                        conn.Close();
                    }
                }
            }
            catch (Exception e)
            {
                LogUtils.LogException(e);
                throw;
            }

            return result;
        }

        /// <summary>
        /// Executes a function that returns atable
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="connectionString"></param>
        /// <returns></returns>
        public static DataTable ExecuteScriptReturningTable( string sql, string connectionString)
        {
            DataTable dataTable;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(sql, conn){ CommandType = CommandType.Text})
                    {
                        conn.Open();
                        dataTable = new DataTable();
                        // Create data adapter
                        var da = new SqlDataAdapter(cmd);
                        // Query the database and return the resulting rows to the datatable
                        da.Fill(dataTable);
                        conn.Close();
                        da.Dispose();
                    }
                }
            }
            catch (Exception e)
            {
                LogUtils.LogException(e);
                throw;
            }

            return dataTable;
        }

        /// <summary>
        /// Returns the SQL Server Database Engine product version as a string
        /// </summary>
        /// <returns>the product version string from the database sys.database_files table</returns>
        public string GetDbVersion()
        {
            var sql = "SELECT CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(128)) AS product_version FROM sys.database_files WHERE FILE_ID = 1; ";
            var connectionString = GetMasterConnectionStringFromConfig();
            return ExecuteScalarScript<string>(sql, connectionString);
        }

        /// <summary>
        /// Using the SQL severver function fn_get_db_version_info (part of the SI standard schema)
        /// Returns all the version information from database, not just the SQL Server Database Engine product version
        /// E.G:
        /// product_level edition         product_version is_express  db_name  current_size_on_Disk_mb  machine_name    db_version  db_size_limit
        /// RTM Express   Edition(64-bit) 14.0.2002.14    1           Pixl_TE1 72                       SATURN          SQL2017     10 GB
        /// 
        /// Expects 1 row to be returned from database
        /// </summary>
        /// <returns>Returns the version information a DataRow as created by the SQL function fn_get_db_version_info</returns>
        public static DataRow GetDbVersionInfo()
        {
            var connectionString = GetAndSubstituteConnectionString();
            var table = ExecuteScriptReturningTable("SELECT * FROM fn_get_db_version_info()", connectionString);
            Utils.Assertion( table.Rows.Count == 1, "Error getting version info");
            return table.Rows[0];
        }

        /// <summary>
        /// Get the row count from a table - can supply a filter
        /// Examples:
        /// GetCountFromWhereClause("[Project]") will return the count of rows in the project table - use brackets as necessary i.e. where a table name might be a reserved SQL keyword
        /// GetCountFromWhereClause($"[Project] WHERE top_level_node = '{x}'" will return the number of projects that have a top level node whose id is x
        /// </summary>
        /// <param name="tableFromWhereClause">Expected to be a table name  optional where filter clause</param>
        /// <param name="databaseName">optional database name if not specified will be the DatabaseName</param>
        /// <returns></returns>
        public static int GetCountFromWhereClause(string tableFromWhereClause, string databaseName = null)
        {
            return GetCount($"SELECT COUNT(*) FROM {tableFromWhereClause}", GetConnectionString(databaseName));
        }

        /// <summary>
        /// Returns the count of the sql
        /// </summary>
        /// <param name="sql">sql like: select count(*) from [table] where x=10. the filter is optional</param>
        /// <param name="databaseName"></param>
        /// <returns></returns>
        public static int GetCount(string sql, string databaseName = null)
        {
            return ExecuteScalarScript<int>(sql, GetConnectionString(databaseName));
        }

        /// <summary>
        /// Creates a new database using CreateDatabaseTemplateFilePath sql script
        /// and optionally populated with the supplied script files
        /// if none are supplied then the standard schema and static data scripts are used
        /// Limitiless script files can be passed which allows for factorisation and resuse of standard functionality
        /// 
        /// The first script should be used to create the schema
        /// Subsequent scripts can be used to add to the schema and populate tables
        /// N.B. if the database exists and dropFirst is false then the population scripts are NOT run
        /// </summary>
        /// <param name="databaseName">Optional - if null uses the app configuration DatabaseName app setting</param>
        /// <param name="dropFirst"></param>
        /// <param name="scriptFilePaths">1 or more SQL files used to dreate the schema and populate the tables</param>
        public static void CreateDatabase( string databaseName = null, bool dropFirst = true, params string [] scriptFilePaths)
        {
            LogCreateDbParamaters(databaseName, scriptFilePaths);
            Utils.Assertion(!string.IsNullOrEmpty(DataSource), "DataSource not configured");

            if (string.IsNullOrEmpty(databaseName))
                databaseName = GetDatabaseNameFromConfig();

            // Drop if required
            if (dropFirst && DatabaseExists(databaseName))
                DropDatabase(databaseName);

            // Generic Default db construction
            if ((scriptFilePaths == null) || (scriptFilePaths.Length == 0))
                scriptFilePaths = new [] { CreateStandardSchemaTemplateFilePath, CreateSchemaTemplateFilePath, CreateStaticDataTemplateFilePath };

            // Only populate if not exists
            if (!DatabaseExists(databaseName))
            {
                // ASSERTION db does not exist
                // Try to delete the mdf and log file first should they exist for some reason
                TryDeleteDbFiles(databaseName, DatabaseRootDir);
                // Run the create DB script against the master database having substituted any tags and removed the comments
                LogUtils.LogI($"Creating database reg for {databaseName} in master db File: [{CreateDatabaseTemplateFilePath}]");
                ProcessScript("master", CreateDatabaseTemplateFilePath, DbNameTag, databaseName, DbPathTag, DatabaseRootDir);

                foreach (var scriptFile in scriptFilePaths)
                    PopulateDatabase(databaseName, scriptFile);
            }

            LogUtils.LogL();
        }

        /// <summary>
        /// This method creates a SqlConnectionStringBuilder from the application configuration - you can embellish this or change it
        /// An SqlConnectionStringBuilder provides easy control over the connection string
        /// POST: returns a SqlConnectionStringBuilder populated from the connection string mapped from sqlConnectionStringConfigKey in the config 
        /// or a ConfigurationErrorsException exception is thrown
        /// </summary>
        /// <param name="sqlConnectionStringConfigKey">optional key name in ConfigurationManager.AppSettings[] default = SqlConnectionStringConfigKey CONST value is set to</param>
        /// <returns>The connection string builder.</returns>
        public static SqlConnectionStringBuilder GetConnectionStringBuilderFromConfig(string sqlConnectionStringConfigKey = null)
        {
            // get data source and database name - from the application configuration
            if (string.IsNullOrEmpty(sqlConnectionStringConfigKey))
                sqlConnectionStringConfigKey = SqlConnectionStringConfigKey;

            // Get the template connection string from the application configuration and
            // Create the ConnectionStringBuilder based on this (substituted) connection string
            return new SqlConnectionStringBuilder(GetAndSubstituteConnectionString(sqlConnectionStringConfigKey));//connectionString));
        }

        /// <summary>
        /// Gets the database name from the configuration app settings section
        /// mapped from (DatabaseNameKey)
        /// or throws a ConfigurationErrorsException exception if it can't find the key
        /// </summary>
        /// <returns></returns>
        public static string GetDatabaseNameFromConfig()
        {
            return GetValueFromConfigSettings(DatabaseNameKey);
        }

        /// <summary>
        /// Gets the server name from the configuration app settings section mapped from (DatabaseNameKey)
        /// or a ConfigurationErrorsException exception is thrown if it can't find the key
        /// </summary>
        /// <returns>the server name from the app settings</returns>
        public static string GetServerNameFromConfig()
        {
            return GetValueFromConfigSettings(ServerKey);
        }

        /// <summary>
        /// Gets the instance name from the configuration app settings section mapped from (DatabaseNameKey)
        /// or a ConfigurationErrorsException exception is thrown if it can't find the key
        /// </summary>
        /// <returns>the instance name from the app settings</returns>
        public static string GetInstanceNameFromConfig()
        {
            return GetValueFromConfigSettings(InstanceKey);
        }

        /// <summary>
        /// Gets the directory for the database files like the .mdf from the configuration app settings section
        /// mapped from (DatabaseNameKey)
        /// or a ConfigurationErrorsException exception is thrown if it can't find the key
        /// </summary>
        /// <returns></returns>
        public static string GetDatabaseRootDirFromConfig()
        {
            return GetValueFromConfigSettings(DatabaseRootDirKey);
        }

        /// <summary>
        /// Returns the "SqlConnectionString" connection string from app configuration
        /// </summary>
        /// <returns></returns>
        public static string GetSimpleConnectionStringFromConfig()
        {
            return GetAndSubstituteConnectionString();
        }

        /// <summary>
        /// Substitutes the DB_NAME tag in the supplied text
        /// </summary>
        /// <param name="text">mandatory non null or empty</param>
        /// <param name="dbNameVal">mandatory non null or empty</param>
        /// <returns>returns the substituted text</returns>
        public static string SubstituteDbNameTag(string text, string dbNameVal)
        {
            return SubstituteTags(text, DbNameTag, dbNameVal);
        }

        /// <summary>
        /// Replaces a map of tag->value pairs in text
        /// i.e. for each tag it replaces the corresponding value
        /// The map is implmented as a simple array of pairs where order could matter if replacing tags with one or more other tags
        /// "PRE" tagValuePairs length must be even so that it can be read as a map of tagValuePairs pairs
        /// 
        /// </summary>
        /// <param name="text" text in which to substitute the tags with values/>
        /// <param name="tagValuePairs">set of tag value pairs to replace in text. It is an array of strings arranged in pairs
        /// Expects [tag, value]* pairs</param>
        /// <returns>substituted text</returns>
        public static string SubstituteTags(string text, params string[] tagValuePairs)
        {
            Utils.Assertion(tagValuePairs.Length % 2 == 0, "SubstituteTags() expects pairs of tags and values");
            var script = text;

            for (int i = 0; i < tagValuePairs.Length; i += 2)
                script = script.Replace(tagValuePairs[i], tagValuePairs[i + 1]);

            return script;
        }

        /// <summary>
        /// Populates the static data 
        /// and optionally the test data
        /// handles the null file path so client code does not have to in scenarios 
        /// where variable script arguments passed (possibly null means N/A)
        /// PRE: CreateDatabase called to create the schema
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="sqlFilePath">path to the template SQL script file</param>
        public static void PopulateDatabase(string databaseName, string sqlFilePath)
        {
            if (!string.IsNullOrEmpty(sqlFilePath))
                ProcessScript(databaseName, sqlFilePath, DbNameTag, databaseName);
        }

        // / <summary>
        // / Creates the database then populating from the schema and static data
        // / optionally dropping it first, 
        // / Producing a "Good to go" database for use. Can override the standard sscripts by supplying then as parameters7
        // / </summary>
        // / <param name="databaseName"></param>
        // / <param name="dropFirst">if true and database exists then this will drop the database first</param>
        // / <param name="schemaTemplateFilePath">optional path the create schema SQL script, if not suppled then the default script is used</param>
        // / <param name="staticDataPath">optional path the static data SQL script, if not suppled then the default script is used</param>
        //public void CreateDatabaseAndPopulateStaticData(string databaseName, bool dropFirst = true, string schemaTemplateFilePath = null, string staticDataPath=null)
        //{
        //    if (string.IsNullOrEmpty(schemaTemplateFilePath))
        //        schemaTemplateFilePath = CreateSchemaTemplateFilePath;

        //    if (string.IsNullOrEmpty(staticDataPath))
        //        staticDataPath = CreateStaticDataTemplateFilePath;

        //    CreateDatabase(databaseName, dropFirst, schemaTemplateFilePath, staticDataPath);
        //}

        /// <summary>
        /// Runs the SQL script associated with the operation type
        /// PRE CHK: DatabaseRootDir specified
        /// <param name="dbOpType">operation type: e.g. CreateDatabase or CreateSchema or CreateStaticData etc.</param>
        /// </summary>
        public void ProcessScript(DbOpType dbOpType)
        {
            Utils.Assertion(!String.IsNullOrEmpty(DatabaseRootDir), RootDirNotDefinedErrorMsg);
            // Get the script from the template and substituted with the values for this Database and operation
            var scriptText = GetScriptForDatabaseAndOpType(dbOpType);

            // Get the correct database - if creating then the db wont exists - so must connect to an existing db - 
            // since we are going to run against master eventually - use it in the first instance as it must exist
            var database = dbOpType == DbOpType.CreateDatabase ? "master" : DatabaseName;

            // Run the script against the database
            RunSqlScript(scriptText, database);
        }

        /// <summary>
        /// Runs a SQL script file against the database, first replacing any supplied tag with thier assciated values
        /// If the database raises an exception then will log and rethrow
        /// Method:
        /// 1. Read the file text
        /// 2. Substitute any tags in the script according to the tagValue parameters
        /// 3. Run the substituted script against the databse
        /// 4. Log any errors
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="filePath"></param>
        /// <param name="tagValue"></param>
        public static void ProcessScript(string databaseName, string filePath, params string[] tagValue)
        {
            var absFilePath = Path.GetFullPath(filePath);
            var script = File.ReadAllText(absFilePath);
            // script = RemoveComments(script);
            // Populate the template script with the tag/value parameters
            script = SubstituteTags(script, tagValue);
            RunSqlScript(script, databaseName, absFilePath);
        }

        /// <summary>
        /// Substitutes tags in script with values based on the expected set for the operation
        /// This is almost identical to SubstituteTags, except is uses a different container type - Dictionary, not an array
        /// <param name="scriptText">script (contents) in which replace the tag with value</param>
        /// <param name="opType">operation type - create db, create schema etc.</param>
        /// </summary>
        /// <returns>Modified script</returns>
        public string FindAndReplaceTagsInScript(string scriptText, DbOpType opType)
        {
            // Get the set of tag/value pairs related to this operation type
            var tagValuePairs = ScriptTags[opType];
            var newScript = scriptText;

            // For each tag value pair: replace the tag with value in the script
            foreach (var tagValuePair in tagValuePairs)
                newScript = FindAndReplaceTagInScript(newScript, tagValuePair.Key, tagValuePair.Value);

            return newScript;
        }

        /// <summary>
        /// Find tag in the script and replace it with the value
        ///  Called by FindAndReplaceTagsInScript
        /// </summary>
        /// <param name="scriptText">script (contents) in which replace the tag with value</param>
        /// <param name="tag">the tag to replace</param>
        /// <param name="value">the value to replace the tag with</param>
        /// <returns>Modified script</returns>
        public string FindAndReplaceTagInScript(string scriptText, string tag, string value)
        {
            // Replace the text
            return scriptText.Replace(tag, value);
        }

        /// <summary>
        /// Encapsulates the map access (testable)
        /// </summary>
        /// <param name="dbOpType"></param>
        /// <returns></returns>
        public string GetScriptFileName(DbOpType dbOpType)
        {
            return ScriptMap[dbOpType];
        }

        /// <summary>
        /// Returns the Entitiy Framework connection string substituted with the database name, server, instance
        /// If parameter not supplied then takes value from application configuration
        /// </summary>
        /// <param name="databaseName">The database to connect to  [OPTIONAL]</param>
        /// <param name="serverName">The Server to use [OPTIONAL]</param>
        /// <param name="instanceName">The SQL Instance to use [OPTIONAL]</param>
        /// <returns></returns>
        public static string GetAndSubstituteEfConnectionString(string databaseName = null, string serverName = null, string instanceName = null)
        {
            //var cs = ConfigurationManager.ConnectionStrings[EfConnectionStringConfigKey];
            //Utils.Assertion(cs != null, $"Missing EF onnection string key in app config: {EfConnectionStringConfigKey}");
            // ReSharper disable once PossibleNullReferenceException
            return GetAndSubstituteConnectionString(EfConnectionStringConfigKey, databaseName, serverName, instanceName);
        }

        /// <summary>
        /// Creates a connection string based on the supplied parameters and the configuration
        /// If any parameter is not supplied then it is taken from the application configuration
        /// </summary>
        /// <param name="databaseName">optional</param>
        /// <param name="server">optional </param>
        /// <param name="instance">optional </param>
        /// <returns></returns>
        public static string GetConnectionString(string databaseName = null, string server = null, string instance = null)
        {
            if (databaseName == null)
                databaseName = GetDatabaseNameFromConfig();

            if (server == null)
                server = GetServerNameFromConfig();

            if (instance == null)
                instance = GetInstanceNameFromConfig();

            Utils.Assertion(!String.IsNullOrEmpty(databaseName), DbNameNotSpecifiedMsg);
            Utils.Assertion(!String.IsNullOrEmpty(server), ServerNameNotSpecifiedMsg);
            Utils.Assertion(!String.IsNullOrEmpty(instance), InstanceNameNotSpecifiedMsg);

            return $"Data Source={server}\\{instance};Initial Catalog={databaseName};{TrustedConnectionString}";
        }

        /// <summary>
        /// Changes the database context, even if already open
        /// Defaults taken from configuration
        /// PRE: CTX not null AND dbName not empty or null
        /// Used in DataLogger and DataLoggerUnitTests
        /// 
        /// N.B. This is redundant now that we overload the EF context constructor to take a connection string defined at runtime
        /// We used to have to let the default contructor get its details from config and then undo it all - hence this method
        /// Have even tried switching the app config at run time - even more hairy!
        /// </summary>
        /// <param name="ctx">Must not be null</param>
        /// <param name="dbName">Must not be null</param>
        /// <param name="server">optional</param>
        /// <param name="instance">optional</param>
        public static void SwitchDatabase(DbContext ctx, string dbName, string server = null, string instance = null)
        {
            if (ctx.Database.Connection.State != ConnectionState.Closed)
                ctx.Database.Connection.Close();

            var sqlBuilder = new SqlConnectionStringBuilder(ctx.Database.Connection.ConnectionString);
            server = server ?? sqlBuilder.GetServer();
            instance = instance ?? sqlBuilder.GetInstance();
            sqlBuilder.DataSource = $"{server}\\{instance}";

            // Set the DbName
            sqlBuilder.InitialCatalog = dbName;
            // now set its connection string whilst the connection is closed
            ctx.Database.Connection.ConnectionString = sqlBuilder.ConnectionString;
        }

        /// <summary>
        /// Creates SqlConnectionStringBuilder from a connection string - handles (LocalDb)
        /// </summary>
        /// <param name="connectionString"></param>
        /// <returns></returns>
        public SqlConnectionStringBuilder CreateConnectionStringBuilder(string connectionString)
        {
            if (connectionString.ToLower().Contains("(localdb)"))
                connectionString = connectionString.Replace("(LocalDb)", "(local)", StringComparison.CurrentCultureIgnoreCase);

            // Connect to Master first and create the database
            return new SqlConnectionStringBuilder(connectionString);
        }

        /// <summary>
        /// Drops the database.
        /// if database name not supplied then gets it from config.
        /// May raise an exception if there is an issue with the database files not existing even though it succeeds
        /// </summary>
        /// <param name="databaseName">optional database to drop - if not supplied takes it from config</param>
        /// <returns></returns>
        public static void DropDatabase(string databaseName = null)
        {
            // Dont drop the main db
            if (ChkDbNotTheConfigurationDb)
            {
                var configDbName = GetDatabaseNameFromConfig();
                Utils.Assertion(!databaseName.Equals(configDbName), $"Drop Database failed for database [{databaseName}] - it is the configured database");
            }

            if (string.IsNullOrEmpty(databaseName))
                databaseName = GetDatabaseNameFromConfig();

            LogUtils.LogS($"dropping database: [{databaseName}]");
            var sql = GetDropDatabaseScriptForDatabase(databaseName);

            try
            {
                // Run against the master database
                if (DatabaseExists(databaseName))
                    RunSqlScript(sql, "master", DropDatabaseTemplateFilePath);
            }
            catch (Exception e)
            {
                LogUtils.LogException(e, $"DropDatabase SQL: {sql}");
                throw;
            }
            finally
            {
                var success = DatabaseExists(databaseName) ? "failed" : "succeeded";
                LogUtils.LogL($"Drop database [{databaseName}]  {success}");
            }
        }

        /// <summary>
        /// Returns a script to drop the given database, kicking off any users first
        /// </summary>
        /// <param name="databaseName">the database name to use, if not supplied then it is taken from the config</param>
        /// <returns></returns>
        public static string GetDropDatabaseScriptForDatabase(string databaseName = null)
        {
            if (string.IsNullOrEmpty(databaseName))
                databaseName = GetDatabaseNameFromConfig();

            return SubstituteDbNameTag(File.ReadAllText(DropDatabaseTemplateFilePath), databaseName);
        }

        /// <summary>
        /// Removes -- and /**/ type comments from SQL
        /// </summary>
        /// <param name="sql"></param>
        /// <returns></returns>
        public static string RemoveComments(string sql)
        {
            var sql2 = RemoveComments(sql, "--", "\n");
            return RemoveComments(sql2, "/*", "*/");
        }

        /// <summary>
        /// Gets the connections string from the App config connection strings
        /// Replaces tokens in the connection string
        /// If paraeter is not supplied then it will be defaulted
        /// </summary>
        /// <param name="connectionStringKey">key in app config connection strings for the connection string with placeholders to substitute values into default = "SqlConnectionString"</param>
        /// <param name="databaseName">database name replacement value default key name = "DatabaseName"</param>
        /// <param name="serverName">data source replacement value     default key name = "Server"</param>
        /// <param name="instanceName">database name replacement value default key name = "Instance"</param>
        /// <returns></returns>
        public static string GetAndSubstituteConnectionString(string connectionStringKey=null, string databaseName = null, string serverName = null, string instanceName = null)
        {
            if (string.IsNullOrEmpty(connectionStringKey))
                connectionStringKey = SqlConnectionStringConfigKey;

            Utils.Assertion(!string.IsNullOrEmpty(connectionStringKey), "unexpected empty cconnectionStringKey parameter");

            // Check the old style call is not still used
            // ReSharper disable once PossibleNullReferenceException
            if (connectionStringKey.Contains("data source ="))
                Utils.Assertion(!connectionStringKey.Contains("data source ="), "Code error");

            var connectionString = GetRawConnectionStringFromConfig(connectionStringKey);
            return SubstituteConnectionStringValues(connectionString, databaseName, serverName, instanceName);
        }

        /// <summary>
        /// Returns the text from the scriptFileName file from the ScriptDir directory
        /// </summary>
        /// <param name="scriptFileName"></param>
        /// <returns></returns>
        public static string GetScriptText(string scriptFileName)
        {
            var scriptFilePath = $"{ScriptDir}\\{scriptFileName}";
            scriptFilePath = Path.GetFullPath(scriptFilePath);
            // Get the (template) script text
            var scriptText = File.ReadAllText(scriptFilePath);
            return scriptText;
        }

        /// <summary>
        /// Runs a stored procedure passing a set of parameters, returning a data set
        /// Uses ADO not EF
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="storedProcedure">name of the stored procedure</param>
        /// <param name="pvPairs">optional set of parameter -> value pairs, first value of pair is the parameter name, the second is the value</param>
        /// <returns>The record-set</returns>
        public DataSet RunStoredProcedure(string databaseName, string storedProcedure, params object[] pvPairs)
        {
            DataSet ds = null;
            SqlConnection con = null;
            var len = pvPairs.Length;
            Utils.Assertion(len % 2 == 0, "pvPairs parameter must be a sequence of pairs (parameter name, parameter value)");

            try
            {
                con = new SqlConnection(GetConnectionString(databaseName));
                var cmd = new SqlCommand(storedProcedure, con) { CommandType = CommandType.StoredProcedure };

                // Add the parameters
                for(int i=0; i< len; i+=2)
                    AddSqlCmdParameter(cmd, pvPairs[i].ToString(), pvPairs[i+1]);

                ds = new DataSet("Results");
                var da = new SqlDataAdapter { SelectCommand = cmd };
                da.Fill(ds);
            }
            catch (Exception e)
            {
                LogUtils.LogE($"DbHelper.RunStoredProcedure raised exception: {e.GetAllMessages()}");
                //throw;
            }
            finally
            {
                con.Dispose();
            }

            return ds;
        }

        /// <summary>
        /// Returns set of indexes for 1 or more tables as specified
        /// Can filter on Table name, Primary key and or is_unique
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="tableName"></param>
        /// <param name="indexName"></param>
        /// <param name="isPrimary"></param>
        /// <param name="isUnique"></param>
        /// <returns></returns>
        public DataTable GetIndexes(string databaseName, string tableName=null, string indexName=null, bool? isPrimary=null, bool? isUnique = null)
        {
            return RunStoredProcedure(databaseName, "sp_get_indexes", "@table_name", tableName, "@index_name", indexName, "@is_primary", isPrimary, "@is_unique", isUnique).Tables[0];
        }

        /// <summary>
        /// Lists columns for 1 or more indexes of 1 or more tables
        /// Can filter on Table name, Primary key and or is_unique
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="table_name"></param>
        /// <param name="index_name"></param>
        /// <param name="is_primary"></param>
        /// <param name="is_unique"></param>
        /// <returns></returns>
        public DataTable GetIndexColumns(string databaseName, string table_name, string index_name, bool? is_primary, bool? is_unique)
        {
            return RunStoredProcedure(databaseName, "sp_get_index_columns", "@table_name", table_name, "@index_name", index_name, "@is_primary", is_primary, "@is_unique", is_unique).Tables[0];
        }

        /// <summary>
        /// Maps a .Net data type to the equivalent SqlDbType
        /// Throws ArgumentException if cannot convert
        /// POST: returns equivalent SqlDbType to theType parameter OR throws ArgumentException if cannot convert
        /// </summary>
        /// <param name="theType"></param>
        /// <returns></returns>
        public static SqlDbType GetDbType(Type theType)
        {
            var param = new SqlParameter();
            var tc = TypeDescriptor.GetConverter(param.DbType);

            if (tc.CanConvertFrom(theType))
            {
                var x = tc.ConvertFrom(theType.Name);

                if (x != null)
                    param.DbType = (DbType)x;
                else
                    throw new ArgumentException($"DbHelper GetDbType({theType.Name}) Unexpected failure to convert type to equivalent SqlDbType");
            }
            else
            {
                // Try to forcefully convert
                try
                {
                    var x = tc.ConvertFrom(theType.Name);

                    if (x != null)
                        param.DbType = (DbType)x;
                    else
                        throw new ArgumentException($"DbHelper GetDbType({theType.Name}) Unexpected failure to convert type to equivalent SqlDbType");
                }
                catch (Exception e)
                {
                    // Ignore the exception ?? - Don't think so!
                    var msgs = e.GetAllMessages();
                    LogUtils.LogE($"DbHelper GetDbType({theType.Name}) threw an exception: {msgs}");
                    throw new ArgumentException($"Unexpected failure to convert type to equivalent SqlDbType {msgs}");
                }
            }

            return param.SqlDbType;
        }

        /// <summary>
        /// Checks if a DbType is a DbType
        /// POST: Returns true if idbType is a DbType false otherwise
        /// </summary>
        /// <param name="idbType"></param>
        /// <returns></returns>
        public bool IsDbStringType(int idbType)
        {
            DbType dbType = (DbType)idbType;
            return (dbType == DbType.AnsiString) || (dbType == DbType.AnsiStringFixedLength) || (dbType == DbType.Guid) || (dbType == DbType.String) || (dbType == DbType.StringFixedLength);
        }

        /// <summary>
        /// Returns the first Unique Key definition found that fits the  data as a Data Table - each row is column in the key in key order
        /// i.e. the first key that does not contain an ignored field
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="ignoredFields"></param>
        /// <returns>The sequence of key columns in key order as a DataTable or Null if no key is available: 
        /// i.e. all available keys reference at least one ignored field</returns>
        public DataTable GetUniqueKey(string tableName, string[] ignoredFields)
        {
            // returns a set of keys - 1 row for each key
            var table = GetIndexes(DatabaseName, tableName, isUnique:true);
            DataTable foundKey = null;

            // Iterate the returned unique keys - looking for a key that does not contain an ignored field
            foreach (DataRow row in table.Rows)
            {
                foundKey = KeyFitsData(tableName, row["index_name"].ToString(), ignoredFields);

                if (foundKey != null)
                    break;
            }

            return foundKey;
        }



        #endregion public methods


        #region protected methods

        /// <summary>
        /// if successful returns a SQL clause like "child_name = '{0}' AND parent_id = {1}"
        /// that can be use in a SQL select statement like SELECT * FROM table WHERE {select clause};
        /// This is a format string that can then be used to populate the data
        /// Call this once to get the format string
        /// </summary>
        /// <param name="keyDef">The key definition as a key definition get by calling GetUniqueKey(tableName, ignoredFields)</param>
        /// <returns>if successful returns a SQL clause like "child_name = '{1}' AND parent_id = {2}" or null if error</returns>
        protected string CreateUqClauseFormatString(DataTable keyDef)
        {
            var clause = new StringBuilder();

            // ASSERTION: we have a valid key that spans the available fields
            // Create the clause by iterating the key rows and constructing the clause 
            var firstTime = true;
            var n = 0;

            foreach (DataRow row in keyDef.Rows)
            {
                if (!firstTime)
                    clause.Append(" AND ");
                else
                    firstTime = false;

                var quote = IsDbStringType((int)row["column_type_id"]) ? "'" : ""; // "" or "'" for strings
                clause.Append($"[{row["column_name"]}] = {quote}{{{n}}}{quote}");
                n++;
            }

            return clause.ToString();
        }

        /// <summary>
        /// Runs a SQL script file against the given connection with optional replacement tags
        /// </summary>
        /// <param name="databaseName">database name to use (and replace any DB_NAME tags in the script with databaseName)</param>
        /// <param name="sqlFilePath">path to the template SQL script file</param>
        /// <param name="tag1">optional tag 1 to replace</param>
        /// <param name="val1">optional value to replace for tag 1</param>
        /// <param name="tag2">optional tag 2 to replace</param>
        /// <param name="val2">optional value to replace for tag 2</param>
        protected static void RunSqlFile(string databaseName, string sqlFilePath, string tag1 = null, string val1 = null, string tag2 = null, string val2 = null)
        {
            ProcessScript(databaseName, sqlFilePath, DbNameTag, databaseName, tag1, val1, tag2, val2);
        }

        /// <summary>
        /// Runs a script to create the standard Pixl database
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="sqlFilePath"></param>
        protected void PopulateStaticData(string databaseName, string sqlFilePath)
        {
            ProcessScript(databaseName, sqlFilePath, DbNameTag, databaseName);
        }


        #endregion protected methods

        #region private methods

        private static void LogCreateDbParamaters( string databaseName, string[] scriptFilePaths)
        {
           var msg = $"Creating database {databaseName}";
            var sb = new StringBuilder(msg + "\n");
            int n = 1;

            if (scriptFilePaths != null)
                foreach (var scriptFilePath in scriptFilePaths)
                    sb.AppendLine($"file {n++}\t{scriptFilePath}");

            LogUtils.LogI(sb.ToString());
        }

        private static string EnsureDbRootDirExists(string databaseRootDir)
        {
            // Ensure the database root directory exists
            if (string.IsNullOrEmpty(databaseRootDir))
                databaseRootDir = GetDatabaseRootDirFromConfig();

            var dbRootDir = Path.GetFullPath(databaseRootDir);
            Utils.Assertion(!string.IsNullOrEmpty(dbRootDir), "DatabaseRootDir not specified in Application Configuration");
            Directory.CreateDirectory(dbRootDir);
            return dbRootDir;
        }

        /// <summary>
        /// Helper to try to delete old db files if they exist
        /// throws exception if error e.g when files exist and attached to server
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="dbRootDir"></param>
        private static void TryDeleteDbFiles(string databaseName, string dbRootDir)
        {
            // ASSERTION db does not exist
            try
            {
                // Try to delete the mdf and log file first should they exist for some reason
                if (File.Exists($"{dbRootDir}\\{databaseName}.mdf"))
                {
                    File.Delete($"{dbRootDir}\\{databaseName}.mdf");
                    File.Delete($"{dbRootDir}\\{databaseName}_log.ldf");
                }
            }
            catch (Exception e)
            {
                LogUtils.LogException(e, $"Trying to delete {dbRootDir}\\{databaseName}.mdf / _log.ldf");
                throw;
            }
        }

        /// <summary>
        /// DataRow specification: {"table_name", "index_name", "column_name", "column_id", "is_unique", "is_primary_key"}
        /// </summary>
        /// <param name="row"></param>
        /// <param name="tableName"></param>
        /// <param name="indexName"></param>
        /// <param name="ignoredFields"></param>
        /// <returns></returns>
        private DataTable KeyFitsData( string tableName, string indexName, string[] ignoredFields)
        {
            // Get the columns for the key in order
            DataTable key = GetIndexColumns(DatabaseName, tableName, indexName, null, true);

            // check col names are in the set of ignoredFields
            foreach (DataRow row in key.Rows)
            {
                var columnName = row["column_name"];

                if (ignoredFields.Contains(columnName))
                    return null;
            }

            // If here then found
            return key;
        }


        /// <summary>
        /// returns a SQL script that can be run to perform the operation specified by dbOpType
        /// <param name="dbOpType">operation type: e.g. CreateDatabase or CreateSchema or CreateStaticData etc.</param>
        /// </summary>
        private string GetScriptForDatabaseAndOpType(DbOpType dbOpType)
        {
            // Lookup the script file name for the script type
            // Get the absolute path of the script
            var scriptFilePath = GetTemplateScriptFilePath(dbOpType);
            scriptFilePath = Path.GetFullPath(scriptFilePath);
            LogUtils.LogI($"Using script file: {scriptFilePath}");
            var bExists = File.Exists(scriptFilePath);

            if (!bExists)
                Utils.Assertion<ConfigurationException>(false, $"{ScriptFileNotFoundMsg} {scriptFilePath}");

            // De-serialise the script from the file to a string
            var scriptText = File.ReadAllText(scriptFilePath);
            // Get the map of tags to value to replace in the script
            // Replace the tags with the appropriate local values in the script
            return FindAndReplaceTagsInScript(scriptText, dbOpType);
        }

        /// <summary>
        /// Returns the path to the operation script template
        /// </summary>
        /// <param name="dbOpType"></param>
        /// <returns></returns>
        private string GetTemplateScriptFilePath(DbOpType dbOpType)
        {
            var fileName = GetScriptFileName(dbOpType);
            Utils.Assertion(!String.IsNullOrEmpty(ScriptDir));
            var scriptFilePath = $"{ScriptDir}\\{fileName}";
            return Path.GetFullPath(scriptFilePath);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private static string GetMasterConnectionStringFromConfig()
        {
            return GetAndSubstituteConnectionString(DbHelper.SqlConnectionStringConfigKey, "master"); ;
        }

        /// <summary>
        /// Removes comments from SQL defined by the commentStartKeyword and commentEndKeyword
        /// This method should be called twice for SQL once with "--" and EOL
        /// Once with "/*" and "*/"
        /// e.g. see  public static string RemoveComments(string SQL)
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="commentStartKeyword"></param>
        /// <param name="commentEndKeyword"></param>
        /// <returns></returns>
        private static string RemoveComments(string sql, string commentStartKeyword, string commentEndKeyword)
        {
            var sb = new StringBuilder();
            // iterate the SQL
            var more = true;
            int i = 0;

            while (more)
                more = RemoveComment(sql, commentStartKeyword, commentEndKeyword, ref sb, ref i);

            return sb.ToString();
        }

        /// <summary>
        /// Removes 1 comment type from the SQL.
        /// The method is intended to be used iteratively through an SQL script containing possibly many comments of either 
        /// line comments signified by '--' synonymous with C# '//' comment keyword
        /// or block comments '/*' '*/' same as C# block comment keyword
        /// 
        /// Each call will update the cursor to point to just after the found comment
        /// 
        /// Use this method repeatedly - twice - once with the //  and once with the /**/ comment types
        /// E>G: see public static string RemoveComments(string SQL, string commentStartKeyword, string commentEndKeyword)
        /// </summary>
        /// <param name="sql">string to search</param>
        /// <param name="commentStart">start token like -- or  /*</param>
        /// <param name="commentEnd"> like EOL for comments starting --  or */ for comments starting /*</param>
        /// <param name="sb">stream for the processed text (comment less)</param>
        /// <param name="cursor">start position of text to search from- modified after a find to point to after the current comment occurrence</param>
        /// <returns>true if more SQL to process, false otherwise</returns>
        private static bool RemoveComment(string sql, string commentStart, string commentEnd, ref StringBuilder sb, ref int cursor)
        {
            // Look for the next occurrence of the start comment keyword
            var nextCommentIndex = sql.IndexOf(commentStart, cursor, StringComparison.Ordinal);

            if (nextCommentIndex == -1)
            {
                // if not found in the rest of the SQL then we are done processing
                sb.Append(sql.Substring(cursor));
                return false; // done
            }

            // Push the block of code from the cursor to just before the comment start to the string builder
            var commentFreeCode = sql.Substring(cursor, nextCommentIndex - cursor);
            sb.Append(commentFreeCode);
            // Go past the line comment
            var x = sql.IndexOf(commentEnd, nextCommentIndex, StringComparison.Ordinal);

            if (x == -1)
                return false; // done

            // If here then found the end of comment
            // So leapfrog the comment
            cursor = x + commentEnd.Length;
            return true;
        }

        /// <summary>
        /// Gets the connections string from the App config connection strings
        /// Replaces tokens in the connection string.
        /// If none are supplied then all are defaulted/
        /// </summary>
        /// <param name="connectionString">the connection string with placeholders to substitute values into</param>
        /// <param name="databaseName">optional database name replacement value default key name = "DatabaseName"</param>
        /// <param name="serverName">  optional data source replacement value     default key name = "Server"</param>
        /// <param name="instanceName">optional database name replacement value default key name = "Instance"</param>
        /// <returns></returns>
        private static string SubstituteConnectionStringValues(string connectionString, string databaseName = null, string serverName = null, string instanceName = null)
        {
            Utils.Assertion(!string.IsNullOrEmpty(connectionString));

            // If needed set defaults
            if (string.IsNullOrEmpty(serverName))
                serverName = GetServerNameFromConfig();

            if (string.IsNullOrEmpty(instanceName))
                instanceName = GetInstanceNameFromConfig();

            if (string.IsNullOrEmpty(databaseName))
                databaseName = GetDatabaseNameFromConfig();

            Utils.Assertion(!string.IsNullOrEmpty(connectionString), "undefined connectionString");
            Utils.Assertion(!string.IsNullOrEmpty(serverName), "undefined serverName");
            Utils.Assertion(!string.IsNullOrEmpty(instanceName), "undefined instanceName");
            Utils.Assertion(!string.IsNullOrEmpty(databaseName), "undefined databaseName");

            var s = connectionString.Replace("{DataSource}", $"{serverName}\\{instanceName}", StringComparison.CurrentCultureIgnoreCase);
            s = s.Replace("{DatabaseName}", databaseName, StringComparison.CurrentCultureIgnoreCase);
            s = s.Replace("{Server}", serverName, StringComparison.CurrentCultureIgnoreCase);
            s = s.Replace("{Instance}", instanceName, StringComparison.CurrentCultureIgnoreCase);
            return s;
        }

        /// <summary>
        /// Gets the raw connection string from config and checks not empty
        /// Does NOT perform any tag substitution
        /// </summary>
        /// <param name="key"> Default = (SqlConnectionStringConfigKey)</param>
        /// <returns>the connections string mapped fom the key in app config connection strings section</returns>
        private static string GetRawConnectionStringFromConfig(string key = null)
        {
            if (string.IsNullOrEmpty(key))
                key = SqlConnectionStringConfigKey;

            var connStr = ConfigurationManager.ConnectionStrings[key]?.ConnectionString;
            Utils.Assertion(!string.IsNullOrEmpty(connStr), $"Failed to get the ConnectionString for key: {key} from configuration ConnectionStrings");
            return connStr;
        }

        /// <summary>
        /// Gets the value from ConfigurationManager.AppSettings specified by key
        /// POSTCONDITION: returns non empty setting string or a ConfigurationErrorsException exception is thrown
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        private static string GetValueFromConfigSettings(string key)
        {
            var val = ConfigurationManager.AppSettings[key];
            Utils.Assertion< ConfigurationErrorsException>(!string.IsNullOrEmpty(val), $"Failed to get the value for key: {key} from configuration settings");
            return val;
        }

        private void AddSqlCmdParameter(SqlCommand cmd, string p1, object v1)
        {
            if ((!String.IsNullOrEmpty(p1)))
                cmd.Parameters.AddWithValue(p1, v1 ?? DBNull.Value);
        }

        #endregion
    }
}
