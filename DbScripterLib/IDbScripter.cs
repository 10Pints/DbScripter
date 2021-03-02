
#nullable enable

namespace DbScripterLib
{
   interface IDbScripter
   { 
      string? Export( Params p);
      string GetTimestamp();
   }
}
