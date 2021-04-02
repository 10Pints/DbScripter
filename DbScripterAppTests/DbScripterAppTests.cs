using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using DbScripterLibNS;
using RSS.Test;
using Moq;
using RSS.Common;
using static RSS.Common.Logger;
using static RSS.Common.Utils;
using System.Diagnostics;
using TestHelpers;

namespace DbScripterAppTestsNS
{
   [TestClass]
   public class DbScripterAppTests : ScriptableUnitTestBase
   {
      [TestMethod]
      public void ParseNullArgsTest()
      {
         LogS();
         Assert.IsFalse(Program.Init(null, out var p, out var msg), msg);
         Assert.IsTrue(msg.Equals("error parsing args: arguments must be supplied"));
         LogL();
      }

      /// <summary>
      /// Issues: 
      ///   1: CREATE SCHEMA [dbo] b4 USE [ut]
      ///   2: script file not timestamped
      /// </summary>
      [TestMethod]
      public void MainHndlBadDbNm()
      {
         LogS();
         // SETUP:
         var svr_nm = @"DESKTOP-UAULS0U\SQLEXPRESS";

         string [] args = new string[]
         { 
             "-S", svr_nm
            ,"-i","SQLEXPRESS"
            ,"-d","covis"
            ,"-rt","Schema"
            ,"-rs","{dbo}"
            ,"-tct","{F,P,T,TTY,V}"
            ,"-E", ScriptFile
            ,"-cm","CREATE"
            ,"-use", "true"
            ,"-disp_script", "false"
         };

         // run test
         Assert.IsTrue(Program.Main(args)==1);
         //   1: CREATE SCHEMA [dbo] b4 USE [ut]
         //   2: script file not timestamped
         LogL();
      }
      [TestMethod]
      public void MainHndl1SchemaDboInCurlies()
      {
         LogS();
         // SETUP:
         var svr_nm = @"DESKTOP-UAULS0U\SQLEXPRESS";

         string [] args = new string[]
         { 
             "-S", svr_nm
            ,"-i","SQLEXPRESS"
            ,"-d","ut"
            ,"-rs","{dbo}"
            ,"-tct","{F,P,T,TTY,V}"
            ,"-E", ScriptFile
            ,"-cm","CREATE"
            ,"-use", "true"
            ,"-disp_script", "false"
         };

         // run test
         Assert.IsTrue(Program.Main(args)==0);
         //   1: CREATE SCHEMA [dbo] b4 USE [ut]
         //   2: script file not timestamped
         LogL();
      }

      /// <summary>
      /// Issues: 
      ///   1: CREATE SCHEMA [dbo] b4 USE [ut]
      ///   2: script file not timestamped
      /// </summary>
      [TestMethod]
      public void MainHndl1SchemaTestInCurlies()
      {
         LogS();
         // SETUP:
         var svr_nm = @"DESKTOP-UAULS0U\SQLEXPRESS";

         string [] args = new string[]
         { 
             "-S", svr_nm
            ,"-i","SQLEXPRESS"
            ,"-d","ut"
            ,"-rs","{test}"
            ,"-tct","{F,P,T,TTY,V}"
            ,"-E", ScriptFile
            ,"-cm","CREATE"
            ,"-use", "true"
            ,"-disp_script", "false"
            ,"-ts", "false"
         };

         // run test
         Assert.IsTrue(Program.Main(args)==0);
         //   1: CREATE SCHEMA [dbo] b4 USE [ut]
         //   2: script file not timestamped
         LogL();
      }

      /// <summary>
      /// Issues: 
      ///   1: CREATE SCHEMA [dbo] b4 USE [ut]
      ///   2: script file not timestamped
      /// </summary>
      [TestMethod]
      public void MainHndl2SchemaInCurlies()
      {
         LogS();
         // SETUP:
         var svr_nm = @"DESKTOP-UAULS0U\SQLEXPRESS";

         string [] args = new string[]
         { 
             "-S", svr_nm
            ,"-i","SQLEXPRESS"
            ,"-d","ut"
            ,"-rs","{dbo, test}"
            ,"-tct","{F,P,T,TTY,V}"
            ,"-E", ScriptFile
            ,"-cm","CREATE"
            ,"-use", "true"
            ,"-disp_script", "false"
         };

         // run test
         Assert.IsTrue(Program.Main(args)==0);
         //   1: CREATE SCHEMA [dbo] b4 USE [ut]
         //   2: script file not timestamped
         LogL();
      }

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
         var svr_nm = @"DESKTOP-UAULS0U\SQLEXPRESS";

         string [] args = new string[]
         { 
             "-S"  , svr_nm
            ,"-i"  ,"SQLEXPRESS"
            ,"-d"  ,"ut"
            ,"-rs" ,"dbo"
            ,"-tct","{F,P,T,TTY,V}"
            ,"-E"  , ScriptFile
            ,"-cm" ,"CREATE"
            ,"-use", "true"
            ,"-ts" , "false"
            ,"-disp_script", "false"
       };

         Params p;
         string msg;

         // run test
         Assert.IsTrue(Program.Init(args, out p, out msg), msg);
         Assert.IsTrue(Program.DoWork( p, out _, out msg), msg);

         //   1: CREATE SCHEMA [dbo] b4 USE [ut]
         //   2: script file not timestamped
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
      ///     ExportScriptPat
      ///     RequiredSchemas
      ///     RootType
      ///     TargetChildTypes
      ///     CreateMode
      ///     ScriptUseDb
      ///     AddTimestamp
      /// </summary>
      /// <param name="args"></param>
      [TestMethod]
      public void ParseValidArgsTestPositive()
      {
         LogS();
         // SETUP:
         var svr_nm = @"DESKTOP-UAULS0U\SQLEXPRESS";

         string [] args = new string[]
         { 
             "-S", svr_nm
            ,"-i","SQLEXPRESS"
            ,"-d","covid"
            ,"-rt","Schema"
            ,"-rs","{dbo, test}"
            ,"-tct","{F,P,S,T,TTY,V}"
            ,"-E", ScriptFile
            ,"-cm","aLter"
            ,"-use", "true"
            ,"-ts", "true"
            ,"-disp_script", "true"
         };

         Params p;
         string msg;

         // run test
         Assert.IsTrue(Program.ParseArgs( args, out p, out msg), msg);

         // POSTCONDITIONS
         // ServerName       
         Assert.AreEqual(svr_nm                 , p.Server,                "Server -S");
         Assert.AreEqual("SQLEXPRESS"           , p.Instance,              "Instance -i");
         Assert.AreEqual("covid"                , p.Database,              "Database -d");
  //       Assert.AreEqual(SqlTypeEnum.Schema     , p.RootType,              "RootType -rt");
         Assert.AreEqual(ScriptFile             , p.ScriptPath,            "ScriptPath -E");
         Assert.AreEqual(2                      , p.RequiredSchemas.Count, "RequiredSchemas -rs");
         Assert.AreEqual("dbo"                  , p.RequiredSchemas[0],    "RequiredSchema[0]");
         Assert.AreEqual("test"                 , p.RequiredSchemas[1],    "RequiredSchema[1]");
         Assert.AreEqual(6                      , p.TargetChildTypes.Count,"TargetChildTypes -tct");
         Assert.AreEqual(SqlTypeEnum.Function   , p.TargetChildTypes[0],   "TargetChildTypes[0]");
         Assert.AreEqual(SqlTypeEnum.Procedure  , p.TargetChildTypes[1],   "TargetChildTypes[1]");
         Assert.AreEqual(CreateModeEnum.Alter   , p.CreateMode,            "CreateMode -M");
         Assert.AreEqual(true                   , p.ScriptUseDb,           "ScriptUseDb -use");
         Assert.AreEqual(true                   , p.AddTimestamp,          "AddTimestamp -ts");
         Assert.AreEqual(true                   , p.DisplayScript,         "DisplayScript -disp_script");

       LogL();
      }

       [TestMethod]
      public void ParseValidArgsTestNegative()
      {
         LogS();
         // SETUP:
         var svr_nm = @"DESKTOP-UAULS0U\SQLEXPRESS";

         string [] args = new string[]
         { 
            "-i","SQLEXPRESS"
            ,"-cm","CREATE"
            ,"-d","ut"
            ,"-disp_script", "false"
            ,"-E", ScriptFile
            ,"-rs","dbo"
            ,"-rt","Schema"
            ,"-S", svr_nm
            ,"-tct","{F,P,T,TTY,V}"
            ,"-use", "false"
            ,"-ts", "false"
            ,"-disp_script", "false"
         };

         Params p;
         string msg;

         // run test
         Assert.IsTrue(Program.ParseArgs( args, out p, out msg), msg);

         // POSTCONDITIONS
         // ServerName       
         Assert.AreEqual(svr_nm                 , p.Server,                "Server -S");
         Assert.AreEqual("SQLEXPRESS"           , p.Instance,              "Instance -i");
         Assert.AreEqual("ut"                   , p.Database,              "Database -d");
   //      Assert.AreEqual(SqlTypeEnum.Schema     , p.RootType,              "RootType -rt");
         Assert.AreEqual(ScriptFile             , p.ScriptPath,            "ScriptPath -E");
         Assert.AreEqual(1                      , p.RequiredSchemas.Count, "RequiredSchemas -rs");
         Assert.AreEqual("dbo"                  , p.RequiredSchemas[0],    "RequiredSchema[0]");
         Assert.AreEqual(5                      , p.TargetChildTypes.Count,"TargetChildTypes -tct");
         Assert.AreEqual(SqlTypeEnum.Function   , p.TargetChildTypes[0],   "TargetChildTypes[0]");
         Assert.AreEqual(SqlTypeEnum.Procedure  , p.TargetChildTypes[1],   "TargetChildTypes[1]");
         Assert.AreEqual(CreateModeEnum.Create  , p.CreateMode,            "CreateMode -M");
         Assert.AreEqual(false                  , p.ScriptUseDb,           "ScriptUseDb -use");
         Assert.AreEqual(false                  , p.AddTimestamp,          "AddTimestamp -ts");
         Assert.AreEqual(false                  , p.DisplayScript,         "DisplayScript -disp_script true/false");

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
         ScriptFile        = $@"{exp_script_dir}\TPC_dbo_{Utils.GetTimestamp()}.sql";
         // specified in app config and ts added
         var exp_log       = $@"D:\Logs\TPC_dbo_{Utils.GetTimestamp()}.log";

         string [] args = new string[]
         {
            "-d","TPC"
         };

         // run test
         Assert.IsTrue(Program.ParseArgs(args, out Params p, out string msg), msg);

         // POSTCONDITIONS
         Assert.AreEqual(svr_nm                , p.Server,                 "ServerName       -S"   );
         Assert.AreEqual("SQLEXPRESS"          , p.Instance,               "InstanceName     -i"   );
         Assert.AreEqual("TPC"                 , p.Database,               "DatabaseName     -d"   );
//         Assert.AreEqual(SqlTypeEnum.Schema    , p.RootType,               "RootType         -rt"  );
         Assert.AreEqual(ScriptFile            , p.ScriptPath,             "ExportScriptPath -E"   );
         Assert.AreEqual(1                     , p.RequiredSchemas.Count,  "RequiredSchemas  -rs"  );
         Assert.AreEqual("dbo"                 , p.RequiredSchemas[0],     "RequiredSchema[0]"     );
         Assert.AreEqual(2                     , p.TargetChildTypes.Count, "TargetChildTypes -tct" );
         Assert.AreEqual(SqlTypeEnum.Function , p.TargetChildTypes[0],     "TargetChildTypes[1]"   );
         Assert.AreEqual(SqlTypeEnum.Procedure, p.TargetChildTypes[1],     "TargetChildTypes[0]"   );
         Assert.AreEqual(CreateModeEnum.Alter  , p.CreateMode,             "CreateMode       -cm"  );
         Assert.AreEqual(false                 , p.ScriptUseDb,            "ScriptUseDb      -use" );
         Assert.AreEqual(false                 , p.AddTimestamp,           "AddTimestamp     -ts"  );
         Assert.AreEqual(exp_log               , p.LogFile,                "AddTimestamp     -ts"  );
         Assert.AreEqual(false                 , p.DisplayScript,          "DisplayScript    -disp_script true");
                                                                           
       LogL();
   }

      #region abstract UnitTestBase impl
      [AssemblyInitialize]
      public static void AssemblySetup_( TestContext ctx)
      {
         Logger.LogS();
         AssemblySetup(ctx);
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
