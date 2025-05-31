
using CommonLib;

namespace DbScripterLibNS
{
   /// <summary>
   /// FUNCTION,PROCEDURE,SCHEMA,TABLE,TABLE TYPE,VIEW
   /// </summary>
   public enum SqlTypeEnum
   {
      [EnumAlias("Error"     , "E"   )]
      Error = 0,

      [EnumAlias("Assembly",   "A", "Db")]
      Assembly,

      [EnumAlias("Database"  , "D",   "Db")]
      Database,                      
                                     
      [EnumAlias("Function"  , "F",   "UserDefinedFunction")]
      Function,                      
                                     
      [EnumAlias("Procedure" , "P",   "StoredProcedure")]
      Procedure,                     
                                     
      [EnumAlias("Schema"    , "S"   )]
      Schema,                        
                                     
      [EnumAlias("Table"     , "T"   )]
      Table,

      [EnumAlias("Trigger", "Tr")]
      Trigger,

      [EnumAlias("Table Type", "TTy" )]
      TableType,

      [EnumAlias("View", "V")]
      View,

      [EnumAlias("UserDefinedDataType", "UDDT")]
      UserDefinedDataType, // Includes UserDefinedDataType and UserDefinedTableType

      [EnumAlias("Undefined", "-")]
      Undefined
   }
}
