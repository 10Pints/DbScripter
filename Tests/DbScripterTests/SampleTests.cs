using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DbScripterTests;

using Microsoft.VisualStudio.TestPlatform.Utilities;

using Xunit;
using Xunit.Abstractions;

/// <summary>
/// https://xunit.net/docs/capturing-output
/// </summary>
public class SampleTests// : XunitTestBase
{
   public SampleTests(ITestOutputHelper output)
//      base(null)
   {
   }
}
/*

   public void Dispose()
   {
      // Do "global" teardown here; Called after every test method.
   }

   [Fact]
   public void Should_Add_Two_Numbers()
   {
      //Console.SetOut(new ConsoleWriter(output));
      Console.WriteLine("Running Should_Add_Two_Numbers() test ...");
      var result = 1 + 1;
      Assert.Equal(2, result);
   }

   public class ConsoleWriter : StringWriter
   {
      private ITestOutputHelper output;
      public ConsoleWriter(ITestOutputHelper output)
      {
         this.output = output;
      }

      public override void WriteLine(string? m)
      {
         output.WriteLine(m);
      }
   }
}
*/
