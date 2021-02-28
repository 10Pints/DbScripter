using RSS;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DbScripterLib
{
   public enum SqlTypeEnum
   {
      [EnumAlias("Undefined")]
      Undefined = 0,
 
      [EnumAlias("Data")]
      Data,       // Exporting static or dynamic data

      [EnumAlias("Database")]
      Database,

      [EnumAlias("FKey")]
      FKey,

      [EnumAlias("Function")]
      Function,

      [EnumAlias("Procedure")]
      Procedure,

      [EnumAlias("Schema")]
      Schema,

      [EnumAlias("Table")]
      Table,

      // Key2: TTy
      [EnumAlias("TableType")]
      TableType,

      [EnumAlias("View")]
      View
   }
}
