using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.IO;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SI.Common;
using SI.Logging;
using SI.Logging.LogUtilities;
using SI.Logging.Providers.log4net;
using SI.Software.SharedControls.MEF;
using SI.Software.TestHelpers.Database.SQL;

namespace SI.Software.TestHelpers
{
    /// <summary>
    /// This class supports Unit testing by providing a helper to perform common test functionality like comparing text output (serialization) against expected "gold" data.
    /// </summary>
    public class UnitTestBase
    {
        #region Constants

        /// <summary>
        /// Get the location for test data.
        /// </summary>
        public const string TestDataDir = ".\\Scripts";

        #endregion

        #region Properties
        #region Protected Properties

        /// <summary>
        /// Get or set the log SqlProvider.
        /// </summary>
        [Import(typeof(ILogProvider))]
        protected ILogProvider LogProvider { get; set; }

        /// <summary>
        /// Some aspects of Tests can be controlled in the app config testConfiguration section
        /// </summary>
        protected TestClassElement  CurrentTestClassElement { get; set; }

        /// <summary>
        /// Set this in the test setup method from the test context
        /// </summary>
        protected string CurrentTestMethodName { get; set; }

        /// <summary>
        /// Depends on CurrentTestMethodName
        /// </summary>
        protected TestMethodElement CurrentTestTestMethodElement => CurrentTestClassElement?.Methods[CurrentTestMethodName];

        /// <summary>
        /// The current class is static to the derived class - not common to all - to do this we need a map of class name to TestClassElement
        /// </summary>
        private static Dictionary<string, TestClassElement> TestClassConfigMap { get; } = new Dictionary<string, TestClassElement>();


        /// <summary>
        /// Adds to the TestClassElement to configuration registry 
        /// PRE: must not exist
        /// </summary>
        /// <param name="el"></param>
        private static void AddTestClassElement(TestClassElement el)
        {
            Assert.IsFalse(TestClassConfigMap.ContainsKey(el.Name)); // PRE
            TestClassConfigMap.Add(el.Name, el);
        }

        /// <summary>
        /// Returns the element to the configuration registry - must be present else asserts
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        protected static TestClassElement GetTestClassElement(string className)
        {
            Assert.IsTrue(TestClassConfigMap.ContainsKey(className)); // PRE
            return TestClassConfigMap[className];
        }

        /// <summary>
        /// Removes the element from the configuration registry if it exists
        /// </summary>
        /// <param className="name"></param>
        private static void RemoveTestClassElement(string className)
        {
            if (TestClassConfigMap.ContainsKey(className))
                TestClassConfigMap.Remove(className);
        }

        #endregion Protected Properties
        #region Public Properties


        /// <summary>
        /// This changes for each test and is a way of Test setup knowing what test method is about to be run
        /// </summary>
        public TestContext TestContext { get; set; }

        /// <summary>
        /// Get the location for script data.
        /// </summary>
        public static string ScriptDir => TestHelper.ScriptDir;

        #endregion Public Properties
        #endregion Properties
        #region Constructors

        /// <summary>
        /// Initializes a new instance of the UnitTestBase 
        /// and initializes the Log4Net logger.
        /// </summary>
        protected UnitTestBase()
        {
            LogUtils.LogS($"Derived type: {GetType().FullName}");
            Initialise();
            LogUtils.LogL();
        }

        /// <summary>
        /// Initialize. This method initializes the Log4Net logger.
        /// This method cannot be overridden as it is called from this classes constructor(s)
        /// </summary>
        private void Initialise()
        {
            // Derived type
            var className = GetType().Name;
            LogUtils.LogS($"class: {className} registering ILogProvider and Log4NetLogProvider Assembly");
            ServiceLocator.Instance.Register(typeof(ILogProvider).Assembly);
            ServiceLocator.Instance.Register(typeof(Log4NetLogProvider).Assembly);
            LogProvider = ServiceLocator.Instance.ResolveByType<ILogProvider>();
            LogUtils.DisplayMessages = false;

            if (!LogUtils.IsInitialised)
                LogUtils.InitLogger();

            // If supplied will setup the Test class element
            SetTestConfig(className);
            LogUtils.LogL(className);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="className">optional - if supplied will configure the test element</param>
        private void SetTestConfig(string className)
        {
            LogUtils.LogS($"setting config for test class: {className}");

            if (!string.IsNullOrEmpty(className))
                CurrentTestClassElement = TestConfigurationSection.GetConfig()?.TestClasses?[className];

            var msg = (CurrentTestClassElement != null) ? "Found test config" : "Did not find any config for this test class so setting <null> test config";
            LogUtils.LogL($" {msg} for {className}");
        }

        #endregion
        #region Methods
        #region Public methods

        /// <summary>
        /// Compare two scripts. Script line order does not matter.
        /// </summary>
        /// <param name="expectedScript">The expected script.</param>
        /// <param name="actualScript">The actual script.</param>
        /// <param name="expectedScriptFilePath">The expected script file path.</param>
        /// <param name="actualScriptFilePath">The actual script file path.</param>
        /// <param name="errorMsg">An error message.</param>
        /// <returns>The result.</returns>
        protected bool CompareScriptsOrderless(string expectedScript, string actualScript, string expectedScriptFilePath, string actualScriptFilePath, ref string errorMsg)
        {
            return DbTestHelper.CompareDatabaseScriptsOrderless(expectedScript, actualScript, expectedScriptFilePath, actualScriptFilePath, ref errorMsg);
        }

        #endregion public methods

        /// <summary>
        /// Compares the scripts, it does NOT do any substitution
        /// DbTestHelper CompareScriptsDatabaseScripts() performs some substitution, 
        /// then uses this method to do the comparison
        /// PRE: CompareDatabaseScripts() expects all substitution done,
        /// </summary>
        /// <param name="expectedScript">expected script</param>
        /// <param name="actualScript"> actual script </param>
        /// <param name="errorMsg">error message </param>
        /// <returns></returns>
        public static bool CompareScripts(string expectedScript, string actualScript, out string errorMsg)
        {
            return TestHelper.CompareScripts(expectedScript, actualScript, out errorMsg);
        }

        /// <summary>
        /// Saves the initial state of a test before running it 
        /// ready for comparison later in the test cleanup.
        /// Call from test setup or similar
        /// 
        /// PRE: expects the following to be set:
        ///     CurrentTestClassElement
        /// 
        /// POST: the following are set
        ///     CurrentTestMethodName
        /// </summary>
        [TestInitialize]
        public virtual void TestSetup()
        {
            LogUtils.LogS();
            CurrentTestMethodName = TestContext.TestName;
            LogUtils.LogS($"Test about to be run: {CurrentTestMethodName}");
            Assert.IsNotNull(CurrentTestMethodName);                    // POST 1
            // Set by constructor
            Assert.IsNotNull(CurrentTestClassElement);                  // PRE 1
            Assert.IsNotNull(CurrentTestTestMethodElement, $"Test {CurrentTestMethodName}: the current method element is not configured");
            LogUtils.LogL($"CurrentTestMethodName = {CurrentTestMethodName}");
        }

        /// <summary>
        /// If the ExportDbStateFlag is set then run a PRE test/post test check on the db state
        /// call from the test cleanup or similar
        /// </summary>
        [TestCleanup]
        public virtual void TestCleanup()
        {
            LogUtils.LogS();
            LogUtils.LogL();
        }

        [ClassInitialize]
        public static void ClassSetup(TestContext ctx)
        {
            LogUtils.LogS();
            LogUtils.InitLogger();
            var className = ctx.FullyQualifiedTestClassName.Split('.').Last();
            var testClassElement = TestConfigurationSection.GetConfig().TestClasses[className];
            Assert.IsNotNull(testClassElement);
            AddTestClassElement(testClassElement);
            LogUtils.LogL();
        }

        /// <summary>
        /// called by sub class - passing the class name at the end of the class tests
        /// </summary>
        /// <param name="testClassName"></param>
        public static void ClassCleanup(string testClassName)
        {
            LogUtils.LogS();
            RemoveTestClassElement(testClassName);
            LogUtils.LogL();
        }


        #endregion
    }
}
