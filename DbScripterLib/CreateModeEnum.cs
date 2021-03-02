using RSS.Common;


namespace DbScripterLib
{
   /// <summary>
   /// CreateModeEnum used to define whether the Dbscripter should emit 
   /// create alter or drop type SQL statements
   /// </summary>
   public enum CreateModeEnum
   {
      [EnumAlias("Undefined")]
      Undefined   = 0,

      [EnumAlias("Create")]
      Create,

      [EnumAlias("Alter")]
      Alter,

      [EnumAlias("Drop")]
      Drop
   }
}
