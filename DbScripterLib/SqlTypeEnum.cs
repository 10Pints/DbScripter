
using RSS.Common;

namespace DbScripterLibNS
{
   /// <summary>
   /// FUNCTION,PROCEDURE,SCHEMA,TABLE,TABLE TYPE,VIEW
   /// </summary>
   public enum SqlTypeEnum
   {
      [EnumAlias("Error"     , "E"   )]
      Error = 0,                     
                                     
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
                                     
      [EnumAlias("Table Type", "TTy" )]
      TableType,

      [EnumAlias("View"      , "V"   )]
      View
   }
}
