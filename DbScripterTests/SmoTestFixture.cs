using Microsoft.SqlServer.Management.Smo;

using Serilog;

namespace DbScripterTests
{
   public class SmoTestFixture : IDisposable
   {
      public Server Server { get; private set; }
      public Database TestDb { get; private set; }
      private readonly ITestOutputHelper _output;

      public SmoTestFixture(ITestOutputHelper output)
      {
         _output = output;
         try
         {
            Log.Verbose("Initializing Server with LocalDB...");
            _output.WriteLine("Initializing Server with LocalDB...");
            Server = new Server("(localdb)\\MSSQLLocalDB");
            Server.ConnectionContext.ConnectTimeout = 60;
            Log.Verbose("Testing connection...");
            _output.WriteLine("Testing connection...");
            Server.ConnectionContext.Connect(); // Explicitly connect to catch issues early
            Log.Verbose("Server initialized. Creating Database object...");
            _output.WriteLine("Server initialized. Creating Database object...");
            TestDb = new Database(Server, "TestSmoDb");
            Log.Verbose("Database object created.");
            _output.WriteLine("Database object created.");

            if (Server.Databases.Contains("TestSmoDb"))
            {
               Log.Verbose("Dropping existing TestSmoDb...");
               _output.WriteLine("Dropping existing TestSmoDb...");
               TestDb.Drop();
            }

            Log.Verbose("Creating TestSmoDb...");
            _output.WriteLine("Creating TestSmoDb...");
            TestDb.Create();
            string setupScriptPath = Path.Combine(AppContext.BaseDirectory, "Setup", "Test01Db.sql");
            Log.Verbose("Reading setup script from {Path}", setupScriptPath);
            _output.WriteLine($"Reading setup script from {setupScriptPath}...");
            string setupScript = File.ReadAllText(setupScriptPath);
            Log.Verbose("Executing setup script...");
            _output.WriteLine("Executing setup script...");
            foreach (string batch in setupScript.Split(new[] { "GO" }, StringSplitOptions.RemoveEmptyEntries))
            {
               if (!string.IsNullOrWhiteSpace(batch))
                  Server.ConnectionContext.ExecuteNonQuery(batch.Trim());
            }
            Log.Verbose("Created and initialized test database: TestSmoDb");
            _output.WriteLine("Created and initialized test database: TestSmoDb");
         }
         catch (Exception ex)
         {
            var errorMessage = $"SmoTestFixture setup failed: {ex.GetType().FullName}\nMessage: {ex.Message}\nStackTrace: {ex.StackTrace}";
            if (ex.InnerException != null)
               errorMessage += $"\nInner Exception: {ex.InnerException.Message}";
            Log.Error(ex, errorMessage);
            _output.WriteLine(errorMessage);
            throw;
         }
      }

      public void Dispose()
      {
         try
         {
            if (TestDb != null && Server.Databases.Contains("TestSmoDb"))
            {
               Log.Verbose("Dropping TestSmoDb in Dispose...");
               _output.WriteLine("Dropping TestSmoDb in Dispose...");
               TestDb.Drop();
            }
            if (Server?.ConnectionContext.IsOpen == true)
            {
               Log.Verbose("Disconnecting server...");
               _output.WriteLine("Disconnecting server...");
               Server.ConnectionContext.Disconnect();
            }
         }
         catch (Exception ex)
         {
            Log.Error(ex, "SmoTestFixture dispose failed: {Message}", ex.Message);
            _output.WriteLine($"SmoTestFixture dispose failed: {ex.Message}");
         }
      }
   }
}