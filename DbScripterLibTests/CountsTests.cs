using DbScripterLibNS;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Diagnostics;
using RSS.Common;
using TestHelpers;
//using static RSS.Common.Logger;

namespace RSS.Test
{
   /// <summary>
   /// Summary description for UnitTest1
   /// </summary>
   [TestClass]
   public class CountsTests : ScriptableUnitTestBase
   {
      #region tests
           public Params CovidBaseParams {get;set; } = new Params
           (
             prms    : null // Use this state to start with and update with the subsequent parameters
            ,svrNm   : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instNm  : "SQLEXPRESS"
            ,dbNm    : "Covid_T1"
            ,newSchNm: "New Schema Name"
            ,rss     : "{dbo, [tEst]}"
            ,rts     : "S"
            ,cm      : null
            ,useDb   : false
            ,addTs   : false
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
         DbScripter sc = new DbScripter();

         Params p = Params.PopParams
         (
             nm        : "Count_Crt_Export_Tables_only_Schemas_dbo_tst_Test Params"
            ,prms      : CovidBaseParams
            ,xprtScrpt : ScriptFile
            ,cm        : CreateModeEnum.Create
            ,rss       : "{dbo, [ test]}"// should handle more than 1 schema and crappy formatting
            ,rts       : "t"             // this is overridden in Export schema as it exports all the child objects
            ,addTs     : false
         );

         Logger.Log(p);
         Assert.IsTrue(sc.Export(ref p, out var script, out var msg), msg);
         Assert.IsTrue(ChkContains(script, @"^([ \t]*CREATE[ \t]+TABLE[ \t\[]+dbo[^\.[ \t\[]+)" , 21, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^([ \t]*CREATE[ \t]+TABLE[ \t\[]+test[^\.[ \t\[]+)",  3, out msg), msg);
         Logger.LogL("All subtests passed");
      }

      public override void TestSetup_()
      {
         Logger.LogS();
         base.TestSetup_();
         Logger.LogL();
      }

      public override void TestCleanup_()
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
   }
}
