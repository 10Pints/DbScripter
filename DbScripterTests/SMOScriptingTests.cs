
using CommonLib;
using Microsoft.SqlServer.Management.Smo;
using System.Text.Json;
using System.Text.RegularExpressions;
using Assert = Xunit.Assert;

namespace DbScripterTests;

public partial class SMOScriptingTests : XunitTestBase, IClassFixture<SmoTestFixture>
{
   private readonly Server?   _server;
   private readonly Database? _testDb;
   private readonly dynamic   _config;


   public SMOScriptingTests(ITestOutputHelper output)
   :  base(output)
   {
      _server = SmoTestFixture.Server;
      _testDb = SmoTestFixture.TestDb;
      _server?.Databases.Refresh(); // Prevent SMO caching
      _config = LoadJsonConfig();
   }
   private dynamic LoadJsonConfig()
   {
      string path = "config.json";
      string fileContent = System.IO.File.ReadAllText(path);
      return Newtonsoft.Json.JsonConvert.DeserializeObject(fileContent) ?? throw new InvalidOperationException("Failed to deserialize JSON content.");
   }

   [Fact]
   public void CreateEntityNameTest()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("./Config/AppSettings.01.json", out string msg);
      string? x;
      x = scripter.Database.Schemas["dbo"].Urn.ToString();                // Server[@Name='DevI9']/Database[@Name='Farming_dev']/Schema[@Name='dbo']
      x = scripter.Database.Assemblies[0].Urn.ToString();                // Server[@Name='DevI9']/Database[@Name='Farming_dev']/SqlAssembly[@Name='Microsoft.SqlServer.Types']
      x = scripter.Database.UserDefinedFunctions[0].Urn.ToString();      // Server[@Name='DevI9']/Database[@Name='Farming_dev']/UserDefinedFunction[@Name='FkExists' and @Schema='dbo']
      x = scripter.Database.Tables[0].Urn.ToString();                    // Server[@Name='DevI9']/Database[@Name='Farming_dev']/Table[@Name='Action' and @Schema='dbo']
      x = scripter.Database.StoredProcedures[0].Urn.ToString();          // Server[@Name='DevI9']/Database[@Name='Farming_dev']/StoredProcedure[@Name='_main_import' and @Schema='dbo']
      x = scripter.Server?.Databases[0].Urn.ToString();                  // Server[@Name='DevI9']/Database[@Name='AdventureWorks2022']
      x = scripter.Server?.Databases[0].Triggers[0].Urn.ToString(); // Server[@Name='DevI9']/Database[@Name='AdventureWorks2022']/DdlTrigger[@Name='ddlDatabaseTriggerLog']
      x = scripter.Database.UserDefinedDataTypes[0].Urn.ToString();      // Server[@Name='DevI9']/Database[@Name='Farming_dev']/UserDefinedDataType[@Name='MyDataType' and @Schema='dbo']
      x = scripter.Database.UserDefinedTypes[0].Urn.ToString();          // Server[@Name='DevI9']/Database[@Name='Farming_dev']/UserDefinedType[@Name='Private' and @Schema='tSQLt']
      x = scripter.Database.UserDefinedTableTypes[0].Urn.ToString();     // Server[@Name='DevI9']/Database[@Name='Farming_dev']/UserDefinedTableType[@Name='ChkFldsNotNullDataType' and @Schema='dbo']
      x = scripter.Database.Views[0].Urn.ToString();                     // Server[@Name='DevI9']/Database[@Name='Farming_dev']/View[@Name='all_vw' and @Schema='dbo']

      Assert.Equal("dbo"                           , scripter.CreateEntityName(SqlTypeEnum.Schema, "sch", "dbo"));
      Assert.Equal("SQLRegEx"                      , scripter.CreateEntityName(SqlTypeEnum.Assembly, "sch", "SQLRegEx"));
      Assert.Equal("dbo.fnCompareStrings"          , scripter.CreateEntityName(SqlTypeEnum.Function, "dbo", "fnCompareStrings"));
      Assert.Equal("test.Results"                  , scripter.CreateEntityName(SqlTypeEnum.Table, "test", "Results"));
      Assert.Equal("dbo.SetCtxFixupRepCls"         , scripter.CreateEntityName(SqlTypeEnum.StoredProcedure, "dbo", "SetCtxFixupRepCls"));
      Assert.Equal("Farming_Dev"                   , scripter.CreateEntityName(SqlTypeEnum.Database, "sch", "Farming_Dev"));
      Assert.Equal("dbo.MyDataType"                , scripter.CreateEntityName(SqlTypeEnum.UserDefinedDataType, "dbo", "MyDataType"));
      Assert.Equal("tSQLtCLR.tSQLtCLR.tSQLtPrivate", scripter.CreateEntityName(SqlTypeEnum.UserDefinedType, "tSQLtCLR", "tSQLtCLR.tSQLtPrivate"));
      Assert.Equal("dbo.ChkFldsNotNullDataType"    , scripter.CreateEntityName(SqlTypeEnum.UserDefinedTableType, "dbo", "ChkFldsNotNullDataType"));
      Assert.Equal("dbo.applog_vw_asc"             , scripter.CreateEntityName(SqlTypeEnum.View, "dbo", "applog_vw_asc"));
   }

   /*
   [Fact]
   public void GetFilterUrns_when_AppSettings_01_then_17_required_items()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("AppSettings.01.json", out string msg);
      Assert.True(ret, msg);

      // Check the the non zero lists
      Dictionary<SqlTypeEnum, List<Urn>> urn_map = scripter.GetFilterUrns();
      Assert.Equal(8, urn_map.Count(x => x.Value.Count > 0));
      int cnt = 0;

      foreach (var list in urn_map.Values)
         cnt += list.Count;

      Assert.Equal(20, cnt);

      // check the WantAll flag counts
      cnt = scripter.P.WantAllMap.Count(v => v.Value == true);
      Assert.Equal(0, cnt);
   }
   */
   /*
   [Fact]
   public void GetFilterUrns_when_AppSettings_01_then_0_required_items()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("AppSettings.02.json", out string msg);
      Assert.True(ret, msg);
      Dictionary<SqlTypeEnum, List<Urn>> urn_map = scripter.GetFilterUrns();

      int cnt = 0;
      foreach (var list in urn_map.Values)
         cnt += list.Count;

      Assert.Equal(3, cnt);
   }
*/
   [Fact]
   public void DbScripterInitTest()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("./Config/AppSettings.01.json", out string msg);
      Assert.True(ret, msg);
      Assert.Equal("", msg);//, "scripter.Init msg");
   }

   [Fact]
   public void DbScripterExportTest()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("./Config/DbScripterExportTest.json", out string msg);
      Assert.True(ret, msg);
      Assert.Equal("", msg);//, "scripter.Init msg");

      ret = scripter.Export(out msg);
      Assert.True(ret, msg);
      Assert.Equal("", msg);//, "scripter.Export msg");
   }

   [Fact]
   public void CreateUrnTest_when_schema_then_ok()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("./Config/AppSettings.01.json", out string msg);
      Assert.True(ret, msg);

      var urnStr = DbScripter.CreateUrn
      (
         server: scripter.P.Server,
         db: scripter.P.Database,
         q_name: "dbo",
         type: SqlTypeEnum.Schema
      );

      Urn urn = new Urn(urnStr);
      Assert.Equal("Server[@Name='DevI9']/Database[@Name='Farming_dev']/Schema[@Name='dbo']", urnStr);
      dynamic? obj = scripter.Server?.GetSmoObject(urn);
      Assert.NotNull(obj);
      Assert.Equal("dbo", obj?.Name);
   }

   [Fact]
   public void CreateUrnTest_when_procedure_then_ok()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("./Config/AppSettings.01.json", out string msg);
      Assert.True(ret, msg);

      var urnStr = DbScripter.CreateUrn
         (
         server: "DevI9",
         db: "Farming_dev",
         q_name: "dbo.sp_assert_table_exists",
         type: SqlTypeEnum.StoredProcedure
         );

      Urn urn = new Urn(urnStr);

      Assert.Equal("Server[@Name='DevI9']/Database[@Name='Farming_dev']/StoredProcedure[@Name='sp_assert_table_exists' and @Schema='dbo']", urnStr);
      dynamic? obj = scripter.Server?.GetSmoObject(urn);
      Assert.NotNull(obj);
      Assert.Equal("sp_assert_table_exists", obj?.Name);
   }

   [Fact]
   public void CreateUrnTest_when_function_then_ok()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("./Config/AppSettings.01.json", out string msg);
      Assert.True(ret, msg);

      var urnStr = DbScripter.CreateUrn
         (
         server: scripter.P.Server,
         db: scripter.P.Database,
         q_name: "test.fnCrtScriptFileName",
         type: SqlTypeEnum.Function
         );

      Urn urn = new Urn(urnStr);

      Assert.Equal("Server[@Name='DevI9']/Database[@Name='Farming_dev']/UserDefinedFunction[@Name='fnCrtScriptFileName' and @Schema='test']", urnStr);
      dynamic? obj = scripter.Server?.GetSmoObject(urn);
      Assert.NotNull(obj);
      Assert.Equal("fnCrtScriptFileName", obj?.Name);
   }

   [Fact]
   public void CreateUrnTest_when_table_then_ok()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("./Config/AppSettings.01.json", out string msg);
      Assert.True(ret, msg);

      var urnStr = DbScripter.CreateUrn
         (
         server: scripter.P.Server,
         db: scripter.P.Database,
         q_name: "dbo.Chemical",
         type: SqlTypeEnum.Table
         );

      Urn urn = new Urn(urnStr);

      Assert.Equal("Server[@Name='DevI9']/Database[@Name='Farming_dev']/Table[@Name='Chemical' and @Schema='dbo']", urnStr);
      dynamic? obj = scripter.Server?.GetSmoObject(urn);
      Assert.NotNull(obj);
      Assert.Equal("Chemical", obj?.Name);
   }

   [Fact]
   public void CreateUrnTest_when_view_then_ok()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("./Config/AppSettings.01.json", out string msg);
      Assert.True(ret, msg);

      var urnStr = DbScripter.CreateUrn
      (
         server: scripter.P.Server,
         db: scripter.P.Database,
         q_name: "dbo.audit_vw",
         type: SqlTypeEnum.View
      );

      Urn urn = new Urn(urnStr);

      Assert.Equal("Server[@Name='DevI9']/Database[@Name='Farming_dev']/View[@Name='audit_vw' and @Schema='dbo']", urnStr);
      dynamic? obj = scripter.Server?.GetSmoObject(urn);
      Assert.NotNull(obj);
      Assert.Equal("audit_vw", obj?.Name);
   }
/*
   [Fact]
   public void GetFilterUrns_when_then_15()
   {
      DbScripter scripter = new DbScripter();
      bool ret = scripter.Init("AppSettings.GetFilterUrns_when_then_15.json", out string msg);
      Assert.True(ret, msg);
      Dictionary<SqlTypeEnum, List<Urn>> urn_map = scripter.GetFilterUrns();
      Assert.Equal(8, urn_map.Count);
      int cnt = 0;

      foreach (var list in urn_map.Values)
         cnt += list.Count;

      Assert.Equal(20, cnt);
   }
*/

   [Fact]
   public void GetUrnTypeTest()
   {
      DbScripter sc = new DbScripter();
      bool ret = sc.Init("./Config/AppSettings.GetUrnTypeTest.json", out string msg);
      Assert.True(GetUrnTypeHlpr(sc.Database.Assemblies, SqlTypeEnum.Assembly));
      Assert.True(GetUrnTypeHlpr(sc.Server.Databases, SqlTypeEnum.Database));
      Assert.True(GetUrnTypeHlpr(sc.Database.UserDefinedFunctions, SqlTypeEnum.Function));
      Assert.True(GetUrnTypeHlpr(sc.Database.StoredProcedures, SqlTypeEnum.StoredProcedure));
      Assert.True(GetUrnTypeHlpr(sc.Database.Schemas, SqlTypeEnum.Schema));
      Assert.True(GetUrnTypeHlpr(sc.Database.Tables, SqlTypeEnum.Table));
      Assert.True(GetUrnTypeHlpr(sc.Database.Views, SqlTypeEnum.View));
      Assert.True(GetUrnTypeHlpr(sc.Database.UserDefinedTypes, SqlTypeEnum.UserDefinedType));
      Assert.True(GetUrnTypeHlpr(sc.Database.UserDefinedTableTypes, SqlTypeEnum.UserDefinedTableType));
      Assert.True(GetUrnTypeHlpr(sc.Database.UserDefinedTableTypes, SqlTypeEnum.UserDefinedTableType));
   }
   /// <summary>
   /*
      "Script Dir": "D:\\Dev\\DbScripter\\Tests\\DbScripterAppTests\\ExportSqlDbUtTest",
      "Script File": "Ut.sql",
      "RequiredAssemblies": "*",
      "RequiredSchemas": "dbo,test",
      "RequiredFunctions": "*",
      "RequiredProcedures": "*",
      "RequiredTables": "*",
      "RequiredUserDefinedTypes": "*",
      "RequiredUserDefinedDataTypes": "*",
      "RequiredUserDefinedTableTypes": "*",
      "RequiredViews": "*",
      "UnwantedAssemblies": "Microsoft.SqlServer.Types",
      "UnwantedSchemas": "INFORMATION_SCHEMA,sys,tSQLt,SQL#",
      "UnwantedFunctions": "fn_diagramobjects",
      "UnwantedProcedures": "",
      "UnwantedTables": "sysdiagrams",
      "UnwantedUserDefinedDataTypes": "",
      "UnwantedUserDefinedTableTypes": "",
      "UnwantedUserDefinedTypes": "",
      "UnwantedViews": "",
    */
   /// ------------------------------------------------
   /// EXEC test.sp_GetRoutineCounts 'dbo'
   /// EXEC test.sp_GetRoutineCounts 'test'
   /// ------------------------------------------------
   /// schema functions   procedures tables   views
   /// ------------------------------------------------
   /// dbo    121	         83	       10       17
   /// test    66	        220	       11        4
   /// ------------------------------------------------
   /// All    187	        303	       21       21
   /// ------------------------------------------------
   /// </summary>
   [Fact]
   public void ExportSqlDbUtTest()
   {
      string testOutputFolder = "D:/Dev/DbScripter/Tests/DbScripterAppTests/ExportSqlDbUtTest";

      Dictionary<string, int> expFolderCntMap = new Dictionary<string, int>()
      {
         {"Misc",               17},
         {"StoredProcedures",  303},
         {"Functions",         187},
         {"Tables",             21},
         {"UserDefinedTypes",    0},
         {"Views",              21}
      };

      int ret = ret = DbScripterApp.Program.Main(new[] { "./Config/ExportSqlDbUtTest.json" });
      Assert.True(ret == 0, $"Program.Main ret: {ret}");
      Assert.True(Directory.Exists(testOutputFolder));

      // Count the numner of actuals in each folder, make sure they match ot asre greater than the expected number
      CheckScriptOutputFoldersHelper(testOutputFolder, expFolderCntMap);
   }

   /*
1 SqlAssemblys
57 UserDefinedFunctions
6 Tables
20 StoredProcedures
2 Views
   */
   //      Check the files exist
   //      functions	procedures	tables	views	assemblies
   //      108	      100	      59	      46	   1
   //       46       191         16        0
   //------------------------------------------------------
   // Exp   57         6         20        2    1
   //                [test].[sp__crt_tst_rtns]  RegEx
   //------------------------------------------------------
   // Act:   9         0          1        0    1
   //------------------------------------------------------
   //                            dbo.AppLog.sql, Regex
   //       dbo.fnGetLogLevel.sql
   //       dbo.fnGetLogLevelKey.sql
   //       dbo.fnGetSessionContextAsInt.sql
   //       dbo.fnLen.sql
   //       dbo.fnLTrim.sql
   //       dbo.fnPadRight.sql
   //       dbo.fnPadRight2.sql
   //       dbo.fnRTrim.sql
   //       dbo.fnTrim.sql
   /*
    * SqlAssemblys
   DbScripter.Export()               	35 dbo UserDefinedFunctions
   DbScripter.Export()               	22 test UserDefinedFunctions
   DbScripter.Export()               	1 dbo Tables
   DbScripter.Export()               	5 test Tables
   DbScripter.Export()               	9 dbo StoredProcedures
   DbScripter.Export()               	11 test StoredProcedures
   DbScripter.Export()               	2 dbo Views[Fact]
 			dbo.fnLen
 			dbo.fnRTrim
 			dbo.fnLTrim
 			dbo.fnTrim
 			dbo.fnPadRight2
 			dbo.fnPadRight
 			dbo.fnGetLogLevelKey
 			dbo.fnGetSessionContextAsInt
 			dbo.fnGetLogLevel
 			dbo.fnAggregateMsgs
 			dbo.fnIsLessThan
 			dbo.fnMin
 			dbo.fnRTrim2
 			dbo.fnLTrim2
 			dbo.fnTrim2
 			dbo.fnGetFullTypeName
 			dbo.fnGetFnOutputCols
 			dbo.fnGetTyNmFrmTyCode
 			dbo.fnMax
 			dbo.fnIsTextType
 			dbo.fnIsFloatType
 			dbo.fnIsGuidType
 			dbo.fnIsIntType
 			dbo.fnIsTimeType
 			dbo.fnGetTypeCat
 			dbo.fnIsBoolType
 			dbo.fnChkEquals
 			dbo.fnDeSquareBracket
 			dbo.fnSplitQualifiedName
 			dbo.fnGetRtnDetails
 			dbo.fnFileExists
 			dbo.fnGetRtnDef
 			dbo.fnPadLeft2
 			dbo.fnPadLeft
 			dbo.fnGetNTabs
 		schema: test
 			test.fnGetNxtTstRtnNum
 			test.fnCreateTestRtnName
 			test.fnGetParamWithSuffix
 			test.fnCrtMnCodeCallHlprPrms
 			test.fnCrtMnCodeCallHlpr
 			test.fnGetRtnDesc
 			test.fnCrtCodeTstHdr
 			test.fnCrtCodeMnTstSig
 			test.fnCrtMnCodeClose
 			test.fnCrtHlprCodeDeclActParams
 			test.fnCrtHlprCodeDeclCoreParams
 			test.fnCrtHlprCodeDecl
 			test.fnCrtHlprLogParams
 			test.fnCrtHlprCodeBegin
 			test.fnCrtHlprCodeCallProc
 			test.fnCrtHlprCodeChkExps
 			test.fnCrtHlprCodeCallFn
 			test.fnCrtHlprCodeCallTF
 			test.fnCrtHlprCodeCallBloc
 			test.fnCrtHlprSigParams
 			test.fnCrtHlprCodeHlprSig
 			test.fnCrtHlprCodeCloseBloc
 	2 Tables:
 		schema: dbo
 			dbo.AppLog
 		schema: test
 			test.sp_first_result_col_info
 			test.ParamDetails
 			test.RtnDetails
 			test.TstDef
 			test.HlprDef
 	2 StoredProcedures:
 		schema: dbo
 			dbo.sp_log
 			dbo.sp_raise_exception
 			dbo.sp_assert_gtr_than
 			dbo.sp_assert_not_null_or_empty
 			dbo.sp_log_exception
 			dbo.sp_assert_equal
 			dbo.sp_assert_not_equal
 			dbo.sp_assert_tbl_pop
 			dbo.sp_assert_file_exists
 		schema: test
 			test.sp_pop_param_details
 			test.sp_pop_rtn_details
 			test.sp_set_rtn_details
 			test.sp_crt_tst_rtns_init
 			test.sp_save_mn_script_file
 			test.sp_crt_tst_mn_script
 			test.sp_crt_tst_mn
 			test.sp_crt_tst_hlpr_script
 			test.sp_crt_hlpr_script_file
 			test.sp_crt_tst_hlpr
 			test.sp__crt_tst_rtns
 	1 Views:
 		schema: dbo
 			dbo.SysRtnPrms_vw
 			dbo.SysRtns_vw
   
   250729: created script for test.sp__crt_tst_rtns
   Errors: 2
   1 script  has 1 syntax error: 1 function is missing a go statement:
SET QUOTED_IDENTIFIER ON
   >>>>>> needs a go statement here
-- ======================================================
-- Author:      Terry Watts
-- Create date: 16-Dec-2023
-- Description: encapsulates the helper header comment
-- 05 Create the test rtn Header->fnCrtHlprCodeTstHdr
--
-- PRECONDITIONS: test.RtnDetails pop'd
-- ======================================================
CREATE FUNCTION [test].[fnCrtCodeTstHdr]( @is_hlpr      BIT = 1)

It only does it for this function??

   2: the following routines are missing:
      helper:
         missing object 'test.sp_tst_hlpr_st'
         missing object 'tSQLt.AssertIsSubString'
         missing object 'test.sp_tst_hlpr_hndl_failure'
         missing object 'test.sp_tst_hlpr_hndl_success'
      main:
        missing object 'test.sp_tst_mn_st'
        missing object 'test.sp_tst_mn_cls'

    */
   [Fact]
   public void AppExportTest()
   {
      string path = @"D:/Dev/DbScripter/Tests/DbScripterTests/AppExportTest";
      string config_file = @".\Config\AppExport.json";
      string[] args = new[] { config_file };
      var ret = DbScripterApp.Program.Main(args);
      Assert.Equal(0, ret);

      // 1. Read the jason to get the settings
      // 2. Parse JSON
      string jsonContent = File.ReadAllText(config_file);
      using JsonDocument doc = JsonDocument.Parse(jsonContent);

      JsonElement appSettings = doc.RootElement.GetProperty("appSettings");
      string? scriptDir = appSettings.GetProperty("Script Dir").GetString();
      Assert.True(scriptDir != null, "scriptDir should not be null");
      string? scriptFile = appSettings.GetProperty("Script File").GetString();
      Assert.True(scriptDir != null, "scriptFile should not be null");

      // 4. Process the found item
      string? outputFile = Path.Combine(scriptDir, scriptFile);

      Assert.True(File.Exists(outputFile), $"output file {outputFile} does not exist");

      //-------------------------------
      // Assertion outputFile exists
      //-------------------------------

      // 4. Read the output file to a string;
      string mainSql = File.ReadAllText(outputFile);
      string msg;
      // first check the existence of certain routines in the main export file and also the relevant subfolder
      Assert.True(ChkItemScripted("tSQLt.AssertIsSubString", SqlTypeEnum.StoredProcedure, scriptDir, mainSql, out msg), msg);
      Assert.True(ChkItemScripted("test.sp_tst_hlpr_hndl_failure", SqlTypeEnum.StoredProcedure, scriptDir, mainSql, out msg), msg);
      Assert.True(ChkItemScripted("test.sp_tst_hlpr_hndl_success", SqlTypeEnum.StoredProcedure, scriptDir, mainSql, out msg), msg);

      Dictionary<string, int> expFolderCntMap = new Dictionary<string, int>()
      {
         {"Functions",          85},
         {"Misc",               2},
         {"StoredProcedures",   44},
         {"Tables",              7},
         {"UserDefinedTypes",   0},
         {"Views",              2}
      };

      // Count the numner of actuals in each folder, make sure they match ot asre greater than the expected number
      Assert.True(Directory.Exists(path));

      CheckScriptOutputFoldersHelper(path, expFolderCntMap);
   }

   /// <summary>
   /// This checks that the item exists in both the main script and as a file the type subfolder.
   /// </summary>
   /// <param name="item_nm">Schema qualified name like dbo.fnX</param>
   /// <param name="type">The SqlTypeEnum type of the item</param>
   /// <returns></returns>
   /// <exception cref="NotImplementedException"></exception>
   private bool ChkItemScripted(string q_item_nm, SqlTypeEnum type, string scriptDir, string mainScript, out string msg)
   {
      msg = "";
      Dictionary<SqlTypeEnum, string> folderMap = new Dictionary<SqlTypeEnum, string>()
      {
         {SqlTypeEnum.Assembly,"Misc"},
         {SqlTypeEnum.StoredProcedure, "StoredProcedures"},
         {SqlTypeEnum.Function, "Functions"},
         {SqlTypeEnum.Table, "Tables"},
         {SqlTypeEnum.UserDefinedTableType, "UserDefinedTypes"},
         {SqlTypeEnum.View, "Views"}
      };

      bool ret = false;
      do
      {
         // 1. check the main script
         // Search for a line like ^CREATE[ +]type name[ +]\[schema\]\.\[item_nm\].*

         string pattern;
         string schema, name;
         string typeName = type.GetAlias();
         var parts = q_item_nm.Split('.');

         if (parts.Length != 2)
         {
            msg = $"expected {q_item_nm} to be like <schema>.<name>";
            break;
         }

         schema = parts[0];
         name = parts[1];

         // ASSERTION: we have the name and schema 

         pattern = $@"^CREATE[ +]{typeName}[ +]\[{schema}\]\.\[{name}\].*";
         MatchCollection? matches = Regex.Matches(mainScript, pattern, RegexOptions.Multiline | RegexOptions.IgnoreCase);
         int numMatches = matches?.Count ?? 0;

         if (numMatches == 0)
         {
            msg = $"did not find the create sql for {q_item_nm} in the main script";
            break;
         }

         // ASSERTION: we have the found the CREATE sql for this item in the main script

         // 2. Look for the existance of an individual no empty script file in the sub folder
         Assert.True(folderMap.TryGetValue(type, out string? subFolder), $"failed to get {type.GetAlias()} subfolder");
         string path = Path.Combine(scriptDir, subFolder, $"{schema}.{name}.sql");

         if (!File.Exists(path))
         {
            msg = $"file {path} does not exist";
            break;
         }

         var contents = File.ReadAllText(path);

         if (contents.Length < 50)
         {
            msg = $"The file {path}.sql exists but is not correct (too short)";
            break;
         }

         // Finally
         ret = true;
      } while (false);

      Assert.True(ret == true || msg.Length > 0, "ChkItemScripted postcondition either succeeded or error message returned");
      return ret;
   }

   [Fact]
   public void ExportTestCrtRtns_When_Expect_45()
   {
      string[] args = new[] { "./Config/ExportTestCrtRtns_When_Expect_45.json" };
      var ret = DbScripterApp.Program.Main(args);

      Assert.True(ret == 0, $"Program.Main ret: {ret}");
   }

   [Fact]
   public void Exportsp_crt_pop_table()
   {
      string[] args = new[] { "./Config/Exportsp_crt_pop_table.json" };
      var ret = DbScripterApp.Program.Main(args);
      Assert.True(ret == 0, $"Program.Main ret: {ret}");
   }

   private static bool GetUrnTypeHlpr(dynamic dbColl, SqlTypeEnum exp_ty)
   {
      Urn urn = dbColl?[0].Urn ?? new Urn();
      //Urn urn = DbScripter.CreateUrn(server, database, q_name, exp_ty);
      SqlTypeEnum type = DbScripter.GetUrnType(urn);
      return exp_ty == type;
   }
}
