
//using DbScripterApp;
//using Xunit;
//using Xunit.Abstractions;
//using Assert = Xunit.Assert;

namespace DbScripterTests;

public class DbScripterAppTests : IDisposable
{
   private readonly ITestOutputHelper _output;

   public DbScripterAppTests(ITestOutputHelper output)
   {
      File.Delete("D:\\Dev\\DbScripter\\DbScripterLibTests\\Scripts\\Farming_dev schema.sql");
      Xunit.Assert.False(File.Exists("D:\\Dev\\DbScripter\\DbScripterLibTests\\Scripts\\Farming_dev schema.sql"));
      _output = output;
      _output.WriteLine("Setup!");
   }

   [Fact]
   // [TestCategory("LongRunning")]
   // [Ignore("Skipping long-running test")]
   public void AppExportTest()
   {
      string[] args = new[] { "AppSettings.DbScripterAppTests.json" };
      var ret = DbScripterApp.Program.Main(args);

      Assert.True(ret == 0, $"Program.Main ret: {ret}");
   }

   [Fact]
   // [TestCategory("LongRunning")]
   // [Ignore("Skipping long-running test")]
   public void ExportTestCrtRtns_When_Expect_45()
   {
      string[] args = new[] { "ExportTestCrtRtns_When_Expect_45.json" };
      var ret = DbScripterApp.Program.Main(args);

      Assert.True(ret == 0, $"Program.Main ret: {ret}");
   }

   [Fact]
   // [TestCategory("LongRunning")]
   // [Ignore("Skipping long-running test")]
   public void Exportsp_crt_pop_table()
   {
      string[] args = new[] { "Exportsp_crt_pop_table.json" };
      var ret = DbScripterApp.Program.Main(args);
      Assert.True(ret == 0, $"Program.Main ret: {ret}");
   }

   public void Dispose()
   {
      // Do "global" teardown here; Called after every test method.
   }
}
