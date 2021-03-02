using DbScripterLib;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Diagnostics;
using static RSS.Common.Logger;

namespace RSS.Test
{
   /// <summary>
   /// Summary description for UnitTest1
   /// </summary>
   [TestClass]
   public class CountsTests : UnitTestBase
   {
      #region tests
           public Params CovidBaseParams {get;set; } = new Params
           (
             prms              : null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : @"C:\tmp\T002_InitTest_export.sql"
            ,newSchemaName     : "New Schema Name"
            ,requiredSchemas   : "{dbo, [tEst]}"
            ,requiredTypes     : "S"
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Undefined
            ,scriptUseDb       : false
            ,addTimestamp      : true
           );

      [TestMethod]
      public void Count1CrtSTableTest()
      {
         LogS();
         DbScripter sc = new DbScripter();
         var exportScriptPath = @"C:\temp\Count1CrtSchemaTest.sql";

         Params p = Params.PopParams(
             name             : "Count1CrtSchemaTest Params"
            ,prms             : CovidBaseParams
            ,exportScriptPath : exportScriptPath
            ,sqlType          : SqlTypeEnum.Table
            ,createMode       : CreateModeEnum.Create
            ,requiredSchemas  : "{dbo, [ teSt]}"// should handle more than 1 schema and crappy formatting
            ,requiredTypes    : "t"              // this is overridden in Export schema as it exports all the child objects
            );

         try
         { 
            Console.WriteLine(p);
            var script = sc.Export(p);

            Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE \[dbo\]\..*)"     , exportScriptPath, 21));
            Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE \[test\]\..*)"    , exportScriptPath,  3));
            LogL("All subtests passed");
         }
         catch(Exception e)
         {
            LogException(e);
            DisplayLog();
            Process.Start("notepad++.exe", exportScriptPath);
            throw;
         }
      }

      #endregion tests
      #region test support


      public CountsTests()
      {
      }

 /*     public Params CovidBaseParams {get;set; } = new Params(
             prms              : null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : @"C:\tmp\T002_InitTest_export.sql"
            ,newSchemaName     : "New Schema Name"
            ,requiredSchemas   : "{ dbo , [ teSt ] }"
            ,requiredTypes     : "F,P"
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Alter
            ,scriptUseDb       : false
            ,addTimestamp      : true
         );*/
 
 
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
