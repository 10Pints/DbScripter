// SqlExportScriptor.cs
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using Microsoft.SqlServer.Management.Sdk.Sfc;
using Microsoft.SqlServer.Management.Smo;
using SI.Common.Extensions;
using SI.Logging;
using SI.Logging.LogUtilities;
using SI.Common;

namespace RSS
{
    /// <summary>
    /// This class is a universal exporter of any SQL database schema and data
    /// It uses the Microsoft.SqlServer.Management.Smo.Scripter class to export the scripts
    /// 
    /// Scripts functions are:
    ///     Create Database
    ///     Create Schema      (tables and stored procedures etc.
    ///     Create static data  (populate the fixed data like LightMode constants and Colony Format types
    ///     DropDatabase the database
    /// 
    /// The scripts are standard SQL scripts - and as such can be used any SQL interpreter
    /// There is another significant use data backups
    /// 
    /// By using standard SQL two advantages are available:
    ///     1. Can easily test on any database
    ///     2. Can filter the backups based on criteria like time span
    ///         e.g. Backup all Project related data for the last month
    ///         This would keep backups small and relevant, 
    ///         Bigger restores could be achieved by iterating several backups - e.g. in a directory
    /// </summary>
   public class DbScripter
    {
        #region  private fields

        private const string GO = "GO";

        #endregion
        #region properties

/*
        /// <summary>
        /// This set of tables is used when exporting static data
        /// </summary>
        public List<string> StaticDataTables
        {
            get;
            set;
        } = new List<string>();
*/

        /// <summary>
        /// Status of object construction - a check that the important properties are populated
        /// </summary>
        public bool Status { get; protected set; } = false;

        /// <summary>
        /// Export file path
        /// </summary>
        public string ExportFilePath { get; set; }

        public Server Server { get; set; }
        public Database Database { get; set; }
        public ScriptingOptions Options { get; set; }

        public DbOpType OpType { get; set; }
        public Scripter Scripter { get; set; }
        public StreamWriter Writer { get; set; }
        public string DatabaseName => Database.Name; 
        #endregion properties

        #region public methods
        /// <summary>
        /// Main constructor
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="opType"></param>
        /// <param name="writerFilePath"></param>
        /// <param name="staticDataTables">Tables to export data from</param>
        public DbScripter(string databaseName = null, /*DbOpType opType = DbOpType.Undefined,*/ string writerFilePath = null/*, string staticDataTables = null*/)
        {
            if (!string.IsNullOrEmpty(databaseName))
                Init(databaseName, writerFilePath/*, staticDataTables*/);
        }


        /// <summary>
        /// Exports all stored procedures and functions
        /// </summary>
        /// <returns>Serialisation of all the user functions and user stored procedures as a set of SQL statements</returns>
        public string ExportRoutines()
        {
            var sb = new StringBuilder();
            ExportFunctions(sb);
            ExportProcedures(sb);
            return sb.ToString();
        }

        /// <summary>
        /// Initialize state, deletes the writerFilePath file if it exists
        /// Only completes the initialisation if the parameters are all specified
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="opType"></param>
        /// <param name="writerFilePath"></param>
        /// <param name="staticDataTables"></param>
        /// <returns>Status</returns>
        public bool Init(string databaseName, /*DbOpType opType, */string writerFilePath/*, string staticDataTables = null*/)
        {
            Status = false;

            if (string.IsNullOrEmpty(databaseName))
                databaseName = DatabaseName;

            //Utils.Assertion(!string.IsNullOrEmpty(databaseName));

            //FeedbackComponentProvider.Append(this, "Init", $"\ndatabaseName:   [{databaseName}] " +
            //                                               $"\nopType:         [{opType.GetAlias()}], " +
            //                                               $"\nwriterFilePath: [{writerFilePath}]");

            InitServer(databaseName);

            try
            {
                //InitStaticDataTables(staticDataTables);
                //InitOpType(opType);
                //FeedbackComponentProvider.Append(this, "Init", $"Creating StreamWriter object path: [{writerFilePath}]");
                // InitWriter calls IsValid() - returns the Validation status - 
                // NOTE: can continue if not all initialised so long as the final init is performed before any write op
                Status = InitWriter(writerFilePath);
            }
            catch (Exception e)
            {
                //LogUtils.LogException(e);
                throw;
            }

            return Status;
        }

        #endregion public methods
        #region private methods

        /// <summary>
        /// Validates the initialization
        /// </summary>
        /// <returns></returns>
        private bool IsValid( )
        {
            var isValid = false;

            do
            {
                if(OpType == DbOpType.Undefined)
                {
                    //FeedbackComponentProvider.Append(this, "Init", $"validation failed: OpType not initialised");
                    break;
                }

                if (Writer == null)
                {
                    //FeedbackComponentProvider.Append(this, "Init", $"validation failed: writer not initialised");
                    break;
                }

                // Lastly if here then all checks have passed
                isValid = true;
                //FeedbackComponentProvider.Append(this, "Init", $"validation succeeded");
            } while (false);

            return isValid;
        }

        /// <summary>
        /// Initializes file writer if writerFilePath is a valid path
        /// calls IsValid at end
        /// POST: writer open pointing to the export file AND
        ///       writer file same as ExportFilePath and both equal exportFilePath parameter
        /// </summary>
        /// <param name="exportFilePath"></param>
        /// <returns>Result of the validity check</returns>
        private bool InitWriter(string exportFilePath)
        {
            if (string.IsNullOrEmpty(exportFilePath))
                return false;

            exportFilePath = Path.GetFullPath(exportFilePath);
            //FeedbackComponentProvider.Append(this, "InitWriter", "starting");

            // Could be called twice - once from Init and once from the Export function
            if ((ExportFilePath != null) && (ExportFilePath.Equals(exportFilePath, StringComparison.OrdinalIgnoreCase)))
            {
                // Check all is correct
                //Utils.Assertion((Writer != null) && ((FileStream)(Writer.BaseStream)).Name.Equals(exportFilePath, StringComparison.OrdinalIgnoreCase));
                return true; // Second call
            }

            // Assertion if here then either writer not initialised or new export file name
            if (!string.IsNullOrEmpty(exportFilePath))
            {
                // If writer is open close it
                Writer?.Close();
                ExportFilePath = exportFilePath;

                if (File.Exists(exportFilePath))
                    File.Delete(exportFilePath);

                var fs = new FileStream(exportFilePath, FileMode.CreateNew);

                Writer = new StreamWriter(fs)
                {
                    AutoFlush = true
                }; // writerFilePath AutoFlush = true debug to dump cache immediately
            }

            var ret = IsValid();
            var msg = ret ? "" : "not";
            //FeedbackComponentProvider.Append(this, "Init", $"the Scriptor object is {msg} fully initialised.");
            return ret;
        }

        /// <summary>
        /// Initializes server connectio - default database: databaseName
        /// </summary>
        /// <param name="databaseName"></param>
        private void InitServer(string databaseName)
        {
            //FeedbackComponentProvider.Append(this, "Init", "Creating Server object.");
            Utils.Assertion(!string.IsNullOrEmpty(databaseName), "databaseName not specified");
            // 1 offs rarely if ever change
            var serverName = DbHelper.GetServerNameFromConfig();
            var instance   = DbHelper.GetInstanceNameFromConfig();
            //Utils.Assertion(!string.IsNullOrEmpty(serverName), "Server not specified");
            //Utils.Assertion(!string.IsNullOrEmpty(instance),   "Instance not specified");

            var scb = new SqlConnectionStringBuilder
            {
                ["Data Source"] = $"{serverName}\\{instance}",
                ["integrated Security"] = true,
                ["Initial Catalog"] = databaseName
            };

            var sqlConnection = new SqlConnection(scb.ToString());
            var serverConnection = new Microsoft.SqlServer.Management.Common.ServerConnection(sqlConnection);
            Server = new Server(serverConnection);
            //Utils.Assertion(Server != null, "Could not create Server object");

            //FeedbackComponentProvider.Append(this, "Init", $"Getting the SMO database object for  object for the database name: [{databaseName}].");
            if (!Server.Databases.Contains(databaseName))
                Server.Refresh();

            //if (!Server.Databases.Contains(databaseName))
                //Utils.Assertion<ConfigurationException>(Server.Databases.Contains(databaseName), $"database {databaseName} not found");

            // ASSERTION: if here then database exists

            Database = Server.Databases[databaseName];
            //Utils.Assertion<ConfigurationException>(Database != null, $"database {databaseName} not found");

            // ASSERTION: if here then database found

            // Smo.Database does not seem to pick-up this property
            // ReSharper disable once PossibleNullReferenceException
            if (Database.TargetRecoveryTime == 0)
            {
                var dbTargetRecoveryTime = ConfigurationManager.AppSettings["DatabaseTargetRecoveryTime"];

                if (!string.IsNullOrEmpty(dbTargetRecoveryTime))
                    Database.TargetRecoveryTime = Convert.ToInt32(dbTargetRecoveryTime);
            }
        }

        /// <summary>
        /// Encapsulates the scripter options and OPType setup
        /// </summary>
        /// <param name="opType"></param>
        private void InitOpType(DbOpType opType)
        {
            // Bow out quick if default
            if (opType == DbOpType.Undefined)
                return;

            OpType = opType;
            //FeedbackComponentProvider.Append(this, "Init", "Creating Scripter object.");
            Scripter = new Scripter(Server);
            //FeedbackComponentProvider.Append(this, "Init", "Creating ScriptingOptions object.");
            var noGoflag = (opType == DbOpType.CreateStaticData);

            Options = new ScriptingOptions()
            {
                IncludeDatabaseContext = false,  // Do not Script the USE Database line
                AllowSystemObjects = false,
                AnsiPadding = false,
                AppendToFile = true, // needed if we use script builder repetitively
                IncludeIfNotExists = false,
                ContinueScriptingOnError = false,
                ConvertUserDefinedDataTypesToBaseType = false,
                WithDependencies = false, //= true Smo.FailedOperationException true, Unable to cast object of type 'System.DBNull' to type 'System.String'.
                IncludeHeaders = false, // true,

                // Include Scripting Parameters Header: False
                // Include system constraint names: False
                // Include unsupported statements: False
                Bindings = false, // Script Bindings: False
                NoCollation = true, // Script Collation: False
                DriDefaults = true, // Script Defaults: True
                                    // Script DROP and CREATE: Script CREATE
                ExtendedProperties = true, // Script Extended Properties: True
                // FileName                                = scripterFilePath, redundant now we know how to get around the bug in populate the script with GO statements
                NoIdentities = true, // From SQL Man,Studio/Tools/Options/SQL Server Object Explorer/Scripting
                                     // Script for Server Version: SQL Server 2017
                                     // Script for the database engine edition: Microsoft SQL Server Standard Edition
                                     // Script for the database engine type: Stand - alone instance
                                     // Script LogUtils.LogIns: False
                                     // Script Object - Level Permissions: False
                                     // Script Owner: False
                                     // Script Statistics: Do not script statistics
                                     // Script USE DATABASE: True
                                     // Types of data to script: Schema only

                // Table / View Options
                // Script Change Tracking: False
                // Script Check Constraints: True
                // Script Data Compression Options: False
                // Script Foreign Keys: True

                SchemaQualifyForeignKeysReferences = true, // 
                                                           // Script Full - Text Indexes: False

                DriIndexes = true,              // Script Indexes: True
                DriPrimaryKey = true,           // Script Primary Keys: True
                                                // Script Triggers: False
                DriUniqueKeys = true,           // Script Unique Keys: True

                ScriptBatchTerminator = false,
                // Exclude GOs after every line

                NoCommandTerminator = noGoflag, // false means should emit GO statements - don't emit GO statements after every SQL insert statement for static data
                Indexes = true,
                DriForeignKeys = false,         // We script FKs later after all tables so that dependencies work
                DriAll = false,
                DriAllKeys = false,
                // https://gist.github.com/vincpa/1755925
                Permissions = false,
                DriAllConstraints = true,       // include referential constraints in the script
                SchemaQualify = true,           // Schema qualify object names.: True e.g. [dbo]
                AnsiFile = true,
                //SchemaQualifyForeignKeysReferences= true;
                //Indexes                           = true,
                //DriIndexes                        = true,
                DriClustered = true,
                DriNonClustered = true,
                NonClusteredIndexes = true,
                ClusteredIndexes = true,
                FullTextIndexes = true,
                EnforceScriptingOptions = true,
            };

            //FeedbackComponentProvider.Append(this, "Init", "Created ScriptingOptions object.");
            // Modified per op Type
            Options.ScriptData = opType == DbOpType.CreateStaticData; // More needed here to filter the static data only - now done in Export Tables
            Options.ScriptSchema = opType != DbOpType.CreateStaticData;
            Options.ScriptDrops = (opType == DbOpType.DropDatabase) || (opType == DbOpType.DropSchema) || (opType == DbOpType.DropTables) || (opType == DbOpType.DropProcedures) || (opType == DbOpType.DropStaticData);

            Scripter.Options = Options;
        }


        /// <summary>
        /// PRE: assumes initialised upto the 
        /// 
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="opType"></param>
        /// <param name="writerFilePath"></param>
        /// <param name="staticDataTables">can configure the static data tables now</param>
        /// <returns></returns>
        public string Export( string databaseName, DbOpType opType, string exportFilePath = null, string staticDataTables=null)
        {
            string script;
            Init(databaseName, opType, exportFilePath, staticDataTables);

            Database = Server.Databases[databaseName];

            InitOpType(opType);

            if(staticDataTables != null)
                InitStaticDataTables(staticDataTables);

            try
            {
                switch (opType)
                {
                    case DbOpType.CreateDatabase:
                        script = ExportCreateDbScript();
                        break;

                    case DbOpType.CreateSchema:
                        script = ExportSchemaScript();
                        break;

                    case DbOpType.CreateStaticData:
                        script = ExportStaticDataScript(exportFilePath);
                        break;

                    case DbOpType.CreateProcedures:
                        {
                            var sb = new StringBuilder();
                            ExportProcedures(sb);
                            script = sb.ToString();
                        }
                        break;

                    case DbOpType.DropDatabase:
                        script = ExportDropDatabaseScript(databaseName);
                        break;

                    case DbOpType.DropProcedures:
                        script = ExportDropProceduresScript();
                        break;

                    case DbOpType.CreateTables:
                        {
                            var sb = new StringBuilder();
                            ExportTables(sb);
                            script = sb.ToString();
                        }
                        break;

                    case DbOpType.DropTables:
                        {
                            var sb = new StringBuilder();
                            ExportTables(sb);
                            script = sb.ToString();
                        }
                        break;

                    case DbOpType.DropSchema:
                        script = ExportDropSchemaScript();
                        break;

                    case DbOpType.ExportStaticData:
                        script = ExportStaticDataScript(exportFilePath);
                        break;

                    case DbOpType.ExportDynamicData:
                        script = ExportDynamicDataScript(exportFilePath);
                        break;

                    case DbOpType.DropStaticData:
                        script = ExportDropStaticDataScript();
                        break;

                    default:
                        script = "";
                        Utils.Assertion(false, $"SQL Export Scriptor error: unhandled script export case: {opType.GetAlias()}");
                        break;
                }
            }
            catch (Exception e)
            {
                //var msgs = e.GetAllMessages();
                //Console.WriteLine( msgs);
                throw;
            }
            finally
            {
                Writer.Close();
                Status = false;
            }

            return script;
        }

        /// <summary>
        /// PRE: InitEnsuringDatabaseExists called with DbOpType.CreateDatabase
        /// </summary>
        protected string ExportCreateDbScript()
        {
            Utils.Assertion<Exception>((OpType == DbOpType.CreateDatabase) && Status, "ExportCreateDbScript not initialised properly");
            // Initialise configuration
            var originalNoCommandTerminator     = Options.NoCommandTerminator;
            var originalIncludeDatabaseContext = Options.IncludeDatabaseContext;
            Options.NoCommandTerminator = false;
            Options.IncludeDatabaseContext = true;

            if (Database.TargetRecoveryTime == 0)
            {
                var dbTargetRecoveryTime = ConfigurationManager.AppSettings["DatabaseTargetRecoveryTime"];

                if (!string.IsNullOrEmpty(dbTargetRecoveryTime))
                {
                    Database.TargetRecoveryTime = Convert.ToInt32(dbTargetRecoveryTime);
                }
            }

            // Create the script
            var sb = new StringBuilder();
            SerialiseScript(Database.Script(Options), sb);

            // Reset configuration
            Options.NoCommandTerminator    = originalNoCommandTerminator;
            Options.IncludeDatabaseContext = originalIncludeDatabaseContext;

            // Do not keep scripting use database lines unless necessary
            if (Options.IncludeDatabaseContext)
                Options.IncludeDatabaseContext = false;

            return sb.ToString();
        }

        /// <summary>
        /// Writes the scriptor output (lines) to the String builder AND the file writer
        /// a transaction is a batch of SQL lines that should be executed
        /// 
        /// Adds a GO after each transaction, if:
        ///   (OpType != DbOpType.CreateStaticData) || (OpType != DbOpType.DropStaticData)
        /// 
        /// together before the next transaction - esp: Create Function or Procedure
        /// </summary>
        /// <param name="transactions">This is a set of sql statements emitted by the scriptor that should be run</param>
        /// <param name="sb"> string builder to add sql to</param>
        /// <returns></returns>
        private void SerialiseScript( IEnumerable transactions, StringBuilder sb)//, bool addNewLine = false)
        {
            foreach (string transaction in transactions)
            {
                SerialiseScriptLine(transaction, sb);

                // Do not put goes in static data - till the end
                if((OpType != DbOpType.CreateStaticData) || (OpType != DbOpType.DropStaticData))
                    ScriptGo(sb);

                if (WantBlankLineBetweenTransactions())
                    ScriptBlankLine(sb);
            }
        }

        /// <summary>
        /// If scripting drops where the transactions are 1 or 2 lines then dont want a blank line
        /// </summary>
        /// <returns></returns>
        private bool WantBlankLineBetweenTransactions(DbOpType dbOpType = DbOpType.Undefined)
        {
            return !IsDropOperation(dbOpType);
        }

        /// <summary>
        /// Determines if db operation is a drop type
        /// </summary>
        /// <param name="dbOpType">defalt: use the OpType property</param>
        /// <returns></returns>
        private bool IsDropOperation(DbOpType dbOpType = DbOpType.Undefined)
        {
            if (dbOpType == DbOpType.Undefined)
                dbOpType = OpType;

            return dbOpType == DbOpType.DropDatabase   ? true :
                   dbOpType == DbOpType.DropProcedures ? true :
                   dbOpType == DbOpType.DropSchema     ? true :
                   dbOpType == DbOpType.DropStaticData ? true :
                   dbOpType == DbOpType.DropTables     ? true : false;
        }

        /// <summary>
        /// Drop Scripts are handled differently.
        /// The drops are repetitive and simple transactions so don want a blank after
        /// each transaction emitted from the scripter.
        /// However if the is a drop operation then we DO want a blank line at the end of the
        /// Script part
        /// </summary>
        /// <param name="sb"></param>
        /// <param name="dbOpType"></param>
        private void CloseScript(StringBuilder sb, DbOpType dbOpType = DbOpType.Undefined)
        {
            if (dbOpType == DbOpType.Undefined)
                dbOpType = OpType;

            // If a drop operation then add a blank line
            if (!WantBlankLineBetweenTransactions(dbOpType))
                ScriptBlankLine(sb);
        }

        /// <summary>
        /// Serialises the line
        /// If the transaction already has an ending newline then we don't add an extra newline
        /// Some transactions have newline at end, some dont.
        /// </summary>
        /// <param name="transaction">a transaction is a sequence of SQL lines that should be run together (i.e - emit a GO at the end of the transaction)</param>
        /// <param name="sb"></param>
        private void SerialiseScriptLine( string transaction, StringBuilder sb)
        {
            if (transaction.EndsWith("\r\n"))
            {
                //    transaction = transaction.Substring(0, transaction.Length - 2);}
                Writer.Write(transaction);
                sb.Append(transaction);
            }
            else
            {
                Writer.WriteLine(transaction);
                sb.AppendLine(transaction);
            }
        }

        /// <summary>
        /// Adds a new line to the script file, and the string builder
        /// </summary>
        /// <param name="sb"></param>
        private void ScriptBlankLine( StringBuilder sb)
        {
            Writer.Write(Environment.NewLine);
            sb.AppendLine();
        }

        /// <summary>
        /// This will script either the create
        /// </summary>
        public string ExportSchemaScript()
        {
            ExportSchemaScriptInit();
            var sb = new StringBuilder();
            // Create the scripts
            // Export tables and checks but not FKs as they may depend on tables not defined yet
            ExportTables( sb);
            ExportForeignKeys(sb);
            ExportTableTypes(sb);
            ExportFunctions(sb);
            ExportProcedures(sb);
            ExportViews(sb);
            return sb.ToString();
        }

        private void ExportSchemaScriptInit()
        {
            //Utils.Assertion<Exception>((OpType == DbOpType.CreateSchema) && (Status), "ExportSchemaScript not initialised properly");
            //Utils.Assertion(Options.ScriptDrops == false);

            Options.ContinueScriptingOnError = true;
            Options.ChangeTracking = false;
            Options.ClusteredIndexes = true;
            Options.Default = true;
            Options.DriAll = true;
            Options.DriAllConstraints = true;
            Options.DriAllKeys = true;
            Options.DriChecks = true;
            Options.DriClustered = true;
            Options.DriDefaults = true;
            Options.DriForeignKeys = true;
            Options.DriIndexes = true;
            Options.DriPrimaryKey = true;
            Options.DriUniqueKeys = true;
            Options.IncludeHeaders = false;
            Options.Indexes = true;
            Options.NoCommandTerminator = false;
            Options.PrimaryObject = true;
        }

        /// <summary>
        /// This will script the create or drop schema
        /// Done in reverse order to create (dependencies first)
        /// </summary>
        public string ExportDropSchemaScript()
        {
            var sb = new StringBuilder();
            //Utils.Assertion(Options.ScriptDrops == true);
            ExportViews(sb);
            // Drop stored procedures while all functions, tables and types defined
            ExportProcedures(sb);
            // Drop functions while all tables and types defined
            ExportFunctions(sb);
            ExportTableTypes(sb);
            // Drop FKs while all tables defined
            ExportForeignKeys(sb);
            // Export tables and checks, but no FKs
            ExportTables(sb);

            // Do not keep scripting use database lines unless necessary
            if (Options.IncludeDatabaseContext)
                Options.IncludeDatabaseContext = false;

            return sb.ToString();
        }

        /// <summary>
        /// PRE: InitEnsuringDatabaseExists called with DbOpType.CreateSchema
        /// <param name="exportFilePath">file to export to</param>
        /// </summary>
        public string ExportStaticDataScript(string exportFilePath)
        {
            return ExportData(true, exportFilePath);
        }

        /// <summary>
        /// Exports the dynamic data and the static data
        /// </summary>
        /// <param name="exportFilePath">file to export to</param>
        /// <returns>a set of SQL commands as a string that can be run using a Server object or the SSMS IDE</returns>
        public string ExportDynamicDataScript(string exportFilePath)
        {
            return ExportData(false, exportFilePath);
        }

        /// <summary>
        /// Exports the data - not of dynamic data then exports static as well
        /// If isStaticData -s true then must have the set of static data tables defined
        /// </summary>
        /// <param name="isStaticData"></param>
        /// <param name="exportFilePath">file to export to</param>
        /// <returns></returns>
        protected string ExportData(bool isStaticData, string exportFilePath)
        {
            OpType = isStaticData ? DbOpType.ExportStaticData : DbOpType.ExportDynamicData;
            //Utils.Assertion(StaticDataTables.Any() || !isStaticData, "In order to export static data the set of static data tables must be defined");
            var filePath = isStaticData ? "ExportStaticDataScript.SQL" : "ExportDynamicDataScript.SQL";

            // All must be valid now InitWriter returns the IsValid check
            //Utils.Assertion(InitWriter(exportFilePath), "Script exporter not initialized");

            // ASSERTION fully valid state - ready to export
            return ScriptDependencyWalk(isStaticData, exportFilePath);
        }

        /// <summary>
        /// To script tables in dependency order (avoiding the issue of a newly created table having a FK referencing 
        /// a non existent primary table)
        /// Get the tables list - i.e. all the tables in Database.Tables
        /// This list is NOT in dependency order
        /// Create a new list from the tables list minus any tables we don't want
        /// Get a walk from this list in dependency order
        /// Script out each table
        /// </summary>
        /// <param name="isStaticData"></param>
        /// <param name="exportFilePath"></param>
        private string ScriptDependencyWalk( bool isStaticData, string exportFilePath)
        {
            var tableCount = 0;
            var tables = new List<Table>();

            foreach (Table table in Database.Tables)
            {
                // static or dynamic - or if not specified then take all
                if ((!StaticDataTables.Any()) || (StaticDataTables.Contains(table.Name.ToLower()) == isStaticData))
                {
                    //LogUtils.LogI($"[{tableCount}] {table.Name} is a required table");
                    tables.Add(table);
                    tableCount++;
                }
            }

            return ScriptTables( tables, exportFilePath);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="tables"></param>
        /// <param name="exportFilePath"></param>
        /// <returns></returns>
        private string ScriptTables(List<Table> tables, string exportFilePath)
        {
            var walk = GetDependencyWalk(tables);
            var sb = new StringBuilder();

            var options = new ScriptingOptions
            {
                ScriptData = true,
                ScriptDrops = false,
                ScriptSchema = false,//true,
                EnforceScriptingOptions = true,
                Indexes = true,
                IncludeHeaders = false,//true,
                WithDependencies = false, //true
                //FileName = exportFilePath,
                NoCommandTerminator = true,
                AppendToFile = true
            };

            foreach (var tableName in walk)
                ScriptTable(tableName, options, sb);

            var script = sb.ToString();
            Writer.Write(script);
            return script;
        }

        /// <summary>
        /// Script 1 table
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="options"></param>
        /// <param name="sb"></param>
        void ScriptTable(string tableName, ScriptingOptions options, StringBuilder sb)
        {
            // Get the insert lines for the table
            var transactions = Database.Tables[tableName].EnumScript(options);
            var enumerable = transactions as string[] ?? transactions.ToArray();

            if (!enumerable.Any())
                return;

            // Each transction appears to be a single insert
            foreach (var transaction in enumerable)
                sb.Append(transaction + "\r\n");

            // Only to the StringBuilder not the file - that is done later - ScriptGo(sb);
            sb.AppendLine(GO);
        }

        /// <summary>
        /// Add GO statements to for the SQL execution at that point
        /// </summary>
        /// <param name="sb"></param>
        private void ScriptGo(StringBuilder sb)
        {
            SerialiseScriptLine(GO, sb);
        }

        /// <summary>
        /// PRE: InitEnsuringDatabaseExists called with DbOpType.CreateSchema
        /// </summary>
        protected string ExportDropStaticDataScript()
        {
            // Set State
            var originalScriptDrops = Options.ScriptDrops;
            Options.ScriptDrops = true;
            var sb = new StringBuilder();
            // Validate
            //Utils.Assertion<Exception>((Options.ScriptDrops == true) && (Status == true), "CreateStaticData not initialised properly");

            Options.AppendToFile = true;
            Options.ScriptData = true;
            Options.ScriptSchema = false;
            Options.IncludeIfNotExists = true;
            //Options.FileName = "SQL data Export.sql";

            foreach (Table table in Database.Tables)
                if (StaticDataTables.Contains(table.Name.ToLower()))
                    ExportStaticDataScript(table, sb);

            // Reset State
            Options.ScriptDrops = originalScriptDrops;

            // Do not keep scripting use database lines unless necessary
            if (Options.IncludeDatabaseContext)
                Options.IncludeDatabaseContext = false;

            return sb.ToString();
        }

        /// <summary>
        /// Exports the data from 1 table
        /// </summary>
        /// <param name="table"></param>
        private void ExportStaticDataScript(Table table, StringBuilder sb)
        {
            // Avoid system tables
            if (table.IsSystemObject)
                return;

            if (!StaticDataTables.Contains( table.Name.ToLower()))
                return;

            SerialiseScript( Scripter.EnumScript(new Urn[] { table.Urn }), sb);

            // 1 Go after each table
            //ScriptGo(sb);

            // Do not keep scripting use database lines unless necessary
            if (Options.IncludeDatabaseContext)
                Options.IncludeDatabaseContext = false;
        }

        /// <summary>
        /// Produces a SQL script to drop the given database, kicking off any users
        /// </summary>
        /// <param name="databaseName"></param>
        /// <returns></returns>
        public string ExportDropDatabaseScript(string databaseName)
        {
            var script = DbHelper.GetDropDatabaseScriptForDatabase(databaseName);
            Writer.Write( script);
            return script;
        }

        /// <summary>
        /// Main entry point to create the "Create Database Script"
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="opType"></param>
        /// <param name="writerFilePath"></param>
        public void CreateDatabase( string databaseName, DbOpType opType, string writerFilePath)
        {
            Init( databaseName, opType, writerFilePath);
            var database = new Database(Server, databaseName);
            database.Create();
        }

        /// <summary>
        /// Main entry point to create the "Drop Database Script"
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="writerFilePath"></param>
        /// <returns></returns>
        public bool DropDatabase( string databaseName, string writerFilePath)
        {
            Init( databaseName, DbOpType.CreateDatabase, writerFilePath);

            if (!Server.Databases.Contains(databaseName))
            {
                Console.WriteLine($"Cannot drop the database: {databaseName} as it does not exist on the server {ConfigurationManager.AppSettings["Server"]}");
                return false;
            }

            Server.Databases[databaseName].Drop();
            return true;
        }

        /// <summary>
        /// Main entry point to create the "Create Schema Script"
        /// 
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="opType"></param>
        /// <param name="writerFilePath"></param>
        public void ScriptSchemaCreate(string databaseName, DbOpType opType, string writerFilePath)
        {
            Init( databaseName, opType, writerFilePath);
        }

        /// <summary>
        /// Main entry point to create the "Export Static Data Script"
        /// 
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="opType"></param>
        /// <param name="writerFilePath"></param>
        protected void ScriptDataExport( string databaseName, DbOpType opType, string writerFilePath)
        {
            Init( databaseName, opType, writerFilePath);
        }

        /// <summary>
        /// PRE: InitEnsuringDatabaseExists called
        /// Scripts Create and Drop
        /// </summary>
        public string ExportViews(StringBuilder sb)
        {
            //Utils.Assertion<Exception>(Status, "SQL Scripter not initialised");

            // Iterate through the tables in database and script each one. Display the script.
            foreach (View view in Database.Views)
            {
                // Check if the table is not a system table
                if (view.IsSystemObject)
                    continue;

                if (!view.Owner.Equals("dbo"))
                    continue;

                // Else if exporting schema then export all non system tables
                // But if exporting static data then check that this is a static data table
                if (OpType == DbOpType.CreateStaticData && IsStaticData(view.Name))
                    continue;

                // Generate script for table
                SerialiseScript(Scripter.Script(new Urn[] {view.Urn}), sb);

                // Don't want separating blank line between object exports for drops
                if (WantBlankLineBetweenTransactions())
                    ScriptBlankLine(sb);
            }

            // Want blank line at end of all drops
            CloseScript(sb);

            return sb.ToString();
        }

        public void ExportTables(StringBuilder sb)
        {
            // Save the previous state
            var driAll              = Options.DriAll;
            var driAllConstraints   = Options.DriAllConstraints;
            var driForeignKeys      = Options.DriForeignKeys;
            var driAllKeys          = Options.DriAllKeys;
            var driIndexes          = Options.DriIndexes;
            var driChecks           = Options.DriChecks;
            var withDependencies    = Options.WithDependencies;
            var scriptDrops         = Options.ScriptDrops;

            // Set the state: don't do keys and checks if create
            Options.DriAll              = Options.ScriptDrops;
            Options.DriAllConstraints   = Options.ScriptDrops;
            Options.DriForeignKeys      = Options.ScriptDrops;
            Options.DriAllKeys          = Options.ScriptDrops;
            Options.DriIndexes          = Options.ScriptDrops;
            //Options.ScriptDrops         = false;
            Options.DriChecks           = true;
            Options.WithDependencies    = false;

            if (Options.ScriptDrops)
                ExportForeignKeys(sb);

            //Utils.Assertion<Exception>(Status, "SQL Scripter not initialised");
            var firstTime = true;

            // Iterate through the tables in database and script each one. Display the script.
            foreach (Table table in Database.Tables)
            {
                // Check if the table is not a system table
                if (table.IsSystemObject)
                    continue;

                ExportTable( table, sb);

                if (firstTime)
                {
                    firstTime = false;
                    Scripter.Options.IncludeDatabaseContext = false;
                    Options.IncludeDatabaseContext = false;
                }
           }

            // Want blank line at end of all drops
            CloseScript(sb);

            // Reset state
            Options.DriAll            = driAll;
            Options.DriAllConstraints = driAllConstraints;
            Options.DriForeignKeys    = driForeignKeys;
            Options.DriAllKeys        = driAllKeys;
            Options.DriIndexes        = driIndexes;
            Options.DriChecks         = driChecks;
            Options.WithDependencies  = withDependencies;
            Options.ScriptDrops       = scriptDrops;
        }

        /// <summary>
        /// PRE: table exists
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="sb"></param>
        public void ExportTable(string tableName, StringBuilder sb)
        {
            var table = Database.Tables[tableName];
            //Utils.Assertion(table != null, $"Attempting to Export non existent table: [{tableName}]");
            ExportTable( table, sb);
        }


        /// <summary>
        /// Scripts a single table
        /// </summary>
        /// <param name="table"></param>
        /// <param name="sb"></param>
        public void ExportTable(Table table, StringBuilder sb)
        {
            // Check if the table is not a system table
            if (table.IsSystemObject)
                return;

            // Else if exporting schema then export all non system tables
            // But if exporting static data then check that this is a static data table
            if (OpType == DbOpType.CreateStaticData && IsStaticData(table.Name))
                return;

            // Generate script for table, want blan lines between each transaction
            // Don't want blank line for drops
            SerialiseScript(Scripter.Script(new Urn[] {table.Urn}), sb);
        }

        /// <summary>
        /// Exports the foreign keys
        /// </summary>
        protected void ExportForeignKeys( StringBuilder sb)
        {
            foreach (Table table in Database.Tables)
                ExportForeignKeys(table, sb);
        }

        /// <summary>
        /// Exports the FKs for a given table provided it is not a system object
        /// </summary>
        /// <param name="table"></param>
        /// <param name="sb">string builder to populate the serialisation all the table's ForeignKeys as a set of SQL statements</param>
        protected void ExportForeignKeys(Table table, StringBuilder sb)
        {
            if (table.IsSystemObject)
                return;

            // Foreign keys
            foreach (ForeignKey key in table.ForeignKeys)
                SerialiseScript(key.Script(Options), sb);
        }

        /// <summary>
        /// This exports Stored procedures and functions without a use statementy   
        /// </summary>
        /// <returns>Serialisation of all the user stored procedures as a set of SQL statements</returns>
        protected string ExportDropProceduresScript()
        {
            var sb = new StringBuilder();
            // Set temporary state
            var oldDrops = Options.ScriptDrops;
            Options.ScriptDrops = true;
            ExportFunctions(sb);
            ExportProcedures(sb);
            // Reset state
            Options.ScriptDrops = oldDrops;

            // Do not keep scripting use database lines unless necessary
            if (Options.IncludeDatabaseContext)
                Options.IncludeDatabaseContext = false;

            return sb.ToString();
        }

        /// <summary>
        /// PRE: InitEnsuringDatabaseExists called
        /// Database database, Scripter scriptor, StreamWriter writer
        /// </summary>
        /// <param name="sb">string builder to populate the serialisation all the user defined functions as a set of SQL statements</param>
        protected void ExportFunctions( StringBuilder sb)
        {
            // Save state
            var oldWithDependencies = Options.WithDependencies;
            Options.WithDependencies = false;  // We want in dependency order

            // Generate script for the functions - and add them to the  writer
            SerialiseScript(Scripter.Script((from   UserDefinedFunction function
                                             in     Database.UserDefinedFunctions
                                             where  function.Owner != "sys"
                                             select function.Urn).ToArray()), sb);

            //If drops then add a blank line at the end
            CloseScript(sb);

            // Reset state
            Options.WithDependencies = oldWithDependencies;
        }

        /// <summary>
        /// This exports all the procedures - it is much quicker than using the Scripter as that returns all the system stored procedures as well 
        /// - then we have to take ages to filter out the user stored procedures.
        /// 
        /// At least I have not found a way to stop it doing so yet
        /// Database database, Scripter, StreamWriter writer
        /// </summary>
        /// <param name="sb">string builder to populate the serialisation as a set of SQL statements</param>
        protected void ExportProcedures(StringBuilder sb)
        {
            //LogUtils.LogS();
            //Utils.Assertion<ConfigurationException>(Database != null, "ExportProcedures(): Null database");

            var transfer = new Transfer(Database)
            {
                Options = Options,
                CopyAllObjects = false,
                CopyAllSchemas = false,
                CopyAllStoredProcedures = true
            };

            transfer.Options.AllowSystemObjects = true;
            transfer.Options.ScriptBatchTerminator = true;
            transfer.Options.WithDependencies = false;
            //LogUtils.LogI($"\nScripter Options:\n{OptionsToString( transfer.Options)}");

            // Want blank line at end of all drops
            SerialiseScript(transfer.ScriptTransfer(), sb);

            // If a drop operation then add a blank line
            CloseScript(sb);
            //LogUtils.LogL();
        }

        /// <summary>
        /// PRE: InitEnsuringDatabaseExists called
        /// Database database, Scripter, StreamWriter writer
        /// </summary>
        /// <returns>Serialisation of all the user defined types as a set of SQL statements</returns>
        protected void ExportTableTypes(StringBuilder sb)
        {
            ExportDatabaseObjects<UserDefinedTableType>(sb, true);
        }

        /// <summary>
        /// Scripts the line USE database
        ///                  GO
        /// 
        /// Relies on Database being set
        /// </summary>
        protected void ScriptUseDatabaseStatement( StringBuilder sb)
        {
            if (Options.IncludeDatabaseContext)
                ScriptUse(sb, true);
        }

        protected void ScriptUse(StringBuilder sb, bool onlyOnce = false)
        {
            SerialiseScriptLine($"USE [{Database.Name}]", sb);
            ScriptGo(sb);

            if(onlyOnce)
                Options.IncludeDatabaseContext = false;
        }

        /// <summary>
        /// PRE: InitEnsuringDatabaseExists called
        /// Database database, Scripter, StreamWriter writer
        /// </summary>
        /// <param name="sb"></param>
        /// <param name="emitGo"></param>
        protected void ExportDatabaseObjects<T>(StringBuilder sb, bool emitGo) where T : ScriptSchemaObjectBase
        {
            var type = typeof(T);
            ScriptUseDatabaseStatement(sb);

            var collection = GetSchemaCollectionForType( type);

            // Iterate through the tables in database and script each one. Display the script.
            foreach (T item in collection)
            {
                SerialiseScript(Scripter.Script(new Urn[] { item.Urn }), sb);

                // Don't want blank line separating types for drops
                if (WantBlankLineBetweenTransactions())
                    ScriptBlankLine(sb);
            }

            // Want blank line at end of all drops
            CloseScript(sb);

            // Do not keep scripting use database lines unless necessary
            if (Options.IncludeDatabaseContext)
                Options.IncludeDatabaseContext = false;
        }

        private SchemaCollectionBase GetSchemaCollectionForType(Type type)
        {
            SchemaCollectionBase collection = null; // SchemaCollectionBase

            switch (type.Name)
            {
                case "UserDefinedTableType": // 
                    collection = Database.UserDefinedTableTypes;
                    break;

                case "StoredProcedure":     // StoredProcedure
                    collection = Database.StoredProcedures;
                    break;

                case "Table":               // Tables
                    collection = Database.Tables;
                    break;

                case "UserDefinedFunction":  // Functions
                    collection = Database.UserDefinedFunctions;
                    break;

                case "View":  // Functions
                    collection = Database.Views;
                    break;

                default:
                    throw new NotImplementedException();
            }

            //Utils.Assertion(collection != null);
            return collection;
        }

        /// <summary>
        /// returns true if table is registered as static data
        /// </summary>
        /// <param name="tableName"></param>
        /// <returns>Returns true if table is part of the static data, false otherwise</returns>
        protected bool IsStaticData(string tableName )
        {
            return StaticDataTables.Contains(tableName);
        }

        public List<string> GetDependencyWalk(List<Table> tables)
        {
            var walk = new List<string>();
            string name;
            var dw = new DependencyWalker(Server);
            var smoTables = new SqlSmoObject[tables.Count];

            for (int i = 0; i < tables.Count; i++)
                smoTables[i] = tables[i];

            var tree = dw.DiscoverDependencies(smoTables, DependencyType.Parents);
            var coll = dw.WalkDependencies(tree);

            foreach (DependencyCollectionNode node in coll)
            {
                var ty = node.Urn.Type;

                if (String.Compare(ty, "Table", StringComparison.Ordinal)==0)
                {
                    name = node.Urn.GetAttribute("Name");
                    walk.Add(name);//walk.Insert(0, name);
                    Debug.WriteLine($"table: {name}");
                }
            }

            return walk;
        }

        /// <summary>
        /// Used to check parameters
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        private string OptionsToString(ScriptingOptions o)
        {
            var sb = new StringBuilder();
            sb.AppendLine($"AgentAlertJob                         {o.AgentAlertJob                        }");
            sb.AppendLine($"AgentJobId                            {o.AgentJobId                           }");
            sb.AppendLine($"AgentNotify                           {o.AgentNotify                          }");
            sb.AppendLine($"AllowSystemObjects                    {o.AllowSystemObjects                   }");
            sb.AppendLine($"AnsiFile                              {o.AnsiFile                             }");
            sb.AppendLine($"AnsiPadding                           {o.AnsiPadding                          }");
            sb.AppendLine($"AppendToFile                          {o.AppendToFile                         }");
            sb.AppendLine($"ChangeTracking                        {o.ChangeTracking                       }");
            sb.AppendLine($"BatchSize                             {o.BatchSize                            }");
            sb.AppendLine($"Bindings                              {o.Bindings                             }");
            sb.AppendLine($"ClusteredIndexes                      {o.ClusteredIndexes                     }");
            sb.AppendLine($"ColumnStoreIndexes                    {o.ColumnStoreIndexes                   }");
            sb.AppendLine($"ContinueScriptingOnError              {o.ContinueScriptingOnError             }");
            sb.AppendLine($"ConvertUserDefinedDataTypesToBaseType {o.ConvertUserDefinedDataTypesToBaseType}");
            sb.AppendLine($"DdlBodyOnly                           {o.DdlBodyOnly                          }");
            sb.AppendLine($"DdlHeaderOnly                         {o.DdlHeaderOnly                        }");
            sb.AppendLine($"Default                               {o.Default                              }");
            sb.AppendLine($"DriAll                                {o.DriAll                               }");
            sb.AppendLine($"DriAllConstraints                     {o.DriAllConstraints                    }");
            sb.AppendLine($"DriAllKeys                            {o.DriAllKeys                           }");
            sb.AppendLine($"DriChecks                             {o.DriChecks                            }");
            sb.AppendLine($"DriClustered                          {o.DriClustered                         }");
            sb.AppendLine($"DriDefaults                           {o.DriDefaults                          }");
            sb.AppendLine($"DriForeignKeys                        {o.DriForeignKeys                       }");
            sb.AppendLine($"DriIncludeSystemNames                 {o.DriIncludeSystemNames                }");
            sb.AppendLine($"DriIndexes                            {o.DriIndexes                           }");
            sb.AppendLine($"DriNonClustered                       {o.DriNonClustered                      }");
            sb.AppendLine($"DriPrimaryKey                         {o.DriPrimaryKey                        }");
            sb.AppendLine($"DriUniqueKeys                         {o.DriUniqueKeys                        }");
            sb.AppendLine($"DriWithNoCheck                        {o.DriWithNoCheck                       }");
            sb.AppendLine($"Encoding                              {o.Encoding                             }");
            sb.AppendLine($"EnforceScriptingOptions               {o.EnforceScriptingOptions              }");
            sb.AppendLine($"ExtendedProperties                    {o.ExtendedProperties                   }");
            sb.AppendLine($"FileName                              {o.FileName                             }");
            sb.AppendLine($"FullTextCatalogs                      {o.FullTextCatalogs                     }");
            sb.AppendLine($"FullTextIndexes                       {o.FullTextIndexes                      }");
            sb.AppendLine($"FullTextStopLists                     {o.FullTextStopLists                    }");
            sb.AppendLine($"IncludeDatabaseContext                {o.IncludeDatabaseContext               }");
            sb.AppendLine($"IncludeDatabaseContext                {o.IncludeDatabaseContext               }");
            sb.AppendLine($"IncludeDatabaseRoleMemberships        {o.IncludeDatabaseRoleMemberships       }");
            sb.AppendLine($"IncludeFullTextCatalogRootPath        {o.IncludeFullTextCatalogRootPath       }");
            sb.AppendLine($"IncludeHeaders                        {o.IncludeHeaders                       }");
            sb.AppendLine($"IncludeIfNotExists                    {o.IncludeIfNotExists                   }");
            sb.AppendLine($"IncludeScriptingParametersHeader      {o.IncludeScriptingParametersHeader     }");
            sb.AppendLine($"Indexes                               {o.Indexes                              }");
            sb.AppendLine($"LoginSid                              {o.LoginSid                             }");
            sb.AppendLine($"NoAssemblies                          {o.NoAssemblies                         }");
            sb.AppendLine($"NoCollation                           {o.NoCollation                          }");
            sb.AppendLine($"NoCommandTerminator                   {o.NoCommandTerminator                  }");
            sb.AppendLine($"NoExecuteAs                           {o.NoExecuteAs                          }");
            sb.AppendLine($"NoFileGroup                           {o.NoFileGroup                          }");
            sb.AppendLine($"NoFileStream                          {o.NoFileStream                         }");
            sb.AppendLine($"NoFileStreamColumn                    {o.NoFileStreamColumn                   }");
            sb.AppendLine($"NoIdentities                          {o.NoIdentities                         }");
            sb.AppendLine($"NoIndexPartitioningSchemes            {o.NoIndexPartitioningSchemes           }");
            sb.AppendLine($"NoMailProfileAccounts                 {o.NoMailProfileAccounts                }");
            sb.AppendLine($"NoMailProfilePrincipals               {o.NoMailProfilePrincipals              }");
            sb.AppendLine($"NonClusteredIndexes                   {o.NonClusteredIndexes                  }");
            sb.AppendLine($"NoTablePartitioningSchemes            {o.NoTablePartitioningSchemes           }");
            sb.AppendLine($"NoVardecimal                          {o.NoVardecimal                         }");
            sb.AppendLine($"NoViewColumns                         {o.NoViewColumns                        }");
            sb.AppendLine($"NoXmlNamespaces                       {o.NoXmlNamespaces                      }");
            sb.AppendLine($"OptimizerData                         {o.OptimizerData                        }");
            sb.AppendLine($"Permissions                           {o.Permissions                          }");
            sb.AppendLine($"PrimaryObject                         {o.PrimaryObject                        }");
            sb.AppendLine($"SchemaQualify                         {o.SchemaQualify                        }");
            sb.AppendLine($"SchemaQualifyForeignKeysReferences    {o.SchemaQualifyForeignKeysReferences   }");
            sb.AppendLine($"ScriptBatchTerminator                 {o.ScriptBatchTerminator                }");
            sb.AppendLine($"ScriptData                            {o.ScriptData                           }");
            sb.AppendLine($"ScriptDataCompression                 {o.ScriptDataCompression                }");
            sb.AppendLine($"ScriptDrops                           {o.ScriptDrops                          }");
            sb.AppendLine($"ScriptForAlter                        {o.ScriptForAlter                       }");
            sb.AppendLine($"ScriptForCreateDrop                   {o.ScriptForCreateDrop                  }");
            sb.AppendLine($"ScriptOwner                           {o.ScriptOwner                          }");
            sb.AppendLine($"ScriptSchema                          {o.ScriptSchema                         }");
            sb.AppendLine($"SpatialIndexes                        {o.SpatialIndexes                       }");
            sb.AppendLine($"Statistics                            {o.Statistics                           }");
            sb.AppendLine($"TargetDatabaseEngineEdition           {o.TargetDatabaseEngineEdition          }");
            sb.AppendLine($"TargetDatabaseEngineType              {o.TargetDatabaseEngineType             }");
            sb.AppendLine($"TargetServerVersion                   {o.TargetServerVersion                  }");
            sb.AppendLine($"TimestampToBinary                     {o.TimestampToBinary                    }");
            sb.AppendLine($"ToFileOnly                            {o.ToFileOnly                           }");
            sb.AppendLine($"Triggers                              {o.Triggers                             }");
            sb.AppendLine($"WithDependencies                      {o.WithDependencies                     }");
            sb.AppendLine($"XmlIndexes                            {o.XmlIndexes                           }");

            return sb.ToString();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="staticDataTables">optional list of tables to populate the StaticDataTables List with</param>
        /// <returns></returns>
        private void InitStaticDataTables(string staticDataTables = null)
        {
            if(string.IsNullOrEmpty(staticDataTables))
                staticDataTables = ConfigurationManager.AppSettings["StaticDataTables"];

            // Convert to lower case List
            if (!string.IsNullOrEmpty(staticDataTables))
                StaticDataTables = staticDataTables.Split(",".ToCharArray()).ToList().ConvertAll(d => d.ToLower());
            else
                StaticDataTables.Clear();
        }

      #endregion private methods
    }
}

