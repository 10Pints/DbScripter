#pragma warning disable CS8602 // Dereference of a possibly null reference.

#nullable enable 

using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using DbScripterLibNS;
using System.Collections.Generic;

using Common;
using static CommonLib.Logger;
using static CommonLib.Utils;
using CommonLib;

namespace RSS.Test
{
   [TestClass]
   public class ParamsTests : ScriptableUnitTestBase
   {
            /// <summary>
      /// Bugs:
      /// 1: ALTER FUNCTION [dbo].[fnALTERTrendSql]
      /// 1: ALTER FUNCTION [dbo].[fnCreateTrendSql]
      /// should only convert the  first instance of ^[ \t]*Create
      /// </summary>
      [TestMethod]
      public void DisplayLog_Test()
      {
         LogS();
         DisplayLog_Test_hlpr(true , true);
         DisplayLog_Test_hlpr(false, false);
         DisplayLog_Test_hlpr(false, true);
         DisplayLog_Test_hlpr(true , false);

         DisplayLog_Test_hlpr(null, null);
         DisplayLog_Test_hlpr(null, false);
         DisplayLog_Test_hlpr(null, true);

         DisplayLog_Test_hlpr(null , null);
         DisplayLog_Test_hlpr(false, null);
         DisplayLog_Test_hlpr(true , null);

         LogL();
      }

      protected void DisplayLog_Test_hlpr(bool ? displayScript, bool ? displayLog)
      { 
         /*
         Params p = Params.PopParams
         (
             prms          : null
            ,name            : "ExportDatabase Params"
            ,databaseName          : "Covid"
            ,scriptFile     : null
            ,createMode            : CreateModeEnum.Alter
            ,requiredSchemas           : "{dbo}"
            ,addTimestamp : true
            ,logFile           : @"D:\Logs\DbScripter.log"
            ,useDb         : true
            ,displayScript : displayScript
            ,displayLog    : displayLog
         );

         Assert.AreEqual(displayScript, p.DisplayScript);
         Assert.AreEqual(displayLog,    p.DisplayLog);
         Assert.AreEqual(displayScript ?? false, p.ShoulDisplayScript());
         Assert.AreEqual(displayLog    ?? false, p.ShoulDisplayLog());
         */
      }

      /*
      /// <summary>
      /// Test Desc: this test checks that when all args are supplied they are populated correctly
      /// 
      /// Usage: E.G.  DbScripter -S DevI9\SQLEXPRESS -i SQLEXPRESS -d ut -rt [dbo] -E D:\tmp\utExport.sql -T F,P -M create|alter|drop
      /// Where:
      /// -S:        server
      /// -i:        instance
      /// -d:        database
      /// -rs:       required schemas like {dbo,test}, optional surrounding { }
      /// -tct:      target child types, optional surrounding { } comma separated list of 1 or more typecodes: like {F,P}
      ///   valid    types: {F,P,S,T,TTY,V}
      ///     F:     user defined function
      ///     P:     stored procedure
      ///     S:     schema
      ///     T:     table
      ///     TTY:   user defined table type
      ///     V      view
      ///
      /// -E:        export file path (timestamp and mode will be added)
      /// -createMode:       create mode: create|alter|drop
      /// -use:      scripts the use datbase command at the start of the script
      /// -ts        adds a timestamp to the specified export file path (default export file paths are timestamped)"
      /// -log_file  sets the log file path                                          default: not set - use default path
      /// -log_level set the logging granularity                                     default: Info
      /// -disp_log  control whether or not to display the log file after            default: FALSE: don't display";
      /// 
      ///  PRE 1: timestamp is set (by cstr)
      ///
      /// RESPONSIBILITIES and POSTCONDITIONS
      ///   POST 1: valid state for export (no invalid args)
      ///   POST 2: all fields of P are specified correctly
      ///      ServerName
      ///      InstanceName
      ///      DatabaseName
      ///      ExportScriptPath
      ///      RequiredSchemas
      ///      RequiredTypes
      ///      Export path
      ///      CreateMode
      ///      ScriptUseDb
      ///      AddTimestamp
      ///
      ///  POST 3: if timestamp is specified the logfile and script file contain the timestamp
      /// </summary>
      /// param name="args"
      [TestMethod]
      public void ParseArgsWhenAllArgsSupplieThenPopCorrectlyGreenTest()
      {
         LogS();

         //-----------------------------------------------------------------------
         // SETUP:
         //-----------------------------------------------------------------------
         var svr_nm = @"DevI9\SQLEXPRESS";

         string [] args = new string[]
         { 
             "-S",            svr_nm
            ,"-i",            "SQLEXPRESS"
            ,"-d",            "covid"
            ,"-rs",           "{dbo, test}"
            ,"-tct",          "{F,P,S,T,TTY,V}"
            ,"-E",            @"D:\Scripts\covid.sql" // Script Path
            ,"-cm",           "alter"
            ,"-use",          "true"
            ,"-ts",           "true"
            ,"-log_file",     @"D:\Logs\Export.Log"
            ,"-log_level",    "Trace"
            ,"-disp_script",  "false"
            ,"-disp_log",     "true"
         };


         //-----------------------------------------------------------------------
         // Call the tested fn
         //-----------------------------------------------------------------------
         Params p = new();
         Assert.IsTrue(Params.ParseArgs( args, ref p, out string msg), msg);

         //-----------------------------------------------------------------------
         // Test the results
         //-----------------------------------------------------------------------

         // POSTCONDITIONS
         // POST 1: valid state for export, no invalid args
         Assert.IsTrue(p.IsValid(out msg));
         Assert.IsTrue(string.IsNullOrEmpty(msg));

         Assert.IsNotNull(p.AddTimestamp);
         Assert.IsNotNull(p.CreateMode);
         Assert.IsNotNull(p.CreateMode);
         Assert.IsNotNull(p.Database);
         Assert.IsNotNull(p.DisplayLog);
         Assert.IsNotNull(p.DisplayScript);
         Assert.IsNotNull(p.Instance);
         Assert.IsNotNull(p.IsExportingData);
         Assert.IsNotNull(p.IsExportingDb);
         Assert.IsNotNull(p.IsExportingFns);
         Assert.IsNotNull(p.IsExportingProcs);
         Assert.IsNotNull(p.IsExportingSchema);
         Assert.IsNotNull(p.IsExportingTbls);
         Assert.IsNotNull(p.IsExportingTTys);
         Assert.IsNotNull(p.IsExportingVws);
         Assert.IsNotNull(p.LogFile);
         Assert.IsNotNull(p.LogLevel);
         Assert.IsNotNull(p.FilePath);
         Assert.IsNotNull(p.RequiredSchemas);
         Assert.IsNotNull(p.ScriptFile);
         Assert.IsNotNull(p.ScriptDir); // ScriptPath
         Assert.IsNotNull(p.ScriptUseDb);
         Assert.IsNotNull(p.Server);
         Assert.IsNotNull(p.RequiredTypes);
         Assert.IsNotNull(p.Timestamp);


         // POST 2: all fields of P are specified correctly
         Assert.AreEqual(svr_nm                 , p.Server,                "Server -S");              // ServerName
         Assert.AreEqual("SQLEXPRESS"           , p.Instance,              "Instance -i");
         Assert.AreEqual("covid"                , p.Database,              "Database -d");
         Assert.IsTrue  (p.ScriptFile.IndexOf(p.Timestamp) > -1,           "ScriptFile should contain the timestamp");
         Assert.IsTrue  (p.ScriptFile.IndexOf(@"D:\Scripts\covid") > -1,   "ScriptFile should contain the original path and db name");
         Assert.IsTrue  (p.ScriptFile.IndexOf(@".sql") > -1,               "ScriptFile should contain the original extension");
         Assert.IsTrue  (p.LogFile   .IndexOf(p.Timestamp) > -1,           "LogFile should contain the timestamp");
         Assert.AreEqual(2                      , p.RequiredSchemas.Count, "RequiredSchemas -rs");
         Assert.AreEqual("dbo"                  , p.RequiredSchemas[0],    "RequiredSchema[0]");
         Assert.AreEqual("test"                 , p.RequiredSchemas[1],    "RequiredSchema[1]");
         Assert.AreEqual(6                      , p.RequiredTypes.Count,"RequiredTypes -tct");
         Assert.AreEqual(SqlTypeEnum.Function   , p.RequiredTypes[0],   "RequiredTypes[0]");
         Assert.AreEqual(SqlTypeEnum.Procedure  , p.RequiredTypes[1],   "RequiredTypes[1]");
         Assert.AreEqual(CreateModeEnum.Alter   , p.CreateMode,            "CreateMode -M");
         Assert.AreEqual(true                   , p.ScriptUseDb,           "ScriptUseDb -use");
         Assert.AreEqual(true                   , p.AddTimestamp,          "AddTimestamp -ts");

         if(p.AddTimestamp?? false)
         {
            Assert.IsTrue(p.LogFile.StartsWith(@"D:\Logs\Export_"), @"Log file should start with the specified log file 'D:\Logs\Export.Log'");
            Assert.IsTrue(p.LogFile.Contains(p.Timestamp), $"Log file should contain the timestamp: {p.Timestamp}");
         }
         else
         {
            Assert.IsTrue(p.LogFile.Equals(@"D:\Logs\Export.Log"), @"Log file should be 'D:\Logs\Export.Log'");
         }

         Assert.AreEqual(CommonLib.LogLevel.Trace  , p.LogLevel);                                        //"-log_level",    "Trace"
         Assert.AreEqual(false                  , p.DisplayScript, "DisplayScript -disp_script");     //"-disp_script",  "false"
         Assert.AreEqual(true                   , p.DisplayLog);                                      //"-disp_log",     "true"

         // POST 3: if timestamp is specified the logfile and script file contain the timestamp

         LogL();
      }

      [TestMethod]
      public void ParseValidArgsTestNegative()
      {
         LogS();
         // SETUP:
         var svr_nm = @"DevI9\SQLEXPRESS";

         string [] args = new string[]
         { 
            "-i","SQLEXPRESS"
            ,"-cm","CREATE"
            ,"-d","ut"
            ,"-disp_script", "false"
            ,"-E", "ScriptFile"
            ,"-rs","dbo"
            ,"-S", svr_nm
            ,"-tct","{F,P,T,TTY,V}"
            ,"-use", "false"
            ,"-ts", "false"
            ,"-disp_script", "false"
         };

         Params p = new();
         string msg;

         // run test
         Assert.IsTrue(Params.ParseArgs( args, ref p, out msg), msg);

         // POSTCONDITIONS
         // ServerName       
         Assert.AreEqual(svr_nm                 , p.Server,                "Server -S");
         Assert.AreEqual("SQLEXPRESS"           , p.Instance,              "Instance -i");
         Assert.AreEqual("ut"                   , p.Database,              "Database -d");
         Assert.AreEqual("ScriptFile"           , p.ScriptFile,            "ScriptFile -E");
         Assert.AreEqual(1                      , p.RequiredSchemas.Count, "RequiredSchemas -rs");
         Assert.AreEqual("dbo"                  , p.RequiredSchemas[0],    "RequiredSchema[0]");
         Assert.AreEqual(5                      , p.RequiredTypes.Count,"RequiredTypes -tct");
         Assert.AreEqual(SqlTypeEnum.Function   , p.RequiredTypes[0],   "RequiredTypes[0]");
         Assert.AreEqual(SqlTypeEnum.Procedure  , p.RequiredTypes[1],   "RequiredTypes[1]");
         Assert.AreEqual(CreateModeEnum.Create  , p.CreateMode,            "CreateMode -M");
         Assert.AreEqual(false                  , p.ScriptUseDb,           "ScriptUseDb -use");
         Assert.AreEqual(false                  , p.AddTimestamp,          "AddTimestamp -ts");
         Assert.AreEqual(false                  , p.DisplayScript,         "DisplayScript -disp_script true/false");

          LogL();
      }

      ///  -S:     server                                                        default: "."
      ///  -i:     instance                                                      default: DevI9\\SQLEXPRESS
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


         //-----------------------------------------------------------------------
         // SETUP:
         //-----------------------------------------------------------------------
         var svr_nm        = @"DevI9";
         var exp_script_dir= @"E:\Backups\iDrive\Dev\Db\Scripts";
         string [] args = new string[0];

         //-----------------------------------------------------------------------
         // Call the tested routine
         //-----------------------------------------------------------------------
         var p = new Params();
         Assert.IsTrue(Params.ParseArgs(args, ref p, out string msg), msg);


         //-----------------------------------------------------------------------
         // Test the results
         //-----------------------------------------------------------------------
         var ScriptFile = $@"{exp_script_dir}\Talisman_dbo_{p.Timestamp}.sql";
         // specified in app config and ts added
         var exp_log = Logger.LogFile;

         // POSTCONDITIONS
         Assert.AreEqual(svr_nm                , p.Server,                 "ServerName       -S"   );
         Assert.AreEqual("SQLExpress"          , p.Instance,               "InstanceName     -i"   );
         Assert.AreEqual("Talisman"            , p.Database,               "DatabaseName     -d"   );
         Assert.AreEqual(ScriptFile            , p.ScriptFile,             "ExportScriptPath -E"   );
         Assert.AreEqual(1                     , p.RequiredSchemas.Count,  "RequiredSchemas  -rs"  );
         Assert.AreEqual("dbo"                 , p.RequiredSchemas[0],     "RequiredSchema[0]"     );
         Assert.AreEqual(2                     , p.RequiredTypes.Count, "RequiredTypes -tct" );
         Assert.AreEqual(SqlTypeEnum.Function  , p.RequiredTypes[0],    "RequiredTypes[1]"   );
         Assert.AreEqual(SqlTypeEnum.Procedure , p.RequiredTypes[1],    "RequiredTypes[0]"   );
         Assert.AreEqual(CreateModeEnum.Create , p.CreateMode,             "CreateMode       -cm"  );
         Assert.AreEqual(false                 , p.ScriptUseDb,            "ScriptUseDb      -use" );
         Assert.AreEqual(false                 , p.AddTimestamp,           "AddTimestamp     -ts"  );
         Assert.AreEqual(exp_log               , p.LogFile,                "AddTimestamp     -ts"  );
         Assert.AreEqual(false                 , p.DisplayScript,          "DisplayScript    -disp_script true");
                                                                           
         LogL();
      }

      // -S DevI9\SQLEXPRESS -i SQLEXPRESS -d tg -ts true -rs {dbo, test} -E D:\Scripts\tg.sql 
      [TestMethod]
      public void ParseArgs_S_i_d_tg_ts_tru_rs_dbo_test_in_curlies_E_Test()
      {
         LogS();
         var ScriptFile = @"D:\Scripts\tg.sql";

         string [] args = new string[]
         { 
             "-S"  , @"DevI9\SQLEXPRESS"
            ,"-i"  ,"SQLEXPRESS"
            ,"-d"  ,"tg"
            ,"-rs" ,"{dbo, test}"
            ,"-ts" ,"true"
            ,"-tct","{F,P,T,TTY,V}"
            ,"-E"  ,ScriptFile
            ,"-cm" ,"CREATE"
            ,"-use","true"
            ,"-disp_script", "true"
         };

         // Run the ParseArgs() rtn
         var p = new Params();
         Assert.IsTrue(Params.ParseArgs( args, ref p, out string msg), msg);

         // Test the ParseArgs outputs
         Assert.AreEqual(2, p.RequiredSchemas?.Count           , "Expected 2 schemas");
         Assert.IsTrue  ( p.RequiredSchemas[0].Equals("dbo")   , "dbo schema missing");
         Assert.IsTrue  ( p.RequiredSchemas[1].Equals("test")  , "test schema missing");
         Assert.AreEqual( 5, p.RequiredTypes.Count          , "Expected 5 types");
         Assert.IsTrue  ( p.AddTimestamp                       , "add ts should be set");
         var ts_short = GetTimestamp().Substring(0,6);
         Assert.IsTrue( p.LogFile.IndexOf(ts_short) > -1       , "LogFile should contain timestamp");
         Assert.IsTrue( p.ScriptFile.IndexOf(ts_short) > -1    , "ScriptFile name should contain timestamp");

         LogL();
      }

      /// <summary>
      /// Check a bad argument is handled correctly
      /// in this case ts ?
      /// </summary>
      [TestMethod]
      public void ParseArgs_HandleArgError_Test()
      {
         LogS();
         var ScriptFile = @"D:\Scripts\tg.sql";

         string [] args = new string[]
         { 
             "-S"  , @"DevI9\SQLEXPRESS"
            ,"-i"  ,"SQLEXPRESS"
            ,"-d"  ,"UT"
            ,"-rs" ,"{dbo}"
            ,"-E"  ,ScriptFile
            ,"-cm" ,"CREATE"
            ,"-ts" ,"1"
            ,"-use","true"
            ,"-disp_script", "true"
         };

         // Run the Init() rtn
         var p = new Params();
         Assert.IsFalse(Params.ParseArgs( args, ref p, out string msg), msg);
         // Checkout the msg
         // chk mn err msg
         Assert.IsTrue(msg.IndexOf("Error parsing args:") > -1, "error parsing args: not found");
         // chk got type right
         Assert.IsTrue(msg.IndexOf("was not recognized as a valid Boolean") > -1, "was not recognized as a valid Boolean not found");
         // chk detailed error msg
         Assert.IsTrue(msg.IndexOf("arg: [-TS] val:[1]") > -1, "arg: [-TS] val:[1] not found");
         LogL();
      }


      [TestMethod]
      public void ArgsToString_Test()
      {
         LogS();
         var ScriptFile = @"D:\Scripts\tg.sql";

         string [] args = new string[]
         { 
             "-S"  , @"DevI9\SQLEXPRESS"
            ,"-i"  ,"SQLEXPRESS"
            ,"-d"  ,"UT"
            ,"-rs" ,"{dbo}"
            ,"-E"  ,ScriptFile
            ,"-cm" ,"CREATE"
            ,"-ts" ,"1"
            ,"-use","true"
            ,"-disp_script", "true"
         };

         var exp =@"-S           : [DevI9\SQLEXPRESS]
-i           : [SQLEXPRESS]
-d           : [UT]
-rs          : [{dbo}]
-E           : [D:\Scripts\tg.sql]
-cm          : [CREATE]
-ts          : [1]
-use         : [true]
-disp_script : [true]
";

         // Run the Init() rtn
         var act = ParamsTestable.ArgsToString( args);

         // Checkout the display string
         Assert.IsFalse(string.IsNullOrWhiteSpace(act), "display string not populated");
         ChkEquals( exp, act, TestContext?.TestName ?? "???", "display string not populated correctly");
         LogL();
      }

      /// <summary>
      /// Check a bad argument is handled correctly
      /// in this case ts ?
      /// </summary>
      [TestMethod]
      public void ParseArgs_HandleBadArg_Test()
      {
         LogS();
         var ScriptFile = @"D:\Scripts\tg.sql";

         string [] args = new string[]
         { 
             "-S"  , @"DevI9\SQLEXPRESS"
            ,"-i"  ,"SQLEXPRESS"
            ,"-d"  ,"UT"
            ,"-rs" ,"{dbo}"
            ,"-Ex" ,ScriptFile // bad arg
            ,"-cm" ,"CREATE"
            ,"-ts" ,"1"
            ,"-use","true"
            ,"-disp_script", "true"
         };

         // Run the Init() rtn
         var p = new Params();
         Assert.IsFalse(Params.ParseArgs( args, ref p, out string msg), msg);
         // Checkout the msg
         // chk mn err msg
         Assert.IsTrue(msg.IndexOf("Error parsing args:") > -1, "error parsing args: not found");
         // chk got type right
         Assert.IsTrue(msg.IndexOf("unrecognised argument") > -1, "unrecognised argument not found");
         // chk detailed error msg
         Assert.IsTrue(msg.IndexOf("-Ex") > -1, "-Ex not found");
         LogL();
      }
      */

      [TestMethod()]
      public void ConstructorSetsTimestampTest()
      {
         var p = new Params();
         Assert.AreNotEqual(null, p.Timestamp);
      }

      /*
      /// <summary>
      /// This test the basic inheritance principle used in the test parameter objects
      /// There are 4 scenarios
      /// 
      ///   Scenario    Parent   Parameter   Child
      ///   1           null     null        null
      ///   2           v1       null        v1
      ///   3           null     v2          v2
      ///   4           v1       v2          v2
      ///   
      /// </summary>
      [TestMethod()]
      public void UpdatePropertyIfNeccessaryTest2()
      {
         //   Scenario    Parent   Parameter   Child
         //   1           null     null        null
         Params parent = new();
         Params child  = new(prms: parent);
         Assert.IsNull(parent.Server);
         Assert.IsNull(child .Server);

         //   Scenario    Parent   Parameter   Child
         //   2           v1       null        v1
         parent = new Params(serverName: "parent svr");
         child  = new Params(prms: parent);
         Assert.AreEqual("parent svr", child.Server);

         //   Scenario    Parent   Parameter   Child
         //   3           null     v2          v2
         parent = new Params();
         child  = new Params(prms: parent, serverName: "child svr");

         Assert.AreEqual("child svr", child.Server);

         //   Scenario    Parent   Parameter   Child
         //   4           v1       v2          v2
         parent = new Params(serverName: "parent svr");
         child  = new Params(prms: parent, serverName: "child svr");
         Assert.AreEqual("child svr", child.Server);
      }
      */

      /*
      [TestMethod()]
      public void SetDefaultsWhenNewTest()
      {
         var p = new ParamsTestable();
         p.SetDefaults();

         // Check no properties are null
         Assert.IsTrue(p.IsValid(out var msg), msg);

         // Check defaults are accurate
         Assert.IsFalse    ( p.AddTimestamp,                               "AddTimestamp"             );
         Assert.AreEqual   ( CreateModeEnum.Create, p.CreateMode,     "CreateMode"               );
         Assert.IsFalse    ( p.DisplayScript,                              "DisplayScript"            );
         Assert.IsFalse    ( p.ScriptUseDb,                                "ScriptUseDb"              );
         Assert.AreEqual   ( "SQLExpress",         p.Instance,        "Instance"                 );
         Assert.IsFalse    ( p.IsExportingData,                            "IsExprtngData"            );
         Assert.IsFalse    ( p.IsExportingDb,                              "IsExprtngDb"              );
         Assert.IsTrue     ( p.IsExportingFns,                             "IsExprtngFns"             );
         Assert.IsTrue     ( p.IsExportingProcs,                           "IsExprtngProcs"           );
         Assert.IsTrue     ( p.IsExportingSchema,                          "IsExprtngSchema"          ); // false because create mode is set to its default: alter
         Assert.IsFalse    ( p.IsExportingTbls,                            "IsExprtngTbls"            );
         Assert.IsFalse    ( p.IsExportingTTys,                            "IsExprtngTTys"            );
         Assert.IsFalse    ( p.IsExportingVws,                             "IsExprtngVws"             );
         Assert.IsFalse    ( p.IsExportingData,                            "AddTimestamp"             );
         Assert.IsTrue     ( Logger.LogFile.Equals(p.LogFile),       "LogFile"                  );
         Assert.IsFalse    ( string.IsNullOrWhiteSpace(p.ScriptFile),"LogFile"                  );
         Assert.IsNotNull  ( p.RequiredSchemas,                               "RequiredSchemas null"     );
         Assert.AreEqual   ( 1, p.RequiredSchemas.Count,              "RequiredSchemas.Count, 1" );
         Assert.AreEqual   ( "dbo", p.RequiredSchemas[0],       "RequiredSchemas[0]"       );
         Assert.AreEqual   ( @"DevI9", p.Server,                      "Server"                   );
         Assert.IsNotNull  ( p.RequiredTypes,                                 "RequiredTypes"         );
         Assert.AreEqual   ( 2,  p.RequiredTypes.Count,                 "RequiredTypes.Count"   );
         Assert.AreEqual   ( SqlTypeEnum.Function,  p.RequiredTypes[0], "RequiredTypes[1]"      );
         Assert.AreEqual   ( SqlTypeEnum.Procedure, p.RequiredTypes[1], "RequiredTypes[1]"      );
      }
      */
      /*
      /// <summary>
      /// Utils.PreconditionS: 
      ///   
      /// POSTCONDITIONS: 
      ///   POST 1: returns null if rs is null, empty
      ///   POST 2: returns null if rs contains no schemas
      ///   POST 3: returns all the required schemas in rs in the returned collection
      ///   POST 4: contains no empty schemas
      ///   POST 5: Server, Instance Database exist
      ///   POST 6: the schemas found should exist in the database
      ///           AND match the Case of the Db Schema name
      /// "{dbo, [ teSt]}"
      /// </summary>
      [TestMethod()]
      public void ParseRequiredSchemasTestWhen2SchemasThenOk()
      {
         //var exportScriptPath = @"C:\temp\PareseRequiredschemasTest.sql";
 /*        
         Params p11_exp = new Params(
             prms      : null // Use this state to start with and update with the subsequent parameters
            ,name        : "p11_exp"
            ,serverName     : @"DevI9\SQLEXPRESS"
            ,instanceName    : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,scriptFile : null
            ,createMode        : null
            ,requiredSchemas       : null
            ,requiredTypes       : null
            ,newSchNm  : null
            ,logFile       : null
            ,useDb     : false
            ,addTs     : true
            );
 * /

         Params p = new(
             prms          : null
            ,name          : "ParseRequiredSchemasTestWhen2SchemasThenOk param"
            ,serverName         : @"DevI9\SQLEXPRESS"
            ,instanceName        : "SQLEXPRESS"
            ,databaseName          : "Covid_T1" 
            ,scriptFile     : null
            ,createMode            : null
            ,requiredSchemas           : "{dbo, [ teSt]}"// should handle more than 1 schema and crappy formatting
            ,requiredTypes           : null
            ,useDb         : null
            ,addTimestamp  : null
         );

         var requiredSchemas = p.RequiredSchemas;
         Assert.IsNotNull(requiredSchemas);
         Assert.AreEqual(2,      requiredSchemas.Count);
         Assert.AreEqual("dbo",  requiredSchemas[0]);
         Assert.AreEqual("teSt", requiredSchemas[1]);
      }
*/
      [TestMethod()]
      public void UpdatePropertyIfNeccessaryTest()
      {
         // all pop inheriting null exp: all pop
         Params? p11_exp    = null;
        Params? p11_act    = null;
       Params? p20_act    = null;
       Params? p20_exp    = null;

         ChkEquals(p11_exp, p11_act, "UpdatePropertyIfNeccessaryTest");
         ChkEquals(p20_exp, p20_act, "UpdatePropertyIfNeccessaryTest");
      }

      /*
      /// <summary>
      /// test overlapping inherirtance append
      /// </summary>
      [TestMethod()]
      public void OverlappingTestNoBaseColls()
      {
         // Create the test objects

         Params prm_base = new(
             prms          : null // Use this state to start with and update with the subsequent parameters
            ,name            : "prm_base"
            ,serverName         : "base svr"
            ,instanceName        : "base instance"
            ,databaseName          : "base db"
            ,scriptFile     : null
            ,createMode            : null
            ,requiredSchemas           : null
            ,requiredTypes           : null
            ,useDb         : false
            ,addTimestamp  : true
            );

         Params prm_exp = new(
             prms       : null
            ,name         : "prm_exp"
            ,serverName      : "ovr svr"
            ,instanceName     : "base instance"
            ,databaseName       : "ovr db" 
            ,scriptFile  : "ovr script path" // base is null
            ,createMode         : null
            ,requiredSchemas        : "{dbo, test}" 
            ,requiredTypes        : "table, function" 
            ,useDb      : false
            ,addTimestamp: true
            );

         Params prm_act = new(
             prms       : prm_base          // sets SVR:UAULS0U\SQLEXPRESS, inst:UAULS0U\SQLEXPRESS, db:Covid_T1, {expth, newschma,requiredSchemas,requiredTypes} :null
            ,name         : "prm act"
            ,serverName      : "ovr svr"
            ,instanceName     : null
            ,databaseName       : "ovr db"          // replaces "Covid_T2"
            ,scriptFile  : "ovr script path" // replaces null
            ,createMode         : null
            ,requiredSchemas        : "{dbo, test}" 
            ,requiredTypes        : "table, function" 
            );

         ChkEquals(prm_exp, prm_act, "OverlappingTest");
      }
      */
      /*
      /// <summary>
      /// test overlapping inherirtance append
      /// </summary>
      [TestMethod()]
      public void OverlappingTestBaseCollSpecd()
      {
         // Create the test objects

         Params prm_base = new(
             prms          : null // Use this state to start with and update with the subsequent parameters
            ,name          : "prm_base"
            ,serverName         : "base svr"
            ,instanceName        : "base instance"
            ,databaseName          : "base db"
            ,scriptFile     : null
            ,createMode            : null
            ,requiredSchemas           : "{base sch 1}" 
            ,requiredTypes           : "procedure, function" 
            ,useDb         : false
            ,addTimestamp  : true
            );

         Params prm_exp = new(
             prms       : null
            ,name          : "prm_exp"
            ,serverName         : "ovr svr"
            ,instanceName        : "base instance"
            ,databaseName          : "ovr db" 
            ,scriptFile     : "ovr script path" // base is null
            ,createMode            : null
            ,requiredSchemas           : "{dbo, test}" 
            ,requiredTypes           : "table, database" 
            ,useDb         : false
            ,addTimestamp  : true
            );

         Params prm_act = new(
             prms          : prm_base          // sets SVR:UAULS0U\SQLEXPRESS, inst:UAULS0U\SQLEXPRESS, db:Covid_T1, {expth, newschma,requiredSchemas,requiredTypes} :null
            ,name          : "prm act"
            ,serverName         : "ovr svr"
            ,instanceName        : null
            ,databaseName          : "ovr db"          // replaces "Covid_T2"
            ,scriptFile     : "ovr script path" // replaces null
            ,createMode            : null
            ,requiredSchemas           : "{dbo, test}" 
            ,requiredTypes           : "table, database" 
            );

         ChkEquals(prm_exp, prm_act, "OverlappingTestBaseCollSpecd");
      }
*/
/*      
p11_ source                                           P21_overlap_inp : p11_exp                       act:   P21_overlap_exp                      
,serverName        : @"DevI9\SQLEXPRESS"    serverName      : DevI9\SQLEXPRESS    serverName      : DevI9\SQLEXPRESS
,instanceName      : "SQLEXPRESS"                     instanceName    : SQLEXPRESS                    instanceName    : SQLEXPRESS                
,databaseName      : "Covid_T1"                       databaseName    : P21 db                        databaseName    : P21 db                    
,exportScriptPath  : null                             exportScriptPath: P21 export path               exportScriptPath: P21 export path           
,newSchemaName     : null                             newSchemaName   :                               newSchemaName   : null                      
,requiredSchemas   : null                             requiredSchemas :                               requiredSchemas : null                      
,requiredTypes     : null                             requiredTypes   :                               requiredTypes   : null                      
,dbOpType          : DbOpTypeEnum.CreateSchema        dbOpType        :                               dbOpType        : CreateSchema              
,sqlType           : SqlTypeEnum.Undefined            sqlType         : default                       sqlType         : null                      
,createMode        : CreateModeEnum.Alter             createMode      : default                       createMode      : null                      
,scriptUseDb       : False                            scriptUseDb     : True                          scriptUseDb     : True                      
,addTimestamp      : True);                           addTimestamp    : False                         addTimestamp    : False                     
*/

      /*
      [TestMethod()]
      public void Overlapping2Test()
      {
         // overwrite will replace all specified parameters even those that are defaults not supplied**
         Params P21_overlap_ovrwrt_exp = new(
             prms          : null                    // was 
            ,name          : "P21_overlap_ovrwrt_exp"
            ,serverName         : @"FRED"                 // was DevI9\SQLEXPRESS
            ,instanceName        : "SQLEXPRESS"            // was same
            ,databaseName          : "P21 db"                // was Covid_T1
            ,scriptFile     : "P21 export path"       // was null
            ,createMode            : null
            ,requiredSchemas           : null                    // was null                     
            ,requiredTypes           : null                    // was null                     
            ,useDb         : true                    // was false                    
            ,addTimestamp  : false                   // was true                     
            );

         Params? p11_exp    = null;

         Params P21_overlap_ovrwrt_act = new(
             prms          : p11_exp           // sets SVR:UAULS0U\SQLEXPRESS, inst:UAULS0U\SQLEXPRESS, db:Covid_T1, {expth, newschma,requiredSchemas,requiredTypes} :null
            ,name          : "P21_overlap_ovrwrt_act:p11_exp"
            ,serverName         : @"FRED"
            ,instanceName        : "SQLEXPRESS"
            ,databaseName          : "P21 db" 
            ,scriptFile     : "P21 export path"
            ,useDb         : true
            ,addTimestamp  : false
            );

         ChkEquals(P21_overlap_ovrwrt_exp, P21_overlap_ovrwrt_act, "Overlapping2Test");
      }
      */

      [TestMethod()]
      public void ParseRequiredTypesTest()
      {
         Params p = new();
         Assert.IsNull( p.PrsReqTypes(null));
         Assert.IsNull( p.PrsReqTypes(""));

         var act = p.PrsReqTypes("t,F,P,v,s");

         LogDirect("------------- ParseRequiredTypesTest --------------");
         Assert.IsNotNull(act);

         foreach(SqlTypeEnum item in act)
            LogDirect($"got req ty: {item.GetAlias()}");

         LogDirect("---------------------------------------------------");

         Assert.AreEqual(5, act.Count);
         Assert.AreEqual(SqlTypeEnum.Table      , act[0], act[0].GetAlias());
         Assert.AreEqual(SqlTypeEnum.Function   , act[1], act[1].GetAlias());
         Assert.AreEqual(SqlTypeEnum.Procedure  , act[2], act[2].GetAlias());
         Assert.AreEqual(SqlTypeEnum.View       , act[3], act[3].GetAlias());
         Assert.AreEqual(SqlTypeEnum.Schema     , act[4], act[4].GetAlias());
      }

      [TestMethod()]
      [ExpectedException((typeof(Exception)), AllowDerivedTypes =true)]
      public void ParseRequiredTypesBadInputTest()
      {
         Params p = new();
         AssertThrows<ArgumentException>(() => p.PrsReqTypes("t,F,P,v,A"), "Unrecognised SQL type A");
      }
   
      [TestMethod()]
      public void ParseRequiredSchemasEmptyTest()
      {
         Params p = new();
         // POST 1,2 required schemas must be specified
         List<string>? rs = p.PrsRegSchema("");
         Assert.IsNull(rs);
         //   POST 3: returns all schemas in rs in the returned ary
         //   POST 4: contains no []
      }
   
      [TestMethod()]
      public void ParseRequiredSchemasMtTest()
      {
         Params p = new();
         List<string>? rs = p.PrsRegSchema("");
         Assert.IsNull(rs);
         // POST 1,2 required schemas must be specified
         //   POST 3: returns all schemas in rs in the returned ary
         //   POST 4: contains no []
      }
   
      protected override void TestSetup_()
      {
      }

      protected override void TestCleanup_()
      {
      }


      public string GetTestDataDir (){return this.TestDataDir; }
   }
}
#pragma warning restore CS8602 // Dereference of a possibly null reference.
