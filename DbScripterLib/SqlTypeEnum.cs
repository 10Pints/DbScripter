
using CommonLib;

namespace DbScripterLibNS
{
   /// <summary>
   /// FUNCTION,PROCEDURE,SCHEMA,TABLE,TABLE TYPE,VIEW
   /// </summary>
   public enum SqlTypeEnum
   {
      [EnumAlias("Assembly", "SqlAssembly")]
      Assembly,

      [EnumAlias("Database"  , "Database")]
      Database,                      
                                     
      [EnumAlias("Function"  ,"UserDefinedFunction")]
      Function,                      
                                     
      [EnumAlias("Procedure" , "StoredProcedure")]
      StoredProcedure,                     
                                     
      [EnumAlias("Schema"    , "Schema")]
      Schema,                        
                                     
      [EnumAlias("Table"     , "Table")]
      Table,

      [EnumAlias("View", "View")]
      View,

      [EnumAlias("UserDefinedType", "UserDefinedType")]
      UserDefinedType,

      // {Server[@Name='DevI9']/Database[@Name='Farming_dev']/UserDefinedType[@Name='Private' and @Schema='tSQLt']}
      [EnumAlias("UserDefinedDataType", "UserDefinedDataType")]
      UserDefinedDataType,

      //{Server[@Name='DevI9']/Database[@Name='Farming_dev']/UserDefinedTableType[@Name='IdNmTbl' and @Schema='dbo']}
      [EnumAlias("UserDefinedTableType", "UserDefinedTableType")]
      UserDefinedTableType,
   }
}
