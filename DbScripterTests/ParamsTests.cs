namespace DbScripterTests;

public class ParamsTests : IDisposable
{
   private readonly ITestOutputHelper _output;
   //protected ConsoleWriter ConsoleWriter_ { get; set; }

   public ParamsTests(ITestOutputHelper output)
   {
      _output = output;
      //ConsoleWriter_ = new ConsoleWriter(output);
      //Console.SetOut(ConsoleWriter_);
   }

   public void Dispose()
   {
      // Do "global" teardown here; Called after every test method.
   }

   [Fact]
   public void Params01Test_when_default_then_()
   {
      LogS();
      Params.Config = new ConfigurationBuilder()
      .AddJsonFile("AppSettings.Params.01.json")
      .Build();

      Params p = new();
      Assert.True(p.LoadConfigFromFile("AppSettings.Params.01.json", out string msg), msg);

      Assert.Equal("AppSettings.Params.01", p.Name);
      Assert.True(p.Server?.Equals("DevI9") ?? false);
      Assert.Equal("", p.Instance);
      Assert.Equal("Farming_dev", p.Database);
      Assert.Equal("D:\\Dev\\DbScripter_new\\DbScripterLibTests\\Scripts", p.ScriptDir);

      Assert.Equal("D:\\Dev\\DbScripter_new\\DbScripterLibTests\\Scripts\\Farming_dev schema.sql",p.ScriptFile);
      Assert.Equal(CreateModeEnum.Create, p.CreateMode);

      Assert.Equal("Farming_dev", p.Database);

      Assert.True(ChkRequiredItems<string>(p.RequiredAssemblies, 3, "RegEx", "tSQLtCLR"));
      Assert.True(ChkRequiredItems<string>(p.RequiredSchemas, 2, "dbo","test"));
      Assert.True(ChkRequiredItems<string>(p.RequiredFunctions, 4, "[dbo].[fnFindPathogen]", "[test].[fnCrtScriptFileName]"));
      Assert.True(ChkRequiredItems<string>(p.RequiredProcedures, 2, "[dbo].[_main_import]", "[dbo].[sp_assert_table_exists]"));
      Assert.True(ChkRequiredItems<string>(p.RequiredTables, 4, "dbo.Chemical", "[test].[HlprDef]"));
      Assert.True(ChkRequiredItems<string>(p.RequiredViews, 2, "[dbo].[audit_vw]","[dbo].[ChemicalProduct_vw]"));
      Assert.True(ChkRequiredItems<string>(p.RequiredUserDefinedTypes, 1, "[tSQLt].[Private]"));//, "[tSQLt].[Private]"));
      Assert.True(ChkRequiredItems<string>(p.RequiredUserDefinedDataTypes, 1, "[dbo].[MyDataType]", "[dbo].[MyDataType]"));
      Assert.True(ChkRequiredItems<string>(p.RequiredUserDefinedTableTypes, 3, "[dbo].[ChkFldsNotNullDataType]", "[test].[CodeTbl]"));

      Assert.False(p.AddTimestamp);
      Assert.True (p.ScriptUseDb );
      Assert.True (p.DisplayScript);
      Assert.True (p.DisplayLog);
      Assert.Equal("D:\\Logs\\Farming.log", p.LogFile);
      Assert.Equal(LogLevel.Info, p.LogLevel);
      Assert.False(p.IsExportingData);
   }

   /// <summary>
   /// Loads the configuration from configFile 
   /// default: Appsettings.json
   /// uses the absolute path
   /// PRE01: (checked) All config files should have the "Name" setting set
   /// </summary>
   /// <param name="configFile"></param>
   /// <param name="msg"></param>
   /// <returns>true if loaded ok, false otherwise</returns>
   [Fact(Skip = "Skipping test")]
   public void InitTest_when_default_then_()
   {
      Params.Config = new ConfigurationBuilder()
      .AddJsonFile("AppSettings.01.json")
      .Build();

      Params p = new();
      Assert.True(p.Init("AppSettings.01.json", out string msg), msg);
      Assert.Equal(2, p.RequiredSchemas.Count);
      Assert.Equal("dbo", p.RequiredSchemas[0]);
      Assert.Equal("test", p.RequiredSchemas[1]);
   }

   [Fact(Skip = "Skipping test")]
   public void LoadConfigFromFileTest()
   {
      Params.Config = new ConfigurationBuilder()
      .AddJsonFile("appsettings.json")
      .Build();

      Params p = new();
      Assert.Empty(p.RequiredSchemas);
      Assert.True(p.LoadConfigFromFile("AppSettings.01.json", out string msg), msg);
      Assert.Equal(2, p.RequiredSchemas.Count);
      Assert.Equal("dbo", p.RequiredSchemas[0]);
      Assert.Equal("test", p.RequiredSchemas[1]);
   }

    [Fact] 
   public void LoadAssembliesTest()
   {
      //Params.Config = new ConfigurationBuilder()
      //.AddJsonFile("appsettings.01.json")
      //.Build();

      Params p = new();
      Assert.Empty(p.RequiredAssemblies);
      Assert.True(p.LoadConfigFromFile("AppSettings.01.json", out string msg), msg);
      Assert.Equal(3, p.RequiredAssemblies.Count);
      Assert.Equal("RegEx", p.RequiredAssemblies[0]);
      Assert.Equal("tSQLtCLR", p.RequiredAssemblies[2]);
   }

   [Fact(Skip = "Skipping test")]
   public void RequiredItemsTest()
   {
      Params.Config = new ConfigurationBuilder()
      .AddJsonFile("appsettings.01.json")
      .Build();

      Params p = new();
      Assert.True(p.LoadConfigFromFile("AppSettings.01.json", out string msg), msg);

      Assert.True(ChkRequiredItems<string>(p.RequiredAssemblies, 3, "RegEx", "tSQLtCLR"));
      Assert.True(ChkRequiredItems<string>(p.RequiredFunctions, 4, "[dbo].[fnFindPathogen]", "[test].[fnCrtScriptFileName]"));
      Assert.True(ChkRequiredItems<string>(p.RequiredProcedures, 2, "[dbo].[_main_import]", "[dbo].[sp_assert_table_exists]"));
      Assert.True(ChkRequiredItems<string>(p.RequiredTables, 4, "dbo.Chemical", "[test].[Cleanup]"));
      Assert.True(ChkRequiredItems<string>(p.RequiredViews, 2, "[dbo].[audit_vw]", "[dbo].[ChemicalProduct_vw]"));
   }

   private static bool ChkRequiredItems<T>(List<T> list, int cnt, T? a = default, T? b = default)
   {
      if(cnt != list.Count) return false;
      
      if(cnt==0)
         return true;

      if ((list[0]    ?.Equals(a) ?? false) == false) return false;

      if (cnt == 1)
         return true;

      if ((list[cnt-1]?.Equals(b) ?? false) == false) return false;
      return true;
   }

   [Fact(Skip = "Skipping test")]
   public void NameTest()
   {
      Params.Config = new ConfigurationBuilder()
      .AddJsonFile("appsettings.json")
      .Build();

      Params p = new();
      Assert.True(p.LoadConfigFromFile("AppSettings.01.json", out string msg), msg);
      Assert.Equal("DbScripterLibTests config", p.Name);

      //Assert.True(p.FilePath.Equals("D:\\Dev\\DbScripter_new\\DbScripterLibTests\\AppSettings.json"));
      Assert.True(p.Server?.Equals("DevI9") ?? false);
      Assert.Equal("Farming_dev", p.Database);
      Assert.Equal("D:\\Dev\\DbScripter_new\\DbScripterLibTests\\Scripts", p.ScriptDir);
      Assert.Equal("D:\\Dev\\DbScripter_new\\DbScripterLibTests\\Scripts\\Farming_dev schema.sql", p.ScriptFile);
      Assert.Equal(CreateModeEnum.Create, p.CreateMode);
      Assert.False(p.AddTimestamp);
      Assert.True(p.ScriptUseDb);
      Assert.True(p.DisplayScript);
      Assert.True(p.DisplayLog);
      Assert.Equal("D:\\Logs\\Farming.log", p.LogFile);
      Assert.Equal(LogLevel.Info, p.LogLevel);
      Assert.False(p.IsExportingData);
   }
}
