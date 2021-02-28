using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SI.Software.Databases.SQL;

namespace SI.Software.TestHelpers.Tests
{
    /// <summary>
    /// This class tests the DbHelper class
    /// </summary>
    [TestClass]
    public class DbHelperTests
    {
        [TestMethod]
        public void GivenGetDbVersionInfo_When_Then()
        {
            // Get the SQL version information from the database engine
            var version = DbHelper.GetDbVersionInfo();
            Assert.IsNotNull(version);
            Assert.IsTrue(version.Table.Columns.Count == 9);
            Assert.IsFalse(version.HasErrors);
            Assert.IsTrue(string.IsNullOrEmpty(version.RowError));
            Assert.IsTrue(version.RowState == System.Data.DataRowState.Unchanged);

            Assert.IsFalse(string.IsNullOrEmpty(version["product_level"].ToString()));
            Assert.IsFalse(string.IsNullOrEmpty(version["edition"].ToString()));
            Assert.IsFalse(string.IsNullOrEmpty(version["product_version"].ToString()));
            Assert.IsFalse(string.IsNullOrEmpty(version["is_express"].ToString()));
            Assert.IsFalse(string.IsNullOrEmpty(version["db_name"].ToString()));
            Assert.IsTrue(Convert.ToInt32(version["current_size_on_Disk_mb"]) >0);
            Assert.IsFalse(string.IsNullOrEmpty(version["machine_name"].ToString()));
            Assert.IsFalse(string.IsNullOrEmpty(version["db_version"].ToString()));
            Assert.IsFalse(string.IsNullOrEmpty(version["db_size_limit"].ToString()));
        }
    }
}
