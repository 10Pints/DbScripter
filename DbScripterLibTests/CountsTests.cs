using DbScripterLibNS;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Diagnostics;
using Common;
using CommonLib;

namespace RSS.Test
{
   /// <summary>
   /// Summary description for UnitTest1
   /// </summary>
   [TestClass]
   public class CountsTests : ScriptableUnitTestBase
   {
      /*
      #region tests
           public Params CovidBaseParams {get;set; } = new Params
           (
              prms         : null // Use this state to start with and update with the subsequent parameters
            , serverName        : @"DEVI9\SQLEXPRESS"
            , instanceName       : "SQLEXPRESS"
            , databaseName         : "Covid_T1"
            , requiredSchemas          : "{dbo, [tEst]}"
            , requiredTypes          : "S"
            , createMode           : null
            , useDb        : false
            , addTimestamp : false
           );
 
      /// <summary>
      /// When exporting a schema we should be able to specift which types are exported
      /// the default should be all types
      /// but if we define a set of types then that should take precidence
      /// </summary>
      [TestMethod]
      public void Count_Crt_Export_Tables_only_Schemas_dbo_tst_Test()
      {
         Logger.LogS();
         DbScripter sc = new();

         Params p = Params.PopParams
         (
             name        : "Count_Crt_Export_Tables_only_Schemas_dbo_tst_Test Params"
            ,prms      : CovidBaseParams
            ,scriptFile : ScriptFile
            ,createMode        : CreateModeEnum.Create
            ,requiredSchemas       : "{dbo, [ test]}"// should handle more than 1 schema and crappy formatting
            ,requiredTypes       : "t"             // this is overridden in Export schema as it exports all the child objects
            , addTimestamp: false
         );

         Logger.Log(p);
         Assert.IsTrue(sc.Export(ref p, out var script, out var msg), msg);
         Assert.IsTrue(ChkContains(script, @"^([ \t]*CREATE[ \t]+TABLE[ \t\[]+dbo[^\.[ \t\[]+)" , 22, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^([ \t]*CREATE[ \t]+TABLE[ \t\[]+test[^\.[ \t\[]+)",  2, out msg), msg);
         Logger.LogL("All subtests passed");
      }

      protected override void TestSetup_()
      {
         Logger.LogS();
         base.TestSetup_();
         Logger.LogL();
      }

      protected override void TestCleanup_()
      {
         Logger.LogS();
         base.TestCleanup_();
         Logger.LogL();
      }

      #endregion tests
      #region test support


      public CountsTests()
      {
      }

 
      #region Additional test attributes
      //
      // You can use the following additional attributes as you write your tests:
      //
      // Use ClassInitialize to run code before running the first test in the class
      // [ClassInitialize()]
      // public static void MyClassInitialize(TestContext testContext) { }
      //
      // Use ClassCleanup to run code after all tests in a class have run
      // [ClassCleanup()]
      // public static void MyClassCleanup() { }
      //
      // Use TestInitialize to run code before running each test 
      // [TestInitialize()]
      // public void MyTestInitialize() { }
      //
      // Use TestCleanup to run code after each test has run
      // [TestCleanup()]
      // public void MyTestCleanup() { }
      //
      #endregion
      #endregion test support
      */
   }
}
