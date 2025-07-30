
using Microsoft.SqlServer.Management.Smo;

namespace DbScripterTests;

public class DbScripterTests : XunitTestBase
{
   public DbScripterTests(ITestOutputHelper output)
   :  base(output)
   {
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

   private static bool GetUrnTypeHlpr(dynamic dbColl, SqlTypeEnum exp_ty)
   {
      Urn urn = dbColl?[0].Urn ?? new Urn();
      //Urn urn = DbScripter.CreateUrn(server, database, q_name, exp_ty);
      SqlTypeEnum type = DbScripter.GetUrnType(urn);
      return exp_ty == type;
   }
}
