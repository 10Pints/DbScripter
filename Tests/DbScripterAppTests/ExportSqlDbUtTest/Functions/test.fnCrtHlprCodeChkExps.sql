SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Author:      Terry Watts
-- Create date: 24-APRE-2024
-- Description: creates the scriptlet for stage 10 of test.sp_crt_tst_hlpr
-- ===========================================================================
CREATE FUNCTION [test].[fnCrtHlprCodeChkExps]()
RETURNS @rtnDef TABLE 
(
    id    INT IDENTITY(1,1)
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @qrn          NVARCHAR(100)
   ,@tab          NCHAR(3)  = '   '
   ,@tab2         NCHAR(6)  = dbo.fnGetNTabs(2)
   ,@tab3         NCHAR(9)  = dbo.fnGetNTabs(3)
   ,@tab4         NCHAR(12) = dbo.fnGetNTabs(4)
   ,@rtn_ty_code  NCHAR(2)
   ,@ad_stp       BIT
   ,@max_prm_len  INT
   ,@line         NVARCHAR(60) = REPLICATE('-', 60)
   SELECT
       @qrn          = qrn
      ,@ad_stp       = ad_stp
      ,@max_prm_len  = max_prm_len
   FROM test.RtnDetails;
   IF @ad_stp = 1
      INSERT INTO @rtnDef (line) VALUES
      (CONCAT(@tab2, '-- fnCrtHlprCodeChkExps',''))
   INSERT INTO @rtnDef (line) SELECT
      CONCAT
      (
          @tab2
         ,'IF @exp_', dbo.fnPadRight(param_nm,@max_prm_len)
         ,' IS NOT NULL EXEC tSQLt.AssertEquals'
         , ' @exp_', dbo.fnPadRight(param_nm,@max_prm_len)
         ,', @act_', dbo.fnPadRight(param_nm,@max_prm_len)
         , ',''',  dbo.fnPadRight(param_nm,@max_prm_len), ' ', ordinal,''''
      )
   FROM test.ParamDetails
   WHERE tst_ty = 'EXP';
   RETURN;
END
/*
SELECT * FROM test.fnCrtHlprCodeChkExps();
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
EXEC tSQLt.RunAll;
*/
GO

