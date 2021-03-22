
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
      public static new string DefaultLogFile
      {
         get => DbScripter.DefaultLogFile;
         set => DbScripter.DefaultLogFile = value;
      }

      public static new string DefaultScriptDir
      {
         get => DbScripter.DefaultScriptDir;
         set => DbScripter.DefaultScriptDir = value;
      }

      public DbScripterTestable(Params? p = null)
         : base(p)
      { 
      }

      public new StringBuilder Init( Params? p, bool append = false)
      {
         return base.Init(p, append);
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

      public new void SetExportSchemaFlags()
      {
         base.SetExportSchemaFlags();
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

      public new static SqlTypeEnum MapTypeToSqlType(SqlSmoObject? smo)
      {
         return DbScripter.MapTypeToSqlType(smo);
      }

      public new void InitScriptingOptions()
      {
         base.InitScriptingOptions();
      }

      public new ScriptingOptions InitTableExport()
      { 
         return base.InitTableExport();
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

      public new static List<SqlTypeEnum> CorrectRequiredTypes( SqlTypeEnum required_type, CreateModeEnum createMode, List<SqlTypeEnum>? requiredTypesIn)
      {
         return DbScripter.CorrectRequiredTypes(required_type, createMode, requiredTypesIn);
      }

      public new static void ScriptSchemaStatements(List<string> schemaNames, StringBuilder sb)
      {
          DbScripter.ScriptSchemaStatements( schemaNames, sb);
      }

      public static new string GetLogFileFromConfig()
      {
         return DbScripter.GetLogFileFromConfig();
      }

      public static new string GetScriptDirFromConfig()
      {
         return DbScripter.GetScriptDirFromConfig();
      }

      public static new void Normalise( Params p)
      {
         DbScripter.Normalise( p);
      }
   }
}
