
#nullable enable
using Microsoft.VisualStudio.TestTools.UnitTesting;

using static CommonLib.Logger;
using static CommonLib.Utils;
using System.Diagnostics;
using System.IO;
using DbScripterLibTests;
using UnitTestBaseLib;

namespace RSS.Test
{
   public abstract class ScriptableUnitTestBase : UnitTestBase
   {
      /// <summary>
      /// Get the standard location for script data.
      /// </summary>
      public static string ScriptDir => TestHelper.ScriptDir;

      /// <summary>
      /// Flag to control whether to display the script after a test fialure
      /// </summary>
      protected bool DisplayScriptAfterTestFailure{ get; set;} = true;
      
      /// <summary>
      /// similar behaviour to UnitTestBase.DisplayLogAfterTest1Off
      /// </summary>
      protected bool DisplayScriptAfterTest1Off{ get; set;} = false;

      protected /*override*/ TestConfig? TestConfig
      {
         get=> ScripterTestConfig; 

         set
         {
            if(ScripterTestConfig!= null)
            {
               ScripterTestConfig.hasTestData                           = value?.hasTestData ?? false;
               ScripterTestConfig.requireExpJson                        = value?.requireExpJson ?? false;
               ScripterTestConfig.displayLogAfterTestFailure            = value?.displayLogAfterTestFailure ?? false;
               ScripterTestConfig.compareExpActResultsAfterTestFailure  = value?.hasTestData ?? false;
               ScripterTestConfig.logLevel                              = value?.logLevel ?? CommonLib.LogLevel.Info;
            }
         }
      }

      protected ScripterTestConfig? ScripterTestConfig { get; set; }


      /// <summary>
      /// standard script file name
      /// </summary>
      protected string ScriptFile { get; set;} = "script.sql";

      /// <summary>
      /// Displays the script file
      /// </summary>
      public void DisplayScript(string? script=null)
      {
         Assert.IsFalse(string.IsNullOrEmpty(ScriptFile), "script file path not specified");

         if(!File.Exists(ScriptFile))
         { 
            // Assert.IsTrue(File.Exists(ScriptFile));
            LogE($"42050: ScriptableUnitTestBase.DisplayScript({ScriptFile}): file does not exist");
            return;
         }

         if (script != null)
            File.WriteAllText(ScriptFile, script);
            
         Process.Start("Notepad++.exe", $"\"{ScriptFile}\"");
      }

      /// <summary>       
      /// This sets the script file
      /// Call base.TestSetup_() at the start
      /// </summary>
      protected override void TestSetup_()
      {
         LogS();
         base.TestSetup_();
         //DisplayScriptAfterTestFailure = GetAppSetting<bool>("Display script after test failure") ?? true; 
         ScriptFile = @$"D:\Logs\UnitTests\{CurrentTestMethodName ?? "????"}.sql";
         LogL();
      }

      /// <summary>
      /// This handles the per test cleanup
      /// Called from UnitTestBas.TestCleanup()
      /// Call base.TestCleanup_() at the end
      /// Display the Script if failed and DisplayScriptAfterTestFailure is true
      /// </summary>
      protected override void TestCleanup_()
      {
         LogS();
         var res = TestContext?.CurrentTestOutcome ?? UnitTestOutcome.Failed;

         // Display the Script if failed and DisplayScriptAfterTestFailure is true
         // Flag will be reset false after the cleanup
         if((res == UnitTestOutcome.Failed && (DisplayScriptAfterTest1Off || DisplayScriptAfterTestFailure)))
            DisplayScript();

         DisplayScriptAfterTest1Off = false;

         // Call base.TestCleanup_() at the end
         base.TestCleanup_();
         LogL();
      }
      /// <summary>
      ///
      /// Attempts to load the test.config.json file from the spefic test's  TestDataDir
      /// if not found it will recursively try up the test dat atree to the test root
      /// 
      /// PRECONDITIONS: expects the following:
      /// a folder named exactly as the test under bin/debug/testdata/
      /// TestDataDir to be correct
      ///
      /// </summary>
      /// POSTCONDITIONS:
      /// <returns></returns>true if config file is found and loaded ok, false other wise</returns>
      protected override bool LoadTestConfig()
      {
         LogS();
         string msg = "";
         bool ok = false;
         int ret = 0;
         var di = new DirectoryInfo(CurrentTestDataDir);
         bool exists = di.Exists;
         string testConfigFilePath = "";

         do
         {
            if (!FindTestConfigFile(di, out testConfigFilePath))
            {
               msg = $"test specific config json file [{testConfigFilePath}] not found";
               Log(msg);
               break;
            }

            // ASSERTION - we have found the TestConfig json file
            //
            ret = Deserialise<ScripterTestConfig>(testConfigFilePath, out var cfg, out var json, out msg);

            if (ret != 0)
               break;

            ScripterTestConfig = cfg;

            // Check it deserialised OK - else its a show stopper 
            Assertion(ScripterTestConfig != null, "Unexpected error loading TestConfig");
            SetLogLevel(cfg?.logLevel ?? CommonLib.LogLevel.Info);

            // ASSERTION - All good: we have loaded the TestConfig
            msg = $"Loaded test config: [{testConfigFilePath}], json:\n{json}";
            ok = true;
            break;
         } while (false);

         return LogRN(ok, msg);
      }
   }
}
