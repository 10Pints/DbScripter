
#nullable enable

using System;
using DbScripterLib;
using Microsoft.SqlServer.Management.Smo;


namespace RSS.Test
{
   public class DbScripterTestable : DbScripter
   {

      public DbScripterTestable(Params? p = null)
         : base(p)
      { 
      }

      public new string HandleExportFilePath(string exportFilePath, bool addTimestamp)
      {
         return base.HandleExportFilePath(exportFilePath, addTimestamp);
      }
      public override string GetTimestamp()
      { 
         return DateTime.Now.ToString("210101-0000");
      }

      public new void ClearState()
      { 
         base.ClearState();
      }
/*
      public new Server? CreateAndOpenServer( string serverName, string instance)// string databaseName )
      { 
         return base.CreateAndOpenServer(serverName, instance);//, databaseName);
      }
*/
      public new void InitWriter()
      {
         base.InitWriter();
      }

      public new bool IsWanted(string currentSchemaName, SqlSmoObject obj)
      {
         return base.IsWanted(currentSchemaName, obj);
      }

      public new bool IsTypeWanted(string typeName)
      {
         return base.IsTypeWanted(typeName);
      }

      public new void SetUndefinedExportSchemaFlags()
      {
         base.SetUndefinedExportSchemaFlags();
      }
      /// <summary>
      /// PRE:  NONE
      /// POST: all UNDEFIEND flags set true
      /// </summary>
      public void ResetUndefinedExportSchemaFlags(bool? st)
      {
         P.IsExprtngFns    = st;
         P.IsExprtngProcs  = st;
         P.IsExprtngSchema = st;
         P.IsExprtngTbls   = st;
         P.IsExprtngTTys   = st;
         P.IsExprtngVws    = st;
      }
   }
}
