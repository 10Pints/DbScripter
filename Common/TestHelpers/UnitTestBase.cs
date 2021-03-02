
#nullable enable 

using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using RSS.Common;
using static RSS.Common.Logger;

//using SI.Common;
//using SI.Logging;
//using SI.Logging.LogUtilities;
//using SI.Logging.Providers.log4net;
//using SI.Software.SharedControls.MEF;
//using RSS.Test.Database.SQL;

namespace RSS.Test
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
      //[Import(typeof(ILogProvider))]
      //protected ILogProvider LogProvider { get; set; }

      /// <summary>
      /// Some aspects of Tests can be controlled in the app config testConfiguration section
      /// </summary>
      protected TestClassElement? CurrentTestClassElement { get; set; }

      /// <summary>
      /// Set this in the test setup method from the test context
      /// </summary>
      protected string? CurrentTestMethodName { get; set; }

      /// <summary>
      /// Depends on CurrentTestMethodName
      /// </summary>
#pragma warning disable CS8604 // Possible null reference argument.
      protected TestMethodElement? CurrentTestTestMethodElement => CurrentTestClassElement?.Methods?[CurrentTestMethodName];
#pragma warning restore CS8604 // Possible null reference argument.

      /// <summary>
      /// The current class is static to the derived class - not common to all - to do this we need a map of class name to TestClassElement
      /// </summary>
      private static Dictionary<string, TestClassElement?> TestClassConfigMap { get; } = new Dictionary<string, TestClassElement?>();


      /// <summary>
      /// Adds to the TestClassElement to configuration registry 
      /// PRE: must not exist
      /// </summary>
      /// <param name="el"></param>
      private static void AddTestClassElement( TestClassElement? el )
      {
         Assert.IsNotNull(el); // PRE
         Assert.IsFalse(TestClassConfigMap.ContainsKey(el?.Name ?? "")); // PRE
         TestClassConfigMap.Add(el?.Name ?? "", el);
      }

      /// <summary>
      /// Returns the element to the configuration registry - must be present else asserts
      /// </summary>
      /// <param name="name"></param>
      /// <returns></returns>
      protected static TestClassElement? GetTestClassElement( string className )
      {
         Assert.IsTrue(TestClassConfigMap.ContainsKey(className)); // PRE
         return TestClassConfigMap[className];
      }

      /// <summary>
      /// Removes the element from the configuration registry if it exists
      /// </summary>
      /// <param className="name"></param>
      private static void RemoveTestClassElement( string className )
      {
         if(TestClassConfigMap.ContainsKey(className))
            TestClassConfigMap.Remove(className);
      }

      #endregion Protected Properties
      #region Public Properties


      /// <summary>
      /// This changes for each test and is a way of Test setup knowing what test method is about to be run
      /// </summary>
      public TestContext? TestContext { get; set; }

      /// <summary>
      /// Get the location for script data.
      /// </summary>
      public static string ScriptDir => TestHelper.ScriptDir;

      #endregion Public Properties
      #endregion Properties
      #region    Constructors

      /// <summary>
      /// Initializes a new instance of the UnitTestBase 
      /// and initializes the Log4Net logger.
      /// </summary>
      protected UnitTestBase()
      {
         //LogS($"Derived type: {GetType().FullName}");
         Initialise();
         //LogL();
      }

      #endregion Constructors
      #region Methods
      #region    Protected Methods

      protected bool ChkContains( string script, string searchClause, string? filePath, int expCount )
      {
         Counts c = new Counts(script, searchClause);
         int actCount = c.Hits.Count;

         try
         {
            // check existance or non existence of clause in str
            if(expCount == -1)
               Assert.IsTrue(actCount > 0, $"regex clause:'{searchClause}' returned zero hits");
            else  // check counts
               Assert.AreEqual(expCount, actCount, $"expected {expCount} hits for regex clause:'{searchClause}', but got {actCount}");

         }
         catch(Exception e)
         {
            LogException(e);

            if(filePath != null)
               Process.Start("notepad++.exe", filePath);

            // list the hits
            Console.WriteLine($"{c.Hits.Count} hits: ");
            foreach(var hit in c.Hits)
               Console.WriteLine(hit);

            throw;
         }

         return true;
      }
      
      /// <summary>
      /// Compares exp against act based on their Equals() method
      /// 
      /// if error:
      ///   writes exp and act to files {resultsDir}\exp.txt, {resultsDir}\act.txt
      ///   using their ToString()
      ///   displays a beyond compare of both exp, act files
      /// </summary>
      /// <param name="exp"></param>
      /// <param name="act"></param>
      protected void ChkEquals(object? exp, object? act, string testName)
      {
         LogS($"checking test: {testName}");
         string msg;

         if((exp == null) && (act == null))
            return;

         if((exp != null) && (act == null))
         {
            msg = $"exp is not null but act is null\r\nexp\r\n{exp.ToString()}";
            LogE(msg);
            Assert.Fail(msg);
         }

         if((exp == null) && (act != null))
         {
            msg = $"exp is null but act is not null \r\nact\r\n{act.ToString()}";
            LogE(msg);
            Assert.Fail(msg);
         }

         //--------------------------------------------------
         // ASSERTION: both exp and act are not null
         //--------------------------------------------------

         if(!exp?.Equals(act)?? false)
         { 
            //--------------------------------------------------
            // ASSERTION: exp does not equal act
            //--------------------------------------------------
            
            // save the result to the Results dir
            var resultsDir = TestHelper.ResultsDir;
            var exp_file   = @$"{resultsDir}\{testName}_exp.txt";
            var act_file   = @$"{resultsDir}\{testName}_act.txt";
            LogE($"test: {testName}: failed\r\nexp:");
            File.WriteAllText(exp_file, exp?.ToString());  
            File.WriteAllText(act_file, act?.ToString());  
            Log(exp?.ToString() ?? "");
            Log("\r\nact:");
#pragma warning disable CS8604 // Possible null reference argument.
            Log(act?.ToString());
#pragma warning restore CS8604 // Possible null reference argument.

            // display a BeyondCompare sessoin for exp/act with unique file names
            Process.Start( "BCompare.exe", $"{act_file} {exp_file}");

            // Display the log file
            Process.Start( "Notepad++.exe", Logger.LogFile);
            Assert.Fail("exp != act");
         }

         LogL($"test: {testName}: Pass");
      }


      #endregion Protected Methods
      #region    Private Methods

      /// <summary>
      /// Initialize. This method initializes the Log4Net logger.
      /// This method cannot be overridden as it is called from this classes constructor(s)
      /// </summary>
      private void Initialise()
      {
         // Derived type
         var className = GetType().Name;
         //LogS($"class: {className} registering ILogProvider and Log4NetLogProvider Assembly");
         ServiceLocator.Instance.Register(typeof(ILogProvider).Assembly);
         ServiceLocator.Instance.Register(typeof(Log4NetLogProvider).Assembly);
         LogProvider = ServiceLocator.Instance.ResolveByType<ILogProvider>();
         DisplayMessages = false;

         //if(!IsInitialised)
         InitLogger();

         // If supplied will setup the Test class element
         SetTestConfig(className);
         var fileName = Logger.LogFile;
         LogDirect($"Test class: {className}");
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="className">optional - if supplied will configure the test element</param>
      private void SetTestConfig( string className )
      {
         //LogS($"setting config for test class: {className}", LogType.Debug);

         if(!string.IsNullOrEmpty(className))
            CurrentTestClassElement = TestConfigurationSection.GetConfig()?.TestClasses?[className];

         var msg = (CurrentTestClassElement != null) ? "Found test config" : "Did not find any config for this test class so setting <null> test config";
         LogDirect($"{msg} for {className}", LogType.Debug);
      }

      #endregion private methods

      #region Public Methods

      /// <summary>
      /// Compare two scripts. Script line order does not matter.
      /// </summary>
      /// <param name="expectedScript">The expected script.</param>
      /// <param name="actualScript">The actual script.</param>
      /// <param name="expectedScriptFilePath">The expected script file path.</param>
      /// <param name="actualScriptFilePath">The actual script file path.</param>
      /// <param name="errorMsg">An error message.</param>
      /// <returns>The result.</returns>
      protected bool CompareScriptsOrderless( string expectedScript, string actualScript, string expectedScriptFilePath, string actualScriptFilePath, ref string errorMsg )
      {
         //return DbTestHelper.CompareDatabaseScriptsOrderless(expectedScript, actualScript, expectedScriptFilePath, actualScriptFilePath, ref errorMsg);

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
         var ret              = true;
         var stringSeparators = new[] { Environment.NewLine };
         // Create an array of the actual lines
         var actualLines = actualScript.Split(stringSeparators, StringSplitOptions.None);
         // Create a list of the expected lines so we can find
         var expectedLines       = expectedScript.Split(stringSeparators, StringSplitOptions.None).ToList();
         var actualCount         = actualLines.Length;
         var expectedCount       = expectedLines.Count;
         actualScriptFilePath    = Path.GetFullPath(actualScriptFilePath);
         expectedScriptFilePath  = Path.GetFullPath(expectedScriptFilePath);

         if(actualCount != expectedCount)
         {
            // Do this once - either now or in the line check but not in both
            errorMsg = $"Scripts don't match: line count: (e/a) {expectedCount}/{actualCount}\n{expectedScriptFilePath}\n{actualScriptFilePath}";
            TestHelper.LogFileNames(actualScriptFilePath, expectedScriptFilePath, $"a/e: {actualCount} / {expectedCount}");
            return false;
         }

         for(var i = 0; i < Math.Min(actualCount, expectedCount); i++)
         {
            var actualLine = actualLines[i];

            if(expectedLines.Contains(actualLine))
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
         if(expectedLines.Count > 0)
         {
            var sb = new StringBuilder("The following expected lines were not matched:");

            foreach(var line in expectedLines)
               sb.AppendLine(line);

            sb.AppendLine();
            errorMsg = sb.ToString();
            ret = false;
         }

         return ret;
      }

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
      public static bool CompareScripts( string expectedScript, string actualScript, out string errorMsg )
      {
         return TestHelper.CompareScripts(expectedScript, actualScript, out errorMsg);
      }

      #endregion Public Methods
      #region    Test Setup

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
         LogLine();
         CurrentTestMethodName = TestContext?.TestName ?? "not specified";
         LogDirect($"\r\nstarting test: {CurrentTestMethodName}");
         Assert.IsNotNull(CurrentTestMethodName);                    // POST 1
                                                                     // Set by constructor
         //Assert.IsNotNull(CurrentTestClassElement);                // PRE 1
         //Assert.IsNotNull(CurrentTestTestMethodElement, $"Test {CurrentTestMethodName}: the current method element is not configured");
         //LogL($"CurrentTestMethodName = {CurrentTestMethodName}");
      }

      /// <summary>
      /// If the ExportDbStateFlag is set then run a PRE test/post test check on the db state
      /// call from the test cleanup or similar
      /// </summary>
      [TestCleanup]
      public virtual void TestCleanup()
      {
         LogLine();
      }

      [ClassInitialize]
      public static void ClassSetup( TestContext ctx )
      {
         InitLogger();
         LogS();
         var className = ctx.FullyQualifiedTestClassName.Split('.').Last();
         var testClasses = TestConfigurationSection.GetConfig()?.TestClasses;
         var testClassElement = testClasses?[className];
         //Assert.IsNotNull(testClassElement);
         if(testClassElement != null)
            AddTestClassElement(testClassElement);

         LogL();
      }

      /// <summary>
      /// called by sub class - passing the class name at the end of the class tests
      /// </summary>
      /// <param name="testClassName"></param>
      public static void ClassCleanup( string testClassName )
      {
         LogLine();
         RemoveTestClassElement(testClassName);
         //MyClassCleanup();
         Logger.FlushLogger();
     }

      #endregion Test Setup
      #endregion Methods
   }
}
