SET ANSI_NULLS ON
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
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @qrn          VARCHAR(100)
   ,@tab          NCHAR(3)  = '   '
   ,@tab2         NCHAR(6)  = dbo.fnGetNTabs(2)
   ,@tab3         NCHAR(9)  = dbo.fnGetNTabs(3)
   ,@tab4         NCHAR(12) = dbo.fnGetNTabs(4)
   ,@rtn_ty_code  NCHAR(2)
   ,@ad_stp       BIT
   ,@max_prm_len  INT
   ,@line         VARCHAR(60) = REPLICATE('-', 60)
   ,@st_ordinal   INT
   SELECT
       @qrn          = qrn
      ,@ad_stp       = ad_stp
      ,@max_prm_len  = max_prm_len
   FROM test.RtnDetails;
   SELECT 
      @max_prm_len = MAX(dbo.fnLen(param_nm))
     ,@st_ordinal  = MIN(ordinal)-1
   FROM test.ParamDetails
   WHERE tst_ty = 'EXP';
   IF @ad_stp = 1
      INSERT INTO @rtnDef (line) VALUES
      (CONCAT(@tab3, '-- fnCrtHlprCodeChkExps',''))
   ----------------------------------------------
   -- Row count chk setup
   ----------------------------------------------
    --INSERT INTO @rtnDef (line) VALUES
    --(CONCAT(@tab3, '--IF @exp_', dbo.fnPadRight('row_cnt', @max_prm_len),' IS NOT NULL SELECT @act_row_cnt = COUNT(*) FROM [<TODO: enter table name here>]'));
   ----------------------------------------------
   -- Add the exp checks not exp exception chks
   ----------------------------------------------
   INSERT INTO @rtnDef (line) SELECT
      CONCAT
      (
          @tab3
         ,'IF @exp_', dbo.fnPadRight(param_nm, @max_prm_len)
         ,' IS NOT NULL EXEC tSQLt.AssertEquals'
         , ' @exp_' , dbo.fnPadRight(param_nm, @max_prm_len)
         ,', @act_' , dbo.fnPadRight(param_nm, @max_prm_len)
         , ',''',FORMAT(ordinal+80 - - @st_ordinal, '000'), ' ',param_nm, ''';'
      )
   FROM test.ParamDetails
   WHERE tst_ty = 'EXP' AND is_exception = 0;
   RETURN;
END
/*
EXEC test.sp_set_rtn_details 'test.sp_crt_tst_mn'
SELECT * FROM test.fnCrtHlprCodeChkExps();
         -- fnCrtHlprCodeChkExps
         IF @exp_row_cnt IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt, @act_row_cnt,'087row_cnt';
         IF @exp_id      IS NOT NULL EXEC tSQLt.AssertEquals @exp_id     , @act_id     ,'088id';
         IF @exp_line    IS NOT NULL EXEC tSQLt.AssertEquals @exp_line   , @act_line   ,'089line';
EXEC tSQLt.RunAll;
*/
GO

