#nullable enable
#pragma warning disable CA1031 // Do not catch general exception types
#pragma warning disable CS8602 // Dereference of a possibly null reference.

using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using DbScripterLibNS;
using Microsoft.SqlServer.Management.Smo;
using System.Configuration;
using System.IO;
using Common;
using static Common.Logger;
using static Common.Utils;
using System.Text;
using Microsoft.SqlServer.Management.Sdk.Sfc;

namespace RSS.Test
{
   [TestClass]
   public class DbScripterTests : ScriptableUnitTestBase
   {
      #region tests

      /// <summary>
      /// Bugs:
      /// 1: ALTER FUNCTION [dbo].[fnALTERTrendSql]
      /// 1: ALTER FUNCTION [dbo].[fnCreateTrendSql]
      /// should only convert the  first instance of ^[ \t]*Create
      /// </summary>
      [TestMethod]
      public void ExportSchemas_ChangeLog_Test()
      {
         LogS();
         var sc = new DbScripterTestable(){  AllowFileDisplay = false};
         string msg = "";

         Params p = Params.PopParams
         (
             prms          : CovidBaseParams
            ,nm            : "ExportDatabase Params"
            ,dbNm          : "Covid"
            ,xprtScrpt     : ScriptFile
            ,cm            : CreateModeEnum.Alter
            ,rss           : "{dbo}"
            ,addTs         : true
            ,log           : @"D:\Logs\DbScripter.log"
            ,useDb         : true
            ,displayScript : true
         );

         Assert.IsTrue(sc.Init(p, out msg), msg);
         Assert.IsTrue(p.LogFile     .IndexOf(p.Timestamp) > -1, "failed to update the log file parameter with the timestamp");
         Assert.IsTrue(p.ScriptFile  .IndexOf(p.Timestamp) > -1, "failed to update the script file parameter with the timestamp");
         Assert.IsTrue(Logger.LogFile.IndexOf(p.Timestamp) > -1, "failed to update the log file with the timestamp");
         sc.CloseWriter();

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);
         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");

         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE", ""    , 0,   50,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION" , ""    , 0,   22,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"    , ""    , 0,    0,     0, out msg), msg); // 3 tables for drop or creat - 0 for alter
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"     , ""    , 0,   22,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE" , ""    , 0,    0,     0, out msg), msg);

         // chk files exist
         Assert.IsTrue(File.Exists(p.LogFile   ), $"Log File [{p.LogFile}]does not exist");
         Assert.IsTrue(File.Exists(p.ScriptFile), $"Script File [{p.ScriptFile}]does not exist");

         // chk the file script is the same as the returned script
         script = File.ReadAllText(p.ScriptFile);
         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");

         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE", ""    , 0,   50,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION" , ""    , 0,   22,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"    , ""    , 0,    0,     0, out msg), msg); // 3 tables for drop or creat - 0 for alter
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"     , ""    , 0,   22,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE" , ""    , 0,    0,     0, out msg), msg);
         LogL();
      }

      /// <summary>
      /// NOTE there is a similar requirement for Script Dir
      /// 
      /// The permutations are:
      ///   1: app settings contains a value: so return it
      ///   2: app settings contains a value: so return the default LogFileProperty
      ///   
      /// Strategy:
      ///   Get the config appsettings and default log file values
      ///   Ensure are non empty and different
      ///   
      ///   1: Call the method GetLogFileFromConfig via DbScripterTestable and compare its return
      ///      Should match the config app settings value
      ///   
      ///   2: Remove the app settings value
      ///      Verify it has been removed
      ///      Call the method GetLogFileFromConfig via DbScripterTestable and compare its return
      ///      Should match the default log file property
      ///
      ///   3: Replace the App settings value
      ///      Verify it has been replaced
      /// </summary>
      [TestMethod]
      public void GetScriptDirFromConfigTest()
      {
         LogS();
         var logKey = "Script Dir";
         //var appSettings = ConfigurationManager.AppSettings;
         var configName = ConfigurationManager.AppSettings["Config Name"];
         Assert.IsTrue(configName.Equals("DbScripterLib Unit Tests config", StringComparison.OrdinalIgnoreCase));
         // Get the config appsettings and default log file values
         // Ensure are non empty and different
         var origConfigScriptDirProperty  = ConfigurationManager.AppSettings.Get(logKey);
         Assert.IsFalse(string.IsNullOrEmpty(origConfigScriptDirProperty), $"appSettings does not contain {logKey} stting");
         var origDefaultScriptDirProperty = Params.DefaultLogFile; //Property;
         Assert.IsFalse(string.IsNullOrEmpty(origDefaultScriptDirProperty), $"origDefaultScriptDirProperty not specified");
         var configuration = System.Configuration.ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

         try
         {
            var configScriptDirProperty = ConfigurationManager.AppSettings.Get(logKey);
            // Cache and replace later
            // Ensure different
            ParamsTestable.DefaultScriptDir = "test value";
            var defaultScriptDirProperty = Params.DefaultScriptDir; //Property;
            Assert.IsFalse(string.IsNullOrEmpty(configScriptDirProperty));
            Assert.IsFalse(string.IsNullOrEmpty(defaultScriptDirProperty));
            Assert.IsFalse(configScriptDirProperty.Equals(defaultScriptDirProperty, StringComparison.OrdinalIgnoreCase));

            // 1: Call the method GetLogFileFromConfig via DbScripterTestable and compare its return
            // Should match the config app settings value
            var act = Params.GetScriptDirFromConfig();
            Assert.IsTrue(configScriptDirProperty.Equals(act, StringComparison.OrdinalIgnoreCase));

            // 2: Remove the app settings value
            configuration.AppSettings.Settings.Remove(logKey);
            configuration.Save(ConfigurationSaveMode.Modified);
            ConfigurationManager.RefreshSection( "appSettings" );

            // Verify it has been removed
            configScriptDirProperty = ConfigurationManager.AppSettings[logKey];
            Assert.IsNull(configScriptDirProperty);

            // Call the method GetLogFileFromConfig via DbScripterTestable and compare its return
            act = Params.GetScriptDirFromConfig();
            // Should match the default log file property
            Assert.IsTrue(defaultScriptDirProperty.Equals(act, StringComparison.OrdinalIgnoreCase));

            // 3: Replace the App settings value
            //ConfigurationManager.AppSettings.Set(logKey, configLogFileProperty);
            configuration.AppSettings.Settings.Add(logKey, origConfigScriptDirProperty);
            configuration.Save(ConfigurationSaveMode.Modified);
            // Verify it has been replaced
            ConfigurationManager.RefreshSection( "appSettings" );
            var x = ConfigurationManager.AppSettings[logKey];
            Assert.IsTrue(origConfigScriptDirProperty.Equals(x));
         }
         catch(Exception e)
         {
            LogException(e);
         }
         finally
         {
            ParamsTestable.DefaultScriptDir = origDefaultScriptDirProperty;
            var currentVal = configuration.AppSettings.Settings[logKey].Value;

            if((currentVal == null) || (!currentVal.Equals(origConfigScriptDirProperty)))
            {
               // ASSERTION: need to reset config state
               if(configuration.AppSettings.Settings[logKey] != null)
                  configuration.AppSettings.Settings.Remove(logKey);

               configuration.AppSettings.Settings.Add(logKey, origConfigScriptDirProperty);

               configuration.Save(ConfigurationSaveMode.Modified);
               ConfigurationManager.RefreshSection( "appSettings" );
               Assert.IsTrue(origConfigScriptDirProperty.Equals(ConfigurationManager.AppSettings.Get(logKey)));
            }
         }

         LogL();
      }

      /// <summary>
      /// Bugs:
      /// 1: ALTER FUNCTION [dbo].[fnALTERTrendSql]
      /// 1: ALTER FUNCTION [dbo].[fnCreateTrendSql]
      /// should only convert the  first instance of ^[ \t]*Create
      /// </summary>
      [TestMethod]
      public void ExportSchemas_Alter_1_ut_dbo_Test()
      {
         LogS();
         DbScripter sc = new();
         // 1 off for this test - reset in test cleanup_
         //DisplayLogAfterTestFailure    = true;
         //DisplayScriptAfterTestFailure = true;

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,dbNm       : "ut"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Alter
            ,rss        : "{dbo}"
            ,rts        : null
            ,log        : @"D:\Logs\DbScripter.log"
            ,useDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);

         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");
         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE"     , ""    , 0,  55,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION"      , ""    , 0,  72,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"         , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"          , ""    , 0,  10,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE"      , ""    , 0,   0,  0, out msg), msg);
         LogL();
      }

      /// <summary>
      /// Bugs:
      /// 1: ALTER FUNCTION [dbo].[fnALTERTrendSql]
      /// 1: ALTER FUNCTION [dbo].[fnCreateTrendSql]
      /// should only convert the  first instance of ^[ \t]*Create
      /// </summary>
      [TestMethod]
      public void ExportSchemas_Alter_2_ut_dbo_tst_Test()
      {
         LogS();
         DbScripter sc = new();
         // 1 off for this test - reset in test cleanup_
         //DisplayLogAfterTestFailure    = true;
         //DisplayScriptAfterTestFailure = true;

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,dbNm       : "ut"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Alter
            ,rss        : "{dbo,test}"
            ,rts        : null
            ,log        : @"D:\Logs\DbScripter.log"
            ,useDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);

         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");
         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE", ""    , 0,  55,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION" , ""    , 0,  72,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"    , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"     , ""    , 0,  10,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE" , ""    , 0,   0,  0, out msg), msg);

         Assert.IsTrue(CheckForSchema( script, "test" , "PROCEDURE", ""    , 0, 112,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test" , "FUNCTION" , ""    , 0,  29,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test" , "TABLE"    , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test" , "VIEW"     , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test" , "DATATYPE" , ""    , 0,   0,  0, out msg), msg);
         LogL();
      }

      /// <summary>
      /// Bugs:
      /// 1: ALTER FUNCTION [dbo].[fnALTERTrendSql]
      /// 1: ALTER FUNCTION [dbo].[fnCreateTrendSql]
      /// should only convert the  first instance of ^[ \t]*Create
      /// </summary>
      [TestMethod]
      public void ExportSchemas_Alter_1_ut_tst_Test()
      {
         LogS();
         DbScripter sc = new();

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,dbNm       : "ut"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Alter
            ,rss        : "{test}"
            ,rts        : null
            ,log        : @"D:\Logs\DbScripter.log"
            ,useDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);

         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");
         Assert.IsTrue(CheckForSchema( script, "test" , "PROCEDURE", ""    , 0, 112,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test" , "FUNCTION" , ""    , 0,  29,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test" , "TABLE"    , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test" , "VIEW"     , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test" , "DATATYPE" , ""    , 0,   0,  0, out msg), msg);
         LogL();
      }

      /// <summary>
      /// Bugs:
      /// 1: ALTER FUNCTION [dbo].[fnALTERTrendSql]
      /// 1: ALTER FUNCTION [dbo].[fnCreateTrendSql]
      /// should only convert the  first instance of ^[ \t]*Create
      /// </summary>
      [TestMethod]
      public void ExportSchemas_Alter_1_cvdT1_dbo_Test()
      {
         LogS();
         DbScripter sc = new();
         string script = "";
         // 1 off for this test - reset in test cleanup_
         //DisplayLogAfterTestFailure    = true;
         //DisplayScriptAfterTestFailure = true;

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,dbNm       : "Covid_T1"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Alter
            ,rss        : "{dbo}"
            ,rts        : null
            ,log        : @"D:\Logs\DbScripter.log"
            ,useDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out script, out string msg), msg);

         //try
         //{ 
         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");
         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE"     , ""    , 0,  50,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION"      , ""    , 0,  22,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"         , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"          , ""    , 0,  23,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE"      , ""    , 0,   0,  0, out msg), msg);

         // More detailed check on the lists - the 5 viewa
         Assert.IsTrue(sc.ExportedViews.ContainsKey("dbo.country_vw"), "expected dbo.country_vw"); // dbo.countryvw
         Assert.IsTrue(sc.ExportedViews.ContainsKey("dbo.owid_vw"), "expected owid_vw");
         Assert.IsTrue(sc.ExportedViews.ContainsKey("dbo.sys_tables_vw"), "expected dbo.sys_tables_vw");
         Assert.IsTrue(sc.ExportedViews.ContainsKey("dbo.covid_staging_1_vw"), "expected dbo.covid_staging_1_vw");
         Assert.IsTrue(sc.ExportedViews.ContainsKey("dbo.covidstaging1_vw"), "expected dbo.covidstaging1_vw");

         Assert.AreEqual(50, sc.ExportedProcedures.Count, "ExportedProcedures");
         Assert.AreEqual(22, sc.ExportedFunctions .Count, "ExportedFunctions ");
         Assert.AreEqual( 0, sc.ExportedTables    .Count, "ExportedTables    ");
         Assert.AreEqual(23, sc.ExportedViews     .Count, "ExportedViews     ");
         Assert.AreEqual( 0, sc.ExportedTableTypes.Count, "ExportedTableTypes");
         //}
         //catch(Exception e)
         //{
         //   LogException(e);
         //   DisplayScript();//script);
         //   throw;
         //}

         LogL();
      }
      

      /// <summary>
      /// Bugs:
      /// 1: ALTER FUNCTION [dbo].[fnALTERTrendSql]
      /// 1: ALTER FUNCTION [dbo].[fnCreateTrendSql]
      /// should only convert the  first instance of ^[ \t]*Create
      /// </summary>
      [TestMethod]
      public void ExportSchemas_Alter_1_cvdT1_1_test_Test()
      {
         LogS();
         DbScripter sc = new();
         string msg;
         string script = "";

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,dbNm       : "Covid_T1"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Alter
            ,rss        : "{test}"
            ,rts        : null
            ,log        : @"D:\Logs\DbScripter.log"
            ,useDb      : true
         );

         try
         { 
            Assert.IsTrue(sc.Export(ref p, out script, out msg), msg);

            Assert.IsNotNull(script, $"export script not defined");
            Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");
            Assert.IsTrue(CheckForSchema( script, "test", "PROCEDURE"     , ""    , 0,  47,  0, out msg), msg);
            Assert.IsTrue(CheckForSchema( script, "test", "FUNCTION"      , ""    , 0,   0,  0, out msg), msg);
            Assert.IsTrue(CheckForSchema( script, "test", "TABLE"         , ""    , 0,   0,  0, out msg), msg);
            Assert.IsTrue(CheckForSchema( script, "test", "VIEW"          , ""    , 0,   1,  0, out msg), msg);
            Assert.IsTrue(CheckForSchema( script, "test", "DATATYPE"      , ""    , 0,   0,  0, out msg), msg);

            Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE"     , ""    , 0,   0,  0, out msg), msg);
            Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION"      , ""    , 0,   0,  0, out msg), msg);
            Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"         , ""    , 0,   0,  0, out msg), msg); // 3 tables for drop or creat - 0 for alter
            Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"          , ""    , 0,   0,  0, out msg), msg);
            Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE"      , ""    , 0,   0,  0, out msg), msg);
         }
         catch(Exception e)
         {
            LogException(e);
            DisplayScript(script);
            throw;
         }
         LogL();
      }

      /// <summary>
      /// Bugs:
      /// 1: ALTER FUNCTION [dbo].[fnALTERTrendSql]
      /// 1: ALTER FUNCTION [dbo].[fnCreateTrendSql]
      /// should only convert the  first instance of ^[ \t]*Create
      /// </summary>
      [TestMethod]
      public void ExportSchemas_Alter_1_cvd_dbo_Test()
      {
         LogS();
         DbScripter sc = new();

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,dbNm       : "Covid"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Alter
            ,rss        : "{dbo}"
            ,rts        : null
            ,log        : @"D:\Logs\DbScripter.log"
            ,useDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);
         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");

         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE", ""    , 0,   50,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION" , ""    , 0,   22,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"    , ""    , 0,    0,     0, out msg), msg); // 3 tables for drop or creat - 0 for alter
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"     , ""    , 0,   22,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE" , ""    , 0,    0,     0, out msg), msg);
         //DisplayScript();
         LogL();
      }

      /// <summary>
      /// Bugs:
      /// 1: ALTER FUNCTION [dbo].[fnALTERTrendSql]
      /// 1: ALTER FUNCTION [dbo].[fnCreateTrendSql]
      /// should only convert the  first instance of ^[ \t]*Create
      /// </summary>
      [TestMethod]
      public void ExportSchemas_Alter_2_cvd_dbo_tst_Test()
      {
         LogS();
         DbScripter sc = new();

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,dbNm       : "Covid"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Alter
            ,rss        : "{dbo,test}"
            ,rts        : null
            ,log        : @"D:\Logs\DbScripter.log"
            ,useDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);
         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");

         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE", ""    , 0,  50,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION" , ""    , 0,  22,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"    , ""    , 0,   0,  0, out msg), msg); // 3 tables for drop or creat - 0 for alter
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"     , ""    , 0,  22,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE" , ""    , 0,   0,  0, out msg), msg);

         Assert.IsTrue(CheckForSchema( script, "test", "PROCEDURE", ""    , 0,  47,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "FUNCTION" , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "TABLE"    , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "VIEW"     , ""    , 0,   1,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "DATATYPE" , ""    , 0,   0,  0, out msg), msg);
         DisplayScript();
         LogL();
      }

      /*// <summary>
      /// Required types depends on the export type
      /// For example if Exporting procedures then required types should be procedures only
      /// 
      /// If the export type is     schema then { Table, Function, Procedure, Table, TableType, View} are required
      /// If the export type is not schema or database then only the same 1 export type is required.
      /// 
      /// PRECONDITIONS:
      ///   PRE 1: required_type not SqlTypeEnum.Undefined (handled)
      ///
      /// POSTCONDITIONS:
      ///   POST 1: If the export type is     schema then { Table, Function, Procedure, Table, TableType, View} are required
      ///   POST 2: If the export type is not schema or database then only the same 1 export type is required
      /// </summary>
      [TestMethod]
      public void CorrectRequiredTypesTest()
      {
         LogS();

         Assert.IsTrue(CorrectRequiredTypesHlpr(createMode: CreateModeEnum.Create, input: null, exp: new List<SqlTypeEnum>() { SqlTypeEnum.Table }, out string msg), msg);
         Assert.IsTrue (CorrectRequiredTypesHlpr(createMode: CreateModeEnum.Create, input: new List<SqlTypeEnum>() { SqlTypeEnum.Table }, exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Table }, out msg), msg);
         Assert.IsTrue (CorrectRequiredTypesHlpr(createMode: CreateModeEnum.Create, input: new List<SqlTypeEnum>() { SqlTypeEnum.Table }, exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Table }, out msg), msg);

         Assert.IsTrue (CorrectRequiredTypesHlpr(createMode: CreateModeEnum.Create, input: new List<SqlTypeEnum>() { SqlTypeEnum.Table,  SqlTypeEnum.Function,  SqlTypeEnum.Procedure }
                       , exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Table, SqlTypeEnum.Function, SqlTypeEnum.Procedure, SqlTypeEnum.TableType, SqlTypeEnum.View }, out msg), msg);

         Assert.IsTrue (CorrectRequiredTypesHlpr(createMode: CreateModeEnum.Drop, input: new List<SqlTypeEnum>() { SqlTypeEnum.Table,  SqlTypeEnum.Function,  SqlTypeEnum.Procedure }
                       , exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Table, SqlTypeEnum.Function, SqlTypeEnum.Procedure, SqlTypeEnum.TableType, SqlTypeEnum.View }, out msg), msg);

         Assert.IsTrue (CorrectRequiredTypesHlpr(createMode: CreateModeEnum.Alter, input: new List<SqlTypeEnum>() { SqlTypeEnum.Function,  SqlTypeEnum.Procedure }
                       , exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Function, SqlTypeEnum.Procedure, SqlTypeEnum.TableType, SqlTypeEnum.View }, out msg), msg);
         LogL();
      }
      */

      /*
      /// <summary>
      /// Required types depends on the export type
      /// For example if Exporting procedures then required types should be procedures only
      /// 
      /// If the export type is     schema then { Table, Function, Procedure, Table, TableType, View} are required
      /// If the export type is not schema or database then only the same 1 export type is required.
      /// 
      /// PRECONDITIONS:
      ///   PRE 1: required_type not SqlTypeEnum.Undefined (handled)
      ///
      /// POSTCONDITIONS:
      ///   POST 1: If the export type is     schema then { Table, Function, Procedure, Table, TableType, View} are required
      ///   POST 2: If the export type is not schema or database then only the same 1 export type is required
      /// </summary>
      [TestMethod]
      [ExpectedException(typeof(Exception), AllowDerivedTypes = true)]
      public void CorrectRequiredTypesTestWhenExpSchemasAndCreateModeErrorThenExpEx()
      {
         LogS();
         Assert.IsFalse(DbScripterTestable.CorrectRequiredTypes(CreateModeEnum.Error, new List<SqlTypeEnum>(), out _, out var msg), msg);
         LogL();
      }

      protected bool CorrectRequiredTypesHlpr(CreateModeEnum createMode, List<SqlTypeEnum>? input, List<SqlTypeEnum> exp, out string msg)
      {
         bool ret = DbScripterTestable.CorrectRequiredTypes(createMode, input, out var act, out msg);

         do
         { 
            if(act.Count != exp.Count)
            {
               msg = $"exp len: {exp.Count}, act len: {act.Count}";
               break;
            }

            // Counts match so check items match
            foreach(var exp_ty in exp)
               if(!(act?.Contains(exp_ty) ?? false))
                  break;

            // If here then all chks passed
            ret = true;
         } while(false);

         return ret;
      }
      */

      /// <summary>
      /// Determeintes if the  schema is a test schema and therfpre should be creeated
      /// or dropped using the tSQLt methods
      /// 
      /// PRECONDITION: schema name is valid
      /// 
      /// POSTCONDITIONS:
      ///   returns true if schema is using tSQLt false otherwise
      /// 
      /// </summary>
      /// <param name="schema"></param>
      /// <returns></returns>
      [TestMethod]
      public void IsTestSchemaTest()
      {
         LogS();
         Assert.IsTrue (DbScripterTestable.IsTestSchema("test"));
         Assert.IsFalse(DbScripterTestable.IsTestSchema("dbo"));
         Assert.IsFalse(DbScripterTestable.IsTestSchema("tSQLt"));
         LogL();
      }


      [TestMethod]
      public void ExportProceduresDropTest()
      {
         LogS();
         DbScripter sc = new();

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Drop
            ,rss        : "{dbo,test,tSQLt}"
            ,rts        : null
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);
         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");

         Assert.IsTrue(ChkContains(script, @"^(DROP PROCEDURE \[dbo\].*)",   50,  out msg), msg);  // dbo   : 39/39
         Assert.IsTrue(ChkContains(script, @"^(DROP PROCEDURE \[test\].*)",  47 , out msg), msg);  // test  : 45
         Assert.IsTrue(ChkContains(script, @"^(DROP PROCEDURE \[tSQLt\].*)", 94,  out msg), msg);  // tSQLt : 93
         Assert.IsTrue(ChkContains(script, @"^(DROP PROCEDURE.*)",           191, out msg), msg);  // all   : 169

         LogL();
      }

      [TestMethod]
      public void ExportFunctionsTest()
      {
         LogS();
         DbScripter sc = new();
         string script="";

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Create
            ,rss        : "{dbo, [ teSt], tSQLt}" // should handle more than 1 schema and crappy formatting
            ,rts        : "F"
         );

         try
         { 
         Assert.IsTrue(sc.Export(ref p, out script, out string msg), msg);
         Assert.IsNotNull(script, "Null script");
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION.*)",           58, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION \[dbo\].*)",   22, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION \[test\].*)",  0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION \[tSQLt\].*)", 36, out msg), msg);
         }
         catch(Exception e)
         {
            LogException(e, "ExportFunctionsTest");
            DisplayScript(script);
            throw;
         }
         
         LogL();
      }


      [TestMethod]
      [Ignore]
      public void ExportDatabaseTest()
      {
         LogS();
         DbScripter sc = new();

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Create
            ,rss        : "{dbo, [ teSt], tSQLt}" // should handle more than 1 schema and crappy formatting
            ,rts        : "Database"
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE Database.*)", 1, out msg), msg);
         LogL();
      }

      [TestMethod]
      public void ExportSchemas_Create_cvd_1_tst_Test()
      {
         LogS();
         DbScripter sc = new();

         // Exception thrown opening server twice: 
         // Microsoft.Data.SqlClient.resources, Version=2.0.20168.4, Culture=en-GB, PublicKeyToken=23ec7fc2d6eaa4a5' or one of its dependencies. 
         // The system cannot find the file specified."

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "Count1CrtSchemaTest Params"
            ,dbNm       : "Covid_T1"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Create
            ,rss        : "{test}" // should handle more than 1 schema and crappy formatting
            ,rts        : null
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);

         Assert.IsTrue(ChkContains(script, @"^(CREATE PROCEDURE \[dbo\].*)"      , 0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^([ \t]*EXEC[ \t]+tSQLt\.NewTestClass[ \t]+'test')", 1 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE.*)",                   2 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE PROCEDURE.*)",               47, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION.*)",                0 , out msg), msg);
         LogL();
      }


      // DependencyWalker.DiscoverDependencies This can fail in MS code if there is more than 1 reference to a an unresolved item like a missing stored procedure
      // as was the case in ut / when commonly used sp name was changed and not all references were updated
      // {"Item has already been added. Key in dictionary:
      // 'Server[@Name='DevI9\\SQLEXPRESS']/Database[@Name='ut']
      // /UnresolvedEntity[@Name='sp_tst_hlpr_chk' and @Schema='test']'
      // Key being added: 'Server[@Name='DevI9\\SQLEXPRESS']/Database[@Name='ut']/UnresolvedEntity[@Name='sp_tst_hlpr_chk' and @Schema='test']'"}
      [TestMethod]
      public void ExportSchemas_Create_ut_1_tst_Test()
      {
         LogS();
         DbScripter sc = new();

         // Exception thrown opening server twice: 
         // Microsoft.Data.SqlClient.resources, Version=2.0.20168.4, Culture=en-GB, PublicKeyToken=23ec7fc2d6eaa4a5' or one of its dependencies. 
         // The system cannot find the file specified."

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "Count1CrtSchemaTest Params"
            ,dbNm       : "ut"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Create
            ,rss        : "{test}" // should handle more than 1 schema and crappy formatting
            ,rts        : null
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);

         Assert.IsTrue(ChkContains(script, @"^(CREATE PROCEDURE \[dbo\].*)"      , 0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^([ \t]*EXEC[ \t]+tSQLt\.NewTestClass[ \t]+'test')", 1 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE.*)",                   1 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE PROCEDURE.*)",              112, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION.*)",               29 , out msg), msg);
         LogL();
      }

      [TestMethod]
      public void ExportSchemas_Alter_2_cvdT1_dbo_tst_Test()
      {
         LogS();
         DbScripter sc = new();

         /*CovidBaseParams:   svrNm:   @"DevI9\SQLEXPRESS"
                             ,instNm:  "SQLEXPRESS"
                             ,dbNm:    "Covid_T1"*/
         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportSchemas_Alter_2_cvdT1_dbo_tst Params"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Alter
            ,rss        : "{dbo,test}" // should handle more than 1 schema and crappy formatting
            ,rts        : null
         );  

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);

         // Alter schema should not create or drop the schema - it merely alters the child entities
         Assert.IsTrue(ChkContains(script, @"^(EXEC[ \t\[]+tSQLt.*NewTestClass 'test';)",       0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(EXEC[ \t]+tSQLt.*DropClass 'test';)",            0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE[ \t]+SCHEMA)",                            0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(DROP[ \t]+SCHEMA)",                              0 , out msg), msg);
         //                                                                       crt alt drp
         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE", ""          , 0,  50, 0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "PROCEDURE", ""          , 0,  47, 0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "view"     , ""          , 0,  23, 0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "view"     , ""          , 0,  1,  0, out msg), msg);
          // Alter schema should not script Table child tables
         Assert.IsTrue(CheckForSchema( script, "dbo", "TABLE"     , ""          , 0,  0,  0, out msg), msg);

         // Alter schema should script FUNCTIONs
         Assert.IsTrue(CheckForSchema( script, "dbo" , "function" , ""          , 0,  22,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "function" , ""          , 0,  0,   0, out msg), msg);

         // CREATE Table data TYPE
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TYPE"     , ".*AS TABLE", 0,  0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "TYPE"     , ".*AS TABLE", 0,  0,  0, out msg), msg);

         // CREATE Table data TYPE
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TYPE"     , ".*FROM"    , 0,  0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "TYPE"     , ".*FROM"    , 0,  0,  0, out msg), msg);
         LogL();
      }

      /*
       Expect a script generated that will drop 1 or more schema and its children in dependency order
       */
         [TestMethod]
      public void ExportSchemas_Drop_1_tst_Test()
      {
         LogS();
         DbScripter sc = new();

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "Count1CrtSchemaTest Params"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Drop
            ,rss        : "{test}" // should handle more than 1 schema and crappy formatting
            ,rts        : "s"
         );

         Log($"params: \r\n {p}");
         
         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);

         Assert.IsTrue(ChkContains(script, @"^(DROP TABLE.*)",          2 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(DROP PROCEDURE.*)",      47, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(DROP FUNCTION.*)",       0 , out msg), msg);

         Assert.IsTrue(ChkContains(script, @"^(EXEC tSQLt\.DropClass 'test')", 1 , out msg), msg);

         LogL();
      }


      [TestMethod]
      public void ExportFunctionsCreateTest()
      {
         LogS();
         DbScripter sc = new();

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,dbNm       : "Covid_T1"
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Create
            ,rss        : "{dbo}"
            ,rts        : "F"
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE Function.*)", 22, out msg), msg);
         LogL();
      }

      [TestMethod]
      public void ExportFunctionsDropTest()
      {
         LogS();
         DbScripter sc = new();

         Params p = Params.PopParams
         (
             prms       : CovidBaseParams
            ,nm         : "ExportDatabase Params"
            ,dbNm       : null
            ,xprtScrpt  : ScriptFile
            ,cm         : CreateModeEnum.Drop
            ,rss        : "{dbo}"
            ,rts        : "F"
         ); 

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(DROP Function.*)", 22, out msg), msg);
         LogL();
      }


      [TestMethod]
      public void Count1CrtSTableTestBothExpSchemaAndExpDataNotDefinedTest()
      {
         LogS();
         DbScripter sc = new();

         Params p = Params.PopParams(
             prms          : CovidBaseParams
            ,nm            : "Count1CrtSchemaTest Params"
            ,xprtScrpt     : ScriptFile
            ,cm            : CreateModeEnum.Create
            ,rss           : "{dbo, [ teSt]}" // should handle more than 1 schema and crappy formatting
            ,rts           : "t"              // this is overridden in Export schema as it exports all the child objects
            );

         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE \[dbo\]\..*)"     , 22, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE \[test\]\..*)"    ,  2, out msg), msg);
         LogL();
      }

      /// <summary>
      /// 
      /// </summary>
      [TestMethod()]
      public void InitTableExportTest()
      {
         LogS();
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = Params.PopParams(
             prms       : CovidBaseParams
            ,nm         : "Fred"
            ,xprtScrpt  : @"C:\temp\InitTableExportTest.sql"
            ,cm         : CreateModeEnum.Create
            ,rss        : "tEst,tSqlt"
              );

         // Create and initise the scripter
         var sc   = new DbScripterTestable();
         Assert.IsTrue(sc.Init(p, out string msg), msg);
         var orig = Utils.ShallowClone( sc.ScriptOptions);

         // Run the rtn
         Assert.IsTrue(sc.InitTableExport(out var so, out msg), msg);
         Assert.IsFalse(so?.ScriptForAlter         ?? true, "ScriptForAlter");
//         Assert.IsFalse(so?.ScriptForCreateOrAlter ?? true, "ScriptForCreateOrAlter");
         Assert.IsNotNull(orig);
         LogDirect($"orig:\r\n{DbScripter.OptionsToString(orig)}");
         LogDirect($"ScriptOptions:\r\n{DbScripter.OptionsToString(sc?.ScriptOptions )}");
         Assert.IsTrue(DbScripter.OptionEquals(orig, sc?.ScriptOptions ?? new(), out msg) , msg);
         LogL();
      }

      /// <summary>
      /// should not allow this combination
      /// </summary>
      [TestMethod()]
      public void InitTableExportTestEx()
      {
         LogS();
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = Params.PopParams(
             prms       : null
            ,svrNm      : @"DevI9\SQLEXPRESS"
            ,instNm     : "SQLEXPRESS"
            ,dbNm       : "Covid_T1"
            ,xprtScrpt  : @"C:\temp\InitTableExportTestEx.sql"
            ,cm         : CreateModeEnum.Alter
            ,rss        : "tEst,tSqlt"
            ,rts        : "table"
          );

         // Create and initise the scripter
         var sc = new DbScripterTestable();
         Assert.IsFalse(sc.Init(p, out string msg), msg);
         // Run the rtn
         Assert.IsFalse(sc.InitTableExport(out _, out msg), msg);
         LogL();
      }


      /// <summary>
      /// Sets up the general scripter options
      /// 
      /// Utils.PreconditionS:
      ///   PRE 1: P is valid
      ///   
      /// POSTCONDITIONS:
      ///  general: Scripter.Options state initialised with general settings
      ///  specific:
      ///  POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
      /// </summary>
      [TestMethod()]
      public void InitScriptingOptionsWhenTAlterAndTableThenExpFalseTest()
      {
         LogS();
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = Params.PopParams(
             prms       : CovidBaseParams
            ,nm         : "Jog=hn"
            ,dbNm       : null
            ,xprtScrpt  : @"C:\temp\T011_ExportSchemaScriptTest.sql"
            ,cm         : CreateModeEnum.Alter
            ,rss        : "tEst,tSqlt"
            ,rts        : "table, function"
          );

         var sc = new DbScripterTestable();
         Assert.IsFalse(sc.Init(p, out string msg), msg);
         LogL();
      }

      [TestMethod()]
      public void InitScriptingOptionsTestExpOk()
      {
         LogS();
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = Params.PopParams( 
             prms          : CovidBaseParams
            ,nm            : "Louis"
            ,dbNm          : null
            ,xprtScrpt     : @"C:\temp\T011_ExportSchemaScriptTest.sql"
            ,cm            : CreateModeEnum.Alter
            ,rss           : "tEst,tSqlt"
            ,displayScript : true
           );

         var sc = new DbScripterTestable(){  AllowFileDisplay = false};

         Assert.IsTrue(sc.Init(p, out var msg), msg);
         Assert.IsTrue(p.DisplayScript,    "DisplayScript: exp true");
         Assert.IsTrue(sc.P.DisplayScript, "DisplayScript: exp true");
         LogL();
      }

      [TestMethod()]
      public void MapTypeToSqlTypeTest()
      {
         LogS();
         Params p = Params.PopParams( 
             prms       : CovidBaseParams
            ,xprtScrpt  : @"C:\temp\MapTypeToSqlTypeTest.sql"
            ,cm         : CreateModeEnum.Create
            ,rss        : "tEst,tSqlt"
           );
       
         var sc = new DbScripterTestable();
         Assert.IsTrue(sc.Init(p, out var msg), msg);
         Assert.AreEqual(SqlTypeEnum.Database , DbScripterTestable.MapTypeToSqlType(sc?.Database));
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
         LogS();
         try
         { 
            Params p = Params.PopParams( 
             prms       : CovidBaseParams
            ,xprtScrpt  : @"C:\temp\MapTypeToSqlTypeTestUnknownTypeTest.sql"
            ,cm         : CreateModeEnum.Create
            ,rss        : "tEst,tSqlt"
            );
       
            var sc = new DbScripterTestable();
            Assert.IsTrue( sc.Init(p, out var msg), msg);
            // expect throw here
            IgnoreThisThrow = true;
            var unexpected = DbScripterTestable.MapTypeToSqlType(new UserDefinedDataType(sc.Database, "unexpected", "dbo"));
         }
         catch(Exception e)
         {
            LogException(e, $"IgnoreThisThrow: {IgnoreThisThrow}");
            IgnoreThisThrow = false;
            LogL();
            throw;
         }

         Assert.Fail("should not have gotten here");
      }


      [TestMethod]
      public void ExportSchemas_Create_2_cvdT1_dbo_tst_Test()
      {
         LogS();
         var sc = new DbScripterTestable() { AllowFileDisplay = false };

         Params p = Params.PopParams(
             prms: CovidBaseParams
            , nm: "Count1CrtSchemaTest Params"
            , xprtScrpt: ScriptFile
            , cm: CreateModeEnum.Create
            , rss: "{dbo, [ teSt]}"// should handle more than 1 schema and crappy formatting
            , rts: null            // this is overridden so that it exports all the child objects
            , displayScript: true
            );

         Assert.IsTrue(p.DisplayScript, "DisplayScript: exp true");
         Assert.IsTrue(sc.Export(ref p, out var script, out string msg), msg);
         Assert.IsTrue(sc.P.DisplayScript, "DisplayScript: exp true");
         Assert.IsTrue(ChkContains(script, @"^(CREATE SCHEMA.*)", 1, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(EXEC tSQLt\.NewTestClass 'test';)", 1, out msg), msg);
         LogL();
      }

      /// <summary>
      /// Test: that the export does not stick extra spaces in
      /// This has been an issue as supsequent export/imports will grow the trailing balanks lines in the routine text.
      /// Strategy:
      /// Export at least 1 procedure, fn, table
      /// read a sp definition
      /// export it
      /// </summary>
      [TestMethod]
      public void ExportSchemas_spaces_Test()
      {
         LogS();
         var sb = new StringBuilder();
         var scripter = new DbScripterTestable() { AllowFileDisplay = false };
         string msg;

         Params p = Params.PopParams(
             prms: CovidBaseParams
            , nm: "Count1CrtSchemaTest Params"
            , xprtScrpt: ScriptFile
            , cm: CreateModeEnum.Create
            , rss: "dbo"            // should handle more than 1 schema and crappy formatting
            , displayScript: true
            );

         scripter.Init(p, out msg);
         var db = scripter.Database;
         var svr = scripter.Server;
         StoredProcedure? proc = db.StoredProcedures["sp__jh_imp_1_csv", "dbo"];
         Urn urn = proc.Urn;
         scripter.ScriptItem(urn, sb);

         // simulate the expected script with a trailing go
         var exp_script = $"SET ANSI_NULLS ON\r\n\r\nSET QUOTED_IDENTIFIER ON\r\n\r\nGO\r\n\r\n{ proc.TextHeader}{proc.TextBody}\r\nGO\r\n";
         var act_script = sb.ToString();

         if(!exp_script.Equals(act_script))
         {
            DisplayExpActInBeyondCompare(exp_script, act_script);
            var len_exp = exp_script.Length;
            var len_act = act_script.Length;
         }

         LogL();
      }

      //------------------------------------------------------------------------------------------------------------------------------------------------------------------
      #endregion test support
      #region test setup
      //------------------------------------------------------------------------------------------------------------------------------------------------------------------

      [AssemblyInitialize]
      public new static void AssemblySetup( TestContext ctx)
      {
         LogS();
         UnitTestBase.AssemblySetup( ctx);
         LogL();
      }

      [AssemblyCleanup]
      public new static void AssemblyCleanup( )
      {
         LogS();
         UnitTestBase.AssemblyCleanup();
         LogL();
      }


      /// <summary>
      /// Use ClassInitialize to run code before running the first test in the class
      /// </summary>
      /// <param name="testContext"></param>
      [ClassInitialize()]
      public new static void ClassSetup(TestContext testContext)
      {
         LogS();
         UnitTestBase.ClassSetup(testContext); // use app config@"D\tmp\DbScriptor.log");
         LogL();
      }
      
      /// <summary>
      /// Use ClassCleanup to run code after all tests in a class have run
      /// </summary>
      [ClassCleanup()]
      public new static void ClassCleanup()
      {
         LogS();
         UnitTestBase.ClassCleanup();
         LogL();
      }

      /// <summary>
      /// Display the Script if failed and DisplayScriptAfterTestFailure is true
      /// </summary>
      protected override void TestCleanup_()
      {
         LogS();
         base.TestCleanup_();
         LogL();
      }

      #endregion test setup
      #region properties

      public Params CovidBaseParams{ get; set;} = new Params
      (
         svrNm:   @"DevI9\SQLEXPRESS"
        ,instNm:  "SQLEXPRESS"
        ,dbNm:    "Covid_T1"
      );
 

      #endregion properties
   }
}

#pragma warning restore CA1031 // Do not catch general exception types
#pragma warning restore CS8602 // Dereference of a possibly null reference.
