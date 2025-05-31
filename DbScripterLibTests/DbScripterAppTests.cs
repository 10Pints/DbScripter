using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DbScripterLibTests
{
   using System;
   using Microsoft.VisualStudio.TestTools.UnitTesting;
   using Microsoft.SqlServer.Management.Smo;
   using System.Configuration;
   using System.IO;
   using CommonLib; //Common;
   using static CommonLib.Logger;
   using static CommonLib.Utils;
   using System.Text;
   using Microsoft.SqlServer.Management.Sdk.Sfc;
   using UnitTestBaseLib;
   using global::RSS.Test;
   using DbScripterAppNS;
   using DbScripterLibNS;
   using static System.Net.WebRequestMethods;

   [TestClass]
   public class DbScripterAppTests : ScriptableUnitTestBase
   {
      //------------------------------------------------------------------------------------------
      #region tests

      /// <summary>
      /// Test config:
      /// "Name"           : "DbScripterLib_Tests1 config",
      /// "FilePath"       : "D:\\Dev\\DbScripter\\DbScripterLibTests\\AppSettings_test1.json",
      /// "Server"         : "DEVI9",
      /// "Instance"       : "",
      /// "Database"       : "Farming_dev",
      /// "Script Dir"     : "D:\\Dev\\DbScripter\\DbScripterLibTests\\Scripts",
      /// "Script File"    : "Farming_dev schema.sql",
      /// "CreateMode"     : "Alter",
      /// "RequiredSchemas": "dbo",
      /// "RequiredTypes"  : "Schema,Tables,Procedures,Functions,Views",
      /// "AddTimestamp"   : "true",
      /// "ScriptUseDb"    : "true",
      /// "DisplayScript"  : "true",
      /// "DisplayLog"     : "true",
      /// "LogFile"        : "D:\\Logs\\Farming.log",
      /// "LogLevel"       : "INFO",
      /// "IsExportingData": "false"
      /// "IndividualFiles": "true"
      /// </summary>
      [TestMethod]
      public void AppMainTest1()
      {
         LogS();
         //--------------------------------------------------------
         // Setup
         //--------------------------------------------------------
         string[] args = new string[1];
         args[0] = "AppSettings_test1.json";
         // Delete expected output files before the test run

         // Run the app with this config
         int rc = Program.Main(args);

         // Test
         //string script = File.ReadAllText();
         Assert.AreEqual(0, rc);
         LogL();
      }

      /// <summary>
      /// --------------------------------------------------------------------------------
      /// Type            : Params
      /// Name            : DbScripter config
      /// --------------------------------------------------------------------------------
      /// Name            : DbScripterLibTests config
      /// FileName        : D:\Dev\DbScripter\DbScripterLibTests\AppSettings.json
      /// Server          : DEVI9\SQLEXPRESS
      /// Instance        : SQLExpress
      /// Database        : Farming_dev
      /// Timestamp       : 240921-1329
      /// 
      /// RequiredSchemas : 1
      /// dbo
      /// 
      /// RequiredTypes : 1
      /// 
      ///   Schema
      /// 
      /// CreateMode      : Alter
      /// ScriptUseDb     : True
      /// AddTimestamp    : True
      /// IsExprtngData   : False
      /// DisplayScript   : True
      /// DisplayLog      : True
      /// LogLevel        : Info
      /// --------------------------------------------------------------------------------
      /// </summary>
      [TestMethod]
      public void InitTest()
      {
         LogS();
         // ?? what is the configuration?

         //--------------------------------------------------------
         // Setup
         //--------------------------------------------------------
         string[] args = new string[1];
         args[0] = "AppSettings_test1.json";

         // Test
         bool flag = Program.Init(args, out Params p, out string? msg);
         Assert.AreEqual(true, flag);
         Assert.AreEqual(0, msg?.Length ?? -1);

         //--------------------------------------------------------
         // Check the configuration
         //--------------------------------------------------------
         Assert.AreEqual("DbScripterLib_Tests1 config", p.Name); // was false
         Assert.AreEqual("D:\\Dev\\DbScripter\\DbScripterLibTests\\AppSettings_test1.json", p.FilePath); // was false
         Assert.AreEqual(true, p.AddTimestamp); // was false
         Assert.AreEqual(CreateModeEnum.Alter, p.CreateMode); // was Create
         Assert.AreEqual(p.Database, "Farming_dev");
         Assert.AreEqual(false, p.DisplayLog);
         Assert.AreEqual(false, p.DisplayScript);
         Assert.AreEqual(true, p.IsValid(out msg));
         Assert.AreEqual(false, p.IsExportingData);
         Assert.AreEqual("", p.Instance);
         Assert.AreEqual($"D:\\Logs\\Farming_{p.Timestamp}.log",  p.LogFile);
         Assert.AreEqual(LogLevel.Info,p.LogLevel);
         Assert.AreEqual(1, p.RequiredSchemas?.Count ?? 0);
         Assert.AreEqual("dbo", p.RequiredSchemas?[0] ?? "");
         Assert.AreEqual("D:\\Dev\\DbScripter\\DbScripterLibTests\\Scripts", p.ScriptDir);
         Assert.AreEqual($"D:\\Dev\\DbScripter\\DbScripterLibTests\\Scripts\\Farming_dev schema_{p.Timestamp}.sql", p.ScriptFile);
         Assert.AreEqual(true, p.ScriptUseDb);
         Assert.AreEqual("DEVI9", p.Server);
         Assert.AreEqual(5, p.RequiredTypes?.Count ?? 0);
         Assert.AreEqual(SqlTypeEnum.Schema, p.RequiredTypes?[0] ?? SqlTypeEnum.Undefined);

         //--------------------------------------------------------
         // Completed tests
         //--------------------------------------------------------
         LogL("All Init() Tests passed");
      }

      #endregion tests
      //------------------------------------------------------------------------------------------
   }
}
