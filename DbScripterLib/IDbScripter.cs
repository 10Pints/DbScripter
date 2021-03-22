
#nullable enable


namespace DbScripterLibNS
{
   public interface IDbScripter
   { 
      string? Export( ref Params p);
      string GetTimestamp();
   }
}
