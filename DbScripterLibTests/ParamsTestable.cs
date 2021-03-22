
#nullable enable

using DbScripterLibNS;

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
         ,string?          logFile           = null
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
             name             : name
            ,prms             : prms
            ,serverName       : serverName
            ,instanceName     : instanceName
            ,databaseName     : databaseName
            ,exportScriptPath : exportScriptPath
            ,newSchemaName    : newSchemaName
            ,requiredSchemas  : requiredSchemas
            ,requiredTypes    : requiredTypes
            ,sqlType          : sqlType
            ,createMode       : createMode
            ,scriptUseDb      : scriptUseDb
            ,addTimestamp     : addTimestamp
            ,logFile          : logFile
            ,isExprtngData    : isExprtngData
            ,isExprtngDb      : isExprtngDb
            ,isExprtngFKeys   : isExprtngFKeys
            ,isExprtngFns     : isExprtngFns
            ,isExprtngProcs   : isExprtngProcs
            ,isExprtngSchema  : isExprtngSchema
            ,isExprtngTbls    : isExprtngTbls
            ,isExprtngTTys    : isExprtngTTys
            ,isExprtngVws     : isExprtngVws
         )
      { 
      }

      public void SetExportFlagsFromSqlType()
      {
         base.SetExportFlagsFromRootType();
      }

      public new void SetExportFlagState(bool? st = null)
      {
         base.SetExportFlagState(st);
      }
   }
}
