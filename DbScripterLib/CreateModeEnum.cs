using CommonLib;


namespace DbScripterLibNS
{
   /// <summary>
   /// CreateModeEnum used to define whether the Dbscripter should emit 
   /// create alter or drop type SQL statements
   /// </summary>
   public enum CreateModeEnum
   {

      [EnumAlias("Undefined")]
      Undefined = -1,
 
      [EnumAlias("Error","E")]
      Error,

      [EnumAlias("Create")]
      Create,

      [EnumAlias("Alter")]
      Alter,

      [EnumAlias("Drop")]
      Drop
  }
}
