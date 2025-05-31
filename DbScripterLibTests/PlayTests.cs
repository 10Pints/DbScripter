using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using DbScripterLibNS;
using static CommonLib.Logger;
using static CommonLib.Utils;
using Microsoft.Extensions.Configuration;
// Using C# with SMO to script table modifications
using Microsoft.SqlServer.Management.Smo;
using System.Collections.Specialized;

namespace DbScripterLibTests
{
   [TestClass]
   public class PlayTests
   {
      [TestMethod]
      public void ScriptPerFileTest() 
      {
         LogS();
         // Connect to server
         Server server = new Server("DEVI9");
         Database database = server.Databases["Dorsu_Dev"];
         Table table = database.Tables["Semester"];

         // Create scripting options
         ScriptingOptions options = new ScriptingOptions();
         options.ScriptDrops = false;           // Don't include DROP statements
         options.IncludeIfNotExists = true;     // Use IF NOT EXISTS
         options.ClusteredIndexes = true;       // Include clustered indexes
         options.Default = true;                // Include defaults
         //options.DriAll = true;                 // Include all constraints
         options.Indexes = true;                // Include indexes
         options.ClusteredIndexes = true;    // Include non-clustered indexes
         options.NonClusteredIndexes = true;    // Include non-clustered indexes
         options.Triggers = true;               // Include triggers
         options.AllowSystemObjects = false;
         options.AnsiFile = true;
         options.AppendToFile = false;
         options.IncludeDatabaseContext = true;
         options.WithDependencies = false;  // Set to true only if needed
         options.IncludeHeaders = true;
         options.ToFileOnly     = false;
         options.SchemaQualify  = true;
         options.ScriptForAlter = true; //# This is important!
         options.ScriptForCreateOrAlter = true;
         //options.ScriptForAlter = true;

         // Generate ALTER scripts instead of DROP/CREATE
         StringCollection alterScripts = table.Script(options);

         // Use the scripts as needed
         /*
         foreach (string? script in alterScripts)
         {
            Console.WriteLine(script);
            // Or execute: database.ExecuteNonQuery(script);
         }*/

         using (var writer = new StreamWriter("test_script.sql"))
         {
            foreach (string? script in alterScripts)
            {
               writer.WriteLine(script);
            }
         }

         LogL();
      }
   }
}
