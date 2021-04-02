
#nullable enable

using System;
using System.Collections.Generic;
using System.Text;
using DbScripterLibNS;
using Microsoft.SqlServer.Management.Smo;


namespace RSS.Test
{
   public class DbScripterTestable : DbScripter
   {
      public DbScripterTestable()
         : base()
      { 
      }

      public new bool Init( Params p, out string msg, StringBuilder? sb = null)
      {
         return base.Init(p, out msg, sb);
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

      public new bool InitWriter(out string msg)
      {
         return base.InitWriter( out msg);
      }

      public new bool IsWanted(string currentSchemaName, SqlSmoObject obj)
      {
         return base.IsWanted(currentSchemaName, obj);
      }

      public new bool IsTypeWanted(string typeName)
      {
         return base.IsTypeWanted(typeName);
      }

      public new static SqlTypeEnum MapTypeToSqlType(SqlSmoObject? smo)
      {
         return DbScripter.MapTypeToSqlType(smo);
      }

      public new void InitScriptingOptions(out string msg)
      {
         base.InitScriptingOptions( out msg);
      }

      public new bool InitTableExport(out ScriptingOptions? so, out string msg)
      { 
         return base.InitTableExport(out so, out msg);
      }


      /// <summary>
      /// Determeintes if the schema is a test schema and therfpre should be creeated
      /// or dropped using the tSQLt methods
      /// </summary>
      /// <param name="schema"></param>
      /// <returns></returns>
      public static new bool IsTestSchema(string schemaName)
      { 
         return DbScripter.IsTestSchema( schemaName);
      }

      public new static bool CorrectRequiredTypes( CreateModeEnum createMode, List<SqlTypeEnum>? reqTypesIn, out List<SqlTypeEnum> reqTypesOut, out string msg)
      {
         return DbScripter.CorrectRequiredTypes(createMode, reqTypesIn, out reqTypesOut, out msg);
      }

      public new static void ScriptSchemaStatements(List<string> schemaNames, StringBuilder sb)
      {
          DbScripter.ScriptSchemaStatements( schemaNames, sb);
      }
   }
}
