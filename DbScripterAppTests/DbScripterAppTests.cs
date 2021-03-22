using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using DbScripterLibNS;
using RSS.Test;
using Moq;
using RSS.Common;
using static RSS.Common.Logger;
using static RSS.Common.Utils;
using System.Diagnostics;

namespace DbScripterAppTestsNS
{
   [TestClass]
   public class DbScripterAppTests : UnitTestBase
   {
     /// <summary>
      /// Issues: 
      ///   1: CREATE SCHEMA [dbo] b4 USE [ut]
      ///   2: script file not timestamped
      /// </summary>
       [TestMethod]
      public void DoWork_Ut_Dbo_crt_use_ts()
      {
         LogS();
         // SETUP:
         var exp_ExprtPth = @"C:\temp\DoWork_Ut_Dbo_crt_use_ts.sql";
         var svr_nm = @"DESKTOP-UAULS0U\SQLEXPRESS";

         string [] args = new string[]
         { 
             "-S", svr_nm
            ,"-i","SQLEXPRESS"
            ,"-d","ut"
            ,"-rt","Schema"
            ,"-rs","dbo"
            ,"-tct","{F,P,T,TTY,V}"
            ,"-E", exp_ExprtPth
            ,"-cm","CREATE"
            ,"-use"
            //,"-ts" // now works
         };

         Params p;
         string msg, script;

         // run test
         Assert.IsTrue(Program.DoWork( args, out p, out script, out msg), msg);

         //   1: CREATE SCHEMA [dbo] b4 USE [ut]
         //   2: script file not timestamped
         LogL();
      }
/*
SET svr=DESKTOP-UAULS0U\SQLEXPRESS
SET inst=SQLEXPRESS
SET EXPORTPATH=E:\Backups\iDrive\Dev\Db\Scripts\utExport.sql
CALL DbScripter.exe -S %svr% -i %inst% -d ut -rt "Schema"-rs [dbo] -E %EXPORTPATH% -tct {F,P,S,T,TTY,V} -cm create -use -ts
 
      Produces: Alters ??
 */
       [TestMethod]
      public void ParseValidArgsTest2()
      {
         LogS();
         // SETUP:
         var exp_ExprtPth = @"E:\Backups\iDrive\Dev\Db\Scripts\utExport.sql";
         var svr_nm = @"DESKTOP-UAULS0U\SQLEXPRESS";

         string [] args = new string[]
         { 
             "-S", svr_nm
            ,"-i","SQLEXPRESS"
            ,"-d","ut"
            ,"-rt","Schema"
            ,"-rs","dbo"
            ,"-tct","{F,P,T,TTY,V}"
            ,"-E", exp_ExprtPth
            ,"-cm","CREATE"
            ,"-use"
            ,"-ts"
         };

         Params p;
         string msg;

         // run test
         Assert.IsTrue(Program.ParseArgs( args, out p, out msg), msg);

         // POSTCONDITIONS
         // ServerName       
         Assert.AreEqual(svr_nm                 , p.ServerName,            "ServerName -S");
         Assert.AreEqual("SQLEXPRESS"           , p.InstanceName,          "InstanceName -i");
         Assert.AreEqual("ut"                   , p.DatabaseName,          "DatabaseName -d");
         Assert.AreEqual(SqlTypeEnum.Schema     , p.RootType,              "RootType -rt");
         Assert.AreEqual(exp_ExprtPth           , p.ExportScriptPath,      "ExportScriptPath -E");
         Assert.AreEqual(1                      , p.RequiredSchemas.Count, "RequiredSchemas -rs");
         Assert.AreEqual("dbo"                  , p.RequiredSchemas[0],    "RequiredSchema[0]");
         Assert.AreEqual(5                      , p.TargetChildTypes.Count,"TargetChildTypes -tct");
         Assert.AreEqual(SqlTypeEnum.Function   , p.TargetChildTypes[0],   "TargetChildTypes[0]");
         Assert.AreEqual(SqlTypeEnum.Procedure  , p.TargetChildTypes[1],   "TargetChildTypes[1]");
         Assert.AreEqual(CreateModeEnum.Create  , p.CreateMode,            "CreateMode -M");
         Assert.AreEqual(true                   , p.ScriptUseDb,           "ScriptUseDb -use");
         Assert.AreEqual(true                   , p.AddTimestamp,          "AddTimestamp -ts");

       LogL();
      }
     
      /// <summary>
      /// Usage: 
      /// E.G.  DbScripter -S DESKTOP-UAULS0U\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
      /// Where:
      ///  -S:     server
      ///  -i:     instance
      ///  -d:     database
      ///  -rt:    root type, optional surrounding [ ]
      ///  -rs:    required schemas like {dbo,test}, optional surrounding { }
      ///  -tct:   target child types, optional surrounding { } comma separated list of 1 or more typecodes: like {F,P}
      ///    valid types: {F,P,S,T,TTY,V}
      ///      F:   user defined function
      ///      P:   stored procedure
      ///      S:   schema
      ///      T:   table
      ///      TTY: user defined table type
      ///      V    view
      /// 
      ///  -E:      export file path (timestamp and mode will be added)
      ///  -cm:     create mode: create|alter|drop
      ///  -use:    scripts the use datbase command at the start of the script
      ///  -ts      adds a timestamp to the specified export file path (default export file paths are timestamped)"
      /// 
      /// PRECONDITIONS:
      ///   none
      ///   
      /// POSTCONDITIONS
      ///  P: valid state for export
      ///  POST 1: all fields of P are specified (mot null)
      ///     ServerName       
      ///     InstanceName     
      ///     DatabaseName     
      ///     ExportScriptPath 
      ///     RequiredSchemas  
      ///     RootType         
      ///     TargetChildTypes 
      ///     CreateMode       
      ///     ScriptUseDb      
      ///     AddTimestamp     
      /// </summary>
      /// <param name="args"></param>
      [TestMethod]
      public void ParseValidArgsTest()
      {
         LogS();
         // SETUP:
         var exp_ExprtPth = @"E:\Backups\iDrive\Dev\Covid-19\Scripts\Covid_Schema_210318-2154.sql";
         var svr_nm = @"DESKTOP-UAULS0U\SQLEXPRESS";

         string [] args = new string[]
         { 
             "-S", svr_nm
            ,"-i","SQLEXPRESS"
            ,"-d","covid"
            ,"-rt","Schema"
            ,"-rs","{dbo, test}"
            ,"-tct","{F,P,S,T,TTY,V}"
            ,"-E", exp_ExprtPth
            ,"-cm","aLter"
            ,"-use"
            ,"-ts"
         };

         Params p;
         string msg;

         // run test
         Assert.IsTrue(Program.ParseArgs( args, out p, out msg), msg);

         // POSTCONDITIONS
         // ServerName       
         Assert.AreEqual(svr_nm                 , p.ServerName,            "ServerName -S");
         Assert.AreEqual("SQLEXPRESS"           , p.InstanceName,          "InstanceName -i");
         Assert.AreEqual("covid"                , p.DatabaseName,          "DatabaseName -d");
         Assert.AreEqual(SqlTypeEnum.Schema     , p.RootType,              "RootType -rt");
         Assert.AreEqual(exp_ExprtPth           , p.ExportScriptPath,      "ExportScriptPath -E");
         Assert.AreEqual(2                      , p.RequiredSchemas.Count, "RequiredSchemas -rs");
         Assert.AreEqual("dbo"                  , p.RequiredSchemas[0],    "RequiredSchema[0]");
         Assert.AreEqual("test"                 , p.RequiredSchemas[1],    "RequiredSchema[1]");
         Assert.AreEqual(6                      , p.TargetChildTypes.Count,"TargetChildTypes -tct");
         Assert.AreEqual(SqlTypeEnum.Function   , p.TargetChildTypes[0],   "TargetChildTypes[0]");
         Assert.AreEqual(SqlTypeEnum.Procedure  , p.TargetChildTypes[1],   "TargetChildTypes[1]");
         Assert.AreEqual(CreateModeEnum.Alter   , p.CreateMode,            "CreateMode -M");
         Assert.AreEqual(true                   , p.ScriptUseDb,           "ScriptUseDb -use");
         Assert.AreEqual(true                   , p.AddTimestamp,          "AddTimestamp -ts");

       LogL();
      }

      ///  -S:     server                                                        default: "."
      ///  -i:     instance                                                      default: DESKTOP-UAULS0U\\SQLEXPRESS
      ///  -d:     database                                                      default: none
      ///  -rt:    root type, optional surrounding [ ]                           default: schema
      ///  -rs:    required schemas like {dbo,test}, optional surrounding { }    default: dbo
      ///
      ///  -tct:   target child types, optional surrounding { }                  default: "P,F"
      ///      comma separated list of 1 or more typecodes: like {F,P}
      ///    valid types: {F,P,S,T,TTY,V}
      ///      F:   user defined function
      ///      P:   stored procedure
      ///      S:   schema
      ///      T:   table
      ///      TTY: user defined table type
      ///      V    view
      /// 
      ///  -E:      export file path (timestamp and mode will be added)          default: %TempPath%\DbName_schemas_tcts_tmstmp_export.sql
      ///  -cm:     create mode: create|alter|drop                               default: ALTER
      ///  -use:    scripts the use datbase command at the start of the script   default: FALSE
      ///  -ts      adds a timestamp to the specified export file path           default: FALSE
      [TestMethod]
      public void ParseArgDefaultsTest()
      {
         LogS();
         // SETUP:
         var svr_nm        = @"DESKTOP-UAULS0U\SQLEXPRESS";
         var exp_script_dir= @"E:\Backups\iDrive\Dev\Db\Scripts";
         var exp_ExprtPth  = $@"{exp_script_dir}\TPC_dbo_{Utils.GetTimeStamp()}_export.sql";
         var exp_log       = @"D:\Logs\UnitTests\Dbscripter.log";

         string [] args = new string[]
         {
            "-d","TPC"
         };

         // run test
         Assert.IsTrue(Program.ParseArgs(args, out Params p, out string msg), msg);

         // POSTCONDITIONS
         Assert.AreEqual(svr_nm                 , p.ServerName,            "ServerName       -S");
         Assert.AreEqual("SQLEXPRESS"           , p.InstanceName,          "InstanceName     -i");
         Assert.AreEqual("TPC"                  , p.DatabaseName,          "DatabaseName     -d");
         Assert.AreEqual(SqlTypeEnum.Schema     , p.RootType,              "RootType         -rt");
         Assert.AreEqual(exp_ExprtPth           , p.ExportScriptPath,      "ExportScriptPath -E");
         Assert.AreEqual(1                      , p.RequiredSchemas.Count, "RequiredSchemas  -rs");
         Assert.AreEqual("dbo"                  , p.RequiredSchemas[0],    "RequiredSchema[0]");
         Assert.AreEqual(2                      , p.TargetChildTypes.Count,"TargetChildTypes -tct");
         Assert.AreEqual(SqlTypeEnum.Procedure  , p.TargetChildTypes[0],   "TargetChildTypes[1]");
         Assert.AreEqual(SqlTypeEnum.Function   , p.TargetChildTypes[1],   "TargetChildTypes[0]");
         Assert.AreEqual(CreateModeEnum.Alter   , p.CreateMode,            "CreateMode       -cm");
         Assert.AreEqual(false                  , p.ScriptUseDb,           "ScriptUseDb      -use");
         Assert.AreEqual(false                  , p.AddTimestamp,          "AddTimestamp     -ts");
         Assert.AreEqual(exp_log                , p.LogFile,               "AddTimestamp     -ts");

       LogL();
   }

      #region abstract UnitTestBase impl
      [AssemblyInitialize]
      public static void AssemblySetup_( TestContext ctx)
      {
         Logger.LogS();
         AssemblySetup(ctx);
         //Program.Init();
         LogL();
      }

      [AssemblyCleanup]
      public static void AssemblyCleanup_( )
      {
         Logger.LogS();
         AssemblyCleanup( );
         LogL();
      }

      [ClassInitialize]
      public static void ClassSetup_( TestContext ctx )
      {
         LogS();
         ClassSetup( ctx );
         LogL();
      }

      [ClassCleanup]
      public static void ClassCleanup_( )
      { 
         LogS();
         ClassCleanup();
         LogL();
      }

      #endregion abstract UnitTestBase impl
   }
}
