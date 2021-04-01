#nullable enable

using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using DbScripterLibNS;
using Microsoft.SqlServer.Management.Smo;
using System.Diagnostics;
using RSS.Common;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.IO;
using TestHelpers;
using static RSS.Common.Logger;
using static RSS.Common.Utils;

namespace RSS.Test
{
   [TestClass]
   public class DbScriptorTests : ScriptableUnitTestBase
   {
      #region tests

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
      public void GetLogFileFromConfigTest()
      {
         LogS();
         var logKey = "Log Dir";
         // Get the config appsettings and default log file values
         // Ensure are non empty and different
         var origConfigLogFileProperty  = ConfigurationManager.AppSettings.Get(logKey);
         var origDefaultLogFileProperty = Params.DefaultLogFile; //Property;
         var configuration = System.Configuration.ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

         try
         {
            var configLogFileProperty  = ConfigurationManager.AppSettings.Get(logKey);
            // Cache and replace later
            // Ensure different
            ParamsTestable.DefaultLogFile = "test value";
            var defaultLogFileProperty = Params.DefaultLogFile; //Property;
            Assert.IsFalse(string.IsNullOrEmpty(configLogFileProperty));
            Assert.IsFalse(string.IsNullOrEmpty(defaultLogFileProperty));
            Assert.IsFalse(configLogFileProperty.Equals(defaultLogFileProperty, StringComparison.OrdinalIgnoreCase));

            // 1: Call the method GetLogFileFromConfig via DbScripterTestable and compare its return
            // Should match the config app settings value
            var act = Params.GetLogFileFromConfig();
            Assert.IsTrue(configLogFileProperty.Equals(act, StringComparison.OrdinalIgnoreCase));

            // 2: Remove the app settings value
            configuration.AppSettings.Settings.Remove(logKey);
            configuration.Save(ConfigurationSaveMode.Modified);
            ConfigurationManager.RefreshSection( "appSettings" );
            //ConfigurationManager.AppSettings.Remove(logKey);

            // Verify it has been removed
            configLogFileProperty = ConfigurationManager.AppSettings.Get(logKey);
            Assert.IsNull(configLogFileProperty);

            // Call the method GetLogFileFromConfig via DbScripterTestable and compare its return
            act = Params.GetLogFileFromConfig();
            // Should match the default log file property
            Assert.IsTrue(defaultLogFileProperty.Equals(act, StringComparison.OrdinalIgnoreCase));

            // 3: Replace the App settings value
            //ConfigurationManager.AppSettings.Set(logKey, configLogFileProperty);
            configuration.AppSettings.Settings.Add(logKey, origConfigLogFileProperty);
            configuration.Save(ConfigurationSaveMode.Modified);
            // Verify it has been replaced
            ConfigurationManager.RefreshSection( "appSettings" );
            Assert.IsTrue(origConfigLogFileProperty.Equals(ConfigurationManager.AppSettings.Get(logKey)));
         }
         catch(Exception e)
         {
            LogException(e);
         }
         finally
         {
            ParamsTestable.DefaultLogFile = origDefaultLogFileProperty;
            var currentVal = configuration.AppSettings.Settings[logKey].Value;

            if((currentVal == null) || (!currentVal.Equals(origConfigLogFileProperty)))
            {
               // ASSERTION: need to reset config state
               if(configuration.AppSettings.Settings[logKey] != null)
                  configuration.AppSettings.Settings.Remove(logKey);

               configuration.AppSettings.Settings.Add(logKey, origConfigLogFileProperty);

               configuration.Save(ConfigurationSaveMode.Modified);
               ConfigurationManager.RefreshSection( "appSettings" );
               Assert.IsTrue(origConfigLogFileProperty.Equals(ConfigurationManager.AppSettings.Get(logKey)));
            }
         }

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
         string msg;
         DbScripter sc = new DbScripter();
         // 1 off for this test - reset in test cleanup_
         DisplayLogAfterTestFailure    = true;
         DisplayScriptAfterTestFailure = true;

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,databaseName     : "ut"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Alter
            ,requiredSchemas  : "{dbo}"
            ,requiredTypes    : null
            ,logFile          : @"D:\Logs\DbScripter.log"
            ,scriptUseDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);

         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");
         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE"     , ""    , 0,  53,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION"      , ""    , 0,  70,  0, out msg), msg);
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
         string msg;
         DbScripter sc = new DbScripter();
         // 1 off for this test - reset in test cleanup_
         DisplayLogAfterTestFailure    = true;
         DisplayScriptAfterTestFailure = true;

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,databaseName     : "ut"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Alter
            ,requiredSchemas  : "{dbo,test}"
            ,requiredTypes    : null
            ,logFile          : @"D:\Logs\DbScripter.log"
            ,scriptUseDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);

         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");
         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE", ""    , 0,  53,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION" , ""    , 0,  70,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"    , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"     , ""    , 0,  10,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE" , ""    , 0,   0,  0, out msg), msg);

         Assert.IsTrue(CheckForSchema( script, "test" , "PROCEDURE", ""    , 0, 100,  0, out msg), msg);
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
         string msg;
         DbScripter sc = new DbScripter();

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,databaseName     : "ut"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Alter
            ,requiredSchemas  : "{test}"
            ,requiredTypes    : null
            ,logFile          : @"D:\Logs\DbScripter.log"
            ,scriptUseDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);

         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");
         Assert.IsTrue(CheckForSchema( script, "test" , "PROCEDURE", ""    , 0, 100,  0, out msg), msg);
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
         string msg;
         DbScripter sc = new DbScripter();
         // 1 off for this test - reset in test cleanup_
         DisplayLogAfterTestFailure    = true;
         DisplayScriptAfterTestFailure = true;

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,databaseName     : "Covid_T1"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Alter
            ,requiredSchemas  : "{dbo}"
            ,requiredTypes    : null
            ,logFile          : @"D:\Logs\DbScripter.log"
            ,scriptUseDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);

         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");
         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE"     , ""    , 0,  40,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION"      , ""    , 0,  20,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"         , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"          , ""    , 0,  12,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE"      , ""    , 0,   0,  0, out msg), msg);

         // More detailed check on the lists - the 5 viewa
         Assert.IsTrue(sc.ExportedViews.ContainsKey("dbo.countryVw"));
         Assert.IsTrue(sc.ExportedViews.ContainsKey("dbo.owidVw"));
         Assert.IsTrue(sc.ExportedViews.ContainsKey("dbo.sysTablesVw"));
         Assert.IsTrue(sc.ExportedViews.ContainsKey("dbo.vwJH_import_stage_1"));
         Assert.IsTrue(sc.ExportedViews.ContainsKey("dbo.vwType1"));

         Assert.AreEqual(40, sc.ExportedProcedures.Count, "ExportedProcedures");
         Assert.AreEqual(20, sc.ExportedFunctions .Count, "ExportedFunctions ");
         Assert.AreEqual( 0, sc.ExportedTables    .Count, "ExportedTables    ");
         Assert.AreEqual(12, sc.ExportedViews     .Count, "ExportedViews     ");
         Assert.AreEqual( 0, sc.ExportedTableTypes.Count, "ExportedTableTypes");
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
         string msg;
         DbScripter sc = new DbScripter();
         // TDD for this test - reset in test cleanup_

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,databaseName     : "Covid_T1"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Alter
            ,requiredSchemas  : "{test}"
            ,requiredTypes    : null
            ,logFile          : @"D:\Logs\DbScripter.log"
            ,scriptUseDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);

         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");
         Assert.IsTrue(CheckForSchema( script, "test", "PROCEDURE"     , ""    , 0,  37,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "FUNCTION"      , ""    , 0,   1,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "TABLE"         , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "VIEW"          , ""    , 0,   1,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "DATATYPE"      , ""    , 0,   0,  0, out msg), msg);

         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE"     , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION"      , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"         , ""    , 0,   0,  0, out msg), msg); // 3 tables for drop or creat - 0 for alter
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"          , ""    , 0,   0,  0, out msg), msg);
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
      public void ExportSchemas_Alter_1_cvd_dbo_Test()
      {
         LogS();
         string msg;
         DbScripter sc = new DbScripter();

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,databaseName     : "Covid"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Alter
            ,requiredSchemas  : "{dbo}"
            ,requiredTypes    : null
            ,logFile          : @"D:\Logs\DbScripter.log"
            ,scriptUseDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);
         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");

         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE", ""    , 0,   48,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION" , ""    , 0,   21,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"    , ""    , 0,    0,     0, out msg), msg); // 3 tables for drop or creat - 0 for alter
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"     , ""    , 0,   15,     0, out msg), msg);
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
         string msg;
         DbScripter sc = new DbScripter();

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,databaseName     : "Covid"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Alter
            ,requiredSchemas  : "{dbo,test}"
            ,requiredTypes    : null
            ,logFile          : @"D:\Logs\DbScripter.log"
            ,scriptUseDb      : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);
         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");

         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE", ""    , 0,   48,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "FUNCTION" , ""    , 0,   21,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TABLE"    , ""    , 0,    0,     0, out msg), msg); // 3 tables for drop or creat - 0 for alter
         Assert.IsTrue(CheckForSchema( script, "dbo" , "VIEW"     , ""    , 0,   15,     0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "DATATYPE" , ""    , 0,    0,     0, out msg), msg);

         Assert.IsTrue(CheckForSchema( script, "test", "PROCEDURE", ""    , 0,  47,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "FUNCTION" , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "TABLE"    , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "VIEW"     , ""    , 0,   0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "DATATYPE" , ""    , 0,   0,  0, out msg), msg);
         //DisplayScript();
         LogL();
      }

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
      public void CorrectRequiredTypesBadRootTest()
      {
         LogS();
         string msg;
         Assert.IsTrue (CorrectRequiredTypesHlpr(ty: SqlTypeEnum.Table, createMode: CreateModeEnum.Create, input: null, exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Table }, out msg), msg);
      }

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
      public void CorrectRequiredTypesTest()
      {
         LogS();
         string msg;

         Assert.IsTrue (CorrectRequiredTypesHlpr(ty: SqlTypeEnum.Schema, createMode: CreateModeEnum.Create, input: null,                                          exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Table }, out msg), msg);
         Assert.IsTrue (CorrectRequiredTypesHlpr(ty: SqlTypeEnum.Schema, createMode: CreateModeEnum.Create, input: new List<SqlTypeEnum>() { SqlTypeEnum.Table }, exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Table }, out msg), msg);
         Assert.IsTrue (CorrectRequiredTypesHlpr(ty: SqlTypeEnum.Schema, createMode: CreateModeEnum.Create, input: new List<SqlTypeEnum>() { SqlTypeEnum.Table }, exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Table }, out msg), msg);

         Assert.IsTrue (CorrectRequiredTypesHlpr(ty: SqlTypeEnum.Schema,createMode: CreateModeEnum.Create, input: new List<SqlTypeEnum>() { SqlTypeEnum.Table,  SqlTypeEnum.Function,  SqlTypeEnum.Procedure }
                       , exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Table, SqlTypeEnum.Function, SqlTypeEnum.Procedure, SqlTypeEnum.TableType, SqlTypeEnum.View }, out msg), msg);

         Assert.IsTrue (CorrectRequiredTypesHlpr(ty: SqlTypeEnum.Schema,createMode: CreateModeEnum.Drop, input: new List<SqlTypeEnum>() { SqlTypeEnum.Table,  SqlTypeEnum.Function,  SqlTypeEnum.Procedure }
                       , exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Table, SqlTypeEnum.Function, SqlTypeEnum.Procedure, SqlTypeEnum.TableType, SqlTypeEnum.View }, out msg), msg);

         Assert.IsTrue (CorrectRequiredTypesHlpr(ty: SqlTypeEnum.Schema,createMode: CreateModeEnum.Alter, input: new List<SqlTypeEnum>() { SqlTypeEnum.Function,  SqlTypeEnum.Procedure }
                       , exp: new List<SqlTypeEnum>(){ SqlTypeEnum.Function, SqlTypeEnum.Procedure, SqlTypeEnum.TableType, SqlTypeEnum.View }, out msg), msg);
         LogL();
      }

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
      public void CorrectRequiredTypesTestWhenSqlTypeErrorReqTypeThenExpEx()
      {
         LogS();
         Assert.IsFalse(DbScripterTestable.CorrectRequiredTypes(SqlTypeEnum.Error, CreateModeEnum.Create, new List<SqlTypeEnum>(), out _, out  var msg), msg);
         LogL();
      }

      [TestMethod]
      [ExpectedException(typeof(Exception), AllowDerivedTypes = true)]
      public void CorrectRequiredTypesTestWhenExpSchemasAndCreateModeErrorThenExpEx()
      {
         LogS();
         Assert.IsFalse(DbScripterTestable.CorrectRequiredTypes(SqlTypeEnum.Schema, CreateModeEnum.Error, new List<SqlTypeEnum>(), out _, out var msg), msg);
         LogL();
      }

      protected bool CorrectRequiredTypesHlpr(SqlTypeEnum ty, CreateModeEnum createMode, List<SqlTypeEnum>? input, List<SqlTypeEnum> exp, out string msg)
      {
         msg = "";
         bool ret = DbScripterTestable.CorrectRequiredTypes(ty, createMode, input, out var act, out msg);

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
          string msg;
        DbScripter sc = new DbScripter();

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Procedure
            ,createMode       : CreateModeEnum.Drop
            ,requiredSchemas  : "{dbo,test,tSQLt}"
            ,requiredTypes    : null
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);
         Assert.IsNotNull(script, $"export script not defined");
         Assert.IsTrue(script.Length >500, $"export script length too small {script.Length}");

         Assert.IsTrue(ChkContains(script, @"^(DROP PROCEDURE \[dbo\].*)",   40,  out msg), msg);  // dbo   : 39/39
         Assert.IsTrue(ChkContains(script, @"^(DROP PROCEDURE \[test\].*)",  37 , out msg), msg);  // test  : 45
         Assert.IsTrue(ChkContains(script, @"^(DROP PROCEDURE \[tSQLt\].*)", 94,  out msg), msg);  // tSQLt : 93
         Assert.IsTrue(ChkContains(script, @"^(DROP PROCEDURE.*)",           171, out msg), msg);  // all   : 169

         LogL();
      }

      [TestMethod]
      public void ExportFunctionsTest()
      {
         LogS();
         string msg;
         DbScripter sc = new DbScripter();

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Function
            ,createMode       : CreateModeEnum.Create
            ,requiredSchemas  : "{dbo, [ teSt], tSQLt}" // should handle more than 1 schema and crappy formatting
            ,requiredTypes    : "F"
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);
         Assert.IsNotNull(script, "Null script");
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION.*)",           57, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION \[dbo\].*)",   20, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION \[test\].*)",  1 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION \[tSQLt\].*)", 36, out msg), msg);
         LogL();
      }


      [TestMethod]
      public void ExportDatabaseTest()
      {
         LogS();
         string msg;
         DbScripter sc = new DbScripter();

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Database
            ,createMode       : CreateModeEnum.Create
            ,requiredSchemas  : "{dbo, [ teSt], tSQLt}" // should handle more than 1 schema and crappy formatting
            ,requiredTypes    : null
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE Database.*)", 1, out msg), msg);
         LogL();
      }

      [TestMethod]
      public void ExportSchemas_Create_cvd_1_tst_Test()
      {
         LogS();
         string msg;
         DbScripter sc = new DbScripter();

         // Exception thrown opening server twice: 
         // Microsoft.Data.SqlClient.resources, Version=2.0.20168.4, Culture=en-GB, PublicKeyToken=23ec7fc2d6eaa4a5' or one of its dependencies. 
         // The system cannot find the file specified."

         Params p = Params.PopParams
         (
             name             : "Count1CrtSchemaTest Params"
            ,prms             : CovidBaseParams
            ,databaseName     :  "Covid_T1"
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Create
            ,requiredSchemas  : "{test}" // should handle more than 1 schema and crappy formatting
            ,requiredTypes    : null
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);

         Assert.IsTrue(ChkContains(script, @"^(CREATE PROCEDURE \[dbo\].*)"      , 0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^([ \t]*EXEC[ \t]+tSQLt\.NewTestClass[ \t]+'test')", 1 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE.*)",                   3 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE PROCEDURE.*)",               37, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION.*)",                1 , out msg), msg);
         LogL();
      }


      // DependencyWalker.DiscoverDependencies This can fail in MS code if there is more than 1 reference to a an unresolved item like a missing stored procedure
      // as was the case in ut / when commonly used sp name was changed and not all references were updated
      // {"Item has already been added. Key in dictionary:
      // 'Server[@Name='DESKTOP-UAULS0U\\SQLEXPRESS']/Database[@Name='ut']
      // /UnresolvedEntity[@Name='sp_tst_hlpr_chk' and @Schema='test']'
      // Key being added: 'Server[@Name='DESKTOP-UAULS0U\\SQLEXPRESS']/Database[@Name='ut']/UnresolvedEntity[@Name='sp_tst_hlpr_chk' and @Schema='test']'"}
      [TestMethod]
      public void ExportSchemas_Create_ut_1_tst_Test()
      {
         LogS();
         string msg;
         DbScripter sc = new DbScripter();

         // Exception thrown opening server twice: 
         // Microsoft.Data.SqlClient.resources, Version=2.0.20168.4, Culture=en-GB, PublicKeyToken=23ec7fc2d6eaa4a5' or one of its dependencies. 
         // The system cannot find the file specified."

         Params p = Params.PopParams
         (
             name             : "Count1CrtSchemaTest Params"
            ,prms             : CovidBaseParams
            ,databaseName     : "ut"
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Create
            ,requiredSchemas  : "{test}" // should handle more than 1 schema and crappy formatting
            ,requiredTypes    : null
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);

         Assert.IsTrue(ChkContains(script, @"^(CREATE PROCEDURE \[dbo\].*)"      , 0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^([ \t]*EXEC[ \t]+tSQLt\.NewTestClass[ \t]+'test')", 1 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE.*)",                   1 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE PROCEDURE.*)",              100, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE FUNCTION.*)",               29 , out msg), msg);
         LogL();
      }

      [TestMethod]
      public void ExportSchemas_Alter_2_cvdT1_dbo_tst_Test()
      {
         LogS();
         string msg;
         DbScripter sc = new DbScripter();

         Params p = Params.PopParams
         (
             name             : "ExportSchemas_Alter_2_cvdT1_dbo_tst Params"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Alter
            ,requiredSchemas  : "{dbo,test}" // should handle more than 1 schema and crappy formatting
            ,requiredTypes    : null
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);

         // Alter schema should not create or drop the schema - it merely alters the child entities
         Assert.IsTrue(ChkContains(script, @"^(EXEC[ \t\[]+tSQLt.*NewTestClass 'test';)",       0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(EXEC[ \t]+tSQLt.*DropClass 'test';)",            0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE[ \t]+SCHEMA)",                            0 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(DROP[ \t]+SCHEMA)",                              0 , out msg), msg);
         //                                                                       crt alt drp
         Assert.IsTrue(CheckForSchema( script, "dbo" , "PROCEDURE", ""          , 0,  40, 0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "PROCEDURE", ""          , 0,  37, 0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "dbo" , "view"     , ""          , 0,  12, 0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "view"     , ""          , 0,  1,  0, out msg), msg);
          // Alter schema should not script Table child tables
         Assert.IsTrue(CheckForSchema( script, "dbo", "TABLE"     , ""          , 0,  0,  0, out msg), msg);

         // Alter schema should script FUNCTIONs
         Assert.IsTrue(CheckForSchema( script, "dbo" , "function" , ""          , 0,  20,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "function" , ""          , 0,  1,   0, out msg), msg);

         // CREATE Table data TYPE
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TYPE"     , ".*AS TABLE", 0,  0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "TYPE"     , ".*AS TABLE", 0,  0,  0, out msg), msg);

         // CREATE Table data TYPE
         Assert.IsTrue(CheckForSchema( script, "dbo" , "TYPE"     , ".*FROM"    , 0,  0,  0, out msg), msg);
         Assert.IsTrue(CheckForSchema( script, "test", "TYPE"     , ".*FROM"    , 0,  0,  0, out msg), msg);
         LogL();
      }

      protected bool CheckForSchema(string? script
         , string schema
         , string ty
         , string optional
         , int expcrt
         , int expalt
         , int expdrp
         , out string msg)
      {
         bool ret = false;

         do
         {
            // Do all 3 tests, log all results before failing
            if(!ChkContains(script, GetRegEx("create",ty, schema, optional), expcrt, out msg)) break;
            if(!ChkContains(script, GetRegEx("alter" ,ty, schema, optional), expalt, out msg)) break;
            if(!ChkContains(script, GetRegEx("drop"  ,ty, schema, optional), expdrp, out msg)) break;

            ret = true;
         } while(false);

         if(!ret)
            LogDirect("CheckForSchema failed");

         return ret;
      }

      protected string GetRegEx(string cmd, string ty, string schema, string optional="")
      {
         cmd = cmd.ToUpper();
         ty = ty.ToUpper();
         string s = $@"^[ \t]*({cmd}[ \t]+{ty}[ \t\[]+{schema}[ \t\]]+\.{optional}.*)";
         return s;
      }

      /*
       Expect a script generated that will drop 1 or more schema and its children in dependency order
       */
      [TestMethod]
      public void ExportSchemas_Drop_1_tst_Test()
      {
         LogS();
         DbScripter sc = new DbScripter();
         string msg;

         Params p = Params.PopParams
         (
             name             : "Count1CrtSchemaTest Params"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Drop
            ,requiredSchemas  : "{test}" // should handle more than 1 schema and crappy formatting
            ,requiredTypes    : "s"
         );

         Logger.Log($"params: \r\n {p}");
         
         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);

         Assert.IsTrue(ChkContains(script, @"^(DROP TABLE.*)",          3 , out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(DROP PROCEDURE.*)",      37, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(DROP FUNCTION.*)",       1 , out msg), msg);

         Assert.IsTrue(ChkContains(script, @"^(EXEC tSQLt\.DropClass 'test')", 1 , out msg), msg);

         LogL();
      }


      [TestMethod]
      public void ExportFunctionsCreateTest()
      {
         LogS();
         string msg;
         DbScripter sc = new DbScripter();

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,prms             : CovidBaseParams
            ,databaseName     : "Covid_T1"
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Function
            ,createMode       : CreateModeEnum.Create
            ,requiredSchemas  : "{dbo}"
            ,requiredTypes    : "F"
            ,isExprtngSchema  : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE Function.*)", 20, out msg), msg);
         LogL();
      }

      [TestMethod]
      public void ExportFunctionsDropTest()
      {
         LogS();
         string msg;
         DbScripter sc = new DbScripter();

         Params p = Params.PopParams
         (
             name             : "ExportDatabase Params"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Function
            ,createMode       : CreateModeEnum.Drop
            ,requiredSchemas  : "{dbo}"
            ,requiredTypes    : "F"
            ,isExprtngSchema  : true
         );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(DROP Function.*)", 20, out msg), msg);
         LogL();
      }


      [TestMethod]
      public void Count1CrtSTableTestBothExpSchemaAndExpDataNotDefinedTest()
      {
         LogS();
         DbScripter sc = new DbScripter();
         string msg;

         Params p = Params.PopParams(
             name             : "Count1CrtSchemaTest Params"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,rootType         : SqlTypeEnum.Table
            ,createMode       : CreateModeEnum.Create
            ,requiredSchemas  : "{dbo, [ teSt]}" // should handle more than 1 schema and crappy formatting
            ,requiredTypes    : "t"              // this is overridden in Export schema as it exports all the child objects
            );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE \[dbo\]\..*)"     , 21, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE TABLE \[test\]\..*)"    ,  3, out msg), msg);
         LogL();
      }

      /// <summary>
      /// 
      /// </summary>
      [TestMethod()]
      public void InitTableExportTest()
      {
         LogS();
         string msg = "";
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = Params.PopParams( 
                prms             : CovidBaseParams
               ,exportScriptPath : @"C:\temp\InitTableExportTest.sql"
               ,createMode       : CreateModeEnum.Create
               ,rootType         : SqlTypeEnum.Table
               ,requiredSchemas  : "tEst,tSqlt"
              );

         // Create and initise the scripter
         var sc   = new DbScripterTestable();
         Assert.IsTrue(sc.Init(p, out msg), msg);
         var orig = Utils.ShallowClone( sc.ScriptOptions);

         // Run the rtn
         var so = sc.InitTableExport();
         Assert.IsFalse(so.ScriptForAlter);
         Assert.IsFalse(so.ScriptForCreateOrAlter);
         Assert.IsNotNull(orig);
         LogDirect($"orig:\r\n{sc.OptionsToString(orig)}");
         LogDirect($"sc.ScriptOptions:\r\n{sc.OptionsToString(sc?.ScriptOptions )}");
         Assert.IsTrue(sc?.OptionEquals(orig, sc?.ScriptOptions ?? new(), out msg) ?? false, msg);
         LogL();
      }

      /// <summary>
      /// should not allow this combination
      /// </summary>
      [TestMethod()]
      [ExpectedException(typeof(Exception), AllowDerivedTypes = true)]
      public void InitTableExportTestEx()
      {
         LogS();
         string msg;
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = Params.PopParams( 
                prms             : CovidBaseParams
               ,exportScriptPath : @"C:\temp\InitTableExportTestEx.sql"
               ,createMode       : CreateModeEnum.Alter
               ,rootType         : SqlTypeEnum.Table
               ,requiredSchemas  : "tEst,tSqlt"
              );

         // Create and initise the scripter
         var sc = new DbScripterTestable();
          Assert.IsTrue(sc.Init(p, out msg), msg);
         // Run the rtn
         var so = sc.InitTableExport();
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
      [ExpectedException(typeof(Exception), AllowDerivedTypes = true)]
      [TestMethod()]
      public void InitScriptingOptionsTestExpEx()
      {
         LogS();
         string msg;
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = Params.PopParams( 
                prms             : CovidBaseParams
               ,exportScriptPath : @"C:\temp\T011_ExportSchemaScriptTest.sql"
               ,createMode       : CreateModeEnum.Alter
               ,rootType         : SqlTypeEnum.Table
               ,requiredSchemas  : "tEst,tSqlt"
              );
       
         var sc = new DbScripterTestable();
         Assert.IsTrue(sc.Init(p, out msg), msg);
         LogL();
      }

      [TestMethod()]
      public void InitScriptingOptionsTestExpNoEx()
      {
         LogS();
         // PRE 1: P is valid
         // POST 1: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
         Params p = Params.PopParams( 
                prms             : CovidBaseParams
               ,exportScriptPath : @"C:\temp\T011_ExportSchemaScriptTest.sql"
               ,createMode       : CreateModeEnum.Alter
               ,rootType         : SqlTypeEnum.Procedure
               ,requiredSchemas  : "tEst,tSqlt"
              );
       
         var sc = new DbScripterTestable();
         Assert.IsTrue(sc.Init(p, out var msg), msg);
         LogL();
      }

      [TestMethod()]
      public void MapTypeToSqlTypeTest()
      {
         LogS();
         Params p = Params.PopParams( 
                prms             : CovidBaseParams
               ,exportScriptPath : @"C:\temp\MapTypeToSqlTypeTest.sql"
               ,createMode       : CreateModeEnum.Create
               ,rootType         : SqlTypeEnum.Procedure
               ,requiredSchemas  : "tEst,tSqlt"
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
                   prms             : CovidBaseParams
                  ,exportScriptPath : @"C:\temp\MapTypeToSqlTypeTestUnknownTypeTest.sql"
                  ,rootType         : SqlTypeEnum.Schema
                  ,createMode       : CreateModeEnum.Create
                  ,requiredSchemas  : "tEst,tSqlt"
                 );
       
            var sc = new DbScripterTestable();
            Assert.IsTrue( sc.Init(p, out var msg), msg);
            // expect throw here
            IgnoreThisThrow = true;
            var unexpected = DbScripterTestable.MapTypeToSqlType(new UserDefinedDataType(sc.Database, "unexpected", "dbo"));
         }
         catch(Exception e)
         {
            var msg = e.GetAllMessages();
            Logger.LogException(e, $"IgnoreThisThrow: {IgnoreThisThrow}");
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
         string msg;
         DbScripter sc = new DbScripter();

         Params p = Params.PopParams(
             name             : "Count1CrtSchemaTest Params"
            ,prms             : CovidBaseParams
            ,exportScriptPath : ScriptFile
            ,newSchemaName    : null
            ,requiredSchemas  : "{dbo, [ teSt]}"// should handle more than 1 schema and crappy formatting
            ,requiredTypes    : null            // this is overridden so that it exports all the child objects
            ,rootType         : SqlTypeEnum.Schema
            ,createMode       : CreateModeEnum.Create
            );

         Assert.IsTrue(sc.Export(ref p, out var script, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(CREATE SCHEMA.*)"                  , 1, out msg), msg);
         Assert.IsTrue(ChkContains(script, @"^(EXEC tSQLt\.NewTestClass 'test';)" , 1, out msg), msg);
         LogL();
      }

      #endregion test support
      #region test setup
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
      public override void TestCleanup_()
      {
         LogS();
         base.TestCleanup_();
         LogL();
      }

      #endregion test setup
      #region properties

      public Params CovidBaseParams{ get; set;} = new Params
      (
         serverName:    @"DESKTOP-UAULS0U\SQLEXPRESS"
        ,instanceName:  "SQLEXPRESS"
        ,databaseName:  "Covid_T1"
      );
 

      #endregion properties
   }
}
