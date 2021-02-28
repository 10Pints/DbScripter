using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Core.Objects;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SI.Common.Extensions;
using SI.Logging.LogUtilities;
using SI.Software.Databases.SQL;
using SI.Common;
using C5;

namespace SI.Software.TestHelpers.Database.SQL
{
    //using alias = SortedDictionary;
    /// <summary>
    /// This class supports DbSchemaUnitTest classes.
    /// It has 2 helpers
    /// </summary>
    public class DbUnitTestBase : UnitTestBase // For logging
    {
        #region private Fields
        private DbTestHelper _dbTestHelper = new DbTestHelper();

        #endregion
        #region protected properties

        // This is the 1 Common database for all tests
        // therefore  <-- DO NOT WRITE TO IT
        // if you want to write then create a new database temp database for the test and handle its destruction in the test clean-up so that it is always removed -
        // especially on the build server even if the test throws an exception.
        protected string DatabaseName
        {
            get { return DbTestHelper.DatabaseName; }
            set { DbTestHelper.DatabaseName = value; }
        }

        protected string CurrentDatabaseName { get; set; }

        protected DbTestHelper DbTestHelper
        {
            get
            {
                Assert.IsTrue(_dbTestHelper != null);
                return _dbTestHelper;
            }

            set { _dbTestHelper = value; }
        }

        protected TestConfigurationSection TestConfigurationSection { get; set; }
        //protected TestClassElement CurrentTestClassElement { get; set; }

         /// <summary>
        /// Instance based
        /// </summary>
        protected bool ExportDbStateFlag { get; private set; }
        protected string DatabaseRootDir => DbHelper.GetDatabaseRootDirFromConfig();
        protected bool TestDbStateAtEachTest
        {
            get;
            set;
        }

        #endregion protected properties 
        #region public properties

        public static string CreateStandardSchemaTemplateFilePath
        {
            get { return DbHelper.CreateStandardSchemaTemplateFilePath; }
        }

        public static string CreateSchemaTemplateFilePath
        {
            get { return DbHelper.CreateSchemaTemplateFilePath; }
        }

        public static string CreateStaticDataTemplateFilePath
        {
            get { return DbHelper.CreateStaticDataTemplateFilePath; }
        }

        public static string PopulateDynamicTestDataTemplateFilePath
        {
            get { return DbTestHelper.PopulateDynamicTestDataTemplateFilePath; }
        }

        #region static Properties

        // Used to determine the version of a test data file if not supplied
        // https://support.microsoft.com/en-us/help/3177312
        private static SortedDictionary<int, Version> SqlYrToFirstVersionMap { get; } =
            new SortedDictionary<int, Version>()
            {
                { 2012, new Version("11.0.0.0")},
                { 2013, new Version("11.0.2395.0")},    // CU 5 for SQL Server 2012
                { 2014, new Version("12.0.0.0")},
                { 2015, new Version("12.0.4100.1")},
                { 2016, new Version("13.0.0.0")},
                { 2017, new Version("14.0.0.0")},
                { 2018, new Version("14.0.3015.40")},   // CU3   - product level (in fn_get_version_info return)
                { 2019, new Version("14.0.3045.24") }   // CU12
            };

        #endregion static Properties

        #endregion  properties

        #region Public Methods
        #region Public Instance Methods
        #region constructors

        /// <summary>
        /// Calls UnitTestBase() to set-up logging
        /// POST: database exists and populated from schema create and test data files
        /// </summary>
        // / <param name="_dbTestHelper"></param>
        protected DbUnitTestBase()
        {
            LogUtils.LogS($"Derived type: {GetType().FullName}");
            Init(); // Not virtual
            LogUtils.LogL();
        }

        /// <summary>
        /// Sets the data base by first looking in the Test Class config if it exists
        /// If not then uses the database name from the configuration appSettings[DatabaseName]
        /// </summary>
        private void Init()
        {
            var className = GetType().Name;
            LogUtils.LogS($"for {className}");
            //TestConfigurationSection = TestConfigurationSection.GetConfig();
            // Could be null if not present in the test config
            //CurrentTestClassElement = TestConfigurationSection.TestClasses[className];
            var s = CurrentTestClassElement == null ? "no " : "";
            var msg = $"{className} tests have {s}test configuration";
            DatabaseName = CurrentTestClassElement?.Database;

            if (string.IsNullOrEmpty(DatabaseName))
                DatabaseName = DbHelper.GetDatabaseNameFromConfig();

            EnsureDatabaseExists(DatabaseName, false, CreateStandardSchemaTemplateFilePath, CreateSchemaTemplateFilePath, CreateStaticDataTemplateFilePath, PopulateDynamicTestDataTemplateFilePath);
            LogUtils.LogL(msg);
        }

        #endregion constructors


        /// <summary>
        /// 
        /// </summary>
        /// <typeparam name="TTbl"></typeparam>
        /// <typeparam name="TDt"></typeparam>
        /// <param name="_ctx"></param>
        /// <param name="expected"></param>
        /// <param name="i"></param>
        /// <returns></returns>
        public bool CheckRow<TTbl, TDt>(DbContext _ctx, TDt expected, int i = 0) where TTbl : class, new() where TDt : class
        {
            return DbTestHelper.CheckRow<TTbl, TDt>(_ctx, expected, i);
        }

        /// <summary>
        /// This method and its overloads test that duplicates are not allowed (as defined by a UQ or PK {Unique key or Primary key - this SQL Server speak).
        /// It checks that a DbUpdateException is thrown and also refines the check to ensure it thrown for the expected reason and not 
        /// a fail quiet issue for example an exception is thrown for another reason, like connection failure.
        /// </summary>
        /// <typeparam name="D">Table type being checked</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="dbSet">The appropriate EF Context DbSet (Table)</param>
        /// <param name="expectedMsg">One or more substrings that should be present in the error message returned by the database.</param>
        /// <returns>true if constraint exist in db, false otherwise</returns>
        public bool UniqueKeyConstraintTestHelper<D>(DbContext _ctx, DbSet<D> dbSet, string expectedMsg) where D : class, new()
        {
            return DbTestHelper.UniqueKeyConstraintTestHelper<D, object>(_ctx, dbSet, expectedMsg, null, null);
        }

        /// <summary>
        /// This method and its related UqTestHelper overloads test that duplicates are not allowed.
        /// It is the worker method for all other overloads
        /// It checks that a DbUpdateException is thrown and also refines the check to ensure it thrown for the expected reason and not 
        /// a fail quiet issue for example an exception is thrown for another reason, like connection failure.
        /// 
        /// Useful when test PK and UQ Primary and Unique Key table constraints
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="tableName">The name of the table being checked - no square brackets</param>
        /// <param name="fields">list of column names used to insert test data into the table - 
        /// PRE CONDITION: square brackets included as necessary</param>
        /// <param name="values">Set of comma separated values - include single ' for string values</param>
        /// <param name="expectedMsgs">set of expected clauses that should be present in the error message returned by the database.</param>
        /// <returns>true if constraint exist in db, false otherwise</returns>
        public bool UniqueKeyConstraintTestHelper(DbContext _ctx, string tableName, string fields, string values, string expectedMsgs)
        {
            return DbTestHelper.UniqueKeyConstraintTestHelper(_ctx, tableName, fields, values, expectedMsgs);
        }

        /// <summary>
        /// Check that the supplied fields are "not null" in the table
        /// Fields should be properties in the C# Class that is used for table
        /// </summary>
        /// <typeparam name="T">the EF C# type</typeparam>
        /// <param name="_ctx">The EF database context (PRE: state = open)</param>
        /// <param name="set">The EF dataset handling the table</param>
        /// <param name="item">A pre-populated instance of T with non null values</param>
        /// <param name="propertyNames">The comma separated set of fields that are to be tested</param>
        /// <returns>true if there exists a non null field constraint in the table for each the columns in the set defined by propertyNames, false otherwise</returns>
        public bool CheckTableFieldConstriantsNonNull<D>(DbContext _ctx, IDbSet<D> set, D item, string propertyNames) where D : class, new()
        {
            return DbTestHelper.CheckTableFieldConstriantsNonNull<D>(_ctx, set, item, propertyNames);
        }

        /// <summary>
        /// Checks that the supplied fields have a constraint that disallows the value supplied
        /// Fields should be properties in the C# Class that is used for table
        /// Will Assert if check fails
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="dbSet">The appropriate EF Context DbSet (Table) for type T</param>
        /// <param name="instance">A instance of type T with benign state that is used to add the 
        /// field with invalid state for the check constraint </param>
        /// <param name="popertyNames">the set of DB fields (1:1 with their associated Properties 
        /// on the supplied instance) to check</param>
        /// <param name="propertyValue">value  of the property to check</param>
        /// <returns>true if there exists a field constraint in the table that disallows the value 
        /// supplied for each the columns in the set defined by propertyNames, false otherwise</returns>
        public bool CheckTableFieldConstraints<D>(DbContext _ctx, IDbSet<D> dbSet, D instance, string popertyNames, object propertyValue) where D : class, new()
        {
            return DbTestHelper.CheckTableFieldConstraints<D>(_ctx, dbSet, instance, popertyNames, propertyValue);
        }

        /// <summary>
        /// This method and its overloads test that duplicates are not allowed (as defined by a UQ or PK {Unique key or Primary key - this SQL Server speak).
        /// It checks that a DbUpdateException is thrown and also refines the check to ensure it thrown for the expected reason and not 
        /// a fail quiet issue for example an exception is thrown for another reason, like connection failure.
        /// 
        /// Useful when test PK and UQ Primary and Unique Key table constraints
        /// This allows specific fields to be set
        /// PRE: (1) must be at least 1 row in the table
        /// PRE: (2) field must exist in type
        /// </summary>
        /// <typeparam name="D">Table type being checked</typeparam>
        /// <typeparam name="TP">The Property type being checked</typeparam>
        /// <param name="_ctx">The EF Context</param>
        /// <param name="dbSet">The appropriate EF Context DbSet (Table)</param>
        /// <param name="expectedMsg">set of expected clauses that should be present in the error message returned by the database.</param>
        /// <param name="propertyName">name of the property to check</param>
        /// <param name="propertyValue">value  of the property to check</param>
        /// <returns>true if constraint exist in db, false otherwise</returns>
        public bool UniqueKeyConstraintTestHelper<D, TP>(DbContext _ctx, DbSet<D> dbSet, string expectedMsg, string propertyName, TP propertyValue) where D : class, new()
        {
            return DbTestHelper.UniqueKeyConstraintTestHelper(_ctx, dbSet, expectedMsg, propertyName, propertyValue);
        }

        /// <summary>
        /// Similar to the above method, but this allows the table name to be specified it has a different name from the C# item type
        /// This is important because stored procedures taking table valued parameters use a db Type not a Table - this is a contentious issue
        /// They are very similar but not the same. A Table Type is 1:1 with a table and have the same fields
        /// Hence any generic approach using reflection will need to handle this issue
        /// </summary>
        /// <typeparam name="D">item type and database type</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="row"> row to check<</param>
        /// <returns>true if parameter row exists in the table in the db and matches it field for field, false otherwise</returns>
        public bool CheckRow<D>(DbContext _ctx, D row) where D : class, new()
        {
            return DbTestHelper.CheckRow(_ctx, row);
        }


        /// <summary>
        /// This method checks that a stored procedure returns a super set of the set of specified columns
        /// (for an EF method see below)
        /// This is an ADO.NET method of checking the rows returned it is not using EF and hence can be more generic
        /// PRE: none
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="conn">connection to the SQL server</param>
        /// <param name="storedProcedureName">name of the stored procedure to run in order to get the rows</param>
        /// <param name="paramNames">comma or tab separated list of parameter names </param>
        /// <param name="paramValues">array of parameter values</param>
        /// <param name="expectedFieldNames">comma or tab separated list of expected field names returned by the stored procedure</param>
        /// <returns>True if row found and matches, false otherwise</returns>
        public bool CheckSpRowsReturned(DbContext _ctx, SqlConnection conn, string storedProcedureName, string paramNames, object[] paramValues, string expectedFieldNames)
        {
            return DbTestHelper.CheckSpRowsReturned(_ctx, conn, storedProcedureName, paramNames, paramValues, expectedFieldNames);
        }

        /// <summary>
        /// This method uses the EF model to check that a stored procedure returns row-set 
        /// which is a super set of the set of specified columns.
        /// (for a non EF method see above)
        /// 1. Check the row count against the expected row count
        /// 
        /// 3. if the expected field values are supplied then
        ///     Check the field values of the first row
        /// 
        /// If we supplied expected values then we would expect at least 1 row
        /// 
        /// </summary>
        /// <typeparam name="T">Type of row returned</typeparam>
        /// <param name="_ctx">EF Database Context</param>
        /// <param name="returnedRowset">row-set returned by the stored procedure</param>
        /// <param name="expectedFields">expected set of fields (comma or tab separated list)</param>
        /// <param name="expectedValues">[optional] The expected values for the first row returned</param>
        /// <param name="expectedRowCount">expect count of the rows returned</param>
        /// <returns>True if row found and matches, false otherwise</returns>
        public bool CheckSpRowsReturned<D>(DbContext _ctx, ObjectResult<D> returnedRowset, string expectedFields, string expectedValues, int expectedRowCount)
        {
            return DbTestHelper.CheckSpRowsReturned(_ctx, returnedRowset, expectedFields, expectedValues, expectedRowCount);
        }

        /// <summary>
        /// This finds the row in the table
        /// Method: 
        /// create a Primary key clause using the Table information and the row to insert in an SQL to 
        /// Use the SQL to find the specific row in the table
        /// </summary>
        /// <typeparam name="TTbl">This is table type</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="row">The row as a TDt to find, it must contain at least all the fields of the associated PK</param>
        /// <returns>The found row or throws an exception if not found</returns>
        public TTbl GetRow<TTbl>(DbContext _ctx, TTbl row) where TTbl : class
        {
            return DbTestHelper.FindRow<TTbl>(_ctx, row);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <typeparam name="TTbl">This is table type</typeparam>
        /// <typeparam name="TDt">This is the equivalent data type - because of the way SQL Server uses a table type data type 
        /// when passing composite table rows  </typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="row">The row as a TDt to find, it must contain at least all the fields of the associated PK</param>
        /// <returns></returns>
        public TTbl GetRow<TTbl, TDt>(DbContext _ctx, TDt row) where TTbl : class, new() where TDt : class
        {
            return DbTestHelper.FindRow<TTbl, TDt>(_ctx, row);
        }

        /// <summary>
        /// This finds the row in the table using the supplied UQ string like: 
        ///     ID=5055  OR 
        ///     name='Fred Smith'
        /// </summary>
        /// <typeparam name="TTbl"></typeparam>
        /// <param name="ctx">The EF context</param>
        /// <param name="uqClause">Unique Key clause name='Fred Smith' </param>
        /// <returns></returns>
        public TTbl GetRow<TTbl>(DbContext ctx, string uqClause) where TTbl : class
        {
            return DbTestHelper.FindRow<TTbl>(ctx, uqClause);
        }

        /// <summary>
        /// Dump a table to debug
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="tableName"> the name of the table - no square brackets</param>
        public void DumpTable(DbContext _ctx, string tableName)
        {
            DbTestHelper.DumpTable(_ctx, tableName);
        }

        public void DumpTables(DbContext ctx, string text)
        {
            LogUtils.LogI($"\nDump tables: {text}");
            DumpTable(ctx, "Sector");
        }

        public string RemoveComments(string sql)
        {
            return DbHelper.RemoveComments(sql);
        }

        /// <summary>
        /// Use this on Report type stored procedures that take simple scalar parameters
        /// Enumerates the fields and values returned from row 0
        /// PRE: connection is not null
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="conn">an open SqlConnection</param>
        /// <param name="storedProcedureName">name of the stored procedure</param>
        /// <param name="paramNames">comma or tab separated list of parameter names</param>
        /// <param name="paramValues">array of parameter values</param>
        /// <param name="expectedFieldNames">comma or tab separated list of expected field names</param>
        public void EnumerateSpReturnedFields(DbContext     _ctx,
                                              SqlConnection conn,
                                              string        storedProcedureName,
                                              string        paramNames,
                                              object[]      paramValues,
                                              string        expectedFieldNames)
        {
            DbTestHelper.EnumerateSpReturnedFields(_ctx, conn, storedProcedureName, paramNames, paramValues, expectedFieldNames);
        }

        /// <summary>
        /// This routine maps the operation type and SQL Server Major Version (Like SQL2016) to the expected script file name
        /// Different versions of the SQL Server Scriptor class are producing slightly different outputs
        /// Particularly SQL 2016 and SQL 2017
        /// 
        /// </summary>
        /// <param name="dbOpType"></param>
        /// <param name="sqlServerVersion"></param>
        /// <returns>Expected script file name (not full path)</returns>
        public string GetExpectedScripFileNameForDbOptypeAndSqlMajorVersion(DbOpType dbOpType, SqlServerVersion sqlServerVersion)
        {
            var majorVersion = sqlServerVersion.GetAlias().Substring(0, 4).ToLower();
            return $"{dbOpType.GetAlias().ToLower()} {majorVersion} expected.sql";
        }

        /// <summary>
        /// This routine maps the operation type no operation type to the expected script file name
        /// use this for SQL version independent scripts
        /// Particularly SQL 2016 and SQL 2017
        /// </summary>
        /// <param name="dbOpType"></param>
        /// <returns>Expected script file name (not full path)</returns>
        public string GetExpectedScripFileNameForDbOptype(DbOpType dbOpType)
        {
            return $"{dbOpType.GetAlias().ToLower()} expected.sql";
        }

        /// <summary>
        /// In-line version of the above
        /// </summary>
        /// <param name="version"></param>
        /// <returns>expanded version or null</returns>
        public string Expand(string version)
        {
            var tmp = version;

            if (!Expand(ref tmp))
                tmp = null;

            return tmp;
        }

        /// <summary>
        /// Saves the initial state of a test before running it 
        /// ready for comparison later in the test cleanup
        /// The Db State should be unaltered by the test.
        ///
        /// The CurrentDatabaseName is set by first looking in the test config,
        ///     then if not found in app settings[Database Name]
        /// 
        /// call from test setup or similar
        /// 
        /// PRE: expects the following to be set:
        ///     CurrentTestClassElement
        /// 
        /// POST: the following are set
        ///     CurrentTestMethodName
        ///     CurrentDatabaseName
        ///     if ExportDbStateFlag set then
        ///         there exists the initial export file
        ///         the database will be created
        /// </summary>
        [TestInitialize]
        public override void TestSetup()
        {
            LogUtils.LogS($"for {TestContext.TestName}");
            // Setup general test config like method related config
            base.TestSetup();
            // Set up any db related config
            ExportDbStateFlag = CurrentTestClassElement?.CheckDbState ?? false;
            CurrentDatabaseName = CurrentTestTestMethodElement?.Database;

            if (string.IsNullOrEmpty(CurrentDatabaseName))
                CurrentDatabaseName = DbHelper.GetDatabaseNameFromConfig();

            Assert.IsFalse(string.IsNullOrEmpty(CurrentDatabaseName));  // POST 2

            if (ExportDbStateFlag)
            {
                if(!DatabaseExists(CurrentDatabaseName))
                    CreateDatabase(CurrentDatabaseName);

                var exportFilePath = CreateDbExportFileName(CurrentDatabaseName, CurrentTestMethodName, true);
                ExportDbState(CurrentDatabaseName, exportFilePath);
                Assert.IsTrue(File.Exists(exportFilePath) && new FileInfo(exportFilePath).Length > 0); // POST 3
            }

            LogUtils.LogL($"CurrentDatabaseName = {CurrentDatabaseName}");
        }

        /// <summary>
        /// If the ExportDbStateFlag is set then run a PRE test/post test check on the db state
        /// call from the test cleanup or similar
        /// </summary>
        [TestCleanup]
        public override void TestCleanup()
        {
            Assert.IsTrue(CurrentTestMethodName.Equals(TestContext.TestName));
            CheckDbState(); // If the ExportDbStateFlag is set then run a PRE test/post test check on the db state
            base.TestCleanup();
        }

        /// <summary>
        /// If the ExportDbStateFlag is set then run a PRE test/post test check on the db state
        /// </summary>
        protected void CheckDbState()
        {
            if (ExportDbStateFlag)
            {
                var initialStateFilePath = CreateDbExportFileName(CurrentDatabaseName, CurrentTestMethodName, true);
                var finalStateFilePath = CreateDbExportFileName(CurrentDatabaseName, CurrentTestMethodName, false);
                ExportDbState(CurrentDatabaseName, finalStateFilePath);

                var match = TestHelper.CompareScriptFiles(initialStateFilePath, finalStateFilePath, out var errorMsg);

                if(!match)
                    Utils.Assertion(match, errorMsg);
            }
        }


        /// <summary>
        /// Maps the call to its DbHelper delegate
        /// </summary>
        /// <param name="dbName"></param>
        /// <param name="dataSource"></param>
        /// <returns></returns>
        public string GetConnectionString(string dbName, string dataSource = null)
        {
            return DbHelper.GetConnectionString(dbName, dataSource);
        }

        #endregion Public Instance Methods
        #region Public Static Methods

        [ClassInitialize]
        public new static void ClassSetup(TestContext ctx)
        {  
            LogUtils.LogS();
            // Register the test configuration for this class
            UnitTestBase.ClassSetup(ctx);

            var className = ctx.FullyQualifiedTestClassName.Split('.').Last();
            var testClassElement = GetTestClassElement(className);//TestConfigurationSection.GetConfig().TestClasses[className];
            var doDbChk = testClassElement?.CheckDbState ?? false;

            // if a check is required at class level or above
            if (doDbChk)
            {
                var database = testClassElement.Database;

                if (!DatabaseExists(database))
                    CreateDatabase(database);

                var exportFilePath = CreateDbExportFileName(database, "class", true);
                ExportDbState(database, exportFilePath);
                Assert.IsTrue(File.Exists(exportFilePath) && new FileInfo(exportFilePath).Length > 0); // POST 3
            }
            
            LogUtils.LogL();
        }

        /// <summary>
        /// called by sub class - passing the class name at the end of the class tests
        /// </summary>
        /// <param name="testClassName"></param>
        public new static void ClassCleanup(string testClassName)
        {
            LogUtils.LogS();
            var testClassElement = GetTestClassElement(testClassName);

            // if a check is required at class level or above
            if (testClassElement.CheckDbState ?? false)
            {
                var database = testClassElement.Database;
                var initialStateFilePath = CreateDbExportFileName(database, "class", true);
                var finalStateFilePath   = CreateDbExportFileName(database, "class", false);
                ExportDbState(database, finalStateFilePath);
                var match = TestHelper.CompareScriptFiles(initialStateFilePath, finalStateFilePath, out var errorMsg);

                if(!match)
                   Utils.Assertion(match, errorMsg);
            }

            UnitTestBase.ClassCleanup(testClassName);
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
            return DbHelper.DatabaseExists(databaseName);
        }

        #endregion Public Static Methods
        #endregion Public Methods
        #region Protected Methods
        #region Protected Instance Methods

        /// <summary>
        /// Expands a string containing dots
        /// Intended for use with strings that contain version numbers
        /// Will convert any substring .{int}. so that the int is padded with up to 4 leading zeros  
        ///  
        /// e.g. 1.200.5Animal.3000.40000  becomes 0001.00200.5Animal.03000.4000
        /// 
        /// </summary>
        /// <param name="version"></param>
        /// <returns></returns>
        protected bool Expand(ref string version)
        {
            var parts = version.Split(".".ToCharArray());
            var newVersion = "";

            var i = 0;

            foreach (var part in parts)
            {
                if (i > 0)
                    newVersion += ".";

                newVersion += (Int32.TryParse(part, out i) ? $"{i:00000}" : part);
                i++;
            }

            version = newVersion;
            return true;
        }

        /// <summary>
        /// Ensure the database exists
        /// if drop first is specified and the database exists it then will drop the existing database first
        /// if it does not exist then it is created and populated with schema and static data
        /// </summary>
        /// <param name="dbName">if name is null or empty then take from config</param>
        /// <param name="dropFirst"></param>
        /// <param name="scriptFilePaths">optional db creation scripts</param>
        protected static void EnsureDatabaseExists(string dbName = null, bool dropFirst = false, params string[] scriptFilePaths)
        {
            DbHelper.EnsureDatabaseExists(dbName, dropFirst, scriptFilePaths);
        }

        /// <summary>
        /// This is the standard create database method, 0-3 SQL scripts can be passed to it to populate the created database
        /// N.B. the database could be created empty  OR
        /// could use just 1 populate script to do all the work (set up the tables, and populate them
        /// But 3 scripts are typically used in line with the 3 script model (Script 0: create schema, script 1: populate static data, script2: populate "dynamic" or test data
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="dropFirst"></param>
        /// <param name="standardStoredProceduresTemplateFilePath">standard functionality common to any database</param>
        /// <param name="schemaTemplateFilePath">schema specific to this database</param>
        /// <param name="staticDataFilePath">static data</param>
        /// <param name="dynamcDataFilePath">optional third script - usually populate "dynamic" data</param>
        protected static void CreateDatabase(string databaseName, bool dropFirst = true, string standardStoredProceduresTemplateFilePath = null, string schemaTemplateFilePath = null, string staticDataFilePath = null, string dynamcDataFilePath = null)
        {
            DbTestHelper.EnsureScriptPathsPopulated(ref standardStoredProceduresTemplateFilePath, ref schemaTemplateFilePath, ref staticDataFilePath, ref dynamcDataFilePath);
            DbHelper.CreateDatabase(databaseName, dropFirst, standardStoredProceduresTemplateFilePath, schemaTemplateFilePath, staticDataFilePath, dynamcDataFilePath);
        }

        /// <summary>
        /// Drop a specific database
        /// </summary>
        /// <param name="dbName"></param>
        protected static void DropDatabase(string dbName)
        {
            DbHelper.DropDatabase(dbName);
        }

        /// <summary>
        /// Compare two scripts. Script line order matters.
        /// </summary>
        /// <param name="expectedScriptFilePath">The expected script file path.</param>
        /// <param name="actualScriptFilePath">The actual script file path.</param>
        /// <param name="databaseName"></param>
        /// <param name="errorMsg">An error message.</param>
        /// <returns>The result.</returns>
        protected bool CompareDatabaseScripts(string expectedScriptFilePath, string actualScriptFilePath, string databaseName, out string errorMsg)
        {
            return DbTestHelper.CompareDatabaseScripts(expectedScriptFilePath, actualScriptFilePath, databaseName, out errorMsg);
        }

        /// <summary>
        /// Returns an expected test file name like ...x64\debug\\Tracking\TestData\create schema expected.sql
        /// If version file not found we may need to regress to either the Major version (SQL2016 or SQL 2017) specific file 
        /// or the non version base test file like
        /// e.g.
        /// drop database 2016 13.0.4210.6 expected.sql -> drop database 2016 expected.sql -> drop database expected.sql
        /// </summary>
        /// <param name="opType"></param>
        /// <param name="dir">directory holding the expected template file</param>
        /// <param name="useThisTestFile">overriding file - if specified</param>
        /// <returns>the expected file path or throws an exception if it cannot</returns>
        protected string GetExpectedTemplateScriptFilePath(DbOpType opType, string dir)//, string useThisTestFile = null)
        {
            // Get the SQL version information from the database engine
            var versionRow = DbHelper.GetDbVersionInfo();

            // Map to its enum using its alias
            return GetExpectedScripFileNameForDbOptypeAndSqlVersion(opType, versionRow, dir);
        }

        /// <summary>
        /// This method creates the candidate map for an OPType and a folder
        /// </summary>
        /// <param name="dir">folder holding the expected files</param>
        /// <param name="dbOpTypeAlias"></param>
        /// <returns></returns>
        protected TreeDictionary<Version, string> CreateCandidateVersionMap(string dir, string dbOpTypeAlias)
        {
            TreeDictionary<Version, string> candidateVersionMap = new TreeDictionary<Version, string>();
            // Make a list of all expected files for the op type
            // Format { op type alias} [SQL Server year] [version or part thereof].SQL
            var fileMask = $"{dbOpTypeAlias}* expected.sql";
            // Make a map of expected files for the OPtype in  most exacting last order
            // Map - sort order - need to remove the "expected" to get a proper sort order based on most exacting last
            var candidates = Directory.EnumerateFiles(dir, fileMask);

            foreach (var candidate in candidates)
            {
                // strip any path
                var fileName = candidate.Contains('\\') ? (candidate.Substring(candidate.LastIndexOf('\\') + 1)) : candidate;
                candidateVersionMap.Add(GetVersionFromFileName(fileName), candidate);
            }

            return candidateVersionMap;
        }

        /// <summary>
        /// This method extracts the version from a candidate expected test script file name
        /// It should handle full and part versions and no versions
        /// handle year and no year
        /// Expect file name like: create database 2016 101.20200.4016 expected.sql
        /// Return default version for year if year is specified, but not version parts are
        /// Not all have versions
        /// It should throw an invalid argument exception if:
        ///     the file name is null or empty
        ///     the filename contains slashes
        /// </summary>
        /// <param name="fileName">file name containing the version</param>
        /// <returns>A Version</returns>
        protected Version GetVersionFromFileName(string fileName)
        {
            Utils.Assertion<ArgumentException>(!string.IsNullOrEmpty(fileName));
            Utils.Assertion<ArgumentException>(!fileName.Contains('\\'));
            // Split
            var parts = fileName.Split(" ".ToCharArray());
            var v = new List<int>();
            int year = 0;

            // Find the first part with a point in
            foreach (var part in parts)
            {
                // If all integer then expect year
                if ((part.Length == 4) && (int.TryParse(part, out year)))
                    continue;

                // May be no version -> .sql
                if (!part.Contains('.'))
                    continue;

                // If here then part contains points so could be version or the .sql if no version
                var versionItems = part.Split(".".ToCharArray());

                // Must be a version
                foreach (var versionItem in versionItems)
                {
                    if (!int.TryParse(versionItem, out var versionInt))
                        break;

                    v.Add(versionInt);
                }

                // Break if we started to find version numbers
                // Parsing is then complete
                if (v.Any())
                    break;
            }

            // Return default version for year if year is specified, but not version parts are
            if ((year > 0) && (v.Count == 0))
            {
                if (year > SqlYrToFirstVersionMap.Keys.Max())
                    year = SqlYrToFirstVersionMap.Keys.Max();

                if (SqlYrToFirstVersionMap.ContainsKey(year))
                    return SqlYrToFirstVersionMap[year];
            }

            while (v.Count < 4)
                v.Add(0);

            Utils.Assertion(v.Count == 4, "GetVersionFromFileName: should have 0-4 version number parts");
            return new Version(v[0], v[1], v[2], v[3]);
        }

        /// <summary>
        /// This routine maps the operation type and SQL Server Version to the expected script file name
        /// Different versions of the SQL Server Scriptor class are producing slightly different outputs
        /// Particularly SQL 2016 and SQL 2017
        /// 
        /// To find the expected file we need either an exact match or the best fit that is less than or equal to the version
        /// The problem is that the version number need to be modified slightly (padded with leading zeros) before they can be compared in alphabetic order.
        /// To do this we can expand the version numbers  so that 15.5.101.2601 is less than say 15.1000.23.001
        /// pad out with leading zeros then  00015.00005.00101.02601 is less than 00015.01000.00001
        /// 
        /// Algorithm:
        /// Create a expected file name unexpanded
        /// Try for an exact match
        /// 
        /// If found
        ///     return that one
        /// 
        /// Expand the db version
        /// 
        /// Format {op type alias} [SQL Server year] [version or part thereof].SQL
        /// 
        /// Make a list of the test files in the test directory like {op type} * {expanded(version)} expected.sql  in reverse alphabetic order
        /// List the files in the directory that start with OP type and end with expected.sql in alphabetic order
        /// Descending the list find the first file whose file name that is less than or equal padded version
        /// 
        /// If found
        ///     use it
        /// else
        ///     error
        /// </summary>
        /// <param name="dbOpType"></param>
        /// <param name="sqlServerVersion">version information of the SQL db - expects 9 fields as per
        /// the database table valued function fn_get_db_version_info() return type</param>
        /// <param name="dir">test directory (absolute or relative)</param>
        /// <returns>Expected script file name (not full path)</returns>
        protected string GetExpectedScripFileNameForDbOptypeAndSqlVersion(DbOpType dbOpType, DataRow sqlServerVersion, string dir)
        {
            Assert.IsTrue(Directory.Exists(dir), $"Directory does not exist [{dir}]");
            // Try full versioned file name first like "drop schema 2016 13.0.4210.6 expected.sql"
            var ret = FindBestExpectedFileForDbOptypeAndSqlVersion(dbOpType, sqlServerVersion, dir, out var filePath);
            Assert.IsTrue(ret, $"No test file can be found for {dbOpType.GetAlias().ToLower()} in folder [{dir}]");

            // ASSERTION: if here then a test file has been found
            return filePath;
        }

        /// <summary>
        /// Finds best match expected file name for OP type and SQL version in a directory
        /// 
        /// Algorithm:
        /// Create a expected file name unexpanded
        /// Try for an exact match
        /// If found
        ///     return it
        /// Else
        ///   get the best fit
        /// 
        /// Format {op type alias} [SQL Server year] [version or part thereof].SQL
        /// 
        /// Throws:
        ///     DirectoryNotFoundException if DIR is invalid
        /// </summary>
        /// <param name="dbOpType"></param>
        /// <param name="sqlServerVersionInfo">version information of the SQL db - expects 9 fields as per
        /// the database table valued function fn_get_db_version_info() return type</param>
        /// <param name="dir"></param>
        /// <param name="filePath">returns best fit expected file</param>
        /// <returns>true if candidate found, filePath by ref, false otherwise</returns>
        protected bool FindBestExpectedFileForDbOptypeAndSqlVersion(DbOpType dbOpType, DataRow sqlServerVersionInfo, string dir, out string filePath)
        {
            var dbOpTypeAlias = dbOpType.GetAlias().ToLower();
            dir = Path.GetFullPath(dir);
            var sqlServerVersion = sqlServerVersionInfo["product_version"].ToString();
            var year = sqlServerVersionInfo["db_version"].ToString().Substring(3);
            // Try full versioned file name first like "drop schema 2016 13.0.4210.6 expected.sql"
            filePath = $"{dir}\\{dbOpTypeAlias} {year} {sqlServerVersion} expected.sql";

            // Look for exact match
            if (File.Exists(filePath))
                return true;

            return FindBestFitExpectedFile(dbOpTypeAlias, sqlServerVersionInfo, dir, out filePath);
        }

        /// <summary>
        /// This method will find the closest test version file that is either equal or 
        /// the closest version less than the required version
        /// See: https://stackoverflow.com/questions/26564329/find-largest-dictionaryint-string-key-whose-value-is-less-than-the-search-valu  (1- Cory Nelson)
        /// Throws:
        ///     DirectoryNotFoundException if DIR is invalid
        /// </summary>
        /// <param name="dbOpTypeAlias"></param>
        /// <param name="sqlServerVersionInfo">version info row for this Sql server</param>
        /// <param name="dir"></param>
        /// <param name="filePath"></param>
        /// <returns>true if can find a match, false if no candidates found</returns>
        protected bool FindBestFitExpectedFile(string dbOpTypeAlias, DataRow sqlServerVersionInfo, string dir, out string filePath)
        {
            // Map candidate expected files against their minimum version
            var candidateVersionMap = CreateCandidateVersionMap(dir, dbOpTypeAlias);
            var version = new Version(sqlServerVersionInfo["product_version"].ToString());
            var last = candidateVersionMap.RangeTo(version).Backwards().FirstOrDefault(); // Order N
            filePath = last.Value;
            return !string.IsNullOrEmpty(filePath);
        }

        #endregion Protected methods
        #region Protected Static Methods

        /// <summary>
        /// Drop a set of databases associated with a test class
        /// Typically called from the Class Clean-up method to clean-up any failed tests
        /// The idea being that successful test clean-up their specific databases, but any failed tests leave the data base intact for debugging
        /// However on the build server all databases will be cleaned up at the end of a test run regardless of success
        /// </summary>
        /// <param name="databases"></param>
        protected static void DropDatabases(string[] databases)
        {
            DbTestHelper.DropDatabases(databases);
        }

        /// <summary>
        /// Create the standard database for the tests 
        /// </summary>
        /// <param name="testContext"></param>
        /// <param name="mainDatabaseName">The database to create before the test run
        /// This database should last the life time of the test class instance and not be written to
        /// If it is written to then:
        ///     the test should be sequential
        ///     and each test must replace its state</param>
        /// <param name="forceCreateDb">optional, use this to force create the database. 
        /// Be careful: if this is used by other classes then creation of db whilst another test is running 
        /// will be a problem that is hard to spot</param>
        protected static void ClassSetup(TestContext testContext, string mainDatabaseName = null, bool? forceCreateDb = false)
        {
            LogUtils.LogS();

            if (string.IsNullOrEmpty(mainDatabaseName))
            {
                LogUtils.LogL("returned doing nothing as the main database for this test class was not supplied");
                return;
            }

            // ASSERTION:  if here then mainDatabaseName is not null
            var isConfiguredDb = mainDatabaseName.Equals(DbHelper.GetDatabaseNameFromConfig());

            // Only drop if forCreateDb is true else the database is not the configured database
            var createDb = forceCreateDb ?? !isConfiguredDb;
            var msg = createDb ? "" : "not ";
            DbHelper.EnsureDatabaseExists(mainDatabaseName, createDb);

            // Export the static and dynamic data
            ExportDbState(mainDatabaseName, $"{mainDatabaseName} Class Initial State.sql");
            LogUtils.LogL();
        }


        /// <summary>
        /// This exports the data from the database and compares with an expected file
        /// </summary>
        /// <param name="databaseName">database to check</param>
        /// <param name="expectedStateFile">file to compare with</param>
        /// <param name="errorMsg">reported error</param>
        protected static bool CheckDbState(string databaseName, string expectedStateFile, out string errorMsg)
        {
            // Export the final db state and compare with the original - should be the same
            Utils.Assertion(File.Exists(expectedStateFile), $"Final Database state for {databaseName} could not be checked as expected file not found: {expectedStateFile}");
            Assert.IsTrue(new FileInfo(expectedStateFile).Length > 0, $"The expected state file: {expectedStateFile} is empty");
            var finalStateFilePath = Path.GetFullPath($"{databaseName} Final State.sql");
            ExportDbState(databaseName, finalStateFilePath);
            var ret = TestHelper.CompareScriptFiles(expectedStateFile, finalStateFilePath, out errorMsg);

            // Debug aid so we can break before Exception stops us editing
            if (!ret)
                LogUtils.LogE("errorMsg");

            return ret;
        }

        /// <summary>
        /// This checks that the database against the expected state file
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="expectedStateFile"></param>
        protected static void AssertDbState(string databaseName, string expectedStateFile)
        {
            Assert.IsTrue(CheckDbState(databaseName, expectedStateFile, out var errorMsg), errorMsg);
        }

        protected static void ExportDbState(string databaseName, string scriptPath)
        {
            LogUtils.LogS($"Exporting database {databaseName}");
            scriptPath = Path.GetFullPath(scriptPath);
            var exporter = new SqlExportScriptor();
            exporter.Export(databaseName, DbOpType.ExportDynamicData, scriptPath);
            var msg = $"Failed to export the state for database: {databaseName} to file: {scriptPath}";
            Assert.IsTrue(File.Exists(scriptPath), msg);
            Assert.IsTrue(new FileInfo(scriptPath).Length > 0, msg);
            LogUtils.LogL();
        }

        #endregion protected Static Methods
        #endregion Protected Methods
        #region Private Methods

        private static string CreateDbExportFileName(string databaseName, string methodName, bool isSetup)
        {
            var s = isSetup ? "Initial" : "Final";
            return Path.GetFullPath($"{databaseName} {methodName} {s} State.sql");
        }

        #endregion Private Methods
    }
}

