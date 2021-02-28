
using System;

namespace RSS
{
   public static class Logger
   {
      public static void Log( this string format, params object[] args )
      {

         // Write the string to a file.append mode is enabled so that the log
         // lines get appended to  test.txt than wiping content and writing the log

         //System.IO.StreamWriter file = new System.IO.StreamWriter("c:\\test.txt", true);
         writer.WriteLine(format, args);
         writer.Flush();
      }

      public static void Log( params object[] args )
      {
         // Write the string to a file.append mode is enabled so that the log
         // lines get appended to  test.txt than wiping content and writing the log

         foreach(var arg in args)
            writer.Write(arg.ToString());

         writer.WriteLine();
         writer.Flush();
      }

      public static void LogException(Exception e, string msg = "")
      {
         Log("Caught exception: ", e.Message);
      }

      public static void Open( string path )
      {
         writer.Close();
         writer = new System.IO.StreamWriter(path, true);
      }

      public static void Close()
      {
         writer.Close();
      }


      private static System.IO.StreamWriter writer = new System.IO.StreamWriter("c:\\tmp\\test.txt", true);
   }
}
