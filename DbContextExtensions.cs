using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Core.Objects;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using SI.Common;

namespace SI.Software.Databases.SQL
{
    /// <summary>
    /// This class holds the Entity Framework extensions
    /// See Also: DbHelper and DbTestHelper classes for more Db support, not necessarily EF context related
    /// 
    /// It contains the following methods:
    /// GetAndSubstituteConnectionStringValues  Returns the Entitiy Framework connection string substituted with the database name, server, instance
    /// GetTableName                            Gets the table name for the EF type (supplied by Template parameter T). 2 overloads
    /// RunSelectSql                            Returns a DataTable - the result of running the supplied SQL string 2 overloads
    /// RunSelectSqlReturning1Row               Renamed overload of the above - returns the first row or default only
    /// DbDelete                                Removes rows from table that match the supplied table name and optional SQL clause filter
    /// GetCountFromWhereClause                                Gets the count of rows filtered by the where clause - 5 overloads
    /// CheckCountUsingNameField                Checks the count of rows that match on the name field matching the supplied name returning bool
    /// CheckCount                              Checks the count of rows for the entire table determiend from the EF template parameter T
    /// CheckCount                              overload of the above - using a table name parameter - not an EF Table Template Type
    /// 
    /// 
    /// </summary>
    public static class DbContextExtensions
    {
        /// <summary>
        /// Gets a substituted connection string from the app config
        /// </summary>
        /// <param name="connStrKey"></param>
        /// <returns></returns>
        public static string GetAndSubstituteConnectionStringValues( string connStrKey = null)
        {
            return DbHelper.GetAndSubstituteConnectionString( connStrKey);
        }

        /// <summary>
        /// Gets the table name for the EF type (supplied by Template parameter T).
        /// It uses the EF object context
        /// </summary>
        /// <typeparam name="T">Table type to get the name for</typeparam>
        /// <param name="context">the context item to get the information from.</param>
        /// <returns>The table name</returns>
        public static string GetTableName<T>(this DbContext context) where T : class
        {
            return ((IObjectContextAdapter)context).ObjectContext.GetTableName<T>();
        }

        /// <summary>
        /// Generic method to get the table name from the EF metadata
        /// </summary>
        /// <typeparam name="T">Table type to get the name for</typeparam>
        /// <param name="context">the context item to get the information from.</param>
        /// <returns>The name of the table</returns>
        public static string GetTableName<T>(this ObjectContext context) where T : class
        {
            var sql = context.CreateObjectSet<T>().ToTraceString();
            var regex = new Regex("FROM (?<table>.*) AS");
            var match = regex.Match(sql);
            char[] seps2 = { '[', ']', '.' };
            var items = match.Groups["table"].Value.Split(seps2).ToList();
            items.RemoveAll(x => x == "");
            Utils.Assertion(items.Count == 2);
            var table = items[1];
            return table;
        }

        /// <summary>
        /// 2 overloads to return a DataTable SQL as either a DataTable or 1 Row as a Type
        /// </summary>
        /// <typeparam name="T">The returned row table type</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="sql">The SQL to run to select the rows</param>
        /// <returns>The set of returned by the SQL select statement</returns>
        public static DataTable RunSelectSql<T>(this DbContext _ctx, string sql)
        {
            // Create a raw SQL query that will return elements of the given generic type T.
            var rows = _ctx.Database.SqlQuery<T>(sql).ToList();
            // Create a generic DataTable
            var table = new DataTable();

            // Populate it from the SQL select
            foreach (var row in rows)
                table.Rows.Add(row);

            // Return the set of rows as a DataTable
            return table;
        }

        /// <summary>
        /// 2 overloads to return SQL as either a DataTable or 1 Row as a Type
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="sql">The SQL to run to select the rows</param>
        /// <returns>The set of returned rows as a DataTable by the SQL select statement</returns>
        public static DataTable RunSelectSql(this DbContext _ctx, string sql)
        {
            if (_ctx.Database.Connection.State != ConnectionState.Open)
                _ctx.Database.Connection.Open();

            Utils.Assertion(_ctx.Database.Connection.State == ConnectionState.Open);

            using (SqlDataAdapter da = new SqlDataAdapter(sql, _ctx.Database.Connection as SqlConnection))
            {
                da.SelectCommand.CommandTimeout = 120;
                DataSet ds = new DataSet();
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        /// <summary>
        /// This overload returns SQL as 1 row as a Type
        /// </summary>
        /// <typeparam name="T">The returned row table type</typeparam>
        /// <param name="sql">The SQL to run to select the row</param>
        /// <returns>The set of returned row (as a T) by the SQL select statement</returns>
        public static T RunSelectSqlReturning1Row<T>(this DbContext _ctx, string sql)
        {
            return _ctx.Database.SqlQuery<T>(sql).FirstOrDefault();
        }

        /// <summary>
        /// Removes rows from table that match clause
        /// if clause not specified then 'delete from table' is run which will remove all rows from teh table
        /// same as the SQL keyword: TRUNCATE - i.3 empties the table of not drops the table.
        /// if clause contains 'where' then the clause is used like delete from table where ...
        /// if clause does not contain a where then the following SQL will be used: delete from [table] where [name] like clause
        /// </summary>
        /// <param name="_ctx">EF context</param>
        /// <param name="table">table name to delete from</param>
        /// <param name="clause">optional filter clause specified above </param>
        public static void DbDelete(this DbContext _ctx, string table, string clause = null)
        {
            string sql = $"delete from [{table}] ";

            if (clause != null)
            {
                if (clause.ToLower().Contains("where"))
                    sql += clause;
                else
                    sql += $"where [name] like '{clause}'";
            }

            _ctx.Database.ExecuteSqlCommand(sql);
        }

        /// <summary>
        /// Gets the count of rows filtered by the where clause
        /// </summary>
        /// <param name="tableNameOrSelectStmt">table name or a full select clause</param>
        /// <param name="whereClause">The where clause like "WHERE name like 'abc%'" 
        /// This is only used if tableNameOrSelectStmt does NOT contain "select "
        /// This allows more flexibility in its use.</param>
        /// <returns>count of rows matching the SQL criteria</returns>
        public static int GetCount(this DbContext _ctx, string tableNameOrSelectStmt, string whereClause = "")
        {
            var sql = (tableNameOrSelectStmt.ToLower().Contains("select ")) ? tableNameOrSelectStmt :
                $"select count(*) FROM [{tableNameOrSelectStmt}] {whereClause};";

            return _ctx.Database.SqlQuery<int>(sql).SingleOrDefault();
        }

        /// <summary>
        /// This derives the table name from the Entity type
        /// </summary>
        /// <typeparam name="T">Entity type</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="whereClause">optional where clause</param>
        /// <returns>count of rows that match criteria</returns>
        public static int GetCount<T>(this DbContext _ctx, string whereClause = "") where T : class
        {
            return _ctx.GetCount(_ctx.GetTableName<T>(), whereClause);
        }

        /// <summary>
        /// Checks the count of rows that match on the name field matching the supplied name
        /// Generates SQL like: "select count(*) FROM [{table}] where [name] like'{name}'"
        /// so if name is "a"
        /// then this will return the count of all rows whose the name field starting with 'a' will be returned like app, aardvark, ass
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="name">name field value as a prefix - this uses the 'like' operator</param>
        /// <param name="expectedCount">The expected count </param>
        /// <returns>true if the actual count matches the expected count, false otherwise</returns>
        public static bool CheckCountUsingNameField<T>(this DbContext _ctx, string name, int expectedCount) where T : class
        {
            return _ctx.CheckCount(_ctx.GetTableName<T>(), name, expectedCount);
        }

        /// <summary>
        /// Returns the count of rows in the table determined from type T
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="expectedCount">The expected count </param>
        /// <returns>true if the actual count matches the expected count, false otherwise</returns>
        public static bool CheckCount<T>(this DbContext _ctx, int expectedCount) where T : class
        {
            var tableName = _ctx.GetTableName<T>();
            return (expectedCount == _ctx.Database.SqlQuery<int>($"select count(*) FROM [{tableName}]").SingleOrDefault());
        }

        /// <summary>
        /// Checks that the count of rows that match a name filed Generates SQL like: "select count(*) FROM [{table}] where [name] like'{name}'"
        /// so if name is "a"
        /// then this will return the count of all rows whose the name field starting with 'a' will be returned like app, aardvark, ass
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="tableName">The name of the table being checked - no square brackets - NO [ BRACKETS</param>
        /// <param name="name">name field value as a prefix - this uses the 'like' operator</param>
        /// <param name="expectedCount">The expected count </param>
        /// <returns>true if the actual count matches the expected count, false otherwise</returns>
        public static bool CheckCount(this DbContext _ctx, string tableName, string name, int expectedCount)
        {
            return (expectedCount == _ctx.Database.SqlQuery<int>($"select count(*) FROM [{tableName}] where [name] like'{name}'").SingleOrDefault());
        }
    }
}
