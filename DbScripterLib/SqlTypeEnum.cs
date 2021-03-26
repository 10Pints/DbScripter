
using RSS.Common;

namespace DbScripterLibNS
{
   /// <summary>
   /// FUNCTION,PROCEDURE,SCHEMA,TABLE,TABLE TYPE,VIEW
   /// </summary>
   public enum SqlTypeEnum
   {
      [EnumAlias("Undefined")]
      Undefined = 0,

      [EnumAlias("Database"  , "D")]
      Database,

      [EnumAlias("Function"  , "F")]
      Function,

      [EnumAlias("Procedure" , "P")]
      Procedure,

      [EnumAlias("Schema"    , "S")]
      Schema,

      [EnumAlias("Table"     , "T")]
      Table,

      [EnumAlias("Table Type", "TTy")]
      TableType,

      [EnumAlias("View"      , "V")]
      View
   }
}
