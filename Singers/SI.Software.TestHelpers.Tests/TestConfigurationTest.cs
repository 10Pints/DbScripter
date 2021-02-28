using System;
using System.Configuration;
using System.Diagnostics.CodeAnalysis;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SI.Software.TestHelpers.Application;
using static SI.Logging.LogUtilities.LogUtils;

namespace SI.Software.TestHelpers.Tests
{
    [TestClass]
    [SuppressMessage("ReSharper", "ParameterOnlyUsedForPreconditionCheck.Local")]
    public class TestConfigurationTests : UnitTestBase
    {
        #region unit tests
        [TestMethod]
        public void Check1CorrectConfigFile()
        {
            var configName = ConfigurationManager.AppSettings["Name"];
            Assert.IsNotNull(configName);
            Assert.IsTrue(configName.Equals("SI.Software.TestHelpers.Tests.config.1"));
        }

        [TestMethod]
        public void Check2CanGetTestConfigurationSection()
        {
            var testSection = TestConfigurationSection.GetConfig();
            Assert.IsNotNull(testSection);
            Assert.IsTrue(testSection.Name.Equals("testConfiguration section"));
        }

        [TestMethod]
        public void Check4GetElementName()
        {
            var x = new TestableConfigurationElementCollectionTemplate<MethodElement>("method");
            var y = x.GetElementName();
            Assert.IsTrue(y.Equals("method"));
        }

        /// <summary>
        ///  this test checks the TestClassCollection Element or node
        /// </summary>
        [TestMethod]
        public void CheckSection()
        {
            var expected = "testConfiguration section";
            var config = TestConfigurationSection.GetConfig();
            Assert.IsTrue(expected.Equals(config.Name), $"Expected '{expected}' actual '{config.Name}'");
            expected = "Pixl_TE0";
            Assert.IsTrue(expected.Equals(config.Database), $"Expected '{expected}' actual '{config.Database}'");
            Assert.IsNull(config.Parent);
        }

        /// <summary>
        ///  this test checks the TestClassCollection Element or node
        /// </summary>
        [TestMethod]
        public void CheckTestClassesCollectionConfigurationElement()
        {
            var config = TestConfigurationSection.GetConfig();
            CheckBasicAttributesHelper(GetConfig().TestClasses, "SI.Software.Products.PIXL.Core.Database.Tests test classes", "Pixl_TE1", config);
        }

        [TestMethod]
        public void CheckTestClassConfigurationElement()
        {
            var testClasses = GetConfig().TestClasses;
            CheckBasicAttributesHelper(testClasses[0], "DbSchemaCameraSettingsTests", "Pixl_TE2", testClasses);
        }

        /// <summary>
        ///  this test checks the TestClassCollection Element or node
        /// </summary>
        [TestMethod]
        public void CheckMethodCollectionConfigurationElement()
        {
             var testClass = GetConfig().TestClasses[0];
            CheckBasicAttributesHelper(testClass.Methods, "DbSchemaCameraSettingsTests methods", "Pixl_TE3", testClass);
        }

        /// <summary>
        /// Check Method Element of the test config
        /// </summary>
        [TestMethod]
        public void CheckMethodConfigurationElement()
        {
            TestClassElement testClass = TestConfigurationSection.GetConfig().TestClasses[0];
            MethodCollection methods = testClass.Methods;
            Assert.IsTrue(methods.Count > 0);
            CheckBasicAttributesHelper(methods[0], "GivenCameraSettings_WhenGoodDataLoad_ThenOK", "Pixl_TE4", methods);
        }

        /// <summary>
        /// This test will check that if a hierarchical attribute is not specified then the system will 
        /// go up the tree to find the first specified value for that attribute at the 
        /// </summary>
        [TestMethod]
        public void CheckHierarchicAttributeGet()
        {
            //testClass[0].method[0] -> direct attribute: Pixl_TE4
            HierarchicAttributeGetHelper(0, 0, "Database", "Pixl_TE4");

            //testClass[0].method[0] -> go to testClass parent: Pixl_TE4
            HierarchicAttributeGetHelper(0, 1, "Database", "Pixl_TE3");

            // testClass[1].method[0] -> go to testClasses parent: Pixl_TE1
            HierarchicAttributeGetHelper(1, 1, "Database", "Pixl_TE1");
        }

        /// <summary>
        /// This test will check that if a hierarchical attribute is not specified then the system will 
        /// go up the tree to find the first specified value for that attribute at the section node
        /// </summary>
        [TestMethod]
        public void CheckHierarchicAttributeGet2()
        {
            LogS();
            TestAppConfig originalAppConfig = null;

            try
            {
                // Switch to app config 2
                originalAppConfig = AppConfigTestHelper.ChangeAppConfig(".\\TestData\\app.2.config", "SI.Software.TestHelpers.Tests.config.2");
                // testClass[0].method[0] -> go to testConfiguration parent: Pixl_TE0
                HierarchicAttributeGetHelper(1, 1, "Database", "Pixl_TE0");
            }
            finally
            {
                // Restore Configuration Manager state back to app.config - the original app config whatever the result
                originalAppConfig?.Dispose();
                Assert.AreEqual(ConfigurationManager.AppSettings["Name"], "SI.Software.TestHelpers.Tests.config.1");
                LogL();
            }
        }

        #endregion unittests
        #region private support methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="classIndex"></param>
        /// <param name="methodIndex"></param>
        /// <param name="propertyName"></param>
        /// <param name="expected"></param>
        private void HierarchicAttributeGetHelper(int classIndex, int methodIndex, string propertyName, string expected)
        {
            var config = TestConfigurationSection.GetConfig();
            var method = config.TestClasses[classIndex].Methods[methodIndex];
            var actual = TestHelper.GetProperty(method, propertyName); // <MethodElement, string>
            Assert.IsTrue( Equals(expected, actual), $"expected: '{expected}', actual: '{actual}'");
        }

        private TestConfigurationSection GetConfig()
        {
            var config = TestConfigurationSection.GetConfig();
            Assert.IsNotNull(config);
            Assert.IsNotNull(config.TestClasses);
            Assert.IsTrue(config.TestClasses.Count > 0);
            return config;
        }

        /// <summary>
        /// This Checks the following attributes:
        ///   Name, Database, Parent, 
        /// </summary>
        /// <param name="el"></param>
        /// <param name="expectedName"></param>
        /// <param name="expectedDatabaseName"></param>
        /// <param name="expectedParent"></param>
        private void CheckBasicAttributesHelper(IElementAndDatabaseElement el,
            string expectedName, string expectedDatabaseName,
            IElement expectedParent)
        {
            Assert.IsNotNull(el);
            LogS($"Checking element: {el.Name}");
           // var expectedSection = GetConfig().Section;
            var name = el.Name;
            var dbName = el.Database;
            Assert.IsTrue(string.Equals(expectedName, name), $"Name Attribute mismatch: \nexpected {expectedName} \nactual  : {name}");
            Assert.IsTrue(string.Equals(dbName, expectedDatabaseName), $"DB name Attribute mismatch: \nexpected {expectedDatabaseName} \nactual  : {dbName}");

            if (expectedParent != null)
                Assert.AreEqual(expectedParent, el.Parent);
            else
                Assert.IsNull(el.Parent);
        }
        #endregion
    }
}
