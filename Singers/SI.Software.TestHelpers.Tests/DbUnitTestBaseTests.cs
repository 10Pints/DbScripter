using System;
using System.Data;
using System.IO;
using C5;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SI.Logging.LogUtilities;
using SI.Software.Databases.SQL;
using SI.Software.TestHelpers.Database.SQL;

namespace SI.Software.TestHelpers.Tests
{
    /*Test Files: 
    create database 2015 1 expected.1.sql
    create database 2015 expected.sql
    create database 2016 100 expected.sql
    create database 2016 101 expected.sql
    create database 2016 101.0 expected.sql
    create database 2016 101.20200 expected.sql
    create database 2016 101.20200.4016 expected.sql
    create database 2016 101.20200.4016.520 expected.sql
    create database 2016 101.20200.4016.5201 expected.sql *
    create database 2016 101.20200.4016.5202 expected.sql
    create database 2016 102 expected.sql
    create database 2016 expected.sql
    create database 2017 expected.sql
    create database expected.sql
    */
    /// <summary>
    /// This class tests the important parts of the DbUnitTestBase Class
    /// </summary>
    [TestClass]
    public class DbUnitTestBaseTests : UnitTestBase
    {
        private TestableDbUnitTestBase dbUnitTestBase = new TestableDbUnitTestBase();

        /// <summary>
        /// There are 3 sub tests:
        ///   1. DbHelper.GetDbVersionInfo() call is tested in SI.Software.TestHelpers.Tests.DbHelperTests
        ///   2. useThisTestFile != null scenario tesed by GivenGetExpectedTemplateScriptFilePath_WhenDefaultSupplied_ThenExpectDefaultReturned() here
        ///   3. GetExpectedScripFileNameForDbOptypeAndSqlVersion
        /// </summary>
        [TestMethod]
        public void GivenGetExpectedTemplateScriptFilePath_When_Then()
        {
            // DbOpType opType, string dir, string useThisTestFile = null
            //dbUnitTestBase.GetExpectedTemplateScriptFilePath();
        }

        /// <summary>
        /// This method tests GetExpectedScripFileNameForDbOptypeAndSqlVersion
        /// </summary>
        [TestMethod]
        public void GivenGetExpectedScripFileNameForDbOptypeAndSqlVersion_When_ThenExpect()
        {
            //var actual = dbUnitTestBase.GetExpectedScripFileNameForDbOptypeAndSqlVersion();
        }

        /// <summary>
        /// The tested method does the following:
        ///     calls CreateCandidateVersionMap() to populate the CandidateVersionMap
        ///     
        /// </summary>
        [TestMethod]
        public void GivenFindBestExpectedFileForDbOptypeAndSqlVersion_When_ThenExpect()
        {
            var dir = ".\\TestData";
            var versionRow = DbHelper.GetDbVersionInfo();
            versionRow["product_version"] = "14.0.2002.14"; // SQL2017.9
            var ret = dbUnitTestBase.FindBestExpectedFileForDbOptypeAndSqlVersion(DbOpType.CreateDatabase, versionRow, dir, out var filePath);
            Assert.IsTrue(ret);
            var fileName = Path.GetFileName(filePath);
            Assert.IsTrue(fileName.Equals("create database 2017 expected.sql"));
        }

        /// <summary>
        /// This method tests DbUnitTestBase.CreateCandidateVersionMap()
        /// It should return all the expected candidatefiles
        /// 
        /// Testing:
        ///     there is a sub test of this method: GivenGetVersionFromFileName_When_Then... which tests that functionality of this method
        /// so no need to do it here
        /// 
        /// </summary>
        [TestMethod]
        public void GivenCreateCandidateVersionMap_WhenDropSchema_ThenExpect3()
        {
            var candidateVersionMap = dbUnitTestBase.CreateCandidateVersionMap(".\\TestData", "drop schema");
            Assert.IsNotNull(candidateVersionMap);
            var count = candidateVersionMap.Count;
            Assert.AreEqual(3, count, $"expected 3 versions, got {count}");
            CandidateVersionMapHelper("0.0.0.0",     ".\\TestData\\drop schema expected.sql",                  candidateVersionMap);
            CandidateVersionMapHelper("13.0.4210.6", ".\\TestData\\drop schema 2016 13.0.4210.6 expected.sql", candidateVersionMap);
            CandidateVersionMapHelper("14.0.0.0",    ".\\TestData\\drop schema 2017 expected.sql",             candidateVersionMap);
        }

        /// <summary>
        /// This method tests DbUnitTestBase.CreateCandidateVersionMap()
        /// It should return all the expected candidatefiles
        /// 
        /// Testing:
        ///     there is a sub test of this method: GivenGetVersionFromFileName_When_Then... which tests that functionality of this method
        /// so no need to do it here
        /// 
        /// </summary>
        [TestMethod]
        public void GivenCreateCandidateVersionMap_WhenCreateDatabase_ThenExpect14()
        {
            var candidateVersionMap = dbUnitTestBase.CreateCandidateVersionMap(".\\TestData", "create database");
            Assert.IsNotNull(candidateVersionMap);
            var count = candidateVersionMap.Count;

            foreach (var key in candidateVersionMap)
                Console.WriteLine($"{key.ToString()}  {candidateVersionMap[key.Key]}");

            Assert.AreEqual(14, count, $"expected 3 versions, got {count}");

            CandidateVersionMapHelper("0.0.0.0",            ".\\TestData\\create database expected.sql",                           candidateVersionMap);
            CandidateVersionMapHelper("1.0.0.0",            ".\\TestData\\create database 2015 1. expected.sql",                   candidateVersionMap);
            CandidateVersionMapHelper("12.0.4100.1",        ".\\TestData\\create database 2015 expected.sql",                      candidateVersionMap);
            CandidateVersionMapHelper("13.0.0.0",           ".\\TestData\\create database 2016 expected.sql",                      candidateVersionMap);
            CandidateVersionMapHelper("14.0.0.0",           ".\\TestData\\create database 2017 expected.sql",                      candidateVersionMap);
            CandidateVersionMapHelper("100.0.0.0",          ".\\TestData\\create database 2016 100. expected.sql",                 candidateVersionMap);
            CandidateVersionMapHelper("101.0.0.0 ",         ".\\TestData\\create database 2016 101. expected.sql",                 candidateVersionMap);
            CandidateVersionMapHelper("101.5000.0.0",       ".\\TestData\\create database 2016 101.5000 expected.sql",             candidateVersionMap);
            CandidateVersionMapHelper("101.20200.0.0",      ".\\TestData\\create database 2016 101.20200 expected.sql",            candidateVersionMap);
            CandidateVersionMapHelper("101.20200.4016.0",   ".\\TestData\\create database 2016 101.20200.4016 expected.sql",       candidateVersionMap);
            CandidateVersionMapHelper("101.20200.4016.520", ".\\TestData\\create database 2016 101.20200.4016.520 expected.sql",   candidateVersionMap);
            CandidateVersionMapHelper("101.20200.4016.5201",".\\TestData\\create database 2016 101.20200.4016.5201 expected.sql",  candidateVersionMap);
            CandidateVersionMapHelper("101.20200.4016.5202",".\\TestData\\create database 2016 101.20200.4016.5202 expected.sql",  candidateVersionMap);
            CandidateVersionMapHelper("102.0.0.0 ",         ".\\TestData\\create database 2016 102. expected.sql",                 candidateVersionMap);
        }

        /// <summary>
        /// Helper to validate CreateCandidateVersionMap()
        /// </summary>
        /// <param name="version"></param>
        /// <param name="expectedFilePath"></param>
        /// <param name="candidateVersionMap"></param>
        private void CandidateVersionMapHelper(string version, string expectedFilePath, TreeDictionary<Version, string> candidateVersionMap)
        {
            var actual = candidateVersionMap[new Version(version)];

            if(!string.Equals(actual, expectedFilePath, StringComparison.OrdinalIgnoreCase))
                Assert.IsTrue( string.Equals( actual, expectedFilePath, StringComparison.OrdinalIgnoreCase), $"expected [{expectedFilePath}] \ngot [{actual}]");
        }

        /// <summary>
        /// This method tests DbUnitTestBase.GetVersionFromFileName() which 
        /// extracts the version from a candidate expected test script 
        /// It should handle full and part versions and no versions
        /// handle year and no year
        /// it should throw an invalid arg exception if the file name is null or empty
        /// </summary>
        [TestMethod]
        public void GivenGetVersionFromFileName_WhenVariousScenarios_ThenExpectCorrectVersionsReturned()
        {
            GivenGetVersionFromFileNameHelper("fred 2005 123.456.789.2000 expected.sql",     "123.456.789.2000");
            GivenGetVersionFromFileNameHelper("create schema 2006 323.36.7809 expected.sql", "323.36.7809.0");
            GivenGetVersionFromFileNameHelper("fred 2005 123.456.sql",  "123.456.0.0"); // Mismatch 123.456.0.0, 0.0.0.0'
            GivenGetVersionFromFileNameHelper("fred 2005 123",          "0.0.0.0");     // no point
            GivenGetVersionFromFileNameHelper("fred 2005 123.",         "123.0.0.0");   // point supplied
            GivenGetVersionFromFileNameHelper("fred 2005 expected",     "0.0.0.0");
            GivenGetVersionFromFileNameHelper("fred 2013",              "11.0.2395.0");
            GivenGetVersionFromFileNameHelper("fred 2014",              "12.0.0.0");
            GivenGetVersionFromFileNameHelper("fred 2015 expected",     "12.0.4100.1");
            GivenGetVersionFromFileNameHelper("fred 2016",              "13.0.0.0");
            GivenGetVersionFromFileNameHelper("fred 2017",              "14.0.0.0");
            GivenGetVersionFromFileNameHelper("fred 2018",              "14.0.3015.40");
            GivenGetVersionFromFileNameHelper("fred 2019",              "14.0.3045.24");
            GivenGetVersionFromFileNameHelper("fred expected.sql",      "0.0.0.0");

            // Expect ArgumentException exceptions
            try { GivenGetVersionFromFileNameHelper("", "");}catch (ArgumentException){}
            try{GivenGetVersionFromFileNameHelper(null, "");}catch (ArgumentException){}
        }

        private void GivenGetVersionFromFileNameHelper(string fileName, string expected)
        {
            var actual = dbUnitTestBase.GetVersionFromFileName(fileName).ToString();

            if(!expected.Equals(actual))
                Assert.IsTrue(expected.Equals(actual), $"Mismatch expected: [{expected}]  actual: [{actual}]");
        }

        /// <summary>
        /// Here we test the test file selection algoritm when it is given a bad directory
        /// Expect DirectoryNotFoundException exception
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(DirectoryNotFoundException))]
        public void GivenFindBestExpectedFileForDbOptypeAndSqlVersion_WhenBadDir_ThenExceptionThrown()
        {
            GivenFindBestExpectedFileForDbOptypeAndSqlVersionHelper(DbOpType.CreateDatabase, "2016", "101.20200.4016.5201", "create database 2016 101.20200.4016.5201 expected.sql", DbHelper.GetDbVersionInfo(), "DirectoryDoesNotExist");
        }

        /// <summary>
        /// Here we test the test file selection algoritm when there are no candidate expected files for the op type
        /// </summary>
        [TestMethod]
        public void GivenFindBestExpectedFileForDbOptypeAndSqlVersion_WhenNoFilesForOpType_ThenExpect()
        {
            Assert.IsFalse( GivenFindBestExpectedFileForDbOptypeAndSqlVersionHelper(DbOpType.DropProcedures, "2016", "101.20200.4016.5201", "create database 2016 101.20200.4016.5201 expected.sql", DbHelper.GetDbVersionInfo(), ".\\TestData", false));
        }

        /// <summary>
        /// Here we test the test file selection algoritm to get the best fit script file
        /// for the current database version.
        /// Microsoft are frequently updating their SQL software
        /// Their scripter object changes its output frequently with these changes
        /// breaking the script tests - especially by changing the order of output, 
        /// adding extra lines controlling new configuration
        /// </summary>
        [TestMethod]
        public void GivenFindBestExpectedFileForDbOptypeAndSqlVersion_WhenNoCandindates_Then()
        {
            // Get a standard Version info object and modify it
            const string testDir = ".\\TestData";
            var versionRow = DbHelper.GetDbVersionInfo();
            // Exact match found -> pick the exact file
            Assert.IsTrue(GivenFindBestExpectedFileForDbOptypeAndSqlVersionHelper(DbOpType.CreateDatabase, "2016", "101.20200.4016.5201", "create database 2016 101.20200.4016.5201 expected.sql", versionRow, testDir));
            // Exact match not found pick the nearest that is lower look for 5203 -> 5202
            Assert.IsTrue(GivenFindBestExpectedFileForDbOptypeAndSqlVersionHelper(DbOpType.CreateDatabase, "2016", "101.20200.4016.5203", "create database 2016 101.20200.4016.5202 expected.sql", versionRow, testDir));
            // Exact match not found pick the nearest that is lower reate database 2016 101.20200.4016.5200 expected -> create database 2016 101.20200.4016.520 expected.sql
            Assert.IsTrue(GivenFindBestExpectedFileForDbOptypeAndSqlVersionHelper(DbOpType.CreateDatabase, "2016", "101.20200.4016.5200", "create database 2016 101.20200.4016.520 expected.sql", versionRow, testDir));
        }

        /// <summary>
        /// Here we test the test file selection algoritm to get the best fit script file
        /// for the current database version.
        /// Microsoft are frequently updating their SQL software
        /// Their scripter object changes its output frequently with these changes
        /// breaking the script tests - especially by changing the order of output, 
        /// adding extra lines controlling new configuration
        /// </summary>
        [TestMethod]
        public void GivenFindBestExpectedFileForDbOptypeAndSqlVersion_WhenCandindates_ThenGetBestFit()
        {
        }

        /// <summary>
        /// Helper to do the work
        /// </summary>
        /// <param name="dbOpType"></param>
        /// <param name="year">like 2017</param>
        /// <param name="productVersion">version to look for</param>
        /// <param name="expectedFile">The expected file (no path)</param>
        /// <param name="sqlServerVersion">standard version data - updated by productVersion</param>
        /// <param name="dir">folder holding the candidate files</param>
        /// <param name="expectedReturn"></param>
        private bool GivenFindBestExpectedFileForDbOptypeAndSqlVersionHelper(DbOpType dbOpType, string year, string productVersion, string expectedFile, DataRow sqlServerVersion, string dir, bool expectedReturn=true)
        {
            // Update the standard version data with productVersion param
            sqlServerVersion["product_version"] = productVersion;
            sqlServerVersion["db_version"] = $"SQL{year}";
            var ret = dbUnitTestBase.FindBestExpectedFileForDbOptypeAndSqlVersion(dbOpType, sqlServerVersion, dir, out var actualFilePath);
            Assert.IsTrue(ret == expectedReturn);

            if (!expectedReturn)
                return false;

            var actualFile = actualFilePath.Substring(actualFilePath.LastIndexOf('\\')+1);

            if(!actualFile.Equals(expectedFile, StringComparison.OrdinalIgnoreCase))
                Assert.IsTrue(actualFile.Equals(expectedFile, StringComparison.OrdinalIgnoreCase), $"expected: [{expectedFile}]\nactual: [{actualFile}]");

            return true;
        }

        [AssemblyInitialize]
        public static void AssemblySetup(TestContext ctx)
        {
            LogUtils.InitLogger();

            var databaseName = DbHelper.GetDatabaseNameFromConfig();
            // Ensure the database is created - dont need any tables just the standard procedures.
            // DbHelper.DropDatabase(databaseName);

            if (!DbHelper.DatabaseExists(databaseName))
            {
                DbHelper.RunSqlScript($"Create Database {databaseName}", "master");
                DbHelper.PopulateDatabase(databaseName, ".\\Scripts\\create standard stored procedures template.sql");
            }
        }

        [ClassCleanup]
        public static void ClassCleanup()
        {
            DbHelper.DropDatabase(DbHelper.GetDatabaseNameFromConfig());
        }
    }
}
