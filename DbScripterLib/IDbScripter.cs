
#nullable enable


namespace DbScripterLibNS
{
   public interface IDbScripter
   { 
      bool Export( ref Params p, out string script, out string msg);
      string GetTimestamp();
   }
}
