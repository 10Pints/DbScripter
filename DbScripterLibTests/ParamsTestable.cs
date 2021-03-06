
#nullable enable

using DbScripterLib;

namespace RSS.Test
{
   class ParamsTestable : Params
   {
      public ParamsTestable
      (
          string           name              = ""
         ,Params?          prms              = null // Use this state to start with and update with the subsequent parameters
         ,string?          serverName        = null
         ,string?          instanceName      = null
         ,string?          databaseName      = null
         ,string?          exportScriptPath  = null
         ,string?          newSchemaName     = null
         ,string?          requiredSchemas   = null
         ,string?          requiredTypes     = null
         ,SqlTypeEnum?     sqlType           = SqlTypeEnum     .Undefined
         ,CreateModeEnum?  createMode        = CreateModeEnum  .Undefined
         ,bool?            scriptUseDb       = null
         ,bool?            addTimestamp      = null
         ,bool?            isExprtngData     = null
         ,bool?            isExprtngDb       = null
         ,bool?            isExprtngFKeys    = null
         ,bool?            isExprtngFns      = null
         ,bool?            isExprtngProcs    = null
         ,bool?            isExprtngSchema   = null
         ,bool?            isExprtngTbls     = null
         ,bool?            isExprtngTTys     = null
         ,bool?            isExprtngVws      = null
      )
         : base
         (
             name
            ,prms
            ,serverName
            ,instanceName
            ,databaseName
            ,exportScriptPath
            ,newSchemaName
            ,requiredSchemas
            ,requiredTypes
            ,sqlType
            ,createMode
            ,scriptUseDb
            ,addTimestamp
            ,isExprtngData
            ,isExprtngDb
            ,isExprtngFKeys
            ,isExprtngFns
            ,isExprtngProcs
            ,isExprtngSchema
            ,isExprtngTbls
            ,isExprtngTTys
            ,isExprtngVws
         )
      { 
      }

      public new void SetExportFlagsFromSqlType()
      {
         base.SetExportFlagsFromSqlType();
      }

      public new void SetExportFlagState(bool? st = null)
      {
         base.SetExportFlagState(st);
      }
   }
}
