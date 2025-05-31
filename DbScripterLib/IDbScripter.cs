
#nullable enable


namespace DbScripterLibNS
{
   public interface IDbScripter
   { 
      bool Export( Params p, out string msg);
      string GetTimestamp();
   }
}
