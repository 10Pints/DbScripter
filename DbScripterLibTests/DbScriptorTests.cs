using System;
using System.IO;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using DbScripterLib;
using System.Linq;
using Microsoft.SqlServer.Management.Smo;
using System.Collections;
using System.Text.RegularExpressions;
using System.Text;
using System.Collections.Generic;
using System.Diagnostics;
using RSS.Common;
using static DbScripterLib.Params;
using static RSS.Common.Logger;
using static RSS.Common.Utils;

namespace RSS.Test
{
   [TestClass]
   public class DbScriptorTests : UnitTestBase
   {
      #region tests

      /// <summary>
      /// 
      /// </summary>
      [TestMethod()]
      public void InitTableExportTest()
      {
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = PopParams( 
                prms             : CovidBaseParams
               ,exportScriptPath : @"C:\temp\InitTableExportTest.sql"
               ,createMode       : CreateModeEnum.Create
               ,sqlType          : SqlTypeEnum.Table
               ,requiredSchemas  : "tEst,tSqlt"
              );

         // Create and initise the scripter
         var sc = new DbScripterTestable(p);
         var orig = ShallowClone( sc.ScriptOptions);

         try 
         {
            // Run the rtn
            var so = sc.InitTableExport();
            Assert.IsFalse(so.ScriptForAlter);
            Assert.IsFalse(so.ScriptForCreateOrAlter);
            Assert.IsTrue(orig.Equals(sc.ScriptOptions));
         }
         catch(Exception e)
         {
            DisplayLog();
         }
      }

      /// <summary>
      /// should not sallow this combination
      /// </summary>
      [TestMethod()]
      [ExpectedException(typeof(Exception), AllowDerivedTypes = true)]
      public void InitTableExportTestEx()
      {
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = PopParams( 
                prms             : CovidBaseParams
               ,exportScriptPath : @"C:\temp\InitTableExportTestEx.sql"
               ,createMode       : CreateModeEnum.Alter
               ,sqlType          : SqlTypeEnum.Table
               ,requiredSchemas  : "tEst,tSqlt"
              );

         // Create and initise the scripter
         var sc = new DbScripterTestable(p);
         // Run the rtn
         var so = sc.InitTableExport();
      }


      /// <summary>
      /// Sets up the general scripter options
      /// 
      /// PRECONDITIONS:
      ///   PRE 1: P is valid
      ///   
      /// POSTCONDITIONS:
      ///  general: Scripter.Options state initialised with general settings
      ///  specific:
      ///  POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
      /// </summary>
      [ExpectedException(typeof(Exception), AllowDerivedTypes = true)]
      [TestMethod()]
      public void InitScriptingOptionsTestExpEx()
      {
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = PopParams( 
                prms             : CovidBaseParams
               ,exportScriptPath : @"C:\temp\T011_ExportSchemaScriptTest.sql"
               ,createMode       : CreateModeEnum.Alter
               ,sqlType          : SqlTypeEnum.Table
               ,requiredSchemas  : "tEst,tSqlt"
              );
       
         var sc = new DbScripterTestable(p);
      }

      [TestMethod()]
      public void InitScriptingOptionsTestExpNoEx()
      {
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = PopParams( 
                prms             : CovidBaseParams
               ,exportScriptPath : @"C:\temp\T011_ExportSchemaScriptTest.sql"
               ,createMode       : CreateModeEnum.Alter
               ,sqlType          : SqlTypeEnum.Procedure
               ,requiredSchemas  : "tEst,tSqlt"
              );
       
         var sc = new DbScripterTestable(p);
      }

      [TestMethod()]
      public void MapTypeToSqlTypeTest()
      {
         Params p = PopParams( 
                prms             :            CovidBaseParams
               ,exportScriptPath :@"C:\temp\MapTypeToSqlTypeTest.sql"
               ,createMode       : CreateModeEnum.Create
               ,sqlType          : SqlTypeEnum.Procedure
               ,requiredSchemas  : "tEst,tSqlt"
              );;
       
         var sc = new DbScripterTestable(p);
         Assert.AreEqual(SqlTypeEnum.Database , DbScripterTestable.MapTypeToSqlType(sc.Database));

         Assert.AreEqual(SqlTypeEnum.Function , DbScripterTestable.MapTypeToSqlType(new UserDefinedFunction()));
         Assert.AreEqual(SqlTypeEnum.Procedure, DbScripterTestable.MapTypeToSqlType(new StoredProcedure()));
         Assert.AreEqual(SqlTypeEnum.Schema   , DbScripterTestable.MapTypeToSqlType(new Schema()));
         Assert.AreEqual(SqlTypeEnum.Table    , DbScripterTestable.MapTypeToSqlType(new Table()));
         Assert.AreEqual(SqlTypeEnum.View     , DbScripterTestable.MapTypeToSqlType(new View()));
         Assert.AreEqual(SqlTypeEnum.TableType, DbScripterTestable.MapTypeToSqlType(new UserDefinedTableType()));
      }

      [TestMethod()]
      [ExpectedException( typeof(ArgumentException), AllowDerivedTypes=false)]
      public void MapTypeToSqlTypeTestUnknownTypeTest()
      {
         bool shouldThrowNow = false;
         try
         { 
            Params p = PopParams( 
                   prms             : CovidBaseParams
                  ,exportScriptPath : @"C:\temp\MapTypeToSqlTypeTestUnknownTypeTest.sql"
                  ,sqlType          : SqlTypeEnum.Schema
                  ,createMode       :  CreateModeEnum.Create
                  ,requiredSchemas  : "tEst,tSqlt"
                 );
       
            var sc = new DbScripter(p);
            // expect throw here
            shouldThrowNow = true;
            var unexpected = DbScripterTestable.MapTypeToSqlType(new UserDefinedDataType(sc.Database, "unexpected", "dbo"));
         }
         catch(Exception e)
         {
            var msg = e.GetAllMessages();
            LogException(e, $"shouldThrowNow: {shouldThrowNow}");

            if(shouldThrowNow)
               DisplayLog();

            Assert.IsTrue(shouldThrowNow);
            throw;
         }

         Assert.Fail("should not have gotten here");
      }


     [TestMethod]
      public void Count1CrtSchemaTest()
      {
         DbScripter sc = new DbScripter();
         var exportScriptPath = @"C:\temp\Count1CrtSchemaTest.sql";

         Params p = Params.PopParams(
             name             : "Count1CrtSchemaTest Params"
            ,prms             : CovidBaseParams
            ,exportScriptPath : exportScriptPath
            ,newSchemaName    : null
            ,requiredSchemas  : "{dbo, [ teSt]}"// should handle more than 1 schema and crappy formatting
            ,requiredTypes    : null            // this is overridden so that it exports all the child objects
            ,sqlType          : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Create
            );

         try
         { 
            Console.WriteLine(p);
            var script = sc.Export(p);

            Assert.IsTrue(ChkContains(script, "^(CREATE SCHEMA.*)"               , exportScriptPath, 2));
            //Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE \[dbo\]\..*)"     , exportScriptPath, 21));
            //Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE \[test\]\..*)"    , exportScriptPath,  3));
            //Assert.IsTrue(ChkContains(script, @"^(CREATE PROCEDURE \[test\]\..*)", exportScriptPath, 36));
         }
         catch(Exception )
         {
            Process.Start("notepad++.exe", exportScriptPath);
            DisplayLog();
            throw;
         }
      }
/*
      /* Test the constructor
      /// <summary>
      /// Main constructor
      /// sets the ionitial state nothing more
      /// i.e does not instantiae a Server etc.
      /// Test: DbScriptorTests.DbScriptorTest
      /// 
      /// PRECONDITIONS: none
      /// 
      /// POSTCONDITIONS:
      /// ServerName     = serverName
      /// InstanceName   = instanceName
      /// DatabaseName   = databaseName
      /// WriterFilePath = writerFilePath
      /// DbOpType       = opType
      /// 
      /// </summary>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath"></param>
      /// <param name="staticDataTables">Tables to export data from</param>
      * /
     [TestMethod()]
      public void T001_DbScripterTest()
      {
         var sc = new DbScripter();

         Assert.IsNull(sc.P.ServerName    ,"serverName");
         Assert.IsNull(sc.P.InstanceName  ,"instanceName");
         Assert.IsNull(sc.P.DatabaseName  ,"databaseName");
         Assert.IsNull(sc.P.ExportScriptPath,"writerFilePath");
//         Assert.IsNull(sc.P.DbOpType      ,"DbOpType");
      }

      /// <summary>
      /// Initialize state, deletes the writerFilePath file if it exists
      /// Only completes the initialisation if the parameters are all specified
      /// 
      /// PRECONDITIONS: none
      ///   
      /// POSTCONDITIONS:
      ///   1: Initialises the initial state
      ///   2: server and makes a connection, throws exception otherwise
      ///   3: sets the scripter options configuration based on optype
      /// </summary>
      /// <param name="databaseName"></param>
      /// <param name="opType"></param>
      /// <param name="writerFilePath"></param>
      /// <param name="staticDataTables"></param>
      /// <returns>Status</returns>
     [TestMethod()]
      public void T002_InitTest()
      {
         Params p = PopParams();
         var tsc = new DbScripterTestable();
         tsc.Init(p);

         Assert.AreEqual(tsc.P.ServerName       , @"DESKTOP-UAULS0U\SQLEXPRESS");
         Assert.AreEqual(tsc.P.InstanceName     , "SQLEXPRESS");
         Assert.AreEqual(tsc.P.DatabaseName     , "Covid_T1");
         Assert.AreEqual(tsc.P.ExportScriptPath , @"C:\tmp\T002_InitTest_export.sql");
 //        Assert.AreEqual(tsc.P.DbOpType         , DbOpTypeEnum.CreateSchema);
         Assert.AreEqual(tsc.P.NewSchemaName    , "newSchemaName");
         Assert.AreEqual(tsc.P.CreateMode       , CreateModeEnum.Alter);
         Assert.AreEqual(tsc.P.RequiredSchemas  , "FP");
      }


      [TestMethod]
      public void T003_Export_FnTest()
      {
         Params p = PopParams();
         var scriptor = new DbScripter();
         throw new NotImplementedException();
         //var script  = scriptor.ExportRoutines(p);
/*
         Assert.IsTrue(HelperChkListCount<UserDefinedFunction>( 
              scriptor.Database.UserDefinedFunctions
            , "dbo"
            , scriptor.ExportedFunctions.Count));
* /
      }


      [TestMethod]
      public void T004_ExportRoutines_ProcTest()
      {
         Params p = PopParams();
         var scriptor = new DbScripter();
/* serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
  ,instanceName:      "SQLEXPRESS"
  ,databaseName:      "ut"
  ,exportScriptPath:  @"C:\temp\T004_ExportRoutines_ProcTest.sql"
  ,requiredSchemas:   "[dbo]"
  ,requiredTypes:     "P"
  ,createMode:        CreateModeEnum.Create
  ,scriptUseDb:       true
  ,addTimestamp:      true
* /
          throw new NotImplementedException();
        /*var script  = scriptor.ExportRoutines(PopParams
         (
             databaseName:    "ut"
            ,exportScriptPath:@"C:\temp\T004_ExportRoutines_ProcTest.sql"
            ,requiredSchemas: "[dbo]"
            ,requiredTypes:   "P"
            ,createMode:      CreateModeEnum.Create
            ,scriptUseDb:     true
            ,addTimestamp:    true
         ));

         Assert.IsTrue(HelperChkListCount<StoredProcedure>(
            scriptor.Database.StoredProcedures
          , "dbo"
          , scriptor.ExportedProcedures.Count));
* /
      }

/* serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
  ,instanceName:      "SQLEXPRESS"
  ,databaseName:      "ut"
  ,exportScriptPath:  @"C:\temp\T005_ExportRoutines_FnAndPocTest.sql"
  ,requiredSchemas:   "[dbo]"
  ,requiredTypes:     "F,P"
  ,createMode:        CreateModeEnum.Create
  ,scriptUseDb:       true
  ,addTimestamp:      true
* /
      [TestMethod]
      public void T005_ExportRoutines_FnAndPocTest()
      {
         var filePath = $"{Path.GetTempPath()}test.sql";
         DbScripter scriptor = new DbScripter();
         throw new NotImplementedException();
         /*
         var script  = scriptor.ExportRoutines(PopParams
            (
             databaseName:    "ut"
            ,exportScriptPath:@"C:\temp\T005_ExportRoutines_FnAndPocTest.sql"
            ,requiredSchemas: "[dbo]"
            ,requiredTypes:   "F,P"
            ,createMode:      CreateModeEnum.Create
            ,scriptUseDb:     true
            ,addTimestamp:    true
            ));

         Assert.IsTrue(HelperChkListCount<UserDefinedFunction>( scriptor.Database.UserDefinedFunctions, "dbo", scriptor.ExportedFunctions.Count));
         Assert.IsTrue(HelperChkListCount<StoredProcedure>    ( scriptor.Database.StoredProcedures, "dbo", scriptor.ExportedProcedures.Count));
         * /
      }

/*
   serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
 , instanceName:      "SQLEXPRESS"
 , databaseName:      "covid"
 , exportScriptPath:  @"C:\temp\T006_ExportRoutines_FnsAlterMode.sql"
 , requiredTypes:     "F"
 , createMode:        CreateModeEnum.Alter
 , scriptUseDb:       true
 , newSchemaName:     "newdbo"
 , addTimestamp:      true
 , requiredSchemas:   "dbo"
* /
      [TestMethod]
      public void T006_ExportRoutines_FnsAlterMode()
      {
          throw new NotImplementedException();/*
        var filePath        = $"{Path.GetTempPath()}test.sql";
         DbScripter scriptor = new DbScripter();//serverName, instance, databaseName, writerFilePath: filePath);
         string script       = scriptor.ExportRoutines(PopParams
            (
             databaseName:    "covid"
            ,exportScriptPath:@"C:\temp\T006_ExportRoutines_FnsAlterMode.sql"
            ,requiredSchemas: "dbo"
            ,requiredTypes:   "F"
            ,createMode:      CreateModeEnum.Alter
            ,scriptUseDb:     true
            ,newSchemaName:   "newdbo"
            ,addTimestamp:    true
            ));

         // chk for alter function
         var numFnsExp = scriptor.ExportedFunctions.Count;
         //var    pattern = @"^ALTER FUNCTION\s\[*(.*?[^\]]*)\]*\.\[*(.*?[^\]]*)";
         var    pattern = @"^ALTER FUNCTION\s(.*)";
         MatchCollection matches= Regex.Matches(script, pattern, RegexOptions.Multiline | RegexOptions.IgnoreCase);
         var numFnsAct = matches.Count;

         if(numFnsExp != numFnsAct)
         {
            Console.WriteLine($"(numFnsExp: {numFnsExp} != numFnsAct: {numFnsAct} listing\r\n EXP:");

            foreach(var exp in scriptor.ExportedFunctions)
               Console.WriteLine(exp);

            Console.WriteLine("\r\nACT:");

            foreach (System.Text.RegularExpressions.Match m in matches)
            { 
               //string line = $"{m.Groups[2].Value}\t\t {m.Groups[1].Value}\t\t{m.Groups[0].Value}";
               string line = $"{m.Name}";

               // add game to list if not contained
               Console.WriteLine(line);
            }

            Console.WriteLine();

            Assert.IsTrue(HelperChkListCount<UserDefinedFunction>( scriptor.Database.UserDefinedFunctions, "dbo", numFnsExp));
         }

         Assert.AreEqual(numFnsExp, numFnsAct);
         * /
      }

/*
 *               serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
               , instanceName:      "SQLEXPRESS"
               , databaseName:      "covid"
               , exportScriptPath:  @"C:\temp\T007_ExportRoutines_AlterMode.sql"
               , requiredSchemas:   "tSQLt"
               , requiredTypes:     "P"
               , createMode:        CreateModeEnum.Alter
               , scriptUseDb:       true
               , addTimestamp:      true
 * /
      [TestMethod]
      public void T007_ExportRoutines_AlterMode()
      {
                   throw new NotImplementedException();/*

         DbScripter scriptor = new DbScripter();
         string script       = scriptor.ExportRoutines(PopParams
            (
             databaseName:      "Covid_T2"
            ,exportScriptPath:  @"C:\temp\T007_ExportSchemaScriptTest.sql"
            ,requiredSchemas:   "dbo"
            ,requiredTypes:     "F"
            ,createMode:        CreateModeEnum.Alter
            ,scriptUseDb:       true
            ,newSchemaName:     "newdbo"
            ,addTimestamp:      true
            ));
 
         // chk for alter proc
         var numPrcsExp = scriptor.ExportedProcedures.Count;
         var pattern = @"^ALTER PROC(.*)";
         MatchCollection matches= Regex.Matches(script, pattern, RegexOptions.Multiline | RegexOptions.IgnoreCase);
         var numpPrcsAct = matches.Count;

         if(numPrcsExp != numpPrcsAct)
         {
            Console.WriteLine($"(numFnsExp: {numPrcsExp} != numFnsAct: {numpPrcsAct} listing\r\n EXP:");

            foreach(var exp in scriptor.ExportedProcedures)
               Console.WriteLine(exp);

            Console.WriteLine("\r\nACT:");

            foreach (System.Text.RegularExpressions.Match m in matches)
               Console.WriteLine(m.Name);

            Console.WriteLine();
            Assert.IsTrue(HelperChkListCount<StoredProcedure>( scriptor.Database.StoredProcedures, "tSQLt", numPrcsExp));
         }

         Assert.AreEqual(numPrcsExp, numpPrcsAct);
         * /
      }

      [TestMethod]
      public void T008_ParseSchemas()
      {
         String msg;
         DbScripterTestable scriptor  = new DbScripterTestable();

         Assert.IsTrue(HelperParseSchemas( scriptor, "{dbo,[test] , [ab c]}", new string []{"dbo","test", "ab c"}, out msg), msg);
         Assert.IsTrue(HelperParseSchemas( scriptor, "   {   dbo    }   ", new string []{"dbo"}, out msg), msg);
         Assert.IsTrue(HelperParseSchemas( scriptor, null, null, out msg), msg);
         Assert.IsTrue(HelperParseSchemas( scriptor, ""  , null, out msg), msg);
      }

/*
 *               serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
               , instanceName:      "SQLEXPRESS"
               , databaseName:      "covid"
               , exportScriptPath:  @"C:\temp\T009_ExportRoutines_MultipleAlterSchemas.sql"
               , requiredSchemas:   "{dbo , [test], tSQLt}"
               , requiredTypes:     "P"
               , createMode:        CreateModeEnum.Alter
               , scriptUseDb:       true
               , addTimestamp:      true
* /
      [TestMethod]
      public void T009_ExportRoutines_MultipleAlterSchemas()
      {
           throw new NotImplementedException();/*
        DbScripter scriptor = new DbScripter();

         string script       = scriptor.ExportRoutines(PopParams
            (
             databaseName:      "covid"
            ,exportScriptPath:  @"C:\temp\T009_ExportRoutines_MultipleAlterSchemas.sql"
            ,requiredSchemas:   "{dbo , [test], tSQLt}"
            ,requiredTypes:     "P"
            ,createMode:        CreateModeEnum.Alter
            ,scriptUseDb:       true
            ,addTimestamp:      true
            ));
 
         // chk for alter proc
         var numPrcsExp = scriptor.ExportedProcedures.Count;
         //var pattern = @"^ALTER PROC[^\s]*[\s\[]*([^\]\.]*)[/s\.](.*)";  137 hits
         var pattern = @"^ALTER PROC[^\s]*[\s\[]*(.*)";
         MatchCollection matches= Regex.Matches(script, pattern, RegexOptions.Multiline | RegexOptions.IgnoreCase);
         var numpPrcsAct = matches.Count;

         //LogExpAct(scriptor.ExportedProcedures.Values, matches, @"C:\Temp\T009_ExportRoutines_MultipleAlterSchemas.dat",@"C:\temp\T007_ExportRoutines_MultipleAlterSchemas.sql");

         Assert.AreEqual(numPrcsExp, numpPrcsAct);
         * /
      }

/*
                 serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
               , instanceName:      "SQLEXPRESS"
               , databaseName:      "covid"
               , exportScriptPath:  @"C:\temp\T010_ExportTest_CrtDb.sql"
               , dbOpType:          DbOpTypeEnum.ExportCreateDatabaseScript
               , addTimestamp:      true
* /
      [TestMethod()]
      public void T010_ExportTest_CrtDb()
      {
         DbScripter scriptor = new DbScripter();

         string script       = scriptor.Export(PopParams
            (
             databaseName:      "covid"
            ,exportScriptPath:  @"C:\temp\T010_ExportTest_CrtDb.sql"
            ,requiredSchemas:   "{dbo , [test], tSQLt}"
            ,requiredTypes:     null
            ,addTimestamp:      true
            ));
      }

      /// <summary>
      /// Format: ut_{dbo}_FP_210214-2109_export.sql
      /// </summary>
      [TestMethod()]
      public void HandleExportFilePathTest()
      {
         string act;
         string exp2 ;
         var sct = new DbScripterTestable();

         // Format: ut_{dbo}_FP_210214-2109_export.sql: exp appended timestamp
         Assert.IsTrue( HandleExportFilePathHlpr(
              sct
            , @"C:\temp\T010_ExportTest_CrtDb.sql"
            , true
            , @"C:\temp\T010_ExportTest_CrtDb_210101-0000.sql"
            , out exp2
            , out act), $" expected: {exp2}, but act: {act}");

         // Format: ut_{dbo}_FP_210214-2109_export.sql: no change
         Assert.IsTrue( HandleExportFilePathHlpr(
              sct
            , @"C:\temp\ut_{dbo}_FP_210214-2109_export.sql"
            , true
            , @"C:\temp\ut_{dbo}_FP_210214-2109_export.sql"
            , out exp2
            , out act), $" expected: {exp2}, but act: {act}");
      }

/*
               serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
            , instanceName:      "SQLEXPRESS"
            , databaseName:      "Covid_T1"
            , newSchemaName:     "testx"
            , exportScriptPath:  @"C:\temp\T011_ExportSchemaScriptTest.sql"
* /
      [TestMethod()]
      public void T011_ExportSchemaScriptTest()
      {
          throw new NotImplementedException();/*
         var sc = new DbScripter();

         var script = sc.ExportSchemas (PopParams
            (
             serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName:      "SQLEXPRESS"
            ,databaseName:      "Covid_T1"
            ,exportScriptPath:  @"C:\temp\T011_ExportSchemaScriptTest.sql"
            ,requiredSchemas:   "{dbo , [test], tSQLt}"
            ,requiredTypes:     null
            ,addTimestamp:      true
            ));

         var counts = new Counts(script, "CREATE");

         Assert.Fail();
* /
      }

      /*         string serverName    = @"DESKTOP-UAULS0U\SQLEXPRESS"
              , instanceName  = "SQLEXPRESS"
              , databaseName  = "Covid_T2"
              , exportScriptPath =  @"C:\temp\TreateDatabaseTest.sql"
              , newSchemaName:   "testx"
* /
      [TestMethod()]
      public void CreateDatabaseTest()
      {
          throw new NotImplementedException();/*
         var sc = new DbScripter();

         var script = sc.ExportCreateDatabaseScript(PopParams
         (
             serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName:      "SQLEXPRESS"
            ,databaseName:      "Covid_T2"
            ,exportScriptPath:  @"C:\temp\TreateDatabaseTest.sql"
            ,requiredSchemas:   null
            ,requiredTypes:     null
            ,addTimestamp:      true
            ,newSchemaName:     null
         ));
         
         Assert.IsNotNull(script);
         Assert.IsTrue(script.Length >0);
         // CREATE DATABASE [Covid_T2]
         Assert.IsTrue(script.Contains("CREATE DATABASE"));
         Assert.IsTrue(script.Contains("[Covid_T2]"));
         Assert.IsFalse(script.Contains("[["));
         Assert.IsFalse(script.Contains("]]"));
         Process.Start("notepad++.exe", sc.P.ExportScriptPath);
      * /
      }
     [TestMethod()]
      public void CreateDatabaseTestHndlSqBrkts()
      {
                   throw new NotImplementedException();/*
var sc = new DbScripter();

         var script = sc.ExportCreateDatabaseScript(PopParams
         (
             serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName:      "SQLEXPRESS"
            ,databaseName:      "[Covid_T2]"
            ,exportScriptPath:  @"C:\temp\CreateDatabaseTestHndlSqBrkts.sql"
            ,requiredSchemas:   null
            ,requiredTypes:     null
            ,addTimestamp:      true
            ,newSchemaName:     null
         ));
         
         Assert.IsNotNull(script);
         Assert.IsTrue(script.Length >0);
         // CREATE DATABASE [Covid_T2]
         Assert.IsTrue(script.Contains("CREATE DATABASE"));
         Assert.IsTrue(script.Contains("[Covid_T2]"));
         Assert.IsFalse(script.Contains("[["));
         Assert.IsFalse(script.Contains("]]"));
         Process.Start("notepad++.exe", sc.P.ExportScriptPath);
      * /
      }

      /// <summary>
      /// Desc: the tested fn: filters against the  current parameters
      /// Rules, Responsibilities & Preconditions
      /// 
      /// Rules:
      /// 
      /// Responsibilities
      /// 
      /// Preconditions
      /// 
      /// Tests, test for the following:
      /// T01: exisiting   wanted db                                    exp: true
      /// T02: exisiting unwanted db                                    exp: true
      /// T03:  null item                                               exp: false
      /// T04: unwanted schema from dif db that exists in the crnt db   exp: false
      /// T05:   wanted sql type                                        exp: true
      /// T06: unwanted sqltype                                         exp: false
      /// T0:  exp: false
      /// </summary>
      [TestMethod()]
      public void IsWantedTest()
      {          throw new NotImplementedException();/*

         var exportScriptPath = @"C:\temp\IsWantedTest_0.sql";
         var defltPrms = new Params
         (
             serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : exportScriptPath 
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
            ,dbOpType          : DbOpTypeEnum.Undefined
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Undefined
            ,scriptUseDb       : false
            ,addTimestamp      : false
         );

         DbScripterTestable tsc = new DbScripterTestable(defltPrms);

         try
         { 
            do
            { 

               /// T01: exisiting   wanted scheam                                   exp: true
               Schema schema = new Schema(tsc.Database, "dbo");
  
               tsc.Init
               (
                  PopParams
                  (
                      prms:               defltPrms
                     ,exportScriptPath:   @"C:\temp\IsWantedTest_1.sql"
                     ,requiredSchemas:    "{dbo , [test], tSQLt}"
                     ,requiredTypes:      null
                  ), true
               ); // Append = true

               Assert.AreEqual(true, tsc.IsWanted(schema.Name, schema));


               /// T02: exisiting unwanted Schema   [test]                                 exp: true
               tsc.Init(PopParams
                  (
                      prms: tsc.P
                     ,exportScriptPath:   @"C:\temp\IsWantedTest_2.sql"
                     ,requiredSchemas:    "{ [test], tSQLt}"
                     ,requiredTypes:      null
                  )
                  ,true // Append = true
                );

               Assert.AreEqual(false, tsc.IsWanted(schema.Name, new Schema(tsc.Database, "dbo")));
              // break;
              
               /// T03:  null item                                               exp: false
               IsWantedHlpr
               (
                   tsc:    tsc
                  ,prms:   PopParams
                  (
                      prms: tsc.P
                     ,exportScriptPath:   @"C:\temp\IsWantedTest_3.sql"
                     ,requiredSchemas:    "{dbo , [test], tSQLt}"
                     ,requiredTypes:      null
                  )
                  , obj: new Schema(tsc.Database, "")
                  ,currentSchemaName: "Fred"
                  ,exp:  true
                );
               /// T04: unwanted schema from dif db that exists in the crnt db   exp: false
               IsWantedHlpr
               (
                   tsc:    tsc
                  ,prms:   PopParams
                  (
                      prms: tsc.P
                     ,requiredSchemas:    "{dbo , [test], tSQLt}"
                     ,exportScriptPath:   @"C:\temp\IsWantedTest_4.sql"
                     ,requiredTypes:      null
                  )
                  , obj: new Schema(tsc.Database, "")
                  ,currentSchemaName: "Fred"
                  ,exp:  true
                );

               /// T05:   wanted sql type                                        exp: true
               IsWantedHlpr
               (
                   tsc:    tsc
                  ,prms:   PopParams
                  (
                      prms: tsc.P
                     ,exportScriptPath:   @"C:\temp\IsWantedTest_5.sql"
                     ,requiredSchemas:    "{dbo , [test], tSQLt}"
                     ,requiredTypes:      null
                  )
                  , obj: new Schema(tsc.Database, "")
                  ,currentSchemaName: "Fred"
                  ,exp:  true
                );

               /// T06: unwanted sqltype                                         exp: false
               IsWantedHlpr
               (
                   tsc:    tsc
                  ,prms:   PopParams
                  (
                      prms: tsc.P
                     ,exportScriptPath:   @"C:\temp\IsWantedTest_6.sql"
                     ,requiredSchemas:    "{dbo , [test], tSQLt}"
                     ,requiredTypes:      null
                  )
                  , obj: new Schema(tsc.Database, "")
                  ,currentSchemaName: "Fred"
                  ,exp:  true
                );

            } while(false);
         }
         catch(Exception e)
         { 
            LogException(e);
            Process.Start("notepad++.exe", exportScriptPath);
            throw;
         }
         * /
      }


      protected void IsWantedHlpr(DbScripterTestable tsc, Params prms, string currentSchemaName, SqlSmoObject obj, bool exp)
      { 
         tsc.Init(prms);
         bool act = tsc.IsWanted(currentSchemaName, obj);
         Assert.AreEqual(exp, act);
      }

      /// <summary>
      /// PRE Init called
      ///     serverName:         @"DESKTOP-UAULS0U\SQLEXPRESS"
      ///   , instanceName:      "SQLEXPRESS"
      ///   , databaseName:      "Covid_T1"
      ///   , exportScriptPath:  @"C:\temp\ExportDropSchemaScriptTest.sql"
      ///   , newSchemaName:     
      ///   , dbOpType:          
      ///   , createMode:        
      ///
      ///  Rules:
      ///   R01: 1 and only 1 schema can be dropped at a time 
      ///   R02: schema name must not be null and have at least 1 character
      ///   R03: Schema {tgtSchemaName} does not exist in the database {Database.Name}
      ///   
      /// Test Dependencies:
      ///   IsWanted
      ///   ExportViews
      ///   ExportTabless
      ///   ExportProcedures
      ///   ExportFunctionss
      /// </summary>
      [TestMethod()]
      public void ExportDropSchemaScriptTest()
      {
         var sc = new DbScripter();
         var exportScriptPath =  @"C:\temp\ExportDropSchemaScriptTest.sql";

         // General Green test
         Params p = PopParams(
             prms:               CovidBaseParams
            ,serverName:         @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName:       "SQLEXPRESS"
            ,databaseName:       "Covid_T1"
            ,exportScriptPath:   exportScriptPath
//          ,dbOpType:           DbOpTypeEnum.DropSchema
            ,requiredSchemas:    "{[test]}"
            ,requiredTypes:      null //"F,P,V,T,TTy" // all types TTy = Table type
            ,scriptUseDb:        true
         );

         var script = sc.Export(p).ToUpper();

         try 
         { 
            // Test the rules
            //   R01: 1 and only 1 schema can be dropped at a time
            Assert.AreEqual(1, script.Occurrences("DROP SCHEMA"), "R01: 1 and only 1 schema can be dropped at a time");
            Assert.IsTrue(script.Contains("DROP VIEW"), "no views droppped");
            Assert.IsTrue(script.Contains("DROP PROCEDURE"), "drop script is not producing drop procedures correctly");
            Assert.IsTrue(script.Contains("DROP FUNCTION") , "drop script is not producing drop functions correctly");

            Assert.IsTrue(script.Contains("COVID_T1"), "Db name present test failed");
            Assert.IsFalse(script.Contains("CREATE PROCEDURE"), "drop script is not producing drop procedures correctly");
            Assert.IsFalse(script.Contains("CREATE FUNCTION"), "drop script is not producing drop functions correctly");

            // Test the rules
            //   R01: 1 and only 1 schema can be dropped at a time

            /*
                     //   R02: schema name must not be null and have at least 1 character
                     Assert.IsTrue( ExportDropSchemaScriptTestExHlpr(sc, PopParams(
                         databaseName:       "Covid_T1"
                        ,exportScriptPath:   @"C:\temp\ExportDropSchemaScriptTest.sql"
                        ,dbOpType:           DbOpTypeEnum.DropSchema
                        ,requiredSchemas:    null
                     // ,requiredTypes:     null
                     // ,addTimestamp:      true
                     // ,newSchemaName:     "testx"
                     ), "R01: 1 and only 1 schema can be dropped at a time"));

                     //   R02.2: schema name must not be null and have at least 1 character
                     Assert.IsTrue( ExportDropSchemaScriptTestExHlpr(sc, PopParams(
                         databaseName:       "Covid_T1"
                        ,exportScriptPath:   @"C:\temp\ExportDropSchemaScriptTest.sql"
                        ,dbOpType:           DbOpTypeEnum.DropSchema
                        ,requiredSchemas:    "{}"
                     // ,requiredTypes:     null
                     // ,addTimestamp:      true
                     // ,newSchemaName:     "testx"
                     ), "R02: schema name must not be null and have at least 1 character"));

                    //   R03: Schema {tgtSchemaName} does not exist in the database {Database.Name}
                    Assert.IsTrue( ExportDropSchemaScriptTestExHlpr(sc, PopParams(
                         databaseName:       "Covid_T1"
                        ,exportScriptPath:   @"C:\temp\ExportDropSchemaScriptTest.sql"
                        ,dbOpType:           DbOpTypeEnum.DropSchema
                        ,requiredSchemas:   "{abcd}"
                     // ,requiredTypes:     null
                     // ,addTimestamp:      true
                     // ,newSchemaName:     "testx"
                     ), $"R03: Schema abcd does not exist in the database {sc.Database.Name}"));
                     * /
         }
         catch(Exception e)
         { 
            LogException(e);
            Process.Start("notepad++.exe", exportScriptPath);
            throw;
         }
      }

/*
   This test tests the creation of a DropDatabaseScript even tho the database does not exist
         string exportScriptPath:  @"C:\temp\ExportDropDatabaseScriptTest.sql"; 
         DB: "Covid_T2"
* /
      [TestMethod()]
      public void ExportDropDatabaseScriptTest()
      {
          throw new NotImplementedException();/*
         var sc = new DbScripter();
         string script;
         string exportScriptPath = @"C:\temp\ExportDropDatabaseScriptTest.sql";
         
         try
         { 
            script = sc.ExportDropDatabaseScript(PopParams
                        (
                           serverName:       @"DESKTOP-UAULS0U\SQLEXPRESS"
                          ,instanceName:     "SQLEXPRESS"
                          ,databaseName:     "Covid_T1"
                          ,exportScriptPath: exportScriptPath
                          ,dbOpType:         DbOpTypeEnum.DropDatabase
                        )).ToUpper();

            Assert.IsTrue(script.Contains("DROP DATABASE"), "DROP DATABASE test failed");
            Assert.IsTrue(script.Contains("COVID_T1"), "Db name present test failed");
         }
         catch(Exception e)
         {
            LogException(e);
            Process.Start("notepad++.exe", exportScriptPath);
            throw;
         }
         * /
      }
/*
      [TestMethod()]
      public void ExportStaticDataScriptTest()
      {
         Assert.Fail();
      }

      [TestMethod()]
      public void ExportDynamicDataScriptTest()
      {
         Assert.Fail();
      }
* /

      [TestMethod()]
      public void ScriptSchemaCreateTest()
      {
          throw new NotImplementedException();/*
         var exportScriptPath = @"C:\temp\ExportDropViewsTest.sql";
         var sc = new DbScripter();
         var script = sc.Export(PopParams
            (
             prms:CovidBaseParams
        //    ,dbOpType: DbOpTypeEnum.DropViews
            ,exportScriptPath: exportScriptPath
            ,requiredSchemas: "dbo"
            ));
* /
      }

      [TestMethod()]
      public void ExportDropViewsTest()
      {  
         var exportScriptPath = @"C:\temp\ExportDropViewsTest.sql";
         var sc = new DbScripter();
         var script = sc.ExportViews(PopParams
            (
             prms:CovidBaseParams
 //         ,dbOpType: DbOpTypeEnum.DropViews
            ,exportScriptPath: exportScriptPath
            ,requiredSchemas: "dbo"
            ));

         ChkContains(script, "DROP VIEW ", exportScriptPath, 5);
      }

      [TestMethod()]
      public void ExportDropViewsTest2()
      {  
         var exportScriptPath = @"C:\temp\ExportDropViewsTest2.sql";
         var sc = new DbScripter();
         Params p =PopParams
            (
                prms:CovidBaseParams
//             ,dbOpType         : DbOpTypeEnum.DropViews
               ,exportScriptPath : exportScriptPath
               ,serverName       : @"DESKTOP-UAULS0U\SQLEXPRESS"
               ,instanceName     : "SQLEXPRESS"
               ,databaseName     : "Covid_T1"
               ,newSchemaName    : null
               ,requiredSchemas  : "{tSqLT}" // case insensitive
               ,requiredTypes    : null
               ,sqlType          : SqlTypeEnum.Undefined
               ,createMode       : CreateModeEnum.Undefined
               ,scriptUseDb      : false
               ,addTimestamp     : false
           );

         var script = sc.ExportViews(p);
         
         var r = new Counts(script, "DROP VIEW ");
         ChkContains(script, "DROP VIEW ", exportScriptPath, 4);
         // 1 accurate line test
         ChkContains(script, "DROP VIEW [tSQLt].[Private_SysIndexes]", exportScriptPath, 4);
/*
         try
         { 
            Assert.IsTrue(script.Contains("DROP VIEW "), "script does not contain 'DROP VIEW '");
            var r = new Counts(script, "DROP");
            // Expect
            Assert.AreEqual(4, r.ExportedViews.Count);
            // 1 accurate line test
            Assert.IsTrue(script.Contains("DROP VIEW [tSQLt].[Private_SysIndexes]"), "script does not contain 'DROP VIEW [tSQLt].[Private_SysIndexes]'");
          }
         catch(Exception e)
         { 
            LogException(e);
            Process.Start("notepad++.exe", exportScriptPath);
            throw;
         }
* /
     }

      /// <summary>
      ///   If InitWriter fails it will throw and exception
      /// </summary>
      [TestMethod()]
      public void T012_InitWriterTest()
      {
         string exportScriptPath = @"C:\temp\T014_InitWriterTest.sql";
         Params p = Params.PopParams(exportScriptPath: exportScriptPath);
         var tsc = new DbScripterTestable();
         tsc.P.ExportScriptPath = exportScriptPath;
         tsc.InitWriter();// "T014_InitWriterTest: InitWriter failed 1");
      }

      /// <summary>
      /// Functional dependencies:
      /// Init()
      /// Test dependencies:
      /// T002_InitTest()
      /// T012_InitWriterTest
      /// </summary>
/*
          string serverName   = @"DESKTOP-UAULS0U\SQLEXPRESS"
              , instanceName  = "SQLEXPRESS"
              , databaseName  = "Covid_T1"
              , newSchemaName = "testX"
              , tableName     = "Covid"
              , exportScriptPath:  $@"C:\tmp\{databaseName}"
              ;

* /
      [TestMethod()]
      public void T013_ExportTableTest()
      {
         string serverName       = @"DESKTOP-UAULS0U\SQLEXPRESS"
              , instanceName     = "SQLEXPRESS"
              , databaseName     = "Covid_T1"
              , newSchemaName    = "testX"
              , tableName        = "Covid"
              , exportScriptPath =  $@"C:\tmp\{databaseName}"
              ;

         StringBuilder sb = new StringBuilder();

        var tsc = new DbScripterTestable();
        tsc.ExportTable
        (  tableName: tableName
        , p: PopParams( 
                databaseName:      "Covid_T1"
               ,serverName:        serverName
               ,instanceName:      instanceName
               ,exportScriptPath:  exportScriptPath
               ,newSchemaName:     newSchemaName
               ,createMode:        CreateModeEnum.Alter
              )
         , sb
        );

        Assert.IsTrue(sb.Length>0);
      }


      /// <summary>
      /// Test dependencies:
      /// T012_InitWriterTest
      /// T013_ExportTableTest()
      /// </summary>
      [TestMethod()]
      public void T014_ExportTablesTest()
      {
         string serverName    = @"DESKTOP-UAULS0U\SQLEXPRESS"
              , instanceName  = "SQLEXPRESS"
              , databaseName  = "Covid_T1";

        var sc = new DbScripter();

         var script = sc.Export
         (PopParams(
             serverName:         serverName
            ,instanceName:       instanceName
            ,databaseName:       databaseName
            ,exportScriptPath:   @"C:\temp\T011_ExportSchemaScriptTest.sql"
//            ,dbOpType:           DbOpTypeEnum.CreateTables
            ,newSchemaName:      "tested"
         ));

         var counts = new Counts(script, "CREATE");

         Assert.Fail();
      }

      [TestMethod()]
      public void T015_ClearStateTest()
      {
         var tsc = new DbScripterTestable();
         tsc.ClearState();

         // Primary properties
         Assert.AreEqual(tsc.P.CreateMode, CreateModeEnum.Undefined);
         Assert.IsNull(tsc.P.DatabaseName);
//         Assert.AreEqual(tsc.P.DbOpType, DbOpTypeEnum.Undefined);
         Assert.IsNull(tsc.P.InstanceName);
         Assert.IsNull(tsc.P.NewSchemaName);
         Assert.IsNull(tsc.P.ServerName);
         Assert.AreEqual(tsc.P.SqlType, SqlTypeEnum.Undefined);
         //Assert.IsFalse(tsc.P.Status);
         Assert.IsNull(tsc.P.NewSchemaName);

         // Major properties
         Assert.IsNull(tsc.Database);
         Assert.IsNull(tsc.Scripter);
         Assert.IsNull(tsc.ScriptOptions);
         Assert.IsNull(tsc.Server);
         Assert.IsNull(tsc.Writer);

         // info cache
         Assert.IsNotNull( tsc.ExportedFunctions);
         Assert.IsNotNull( tsc.ExportedProcedures);
         Assert.IsNotNull( tsc.ExportedTables);
         Assert.IsNotNull( tsc.ExportedViews);
         
         Assert.AreEqual( 0, tsc.ExportedFunctions .Count);
         Assert.AreEqual( 0, tsc.ExportedProcedures.Count);
         Assert.AreEqual( 0, tsc.ExportedTables    .Count);
         Assert.AreEqual( 0, tsc.ExportedViews     .Count);
      }


      [TestMethod()]
      public void T016_CreateAndOpenServerTest()
      {
         string serverName    = @"DESKTOP-UAULS0U\SQLEXPRESS"
              , instanceName  = "SQLEXPRESS";
//            , databaseName  = "Covid_T1";

         var tsc = new DbScripterTestable();
         Server server = Utils.CreateAndOpenServer(serverName, instanceName);//, databaseName);
         Assert.IsNotNull(server,  "did not create Server object");
      }

      [TestMethod()]
      public void GetDependencyWalkTest()
      {
         Params p = PopParams( 
                prms:            CovidBaseParams
               ,exportScriptPath:@"C:\temp\T011_ExportSchemaScriptTest.sql"
 //            ,dbOpType:        DbOpTypeEnum.CreateTables
               ,requiredSchemas: "tEst,tSqlt"
              );
       
         var sc = new DbScripter(p);
         var name = sc.Database.Tables[0].Name;
         var tables= new List<Table>();
         tables.Add(sc.Database.Tables["AppLog", "test"]);
         tables.Add(sc.Database.Tables["Covid_tst", "test"]);
         tables.Add(sc.Database.Tables["Private_AssertEqualsTableSchema_Actual", "tSQLt"]);
         tables.Add(sc.Database.Tables["Private_ExpectException", "tSQLt"]);
         var walk = sc.GetDependencyWalk(tables);
         Assert.AreEqual(5, walk.Count);
         Assert.IsTrue(walk.Contains("Private_AssertEqualsTableSchema_Actual"));
      }

      [TestMethod()]
//      [ExpectedException( typeof(ArgumentException), AllowDerivedTypes=false)]
      public void IsTypeWantedTest()
      {
         Params p = PopParams( 
                prms             : CovidBaseParams
               ,exportScriptPath : @"C:\temp\T011_ExportSchemaScriptTest.sql"
               //,dbOpType         : DbOpTypeEnum.CreateTables
               ,requiredSchemas  : "tEst,tSqlt"
               //,isExprtngData    : true
               //,isExprtngDb      : true
               //,isExprtngFKeys   : true
               //,isExprtngFns     : true
               //,isExprtngProcs   : true
               //,isExprtngSchema  : true
               //,isExprtngTbls    : true
               //,isExprtngTTys    : true
               //,isExprtngVws   : true
              );
       
         var sc = new DbScripter(p);

         // 1: defaults
         Assert.IsNull(sc.P.IsExprtngData   );
         Assert.IsNull(sc.P.IsExprtngDb     );
         Assert.IsNull(sc.P.IsExprtngFKeys  );
         Assert.IsNull(sc.P.IsExprtngFns    );
         Assert.IsNull(sc.P.IsExprtngProcs  );
         Assert.IsNull(sc.P.IsExprtngSchema );
         Assert.IsNull(sc.P.IsExprtngTbls   );
         Assert.IsNull(sc.P.IsExprtngTTys   );
         Assert.IsNull(sc.P.IsExprtngVws    );

         // set true get cycle
         sc.P.IsExprtngData   = true;
         sc.P.IsExprtngDb     = true;
         sc.P.IsExprtngFKeys  = true;
         sc.P.IsExprtngFns    = true;
         sc.P.IsExprtngProcs  = true;
         sc.P.IsExprtngSchema = true;
         sc.P.IsExprtngTbls   = true;
         sc.P.IsExprtngTTys   = true;
         sc.P.IsExprtngVws    = true;

         Assert.IsTrue(sc.P.IsExprtngData   ?? false);
         Assert.IsTrue(sc.P.IsExprtngDb     ?? false);
         Assert.IsTrue(sc.P.IsExprtngFKeys  ?? false);
         Assert.IsTrue(sc.P.IsExprtngFns    ?? false);
         Assert.IsTrue(sc.P.IsExprtngProcs  ?? false);
         Assert.IsTrue(sc.P.IsExprtngSchema ?? false);
         Assert.IsTrue(sc.P.IsExprtngTbls   ?? false);
         Assert.IsTrue(sc.P.IsExprtngTTys   ?? false);
         Assert.IsTrue(sc.P.IsExprtngVws    ?? false);

          // set false get cycle
         sc.P.IsExprtngData   = false;
         sc.P.IsExprtngDb     = false;
         sc.P.IsExprtngFKeys  = false;
         sc.P.IsExprtngFns    = false;
         sc.P.IsExprtngProcs  = false;
         sc.P.IsExprtngSchema = false;
         sc.P.IsExprtngTbls   = false;
         sc.P.IsExprtngTTys   = false;
         sc.P.IsExprtngVws    = false;

         Assert.IsFalse(sc.P.IsExprtngData   ?? true);
         Assert.IsFalse(sc.P.IsExprtngDb     ?? true);
         Assert.IsFalse(sc.P.IsExprtngFKeys  ?? true);
         Assert.IsFalse(sc.P.IsExprtngFns    ?? true);
         Assert.IsFalse(sc.P.IsExprtngProcs  ?? true);
         Assert.IsFalse(sc.P.IsExprtngSchema ?? true);
         Assert.IsFalse(sc.P.IsExprtngTbls   ?? true);
         Assert.IsFalse(sc.P.IsExprtngTTys   ?? true);
         Assert.IsFalse(sc.P.IsExprtngVws    ?? true);
      }

      /// <summary>
      /// PRE:  NONE
      /// POST: all UNDEFIEND flags set true
      /// </summary>
      [TestMethod()]
      public void SetUndefinedExportSchemaFlagsTest()
      {
         string fn = "SetUndefinedExportSchemaFlagsTest";
         LogS(fn);

         Params p = PopParams( 
                name             : "SetUndefinedExportSchemaFlagsTest Params"
               ,prms             : CovidBaseParams
               ,exportScriptPath : null
//             ,dbOpType         : DbOpTypeEnum.CreateTables
               ,requiredSchemas  : "tEst,tSqlt"
               //,isExprtngData  : true
               //,isExprtngDb    : true
               //,isExprtngFKeys : true
               //,isExprtngFns   : true
               //,isExprtngProcs : true
               //,isExprtngSchema: true
               //,isExprtngTbls  : true
               //,isExprtngTTys  : true
               //,isExprtngVws   : true
              );
       
         LogD("calling new DbScripterTestable(p)");
         var tsc = new DbScripterTestable(p);
         LogD("ret frm new DbScripterTestable(p)");
         string msg;
         // start with all null
         Assert.IsTrue(SetUndefinedExportSchemaFlagsTestHlpr("ST01", null,  out msg), msg);
         // start with all clear
         Assert.IsTrue(SetUndefinedExportSchemaFlagsTestHlpr("ST01", false, out msg), msg);
         // start with all set
         Assert.IsTrue(SetUndefinedExportSchemaFlagsTestHlpr("ST01", true , out msg), msg);
      }

      protected bool SetUndefinedExportSchemaFlagsTestHlpr(string name, bool? st, out string msg)
      {
         string fn = "SetUndefinedExportSchemaFlagsTestHlpr";
         LogS(fn);
         var tsc = new DbScripterTestable();
         msg = null;
         bool ret = false;

         // start with all null
         tsc.ResetUndefinedExportSchemaFlags(null);

         tsc.Init(PopParams
         (
               name             : name
            ,prms             : CovidBaseParams
            ,exportScriptPath : $@"C:\temp\SetUndefinedExportSchemaFlagsTest {name}.sql"
//          ,dbOpType         : DbOpTypeEnum.CreateTables
//          ,requiredSchemas  : "tEst,tSqlt"
            ,isExprtngData    : st
            ,isExprtngDb      : st
            ,isExprtngFKeys   : st
            ,isExprtngFns     : st
            ,isExprtngProcs   : st
            ,isExprtngSchema  : st
            ,isExprtngTbls    : st
            ,isExprtngTTys    : st
            ,isExprtngVws   : st
            ));

         do { 
         if(tsc.P.IsExprtngData   != st) { msg = "IsExprtngData  "; break;}
         if(tsc.P.IsExprtngDb     != st) { msg = "IsExprtngDb    "; break;}
         if(tsc.P.IsExprtngFKeys  != st) { msg = "IsExprtngFKeys "; break;}
         if(tsc.P.IsExprtngFns    != st) { msg = "IsExprtngFns   "; break;}
         if(tsc.P.IsExprtngProcs  != st) { msg = "IsExprtngProcs "; break;}
         if(tsc.P.IsExprtngSchema != st) { msg = "IsExprtngSchema"; break;}
         if(tsc.P.IsExprtngTbls   != st) { msg = "IsExprtngTbls  "; break;}
         if(tsc.P.IsExprtngTTys   != st) { msg = "IsExprtngTTys  "; break;}
         if(tsc.P.IsExprtngVws    != st) { msg = "IsExprtngViews "; break;}

         ret = true;
         } while(false);

         LogL($"Leaving: ret:{ret}");
         return ret;
      }

      //------------------------------------------ end of tests ------------------------------

      #endregion tests

      #region test support
/*
      protected bool ChkContains(string script, string clause, string filePath, int expCount = 1, int actCount = -1)
      {
         try
         {
            // check existance or non existence of clause in str
            if(expCount>0)
               Assert.IsTrue (script.ContainsIgnoreCase(clause), $"script should contain '{clause}' ");
            else
               Assert.IsFalse(script.ContainsIgnoreCase(clause), $"script should not contain'{clause}' ");

            // check counts
            if(actCount >-1)
               Assert.AreEqual(expCount, actCount, $"expected {expCount} hits for clause:[{clause}], but got {actCount}");

         }
         catch(Exception e)
         { 
            var msgs = e.GetAllMessages();
            Logger.Log(msgs);
            Process.Start("notepad++.exe", filePath);
            throw;
         }

         return true;
      }
* /

      protected bool HandleExportFilePathHlpr( DbScripterTestable sc
                                             , string exportFilePath
                                             , bool addTimestamp
                                             , string exp
                                             , out string exp2
                                             , out string act)
      { 
         exp2 = exp;
         act = sc.HandleExportFilePath(exportFilePath, addTimestamp);
         return exp == act;
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="expColl"></param>
      /// <param name="matches"></param>
      /// <param name="expFile">@"C:\Temp\T007_exp.dat"</param>
      /// <param name="actFile">@"C:\Temp\T007_act.dat"</param>
      private void LogExpAct(ICollection expColl, MatchCollection matches, string expFile, string actFile)
      { 
         // hdr
         int numExp = expColl.Count;
         int numAct = matches.Count;
         Console.WriteLine();
         Console.WriteLine($"(numFnsExp: {numExp} != numFnsAct: {numAct} listing\r\n EXP:");

         // Log the Expected
         using (StreamWriter file =  new System.IO.StreamWriter(expFile))
         { 
            LogExpected( expColl, file);
         }

         // Log the Actual
         using (StreamWriter file =  new System.IO.StreamWriter(actFile))
         { 
            LogActual( matches, file);
         }
      }

      /// <summary>
      /// Log the Expected  scriptor.ExportedProcedures.Values
      /// </summary>
      /// <param name="scriptor"></param>
      /// <param name="file"></param>
      private void LogExpected(ICollection expColl, StreamWriter file)
      { 
         LogDetail("TEST EXP:", file);

         foreach(var exp in expColl)
            LogDetail(exp as string, file);

         Console.WriteLine();
       }

      /// <summary>
      /// Log the Actual
      /// </summary>
      /// <param name="matches"></param>
      /// <param name="file"></param>
      private void LogActual(MatchCollection matches, StreamWriter file)
      { 
         LogDetail("TEST ACT:", file);

         foreach (System.Text.RegularExpressions.Match m in matches)
            LogMatchDetails( m, file);

         Console.WriteLine();
       }

      private string GetMatchDetails(System.Text.RegularExpressions.Match m )
      {
         var v = m.Groups[1].Value;
         var t = v.Split(new [] { '[', ']', '.', '\r'}); //, '.', '\r'});
         StringBuilder sb = new StringBuilder();
         var schema = t[0];
         var rtn =  string.IsNullOrEmpty(t[1]) ? 
                   (string.IsNullOrEmpty(t[2]) ? t[3] : t[2]) : t[1];

         sb.Append($"{schema}.{rtn}");
         return sb.ToString();
      }

      private void LogMatchDetails(System.Text.RegularExpressions.Match m, StreamWriter file)
      {
         var s = GetMatchDetails(m);
         LogDetail(s, file);
      }

      private void LogDetail(string s, StreamWriter file)
      { 
         file.WriteLine(s);
         Console.WriteLine(s);
      }


      // ParseSchemas: <summary>
      // Handles strings like:
      //   "{test, [dbo]", "dbo",  "", null}
      //   "   {   dbo    }   ", "" null
      // 
      // PRECONDITIONS : scriptor is intialised
      // POSTCONDITIONS: 
      //   POST 1: returns null if rs is null, empty
      //   POST 2: returns null if rs contains no schemas
      //   POST 3: returns all schemas in rs in the returned arry
      // Method:
      //   trim
      //   remove surrounding {}
      //   split on ,
      //   for each schema: remove any []and trim
      // </summary>
      // <param name="rs">required_schemas</param>
      // <returns>string array of the unwrapped schemas in rs</returns>
     protected bool HelperParseSchemas(DbScripterTestable scriptor, string inpSchemas, string [] expSchemas, out string msg)
      { 
         // PRECONDITIONS:  P pop
         var actSchemas = scriptor.P.ParseRequiredSchemas(inpSchemas);

         // check exp Null
         if(expSchemas == null)
         { 
            if (actSchemas!= null)
            { 
               msg = $"expected null schema but got [{actSchemas}]";
               return false;
            }

            msg = "";
            return true;
         }

         // ASSERTION expSchemas is not null
         // compare arrays
         if(expSchemas.Length != actSchemas.Count)
         {
            msg = $"mismatch on array length exp:{expSchemas.Length} act: {actSchemas.Count}";
            return false;
         }

         // Compare contents
         foreach( var schema in expSchemas)
         {
            if(!actSchemas.Contains(schema))
            { 
               msg = $"expected shema:[{schema}] not found";
               return false;
            }
         }

        msg = "";
        return true;
      }

      // IEnumerable
      // ICollection has a CopyTo(art, start) - needs ary sized first
      //protected bool HelperChkListCount<Ty>(System.Collections.Generic.IEnumerable<Ty> expColl, int act_count) where Ty : ScriptSchemaObjectBase
      protected bool HelperChkListCount<Ty>( ICollection expColl, string schemaName, int act_count) where Ty: ScriptSchemaObjectBase
      { 
         //var rtnColl = expColl.Where(f=>f.Schema == schemaName);
         var rtnColl = new List<Ty>(expColl.Count);

         foreach(var item in expColl)
         { 
            var schemaObj = item as Ty;

            if(schemaObj.Schema == schemaName)
                rtnColl.Add(schemaObj);
         }

         return rtnColl.Count() == act_count;
     }
*/
      #endregion test support
      #region test setup
      /// <summary>
      /// Use ClassInitialize to run code before running the first test in the class
      /// </summary>
      /// <param name="testContext"></param>
      [ClassInitialize()]
      public new static void ClassSetup(TestContext testContext)
      {
         UnitTestBase.ClassSetup(testContext); // use app config@"D\tmp\DbScriptor.log");
      }
      
      /// <summary>
      /// Use ClassCleanup to run code after all tests in a class have run
      /// </summary>
      [ClassCleanup()]
      public static void ClassCleanup()
      {
         UnitTestBase.ClassCleanup("CbScriptorTests");
      }

      /// <summary>
      /// Use TestInitialize to run code before running each test
      /// </summary>
      [TestInitialize()]
      public override void TestSetup()
      {
         base.TestSetup();
      }
      
      /// <summary>
      /// Use TestCleanup to run code after each test has run
      /// </summary>
      [TestCleanup()]
      public override void TestCleanup()
      {
         base.TestCleanup();
      }

      #endregion test setup
      #region properties

      public Params CovidBaseParams{ get; set;} = new Params
      (
         serverName:        @"DESKTOP-UAULS0U\SQLEXPRESS"
        ,instanceName:      "SQLEXPRESS"
        ,databaseName:      "Covid_T1"
      );

      #endregion properties
   }
}
