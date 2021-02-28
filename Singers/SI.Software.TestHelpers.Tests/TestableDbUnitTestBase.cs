using System;
using System.Data;
using C5;
using SI.Software.Databases.SQL;
using SI.Software.TestHelpers.Database.SQL;

namespace SI.Software.TestHelpers.Tests
{
    /// <inheritdoc />
    /// <summary>
    /// This class exposes protected methods of its base class for testing
    /// </summary>
    public class TestableDbUnitTestBase : DbUnitTestBase
    {
        public new string GetExpectedTemplateScriptFilePath(DbOpType opType, string dir)
        {
            return base.GetExpectedTemplateScriptFilePath(opType, dir);
        }

        public new TreeDictionary<Version, string> CreateCandidateVersionMap(string dir, string dbOpTypeAlias)
        {
            return base.CreateCandidateVersionMap(dir, dbOpTypeAlias);
        }

        public new String GetExpectedScripFileNameForDbOptypeAndSqlVersion(DbOpType dbOpType, DataRow sqlServerVersion, string dir)
        {
            return base.GetExpectedScripFileNameForDbOptypeAndSqlVersion(dbOpType, sqlServerVersion, dir);
        }

        public new bool FindBestExpectedFileForDbOptypeAndSqlVersion(DbOpType dbOpType, DataRow sqlServerVersionInfo, string dir, out string filePath)
        {
            return base.FindBestExpectedFileForDbOptypeAndSqlVersion(dbOpType, sqlServerVersionInfo, dir, out filePath);
        }

        public new bool FindBestFitExpectedFile(string dbOpTypeAlias, DataRow sqlServerVersionInfo, string dir, out string filePath)
        {
            return base.FindBestFitExpectedFile( dbOpTypeAlias, sqlServerVersionInfo, dir, out filePath);
        }

        public new Version GetVersionFromFileName(string fileName)
        {
            return base.GetVersionFromFileName(fileName);
        }
    }
}
