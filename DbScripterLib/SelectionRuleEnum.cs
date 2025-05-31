
using CommonLib;

namespace DbScripterLibNS
{
   public enum SelectionRuleEnum
   {
      [EnumAlias("Wanted")]
      Wanted,

      [EnumAlias("Considering")]
      Considering,

      [EnumAlias("Unwanted type")]
      UnwantedType,

      [EnumAlias("Unwanted schema")]
      UnwantedSchema,

      [EnumAlias("Is system object")]
      SystemObject,

      [EnumAlias("Duplicate dependency")]
      DuplicateDependency,

      [EnumAlias("Different database")]
      DifferentDatabase,

      [EnumAlias("Unresolved entity")]
      UnresolvedEntity,

      [EnumAlias("Unknown entity")]
      UnknownEntity
   }
}
