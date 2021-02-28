using DbScripterLib;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using RSS;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using RSS.Test;

namespace RSS.Test
{
   /// <summary>
   /// Summary description for UnitTest1
   /// </summary>
   [TestClass]
   public class CountsTests : UnitTestBase

   {
      #region tests
      /*     public Params CovidBaseParams {get;set; } = new Params(
             prms              : null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : @"C:\tmp\T002_InitTest_export.sql"
            ,newSchemaName     : "New Schema Name"
            ,requiredSchemas   : "{dbo, [tEst]}"
            ,requiredTypes     : "S"
            ,dbOpType          : DbOpTypeEnum.CreateSchema
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Alter
            ,scriptUseDb       : false
            ,addTimestamp      : true  */

      [TestMethod]
      public void Count1CrtSchemaTest()
      {
         DbScripter sc = new DbScripter();
         var exportScriptPath = @"C:\temp\Count1CrtSchemaTest.sql";

         Params p = Params.PopParams(
             name             : "Count1CrtSchemaTest Params"
            ,prms             : CovidBaseParams
            ,dbOpType         : DbOpTypeEnum.CreateSchema
            ,exportScriptPath : exportScriptPath
            ,newSchemaName    : null
            ,requiredSchemas  : "{dbo, [ teSt]}"// should handle more than 1 schema and crappy formatting
            ,requiredTypes    : ""              // this is overridden in Export schema as it exports all the child objects
//            ,createMode       : CreateModeEnum.Alter
            );

         try
         { 
            Console.WriteLine(p);
            var script = sc.Export(p);

            Assert.IsTrue(ChkContains(script, "^(CREATE SCHEMA.*)"               , exportScriptPath, 2));
            Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE \[dbo\]\..*)"     , exportScriptPath, 21));
            Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE \[test\]\..*)"    , exportScriptPath,  3));
            Assert.IsTrue(ChkContains(script, @"^(CREATE PROCEDURE \[test\]\..*)", exportScriptPath, 36));
         }
         catch(Exception)
         {
            Process.Start("notepad++.exe", exportScriptPath);
            throw;
         }
      }

      #endregion tests
      #region test support


      public CountsTests()
      {
      }

      public Params CovidBaseParams {get;set; } = new Params(
             prms              : null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : @"C:\tmp\T002_InitTest_export.sql"
            ,newSchemaName     : "New Schema Name"
            ,requiredSchemas   : "{ dbo , [ teSt ] }"
            ,requiredTypes     : "F,P"
            ,dbOpType          : DbOpTypeEnum.CreateSchema
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Alter
            ,scriptUseDb       : false
            ,addTimestamp      : true
         );

 
     // private TestContext testContextInstance;

 
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
