
#nullable enable

using DbScripterLibNS;

namespace RSS.Test
{
   class ParamsTestable : Params
   {

      public new static string DefaultLogFile {get=>Params.DefaultLogFile ; set=> Params.DefaultLogFile = value;}// = @"D:\Logs\DbScripter.log";

      public new static string DefaultScriptDir {get=>Params.DefaultScriptDir ; set=> Params.DefaultLogFile = value;}// @"D:\Dev\Repos\C#\Db\Scripts";

      public ParamsTestable
      (
          string           nm        = ""
         ,Params?          prms      = null // Use this state to start with and update with the subsequent parameters
         ,string?          svrNm     = null
         ,string?          instNm    = null
         ,string?          dbNm      = null
         ,string?          xprtScrpt = null
         ,string?          newSchNm  = null
         ,string?          rss       = null
         ,string?          rts       = null
         ,CreateModeEnum?  cm        = null //CreateModeEnum  .Undefined
         ,bool?            useDb     = null
         ,bool?            addTs     = null
         ,string?          log       = null
         ,bool?            isXprtDta = null
      )
         : base
         (
             nm        : nm       
            ,prms      : prms     
            ,svrNm     : svrNm    
            ,instNm    : instNm   
            ,dbNm      : dbNm     
            ,xprtScrpt : xprtScrpt
            ,newSchNm  : newSchNm 
            ,rss       : rss      
            ,rts       : rts      
            ,cm        : cm       
            ,useDb     : useDb    
            ,addTs     : addTs    
            ,log       : log      
            ,isXprtDta : isXprtDta
         )
      { 
      }

      public new void SetDefaults()
      {
         base.SetDefaults();
      }

      public new static string ArgsToString(string []? args)
      {
         return Params.ArgsToString(args);
      }
   }
}
