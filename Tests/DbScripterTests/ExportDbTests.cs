using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DBScripterTests;

public class ExportDbTests : IDisposable
{
   private readonly ITestOutputHelper _output;
   public ExportDbTests(ITestOutputHelper output)
   {
      //File.Delete("D:\\Dev\\DbScripter\\DbScripterLibTests\\Scripts\\Farming_dev schema.sql");
      //Xunit.Assert.False(File.Exists("D:\\Dev\\DbScripter\\DbScripterLibTests\\Scripts\\Farming_dev schema.sql"));
      _output = output;
      _output.WriteLine("Setup!");
   }

   public void Dispose()
   {
      // Do "global" teardown here; Called after every test method.
   }

}
