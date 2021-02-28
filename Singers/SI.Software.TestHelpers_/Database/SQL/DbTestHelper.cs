using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Core.Metadata.Edm;
using System.Data.Entity.Core.Objects;
using System.Data.Entity.Infrastructure;
using System.Data.Entity.Validation;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SI.Common;
using SI.Logging.LogUtilities;
using SI.Software.Databases.SQL;

namespace SI.Software.TestHelpers.Database.SQL
{
    /// <summary>
    /// This class provides support for Entity Frameworks and C# SQL API Database
    /// </summary>
    public class DbTestHelper : DbHelper
    {
        #region StaticFields

        private static readonly char[] seps = { ',', '\t' };
        public const string Line = "------------------------------------------------------------------------\n";
        public static string PopulateDynamicTestDataTemplateFileName => "populate dynamic test data template.sql";
        public static string PopulateDynamicTestDataTemplateFilePath => $"{ScriptDir}\\{PopulateDynamicTestDataTemplateFileName}";

        #endregion

        #region Public Methods
        /// <summary>
        /// Populates the dynamic test data
        /// PRECONDITION: Assumes db exists
        /// </summary>
        public void PopulateDynamicTestData(string databaseName, string dynamicTestDataTemplateFilePath = null)
        {
            if (dynamicTestDataTemplateFilePath == null)
                dynamicTestDataTemplateFilePath = PopulateDynamicTestDataTemplateFilePath;

            Assert.IsFalse(string.IsNullOrEmpty(dynamicTestDataTemplateFilePath));

            // Populate the new database with test data
            RunSqlFile( databaseName, dynamicTestDataTemplateFilePath);
        }

        /// <summary>
        /// Asserts that the count of rows that match a name filed Generates SQL like: "select count(*) FROM [{table}] where [name] like'{name}'"
        /// so if name is "a"
        /// then this will return the count of all rows whose the name field starting with 'a' will be returned like app, aardvark, ass
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="sql">The SQL to run to get the count must be like select count(*) from ....</param>
        /// <param name="expectedCount">The expected count </param>
        /// <returns>true if the actual count matches the expected count, false otherwise</returns>
        public bool CheckCount( DbContext _ctx, string sql, int expectedCount)
        {
            return CheckCountSql(_ctx, sql, expectedCount);
        }

        /// <summary>
        /// Returns the count of rows that match a name filed Generates SQL like: "select count(*) FROM [{table}] where [name] like'{name}'"
        /// so if name is "a"
        /// then this will return the count of all rows whose the name field starting with 'a' will be returned like app, aardvark, ass
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="sql">SQL to run</param>
        /// <param name="expectedCount">The expected count </param>
        /// <returns>true if the actual count matches the expected count, false otherwise</returns>
        public bool CheckCountSql( DbContext _ctx, string sql, int expectedCount)
        {
            var actualCount = _ctx.Database.SqlQuery<int>(sql).SingleOrDefault();
            var ret = (expectedCount == actualCount);

            if(!ret)
                LogUtils.LogE($"Count mismatch expected: {expectedCount} actual: {actualCount}");

            return ret;
        }

        /// <summary>
        /// Check that the supplied fields are "not null" in the table
        /// Fields should be properties in the C# Class that is used for table
        /// </summary>
        /// <typeparam name="T">the EF C# type</typeparam>
        /// <param name="_ctx">The EF database context (PRE: state = open)</param>
        /// <param name="set">The EF dataset handling the table</param>
        /// <param name="item">A pre populated instance of T with non null values</param>
        /// <param name="propertyNames">The comma separated set of fields that are to be tested</param>
        /// <returns>true if there exists a non null field constraint in the table for each the columns in the set defined by propertyNames, false otherwise</returns>
        public bool CheckTableFieldConstriantsNonNull<T>( DbContext _ctx, IDbSet<T> set, T item, string propertyNames) where T : class, new()
        {
            foreach (var popertyName in propertyNames.Split(','))
                if (!CheckTableFieldNotNull(_ctx, set, item, popertyName))
                    return false;

            return true;
        }

        /// <summary>
        /// EF state is cached, and sometimes we need to clean up dirty state
        /// Useful after failed tests or between SaveChanges calls
        /// This overload uses the supplied context.
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        public void UndoDbContextChanges( DbContext _ctx)
        {
            foreach (DbEntityEntry entry in _ctx.ChangeTracker.Entries())
            {
                switch (entry.State)
                {
                    case EntityState.Modified:
                        entry.State = EntityState.Unchanged;
                        break;

                    case EntityState.Added:
                        entry.State = EntityState.Detached;
                        break;

                    case EntityState.Deleted:
                        entry.Reload();
                        break;
                }
            }
        }

        /// <summary>
        ///  Checks that 1 field has a not null Check constraint on it
        ///   CALLED BY: CheckTableFieldsNotNull iteratively for each field
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <param name="_ctx">The EF database context (PRE: state = open)</param>
        /// <param name="set">The EF DbSet related to the table type</param>
        /// <param name="item">A pre populated instance of T with non null values</param>
        /// <param name="propertyName">name of the property to check</param>
        /// <returns>true if there exists a not null Check constraint in the table for the column named as the propertyName, false otherwise</returns>
        public bool CheckTableFieldNotNull<T>(DbContext _ctx, IDbSet<T> set, T item, string propertyName) where T : class, new()
        {
            var errorMsg = $"Field: {propertyName}: ";

            try
            {
                // Undo any cached changes ( clean the EF cache)
                UndoDbContextChanges(_ctx);
                // Make a copy of the complete instance
                T item2 = TestHelper.Clone<T>(item);
                var type = typeof(T);
                var property = type.GetProperty(propertyName);
                Assert.IsNotNull(property);
                // null this field
                property.SetValue(item2, null);
                set.Add(item2);
                // Try the save - should throw
                _ctx.SaveChanges();
                // Should NOT get here (provided that NOT NULL is specified for the field in the table in the Db)
                LogUtils.LogE($"oops! expected exception to be thrown, but it was not. type: {type.Name} field: {property.Name}");
                return false;
            }
            catch (DbUpdateException e)
            {
                errorMsg += LogUtils.LogException(e);

                if (!errorMsg.Contains(NullColumnError2Msg))
                {
                    LogUtils.LogE($"Error message is missing the following message: {NullColumnError2Msg}");
                    return false;
                }
            }
            catch (DbEntityValidationException e)
            {
                errorMsg += LogUtils.LogException(e);

                if (e.EntityValidationErrors.Any())
                    errorMsg += e.EntityValidationErrors.SelectMany(err => err.ValidationErrors).Aggregate(errorMsg, (current, ve) => current + $"Validation error {ve.ErrorMessage}");

                if (!errorMsg.Contains(RequiredFieldMissingMsg))
                {
                    LogUtils.LogE($"Error message is missing the following message: {RequiredFieldMissingMsg}");
                    return false;
                }
            }
            catch (Exception e)
            {
                LogUtils.LogException(e);
                return false;
            }

            return true;
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
        public bool UniqueKeyConstraintTestHelper( DbContext _ctx, string tableName, string fields, string values, string expectedMsgs)
        {
            string sql = $"insert into [{tableName}] ({fields}) values ({values})";

            try
            {
                _ctx.Database.ExecuteSqlCommand(sql);
                LogUtils.LogE($"oops! {sql} succeeded when expected failure message: {expectedMsgs}");
                return false;
            }
            catch (SqlException e)
            {
                var msg = LogUtils.LogException(e);
                Assert.IsTrue(TestHelper.CheckMessages(msg, expectedMsgs), $"Did not find all of the expected clauses in the error message: {expectedMsgs}");
            }
            catch (Exception e)
            {
                LogUtils.LogException(e, "Oops!");
                throw;
            }

            return true;
        }

        /// <summary>
        /// This method and its overloads test that duplicates are not allowed (as defined by a UQ or PK {Unique key or Primary key - this SQL Server speak).
        /// It checks that a DbUpdateException is thrown and also refines the check to ensure it thrown for the expected reason and not 
        /// a fail quiet issue for example an exception is thrown for another reason, like connection failure.
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="dbSet">The appropriate EF Context DbSet (Table)</param>
        /// <param name="expectedMsg">One or more substrings that should be present in the error message returned by the database.</param>
        /// <returns>true if constraint exist in db, false otherwise</returns>
        public bool UniqueKeyConstraintTestHelper<T>( DbContext _ctx, DbSet<T> dbSet, string expectedMsg) where T : class, new()
        {
            return UniqueKeyConstraintTestHelper<T, object>(_ctx, dbSet, expectedMsg, null, null);
        }

        /// <summary>
        /// This method and its overloads test that duplicates are not allowed (as defined by a UQ or PK {Unique key or Primary key - this SQL Server speak).
        /// It checks that a DbUpdateException is thrown and also refines the check to ensure it thrown for the expected reason and not 
        /// a fail quiet issue for example an exception is thrown for another reason, like connection failure.
        /// 
        /// Guarantees that the table is unaltered afterwards
        /// 
        /// Useful when test PK and UQ Primary and Unique Key table constraints
        /// This allows specific fields to be set
        /// PRE: (1) must be at least 1 row in the table
        /// PRE: (2) field must exist in type
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <typeparam name="TP">The Property type being checked</typeparam>
        /// <param name="_ctx">The EF Context</param>
        /// <param name="dbSet">The appropriate EF Context DbSet (Table)</param>
        /// <param name="expectedMsg">set of expected clauses that should be present in the error message returned by the database.</param>
        /// <param name="propertyName">name of the property to check</param>
        /// <param name="propertyValue">value  of the property to check</param>
        /// <returns>true if constraint exist in db, false otherwise</returns>
        public bool UniqueKeyConstraintTestHelper<T, TP>( DbContext _ctx, DbSet<T> dbSet, string expectedMsg, string propertyName, TP propertyValue) where T : class, new()
        {
            var type = typeof(T);
            var tableName = _ctx.GetTableName<T>();
            var count1 = _ctx.RunSelectSqlReturning1Row<int>($"SELECT count(*) FROM [{tableName}]");
            var item = _ctx.Database.SqlQuery<T>($"select TOP 1 * FROM [{tableName}]").SingleOrDefault();
            Utils.Assertion((item != null), $"Error no rows found in table: {tableName} - expected at least 1 - needed to copy from");

            try
            {
                if (propertyName != null) // overwrite field if supplied
                {
                    var propertyInfo = type.GetProperty(propertyName);
                    Assert.IsNotNull(propertyInfo);
                    propertyInfo.SetValue(item, propertyValue, null); // PRE 2
                }

                dbSet.Add(item);
                _ctx.SaveChanges();
                // if here no Key violation - oops
                LogUtils.LogE($"oops! expected DB check constraint to fire but it did not, expectedMsg: {expectedMsg}, propertyName:{propertyName}, propertyValue: {propertyValue.ToString()}");
                return false;
            }
            catch (DbUpdateException e)
            {
                var msg = LogUtils.LogException(e);

                if ((expectedMsg != null) && (!msg.Contains(expectedMsg)))
                {
                    LogUtils.LogE($"Expected message:[{expectedMsg}] not found in actual error message");
                    return false;
                }
            }
            catch (Exception e)
            {
                // This is unexpected - throw it
                LogUtils.LogException(e);
                throw;
            }
            finally
            {
                dbSet.Remove(item);
                _ctx.SaveChanges();
                Assert.IsTrue(count1 == _ctx.RunSelectSqlReturning1Row<int>($"SELECT count(*) FROM [{tableName}]"));
            }

            return true;
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
        public bool CheckTableFieldConstraints<T>( DbContext _ctx, IDbSet<T> dbSet, T instance, string popertyNames, object propertyValue) where T : class, new()
        {
            foreach (var popertyName in popertyNames.Split(",".ToCharArray()))
                if(!CheckTableFieldConstraint(_ctx, dbSet, instance, popertyName, propertyValue))
                    return false;

            return true;
        }

        /// <summary>
        /// Checks 1 field called by CheckTableFieldConstraints iteratively for each field
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="dbSet">The appropriate EF Context DbSet (Table) for type T</param>
        /// <param name="instance">A instance of type T with benign state that is used to add 
        /// the field with invalid state for the check constraint </param>
        /// <param name="propertyName">name of the property to check</param>
        /// <param name="value"></param>
        /// <returns>true if there exists a field constraint in the table that disallows the 
        /// value supplied for each the columns in the set defined by propertyNames, false otherwise</returns>
        public bool CheckTableFieldConstraint<T>( DbContext _ctx, IDbSet<T> dbSet, T instance, string propertyName, object value) where T : class, new()
        {
            var tableName = _ctx.GetTableName<T>();
            var errorMsg = $"Field: {propertyName}: ";
            T item = TestHelper.Clone<T>(instance);
            var count1 = _ctx.RunSelectSqlReturning1Row<int>($"SELECT count(*) FROM [{tableName}]");

            try
            {
                UndoDbContextChanges(_ctx);
                // Make a copy of the complete instance
                var type = typeof(T);
                var property = type.GetProperty(propertyName);

                if (property == null)
                {
                    LogUtils.LogE($"oops! unexpected null property: {propertyName}");
                    Assert.IsNotNull(property);
                }

                // set this field
                property.SetValue(item, value);
                dbSet.Add(item);
                // Try the save - should throw
                _ctx.SaveChanges();
                // Should NOT get here (provided that NOT NULL is specified for the field in the table in the database)
                LogUtils.LogE($"oops! CheckTableFieldConstraint<{type.Name}> field: {property.Name} value: {value} constraint check failed expected exception to be thrown, but it was not. table: {type.Name} ");
                return false;
            }
            catch (DbUpdateException e)
            {
                errorMsg += LogUtils.LogException(e);

                if (!errorMsg.Contains(CheckConstraintViolationMsg))
                {
                    LogUtils.LogE($"Error message does not contain the expected check constraint violation message: {CheckConstraintViolationMsg}");
                    return false;
                }
            }
            catch (DbEntityValidationException e)
            {
                errorMsg += e.GetAllMessages();

                if (e.EntityValidationErrors.Any())
                    errorMsg += e.EntityValidationErrors.SelectMany(err => err.ValidationErrors).Aggregate(errorMsg, (current, ve) => current + $"Validation error {ve.ErrorMessage}");

                LogUtils.LogE($"exception message: {errorMsg}");

                if (!errorMsg.Contains(RequiredFieldMissingMsg))
                {
                    LogUtils.LogE($"Error: message did not contain the expected message:[{RequiredFieldMissingMsg}]");
                    return false;
                }
            }
            catch (Exception e)
            {
                // not expected - throw
                LogUtils.LogException(e);
                throw;
            }
            finally
            {
                dbSet.Remove(item);
                _ctx.SaveChanges();
                Assert.IsTrue(count1 == _ctx.RunSelectSqlReturning1Row<int>($"SELECT count(*) FROM [{tableName}]"));
            }

            // ASSERTION: if here then OK
            return true;
        }

        /// <summary>
        /// This checks a table has rows that match the list of expected rows ignoring certain fields
        /// This is a full check on each field of each row (barring the ignore fields)
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="expectedRows">A list of expected rows -each field in each row is checked</param>
        /// <param name="ignoredFields">A comma separated list fields to ignore</param>
        /// <returns>true if the rows exist in db and each field of each matching row matches the expected fields in the rows, false otherwise</returns>
        public bool CheckTableIgnoreFields<T>( DbContext _ctx, List<T> expectedRows, string [] ignoredFields) where T : class
        {
            var tableName = _ctx.GetTableName<T>();
            var i = 0;
            var keyDef = GetUniqueKey(tableName, ignoredFields);
            var uniqueKeyFormatString = CreateUqClauseFormatString( keyDef);

            // Test they exist
            foreach (var expectedRow in expectedRows)
                if(!CheckRowUQ(_ctx, tableName, uniqueKeyFormatString, keyDef, expectedRow, ignoredFields, i++))
                    return false;

            return true;
        }
        /// <summary>
        /// This checks the values in the supplied list have matching rows all fields match exactly
        /// Use this when the class name is the same as the table name
        /// </summary>
        /// <typeparam name="T">Table type being checked</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="expectedRows">A list of expected rows -each field in each row is checked</param>
        /// <returns>true if the rows exist in db and each field of each matching row matches the expected fields in the rows, false otherwise</returns>
        public bool CheckTable<T>( DbContext _ctx, List<T> expectedRows) where T : class
        {
            var tableName = _ctx.GetTableName<T>();

            foreach (var item in expectedRows)
                if (!CheckRow(_ctx, item, tableName))
                    return false;

            return true;
        }

        /// <summary>
        /// This extension method compares each item in the items list against the equivalent row in the table.
        /// Equivalent is defined as having the same Primary Key (PK)
        /// Use this when the class is different from  the table name
        /// 
        /// It will assert if any field of any expected row does not match the equivalent field in the equivalent row
        /// Or if the row does not exist in the table
        /// </summary>
        /// <typeparam name="TTbl">The Table type</typeparam>
        /// <typeparam name="TDt">The Equivalent C# Type of SQL Data Type that  matches the Table type</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="expectedRows">A list of expected rows - each field in each row is checked</param>
        /// <returns>true if the rows exist in db and each field of each matching row matches the expected fields in the rows, false otherwise</returns>
        public bool CheckTable<TTbl, TDt>( DbContext _ctx, List<TDt> expectedRows) where TTbl : class, new() where TDt : class
        {
            var i = 0;

            // Check each item in the list against its equivalent row in the table
            foreach (var expectedRow in expectedRows)
                if(!CheckRow<TTbl, TDt>(_ctx, expectedRow, i++))
                    return false;

            return true;
        }

        /// <summary>
        /// This extension method compares a row in the DB table against the expected value.
        /// 
        /// Method:
        /// Create a filter based on the table's primary key and the TDt data
        /// Find the row in the DB table
        /// Compare the fields in the row against the properties of the TDt data for the common subset of simple fields.
        /// 
        /// It does not compare any complex field types as they are not row data FK data is NOT compared - just the values in row.
        /// </summary>
        /// <typeparam name="TTbl">This is table type</typeparam>
        /// <typeparam name="TDt">This is the equivalent data type -SQL Server uses a table data type when passing composite table rows 
        /// we need to use different C# types, the types need to have a common subset of fields to compare</typeparam>
        /// <param name="_ctx">The local DB context it contains all the state pertinent to the database connection, tables and types
        /// It may be different from the class one if the tests are run in parallel</param>
        /// <param name="expected">The expected instance state</param>
        /// <param name="i">The index of the row in the calling code's list</param>
        /// <returns>true if the rows exist in db and each field of each matching row matches the expected fields in the rows, false otherwise</returns>
        public bool CheckRow<TTbl, TDt>( DbContext _ctx, TDt expected, int i=0) where TTbl : class, new() where TDt : class
        {
            var actual = FindRow<TTbl, TDt>(_ctx, expected);

            if (actual == null)
                return false;

            var ret = TestHelper.Equals<TTbl, TDt>(actual, expected);

            if (!ret)
            {
                var tableName = _ctx.GetTableName<TTbl>();
                var pkClause = CreatePKClause<TTbl, TDt>(_ctx, expected);
                LogUtils.LogE($"Check failed: item {i}: {tableName} {pkClause}\n\nDumping objects: actual:\nTestHelper.Dump(actual)\nexpected value: {TestHelper.Dump(expected)}");
            }

            return ret;
        }

        /// <summary>
        /// Checks that the rows exist in the table and the data matches exactly
        /// </summary>
        /// <typeparam name="Tbl">Table type</typeparam>
        /// <typeparam name="Dt">Data type</typeparam>
        /// <param name="_ctx">The local DB context it contains all the state pertinent to the database connection, tables and types </param>
        /// <param name="expected_rows">The set of expected rows - each field is checked</param>
        /// <returns>true if the rows exist in db and each field of each matching row matches the expected fields in the rows, false otherwise</returns>
        public bool CheckRows<Tbl, Dt>( DbContext _ctx, List<Dt> expected_rows) where Tbl : class, new() where Dt : class
        {
            var i = 0;

            foreach (var expected_row in expected_rows)
            {
                if (!CheckRow<Tbl, Dt>(_ctx, expected_row, i))
                {
                   LogUtils.LogE($"Error on row {i}");
                    return false;
                }

                i++;
            }

            return true;
        }

        /// <summary>
        /// Checks 1 row
        /// </summary>
        /// <typeparam name="Tbl"></typeparam>
        /// <typeparam name="Dt"></typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="expectedRow">The expected row - each field is checked</param>
        /// <param name="i">The index of the row in the calling code's row container - used for debug messaging if failure</param>
        /// <returns>true if the rows exist in db and each field of each matching row matches the expected fields in the rows, false otherwise</returns>
        public bool CheckTable<Tbl, Dt>( DbContext _ctx, Dt expectedRow, int i) where Tbl : class, new() where Dt : class
        {
            return CheckRow<Tbl, Dt>(_ctx, expectedRow, 0);
        }

        /// <summary>
        /// Similar to the above method, but this allows the table name to be specified it has a different name from C# item type
        /// </summary>
        /// <typeparam name="T">item type and database type</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="row"> row to check<</param>
        /// <param name="tableName"> the name of the table to check<</param>
        /// <returns>true if the rows exist in db and each field of row parameter matches the expected fields in the table row, false otherwise</returns>
        public bool CheckRow<T>( DbContext _ctx, T row, string tableName) where T : class
        {
            return CheckRow(_ctx, tableName, CreatePKClause(_ctx, row), row, 0);
        }

        /// <summary>
        /// This is the final worker method. It works as follows:
        /// - Get the row from the table based on the primary key clause
        /// - Use the generic compare ignoring any specified fields
        /// 
        /// This is a test helper method and if error it will enumerate the found object to debug
        /// 
        /// This will assert if:
        ///     row not found
        ///     mismatch in row data against the expected in which case a debug trace is output indicating the property that failed to match
        /// </summary>
        /// <typeparam name="T">The Table type of the data</typeparam>
        /// <param name="_ctx">The db context</param>
        /// <param name="tableName">The table name</param>
        /// <param name="pkClause">The PK clause generated for the PK fields and their data values so that a select SQL can easily be created to get the one row that matches this data. </param>
        /// <param name="expectedRow">The expected instance whose properties will be checked against their table column equivalent values</param>
        /// <param name="i">The index of the item being check (client code will be iterating a list of expected data) - this is for debugging purposes to identify the data row item that failed</param>
        /// <param name="ignoredFields">Can be used to ignore some common fields - this is particularly useful if checking a stored procedure that takes a list of items but when it store the values 
        /// the procedure changes 1 like a parent FK field</param>
        /// <returns>true if the row exists in db and each field of each matching row matches the expected fields in the expected row, false otherwise</returns>
        public bool CheckRow<T>(DbContext _ctx, string tableName, string pkClause, T expectedRow, int i, string[] ignoredFields = null) where T : class
        {
            return CheckRowUQBase(_ctx, tableName, expectedRow, pkClause, ignoredFields, i);
        }


        /// <summary>
        /// Checks a row in the table
        /// The row is first found by building a specific SQL Select statement based on the supplied unique key
        /// This SQL Select statement is then used to find the row (if it exists - if not returns null)
        /// 
        /// Note: the UQ (Unique key) does not have to be the Primary key - it can be any unique key that uniquely identifies a row
        /// Sometimes this is very useful when the PK= [id field] and the id is auto generated - so test data has no way of knowing it
        /// I much prefer to use natural keys and not auto generated ones, but sometimes this is forced on us by things like the MS EF Model 
        /// which cant handle Primary keys with multiple fields.
        /// Very poor show MS! WE can... see below
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="_ctx"></param>
        /// <param name="tableName"></param>
        /// <param name="uniqueKeyFormatString">this is a template string like </param>
        /// <param name="keyDef"></param>
        /// <param name="expectedRow"></param>
        /// <param name="ignoredFields"></param>
        /// <param name="i">this is just a debug parameter to indicate a mismatch on field index i</param>
        /// <returns>true if Db row matches the expected row, false otherwise</returns>
        public bool CheckRowUQ<T>(DbContext _ctx, string tableName, string uniqueKeyFormatString, DataTable keyDef, T expectedRow, string[] ignoredFields, int i) where T : class
        {
            var uqClause = PopulateUQClause(expectedRow, keyDef, uniqueKeyFormatString);
            return CheckRowUQBase(_ctx, tableName, expectedRow, uqClause, ignoredFields, i);
        }

        /// <summary>
        /// Similar to the above method, but this allows the table name to be specified it has a different name from the C# item type
        /// This is important because stored procedures taking table valued parameters use a db Type not a Table - this is a contentious issue
        /// They are very similar but not the same. A Table Type is 1:1 with a table and have the same fields
        /// Hence any generic approach using reflection will need to handle this issue
        /// </summary>
        /// <typeparam name="T">item type and database type</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="row"> row to check<</param>
        /// <returns>true if parameter row exists in the table in the db and matches it field for field, false otherwise</returns>
        public bool CheckRow<T>( DbContext _ctx, T row) where T : class, new()
        {
            return CheckRow<T, T>(_ctx, row, 0);
        }

        /// <summary>
        /// This creates the primary key clause to be used in a select to get the unique row based on the primary key
        /// It can be multi field
        /// Examples "id=10"
        /// OR for the Pinning_Map table  something like 
        /// "colony='colony id' AND target_plate='target plate id' AND well='well id'
        /// </summary>
        /// <typeparam name="TTbl">The EF table type</typeparam>
        /// <typeparam name="TDt">This is the equivalent data type - because of the way SQL Server uses A table type Data type when 
        /// passing composite table rows </typeparam>
        /// <param name="_ctx">The EF data context</param>
        /// <param name="row">The row to take the primary key values from - it must contain the at least the values used in the primary key</param>
        /// <returns>The primary key clause, a string  like "ID=10" that can be used in a select to get the 1 row in the table that matches the row parameter</returns>
        public string CreatePKClause<TTbl, TDt>( DbContext _ctx, TDt row) where TTbl : class where TDt : class
        {
            var clause = "";
            var fieldNames = GetPrimaryKeyFieldNames(_ctx, typeof(TTbl));
            var andFlag = false;

            foreach (var pkFieldName in fieldNames)
            {
                clause += CreatePkFieldClause(row, pkFieldName, andFlag);
                andFlag = true; // Use for second and subsequent items
            }

            return clause;
        }

        /// <summary>
        /// This creates a part of the PK clause
        /// Handles each primary key item, adding wrapping quote mark for strings
        /// 
        /// CALLED BY: CreatePKClause for each field in the PK
        /// </summary>
        /// <typeparam name="TTbl">The EF table type</typeparam>
        /// <param name="row"> this is the data instance we are taking the primary key data from</param>
        /// <param name="pkFieldName">The field to take the data from</param>
        /// <param name="andFlag"> adds the " AND " clause for multiple field keys
        /// pass false on the first time, true thereafter</param>
        /// <returns>returns a string like "ID=10"  or if a subsequent part of a multiple field PK like AND [name]='Fred'</returns>
        private string CreatePkFieldClause<TTbl>(TTbl row, string pkFieldName, bool andFlag) where TTbl : class
        {
            var type = typeof(TTbl);
            var clause = "";
            var andClause = andFlag ? " AND " : "";
            var propertyInfo = type.GetProperty(pkFieldName);

            if (propertyInfo == null)
            {
                LogUtils.LogE($"CreatePKClauseItem() cannot get property {pkFieldName} from type {type.FullName} - dumping fields: ");
                var properties = type.GetProperties();

                foreach(var property in properties)
                    LogProvider.Log($"{property.Name}");

                Assert.Fail($"CreatePKClauseItem() cannot get property {pkFieldName} from type {type.FullName}");
            }

            Assert.IsNotNull(propertyInfo);
            var propertyType = propertyInfo.PropertyType;
            var propertyTypeInfo = propertyType.GetTypeInfo();
            var value = propertyInfo.GetValue(row, null).ToString();
            var quote = "";

            if (propertyTypeInfo == typeof(string))
                quote = "'";

            clause += $"{andClause}[{pkFieldName}] = {quote}{value}{quote} ";
            // Use for second and subsequent items
            return clause;
        }

        /// <summary>
        /// Gets the primary key field names for type TEntity using the DbContext extension method below.
        /// Templated version - deduces the entityType from the TTbl Template parameter
        /// 
        /// Primary keys are usually single field - typically an ID field, 
        /// There are 2 schools of thought on natural, multi-field primary keys
        /// 1 says use a new and separate unique ID field
        /// The other says use the natural fields
        /// I subscribe to that later - natural keys are there why create redundancy - 
        /// In the early days people used superfluous id fields because their implementations couldn't handle multi field keys.
        /// We can, so we don't need to use superfluous ids
        /// The table in question for us is the Pinning_Map Table - it has a PK of [target plate, colony, well]
        /// As a colony could be pinned to many wells in a target plate and to many target plates, 
        /// but never the same well in a given target plate. 
        /// Here we have a natural multi-part PK: [target plate, colony, well]
        /// </summary>
        /// <typeparam name="TTbl">The EF table type</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <returns>An array of primary key field names in the key order</returns>
        public static string[] GetPrimaryKeyFieldNames<TTbl>( DbContext _ctx) where TTbl : class
        {
            return GetPrimaryKeyFieldNames(_ctx, typeof(TTbl));
        }

        /// <summary>
        /// Gets the primary key field names for type entityType.
        /// Non templated version - needs the entityType
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="entityType">EF Table type to get the primary key field names from</param>
        /// <returns>An array of primary key field names in the key order</returns>
        public static string[] GetPrimaryKeyFieldNames( DbContext _ctx, Type entityType)
        {
            Assert.IsNotNull(_ctx);
            Assert.IsNotNull(entityType);

            var metadata = ((IObjectContextAdapter)_ctx).ObjectContext.MetadataWorkspace;

            // Get the mapping between CLR types and metadata OSpace
            var objectItemCollection = ((ObjectItemCollection)metadata.GetItemCollection(DataSpace.OSpace));

            // Get metadata for given CLR type
            var metaItems = metadata.GetItems<EntityType>(DataSpace.OSpace);
            var entityMetadata = metaItems.Single(e => objectItemCollection.GetClrType(e) == entityType);
            var keyNames = entityMetadata.KeyProperties.Select(p => p.Name).ToArray();
            return keyNames;
        }

        /// <summary>
        /// This method checks that a stored procedure returns a super set of the set of specified columns
        /// (for an EF method see below)
        /// It does not check any row data. For that use
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
        public bool CheckSpRowsReturned( DbContext _ctx, SqlConnection conn, string storedProcedureName, string paramNames, object[] paramValues, string expectedFieldNames)
        {
            var expectedFieldNamesList = expectedFieldNames.Split(seps).ToList();
            var expectedFieldCount = expectedFieldNamesList.Count;
            Assert.IsNotNull(conn);

            if (conn.State != ConnectionState.Open)
                conn.Open();

            Assert.IsTrue(conn.State == ConnectionState.Open);

            // 1.  create a command object identifying
            //     the stored procedure
            // 2. set the command object to execute a stored procedure
            var cmd = new SqlCommand(storedProcedureName, conn) { CommandType = CommandType.StoredProcedure };
            var paramNamesArray = paramNames.Split(seps);

            // 3. add parameter to command, which will be passed to the stored procedure
            for (var i = 0; i < paramNames.Length; i++)
                cmd.Parameters.Add(new SqlParameter(paramNamesArray[i], paramValues[i]));

            var da = new SqlDataAdapter() { SelectCommand = cmd };
            var dt = new DataTable();
            da.Fill(dt);
            var row = dt.Rows[0];
            PrintFields(dt, storedProcedureName, expectedFieldNamesList);

            // Check the number of returned columns
            foreach (var fieldName in expectedFieldNamesList)
            {
                if (!row.Table.Columns.Contains(fieldName))
                {
                    LogUtils.LogE($"Could not find column [{fieldName}] in table [{row.Table.TableName}]");
                    return false;
                }

                var value = row[fieldName];
                LogProvider.Log($"col name: [{fieldName}]: value: [{value}]");
            }

            Assert.AreEqual(dt.Columns.Count, expectedFieldCount);
            return true;
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
        /// <param name="_ctx">EF Db Context</param>
        /// <param name="returnedRowset">row-set returned by the stored procedure</param>
        /// <param name="expectedFields">expected set of fields (comma or tab separated list)</param>
        /// <param name="expectedValues">[optional] The expected values for the first row returned</param>
        /// <param name="expectedRowCount">expect count of the rows returned</param>
        /// <returns>True if row found and matches, false otherwise</returns>
        public bool CheckSpRowsReturned<T>( DbContext _ctx, ObjectResult<T> returnedRowset, string expectedFields, string expectedValues, int expectedRowCount)
        {
            var expectedFieldList = expectedFields.Split(seps);
            var expectedFieldCount = expectedFieldList.Length;
            // Parameters and values must match or values = null
            var resultsList = returnedRowset.ToList();
            var actualCount = resultsList.Count();

            if(expectedRowCount != actualCount)
                Assert.Fail($"row count mismatch: expected #rows: {expectedRowCount} rows actual #rows: {actualCount}");     // 1. Check the row count against the expected

            if (expectedRowCount == 0)
            {
                // If we supplied expected values then we would expect at least 1 row
                if (expectedValues.Length != 0)
                {
                    LogUtils.LogE("Expected at least 1 row as field values were supplied to this method");
                    return false;
                }

                return true;
            }

            // Check the returned rows
            var row = resultsList.FirstOrDefault();
            Assert.IsNotNull(row);
            var hasValues = (expectedValues != null);
            var expectedFieldMap = new Dictionary<string, string>();

            if (hasValues)
            {
                // Make sure test data is consistent: that the # of the expected field names = count of the expected field values
                var expectedValuesList = expectedValues.Split(seps);

                if (expectedFieldCount != expectedValuesList.Length)
                {
                    var sb = new StringBuilder($"Inconsistent data supplied expectedFieldCount:{expectedFieldCount}, expectedValuesList count:{expectedValuesList.Length}" +
                                     "\n---------------------------------------- - \nexpected fields:\n");

                    foreach (var item in expectedFieldList)
                        sb.Append($"{item}\n");

                    sb.Append("\nexpected values:\n");

                    foreach (var item in expectedValuesList)
                        sb.Append($"{item}\n");

                    sb.Append("\n-----------------------------------------");
                    LogUtils.LogE(sb.ToString());
                    return false;
                }

                // Populate a field name -> value lookup map
                for (var i = 0; i < expectedFieldList.Length; i++)
                    expectedFieldMap.Add(expectedFieldList[i], hasValues ? expectedValuesList[i] : null);
            }

            // Must be at least 1 row
            if (!resultsList.Any())
            {
                LogUtils.LogE($"Expecting at least 1 row returned by the SP");
                return false;
            }

            return CheckPropertiesMatch(_ctx, row, expectedFieldMap);
        }

        /// <summary>
        /// CheckFieldsMatch is used by CheckSpRowsReturned to check the row
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="actualRow">Actual data row</param>
        /// <param name="expectedState"> object containing the expected fields - possibly null values</param>
        /// <returns>True if row matches the expectedState, false otherwise</returns>
        private static bool CheckPropertiesMatch<T>( DbContext _ctx, T actualRow, Dictionary<string, string> expectedState)
        {
            var properties = typeof(T).GetProperties().ToList();

            foreach (var expectedField in expectedState)
                if(!CheckPropertyMatches(_ctx, actualRow, properties, expectedField.Key, expectedField.Value))
                    return false;

            return true;
        }

        /// <summary>
        /// Checks 1 field - called by CheckFieldsMatch
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="actualRow">data row to check</param>
        /// <param name="properties">properties of the row type</param>
        /// <param name="fieldName">field to check</param>
        /// <param name="expectedValue"></param>
        /// <returns>True if the property the expected value, false otherwise</returns>
        private static bool CheckPropertyMatches<T>( DbContext _ctx, T actualRow, List<PropertyInfo> properties, string fieldName, string expectedValue)
        {
            var p = properties.Find(t => t.Name.Equals(fieldName));
            Assert.IsNotNull(actualRow);
            Assert.IsNotNull(expectedValue);
            Assert.IsNotNull(p);
            var actualFieldValueObj = p.GetValue(actualRow);

            if (actualFieldValueObj == null)
            {
                LogUtils.LogE($"\n\nMismatch on field: [{fieldName}]\n expected value: [{expectedValue}]\n actual   value: <null>");
                return false;
            }

            var actualFieldValue = actualFieldValueObj.ToString();

            // Date times can have several formats
            if (p.PropertyType.Name == "DateTime")
            {
                var dt1 = DateTime.Parse(expectedValue);
                var dt2 = DateTime.Parse(actualFieldValue);
                expectedValue = dt1.ToString(CultureInfo.InvariantCulture);
                actualFieldValue = dt2.ToString(CultureInfo.InvariantCulture);
            }

            if (expectedValue.Length != actualFieldValue.Length)
            {
                LogUtils.LogE($"\n\nMismatch on field [{fieldName}]\n expected value: [{expectedValue}] length: [{expectedValue.Length}]\n actual   value: [{actualFieldValue}] length [{actualFieldValue.Length}]");
                return false;
            }

            if (!string.Equals(expectedValue, actualFieldValue))
            {
                LogUtils.LogE($"\n\nMismatch on field: [{fieldName}]\n expected value: [{expectedValue}]\n actual   value: [{actualFieldValue}]");
                return false;
            }

            return true;
        }

        /// <summary>
        /// This finds the row in the table
        /// Method:
        /// Create a Primary key clause using the Table information and the row to insert in an SQL to 
        /// Use the SQL to find the specific row in the table
        /// </summary>
        /// <typeparam name="TTbl">This is table type</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="row">The row as a TDt to find, it must contain at least all the fields of the associated PK</param>
        /// <returns>The found row or throws an exception if not found</returns>
        public TTbl FindRow<TTbl>( DbContext _ctx, TTbl row) where TTbl : class
        {
            return FindRow<TTbl>(_ctx, CreatePKClause(_ctx, row));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <typeparam name="TTbl"></typeparam>
        /// <typeparam name="TDt"></typeparam>
        /// <param name="_ctx"></param>
        /// <param name="_row"></param>
        /// <returns></returns>
        public TTbl FindRow<TTbl, TDt>( DbContext _ctx, TDt _row) where TTbl : class, new() where TDt : class
        {
            var row = TestHelper.AssignFrom<TDt, TTbl>(_row);
            return FindRow<TTbl>(_ctx, CreatePKClause(_ctx, row));
        }

        /// <summary>
        /// This finds the row in the table using the supplied UQ string like: 
        ///     ID=5055  OR 
        ///     name='Fred Smith'
        /// </summary>
        /// <typeparam name="TTbl"></typeparam>
        // <typeparam name="TDt"></typeparam>
        /// <param name="_ctx"></param>
        /// <param name="uqClause">Unique Key clause name='Fred Smith' </param>
        /// <returns></returns>
        /// , TDt>
        public TTbl FindRow<TTbl>( DbContext _ctx, string uqClause) where TTbl : class // where TDt : class
        {
            var tableName = _ctx.GetTableName<TTbl>();
            var sql = $"SELECT * FROM [{tableName}] WHERE {uqClause}";
            return _ctx.Database.SqlQuery<TTbl>(sql).SingleOrDefault();
        }

        /// <summary>
        /// Use this on Report type stored procedures that take simple scalar parameters
        /// Enumerates the fields and values returned from row 0
        /// PRE: SqlConnection is not null
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="conn">an open SqlConnection</param>
        /// <param name="storedProcedureName">name of the stored procedure</param>
        /// <param name="paramNames">comma or tab separated list of parameter names</param>
        /// <param name="paramValues">array of parameter values</param>
        /// <param name="expectedFieldNames">comma or tab separated list of expected field names</param>
        public void EnumerateSpReturnedFields(DbContext _ctx, 
                                                     SqlConnection conn,
                                                     string storedProcedureName,
                                                     string paramNames,
                                                     object[] paramValues,
                                                     string expectedFieldNames)
        {
            var paramNamesAry = paramNames?.Split(seps) ?? new string[0];
            var numParams = paramNamesAry.Length;
            var expectedFieldNamesList = expectedFieldNames?.Split(seps).ToList();
            // Parameter name count and values count must be same
            Assert.IsTrue(numParams == paramValues.Length);
            Assert.IsNotNull(conn);

            if (conn.State != ConnectionState.Open)
                conn.Open();

            Assert.IsTrue(conn.State == ConnectionState.Open);

            // 1. Create a command object identifying the stored procedure
            // 2. Set the command object so it knows to execute a stored procedure
            var cmd = new SqlCommand(storedProcedureName, conn) { CommandType = CommandType.StoredProcedure };

            // 3. Add parameters to command, which will be passed to the stored procedure
            for (int i = 0; i < numParams; i++)
                cmd.Parameters.Add(new SqlParameter(paramNamesAry[i], paramValues[i]));

            var da = new SqlDataAdapter() { SelectCommand = cmd };
            var dt = new DataTable();
            da.Fill(dt);
            PrintFields(dt, storedProcedureName, expectedFieldNamesList);
            Assert.IsTrue(ChkReturnedFields(_ctx, dt.Columns, expectedFieldNamesList));
        }

        /// <summary>
        /// Helper method to list the fields returned by  stored procedure
        /// if there is row data then the first row field values are printed as well
        /// Useful in TDD
        /// </summary>
        /// <param name="dt">Table containing 0 or more Rows</param>
        /// <param name="storedProcedureName">stored procedure name</param>
        /// <param name="expectedFieldNamesList">list of the expected fields</param>
        private static void PrintFields(DataTable dt, string storedProcedureName, List<string> expectedFieldNamesList)
        {
            var sb = new StringBuilder($"{Line}columns returned by stored procedure [{storedProcedureName}]{Line}");

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];

                foreach (DataColumn col in dt.Columns)
                {
                    var name = col.ColumnName;
                    var value = row[col];
                    sb.Append($"col name: [{name}] type: [{col.DataType.Name}] value: [{value}]\n");
                }
            }
            else
            {
                sb.Append("No rows returned\n");

                foreach (DataColumn col in dt.Columns)
                {
                    var name = col.ColumnName;
                    sb.Append($"col name: [{name}] type: [{col.DataType.Name}]\n");
                }
            }

            sb.Append($"{Line}");
            LogUtils.LogI(sb.ToString());

            // Check the actual fields match the expected (are a super set of)
            foreach (var fieldName in expectedFieldNamesList)
                Assert.IsTrue(dt.Columns.Contains(fieldName));
        }

        /// <summary>
        /// Helper method to list the fields returned by  stored procedure
        /// if there is row data then the first row field values are printed as well
        /// Useful in TDD
        /// </summary>
        /// <param name="dt">Table containing 0 or more Rows</param>
        private static void PrintFields(DataTable dt)
        {
            var sb = new StringBuilder($"{Line}DataTable contents{Line}");

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];

                foreach (DataColumn col in dt.Columns)
                {
                    var name = col.ColumnName;
                    var value = row[col];
                    sb.AppendLine($"col name: [{name}] type: [{col.DataType.Name}] value: [{value}]");
                }
            }
            else
            {
                sb.Append("No rows returned\n");

                foreach (DataColumn col in dt.Columns)
                {
                    var name = col.ColumnName;
                    sb.AppendLine($"col name: [{name}] type: [{col.DataType.Name}]");
                }
            }

            sb.Append($"{Line}");
            LogUtils.LogI(sb.ToString());
        }

        /// <summary>
        /// Check ALL the expected fields are returned by a stored procedure
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="columns">EF DataTable columns</param>
        /// <param name="expectedFieldNamesList">expected fields</param>
        /// <returns></returns>
        public static bool ChkReturnedFields( DbContext _ctx, DataColumnCollection columns, List<string> expectedFieldNamesList)
        {
            foreach (var expectedField in expectedFieldNamesList)
            {
                if (!columns.Contains(expectedField))
                {
                    LogUtils.LogE($"stored procedure retuned field set is missing field {expectedField}");
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// Dump a table to debug
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="tableName"> the name of the table - no square brackets</param>
        public void DumpTable( DbContext _ctx, string tableName)
        {
            DumpSql(_ctx, $"SELECT * FROM [{tableName}]", tableName);
        }

        /// <summary>
        /// Populates the  static data tables by running a SQL script 
        /// </summary>
        /// <param name="databaseName"></param>
        /// <param name="scriptPath"></param>
        public new void PopulateStaticData(string databaseName, string scriptPath = ".\\Scripts\\create schema template.sql")
        {
            Utils.Assertion(!databaseName.ToLower().Contains("master"));
            // Create the schema (but no data)
            var staticDataTemplateFilePath = Path.GetFullPath(scriptPath);
            base.PopulateStaticData( databaseName, staticDataTemplateFilePath);
        }

        #endregion Public instatnce methods
        #region Public Static Methods

        /// <summary>
        /// Dump a SQL to debug - limits to  100 rows
        /// </summary>
        /// <param name="_ctx">The EF context</param>
        /// <param name="sql">like select * from Lighting_mode</param>
        /// <param name="name">Name to appear in the debug output</param>
        public static void DumpSql(DbContext _ctx, string sql, string name = "")
        {
            var line = "------------------------------------------------------------------------------------------------------------";
            var dt = _ctx.RunSelectSql(sql);
            // header
            var sb = new StringBuilder($"\n\n{line}\nDumping SQL: {name}:\n{sql}\n{line}\n");

            foreach (DataColumn col in dt.Columns)
                sb.Append($"{col.ColumnName}\t");

            sb.AppendLine($"\n{line}");
            var limit = 100;
            var i = 1;

            foreach (DataRow row in dt.Rows)
            {
                sb.Append($"i\t");

                foreach (DataColumn column in dt.Columns)
                    sb.Append($"{row[column]}\t");

                sb.AppendLine();

                if (i++ > limit)
                {
                    sb.AppendLine("Limiting trace to 100 lines)");
                    break;
                }
            }

            sb.AppendLine($"{line}\n");
            LogUtils.LogI(sb.ToString());
        }

        /// <summary>
        /// Drops the set of databases
        /// </summary>
        /// <param name="databases">he set of databases to drop</param>
        public static void DropDatabases(string[] databases)
        {
            if (databases == null)
                return;

            LogUtils.LogS($"Dropping {string.Join(",", databases)}");
            var butNotThisdb = DbHelper.GetDatabaseNameFromConfig();

            foreach (var database in databases)
            {
                try
                {
                    if ((!database.Equals(butNotThisdb)) && DatabaseExists(database))
                        DropDatabase(database);
                }
                catch(Exception e)
                {
                    LogUtils.LogException(e);
                }
            }

            LogUtils.LogL();
        }

        /// <summary>
        /// Gets the expected table script for a given table
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="dir"></param>
        /// <returns></returns>
        public static string GetExpectedTableScriptFileName(string tableName)
        {
            return $"table export {tableName} expected.sql";
        }

        /// <summary>
        /// Gets the expected table script for a given table
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="dir"></param>
        /// <returns></returns>
        public static string GetExpectedTableScriptFilePath(string tableName, string dir = null)
        {
            if (string.IsNullOrEmpty(dir))
                dir = ScriptDir;

            return Path.GetFullPath($"{dir}\\{GetExpectedTableScriptFileName(tableName)}");
        }

        /// <summary>
        /// Gets the expected table script for a given table
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="dir"></param>
        /// <param name="expectedPath"></param>
        /// <returns></returns>
        public static string GetExpectedTableScript(string tableName, string dir, out string expectedPath)
        {
            expectedPath = GetExpectedTableScriptFilePath(tableName, dir);
            return File.ReadAllText(expectedPath);
        }

        /// <summary>
        /// Removes a set of rows from a table
        /// Useful after a test has run to reset the database state in a database shared by several data write type tests
        /// </summary>
        /// <typeparam name="T">Table type</typeparam>
        /// <typeparam name="TFld">pk field type - e.g. int or string</typeparam>
        /// <param name="dbName"></param>
        /// <param name="rows"></param>
        /// <param name="tableName"></param>
        /// <param name="pkField"></param>
        public void RemoveRowsFromTable<T, TFld>(string dbName, List<T> rows, string tableName, string pkField = "id")
        {
            if (rows.Count == 0)
                return; // nothing to do

            var type = typeof(TFld);
            var typeStr = typeof(string);

            var quote = type== typeStr ? "'" : "";

            // Remove the colonies
            var sb = new StringBuilder($"DELETE FROM [{tableName}] WHERE [{pkField}] IN (");
            var firstTime = true;

            foreach (var colony in rows)
            {
                if (firstTime)
                    firstTime = false;
                else
                    sb.Append(", ");

                var x = TestHelper.GetProperty<T, TFld>(colony, pkField);
                sb.Append($"{quote}{x}{quote}");
            }

            sb.Append(");");
            RunSqlScript( sb.ToString(), dbName);
        }

        /// <summary>
        /// Use this to substitute with the default values
        /// </summary>
        /// <param name="standardStoredProceduresTemplateFilePath">Common functionality to any database</param>
        /// <param name="schemaTemplateFilePath">schema specific to the database being created</param>
        /// <param name="staticDataFilePath">data specific to the database being created</param>
        /// <param name="dynamcDataFilePath">test data specific to the database being created and the test project</param>
        public static void EnsureScriptPathsPopulated(ref string standardStoredProceduresTemplateFilePath , ref string schemaTemplateFilePath, ref string staticDataFilePath, ref string dynamcDataFilePath)
        {
            if (String.IsNullOrEmpty(standardStoredProceduresTemplateFilePath))
                standardStoredProceduresTemplateFilePath = CreateStandardSchemaTemplateFilePath;

            if (String.IsNullOrEmpty(schemaTemplateFilePath))
                schemaTemplateFilePath = CreateSchemaTemplateFilePath;

            if (String.IsNullOrEmpty(staticDataFilePath))
                staticDataFilePath = CreateStaticDataTemplateFilePath;

            if (String.IsNullOrEmpty(dynamcDataFilePath))
                dynamcDataFilePath = PopulateDynamicTestDataTemplateFilePath;

            Utils.Assertion(!String.IsNullOrEmpty(standardStoredProceduresTemplateFilePath), "standardStoredProceduresTemplateFilePath not configured");
            Utils.Assertion(!String.IsNullOrEmpty(schemaTemplateFilePath),                   "schemaTemplateFilePath not configured");
            Utils.Assertion(!String.IsNullOrEmpty(staticDataFilePath),                       "staticDataFilePath not configured");
            Utils.Assertion(!String.IsNullOrEmpty(dynamcDataFilePath),                       "dynamcDataFilePath not configured");
        }

        /// <summary>
        /// Compares SQL scripts (expected/ actual and returns error message if different
        /// </summary>
        /// <param name="expectedFilePath"></param>
        /// <param name="actualFilePath"></param>
        /// <param name="databaseName"></param>
        /// <param name="errorMsg"></param>
        /// <returns></returns>
        public static bool CompareDatabaseScripts(string expectedFilePath, string actualFilePath, string databaseName, out string errorMsg)
        {
            actualFilePath = Path.GetFullPath(actualFilePath);
            LogUtils.LogS($"Expected possible file: [{expectedFilePath}]\nActual file:[{actualFilePath}]");
            var actualScript   = ReadScriptFileAndRemoveComments(actualFilePath);
            var expectedScript = ReadScriptFileAndSubstituteTags(expectedFilePath, databaseName);
            var match = TestHelper.CompareScripts(expectedScript, actualScript, out errorMsg);

            if (!match)
                errorMsg += $"\nActual file: {expectedFilePath}\nexpected file: actualFilePath: {actualFilePath}";

            LogUtils.LogL($"returning match: {match}");
            return match;
        }

        /// <summary>
        /// Reads a script file, removes any SQL comments
        /// Replaces the 2 standard DB tags DB_NAME, PATH_TAG
        /// </summary>
        /// <returns></returns>
        public static string ReadScriptFileAndSubstituteTags(string filePath, string databaseName)
        {
            var script = ReadScriptFileAndRemoveComments(filePath);
            script = script.Replace(DbNameTag, databaseName);
            script = script.Replace(DbPathTag, DatabaseRootDir);
            return script;
        }

        /// <summary>
        /// Reads a script file, removes any SQL comments
        /// Replaces the 2 standard DB tags DB_NAME, PATH_TAG
        /// </summary>
        /// <param name="filePath">The file path to read the sript from</param>
        /// <returns></returns>
        public static string ReadScriptFileAndRemoveComments(string filePath)
        {
            var script = File.ReadAllText(filePath);
            script = RemoveComments(script);
            return script;
        }

        /// <summary>
        /// Use this comparison method where the order does not matter or cannot be guaranteed
        /// But the set of actual rows must equal the set of expected rows
        /// </summary>
        /// <param name="expectedScript"></param>
        /// <param name="actualScript"></param>
        /// <param name="expectedScriptFilePath"></param>
        /// <param name="actualScriptFilePath"></param>
        /// <param name="errorMsg"></param>
        /// <returns></returns>
        public static bool CompareDatabaseScriptsOrderless(string expectedScript, string actualScript, string expectedScriptFilePath, string actualScriptFilePath, ref string errorMsg)
        {
            var ret = true;
            var stringSeparators = new[] { Environment.NewLine };
            // Create an array of the actual lines
            var actualLines = actualScript.Split(stringSeparators, StringSplitOptions.None);
            // Create a list of the expected lines so we can find
            var expectedLines = expectedScript.Split(stringSeparators, StringSplitOptions.None).ToList();
            var actualCount = actualLines.Length;
            var expectedCount = expectedLines.Count;
            actualScriptFilePath = Path.GetFullPath(actualScriptFilePath);
            expectedScriptFilePath = Path.GetFullPath(expectedScriptFilePath);

            if (actualCount != expectedCount)
            {
                // Do this once - either now or in the line check but not in both
                errorMsg = $"Scripts don't match: line count: (e/a) {expectedCount}/{actualCount}\n{expectedScriptFilePath}\n{actualScriptFilePath}";
                TestHelper.LogFileNames(actualScriptFilePath, expectedScriptFilePath, $"a/e: {actualCount} / {expectedCount}");
                return false;
            }

            for (var i = 0; i < Math.Min(actualCount, expectedCount); i++)
            {
                var actualLine = actualLines[i];

                if (expectedLines.Contains(actualLine))
                {
                    // Remove from list v- as there may be repeats
                    expectedLines.Remove(actualLine);
                }
                else
                {
                    errorMsg = $"Scripts don't match at line {i + 1} Actual: [{actualLine}]\tExpected: [{expectedLines[i]}]\t";
                    return false;
                }
            }

            // Log any unmatched lines
            if (expectedLines.Count > 0)
            {
                var sb = new StringBuilder("The following expected lines were not matched:");

                foreach (var line in expectedLines)
                    sb.AppendLine(line);

                sb.AppendLine();
                errorMsg = sb.ToString();
                ret = false;
            }

            return ret;
        }

        /// <summary>
        /// Compares a script against 1 or more possibilities for valid scripts
        /// This is useful when there are more than one solution, but order matters
        /// We need it for dealing with 'non deterministic' entities like  the MS MSO.Scripter that can output different valid outputs depending on?? 
        /// version ?? and other state not currently known
        /// if all fail to match - all the error messages are returned
        /// NB: This removes SQL comments before comparing
        /// </summary>
        /// <param name="expectedScriptFilePaths">1 or more valid script file paths</param>
        /// <param name="actualScriptFilePath"></param>
        /// <param name="databaseName"></param>
        /// <param name="errorMsg"></param>
        /// <returns>result of the comparison - true if match</returns>
        public static bool CompareDatabaseScriptsMultiplePossibilities(string[] expectedScriptFilePaths, string actualScriptFilePath, string databaseName, out string errorMsg)
        {
            errorMsg = "";
            string msg;
            var sb = new StringBuilder();

            // Call the file comparison on each test file till we get a match
            foreach (var expectedScriptFilePath in expectedScriptFilePaths)
            {
                if (CompareDatabaseScripts(expectedScriptFilePath, actualScriptFilePath, databaseName, out msg))
                    return true;

                sb.Append(msg);
            }

            errorMsg = sb.ToString();
            return false;
        }

        #endregion Public Methods
        #region Protected Methods

        /// <summary>
        /// Worker routine shared by the Check row routines
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="_ctx"></param>
        /// <param name="tableName"></param>
        /// <param name="expectedRow"></param>
        /// <param name="uqClause"></param>
        /// <param name="ignoredFields"></param>
        /// <param name="i"></param>
        /// <returns></returns>
        protected bool CheckRowUQBase<T>(DbContext _ctx, string tableName, T expectedRow, string uqClause, string[] ignoredFields, int i) where T : class
        {
            var sql = $"SELECT * FROM [{tableName}] WHERE {uqClause}";
            var actual = _ctx.Database.SqlQuery<T>(sql).SingleOrDefault();

            if (actual == null)
            {
                LogUtils.LogE($"row not found in table SQL: {sql}");
                return false;
            }

            if (!TestHelper.EqualsNotFields(actual, expectedRow, ignoredFields))
            {
                LogUtils.LogE($"Check failed: item {i}: {tableName} {uqClause}\n\nDumping objects: actual:\n{TestHelper.Dump<T>(actual)}\n\nexpected value:\n{TestHelper.Dump(expectedRow)}");
                return false;
            }

            return true;
        }

        #endregion Protected Methods
        #region Private methods

        /// <summary>
        /// This will build a PK clause based on the table type TTbl and the row data row.
        /// The row must contain the at least the values used in the primary key
        /// It can be used in the select-where clause to uniquely identify a row based on the primary key
        /// e.g for a pinning map row the primary key is [colony, target_plate, well]
        /// so we would want an SQL like: 
        /// SELECT * FROM Pinning_Map 
        /// WHERE colony = 'colony x' AND target_plate='target plate y' AND well='well w'
        /// 
        /// This routine will create a string like 
        /// colony = 'colony x' AND target_plate='target plate y' AND well='well w'
        /// 
        /// It can be used where row Type is the same as the EF Table type
        /// </summary>
        /// <typeparam name="TTbl">The EF table type</typeparam>
        /// <param name="_ctx">The EF context</param>
        /// <param name="row">The row to take the primary key values from - it must contain the at least the values used in the primary key</param>
        /// <returns>The primary key clause, a string  like "ID=10" that can be used in a select to get the 1 row in the table that matches the row parameter</returns>
        private string CreatePKClause<TTbl>(DbContext _ctx, TTbl row) where TTbl : class
        {
            var clause = "";
            var fieldNames = GetPrimaryKeyFieldNames<TTbl>(_ctx);
            var andFlag = false;

            foreach (var pkFieldName in fieldNames)
            {
                clause += CreatePkFieldClause(row, pkFieldName, andFlag);
                andFlag = true; // Use for second and subsequent items
            }

            return clause;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="expectedRow"></param>
        /// <param name="keyDef"></param>
        /// <param name="uniqueKeyFormatString"></param>
        /// <returns></returns>
        private string PopulateUQClause<T>(T expectedRow, DataTable keyDef, string uniqueKeyFormatString)
        {
            var keyDefRows = keyDef.Rows;

            if (keyDefRows.Count == 0)
                throw new ArgumentException("Empty Key definition");

            object[] args = new object[keyDefRows.Count];
            int i = 0;

            foreach (DataRow row in keyDefRows)
            {
                var propertyName = row["column_name"].ToString();
                args[i++] = TestHelper.GetProperty(expectedRow, propertyName);
            }

            return String.Format(uniqueKeyFormatString, args);
        }

        #endregion private methods
    } // end of class DbTestHelper
} // end of namespace
