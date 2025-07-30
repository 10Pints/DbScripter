SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:      Terry Watts
-- Create date: 16-Apr-2024
-- Description: creates the as begin ...script for the main test 
--
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions:
-- Returns: @rtnDef
-- Post 01:
-- ==============================================================================================
CREATE FUNCTION [test].[fnCrtMnCodeCallHlpr]()
RETURNS @t TABLE
(
    id    INT
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab1                NVARCHAR(3) = '   '
   ,@tab2                NVARCHAR(3) = '      '
   ,@trn                INT
   ,@rtn_ty_code        NCHAR(2)
   ,@tst_proc_hlpr_nm   NVARCHAR(60)
   ,@detld_rtn_ty_code  NVARCHAR(2)
   ,@qrn                NVARCHAR(100)
   ,@rtn_nm             NVARCHAR(60)
   ,@sc_fn_ret_ty       NVARCHAR(50)
   ,@ad_stp             BIT = 0
   ,@max_prm_len        INT
   SELECT
       @tst_proc_hlpr_nm = hlpr_rtn_nm
      ,@max_prm_len      = max_prm_len
      ,@ad_stp           = ad_stp
      ,@trn              = trn
      ,@rtn_nm           = rtn_nm
   FROM test.RtnDetails
   INSERT INTO @t (line) VALUES
    (CONCAT('AS  ', IIF(@ad_stp = 1 ,'-- AS-BGN-ST', '')))
   ,('BEGIN')
   ,('DECLARE')
   ,(CONCAT(@tab1, '@fn NVARCHAR(35) = ''H',@trn,'_',UPPER(@rtn_nm), '''', IIF(@ad_stp = 1 ,' -- fnCrtMnCodeCallHlpr', '')))
   ,('')
   ,(CONCAT(@tab1, 'EXEC test.',@tst_proc_hlpr_nm))
   INSERT INTO @t (line) VALUES
   ( CONCAT( @tab2, dbo.fnPadRight(' @tst_num', @max_prm_len+5), ' =''T001'''))
   INSERT INTO @t (line) 
   SELECT
      CONCAT
      (
         @tab2, iif(ordinal=1, ' ', ',')
      , dbo.fnPadRight(test.fnGetParamWithSuffix(param_nm), @max_prm_len+4), ' = ', iif(is_chr_ty=1, '''''', '0'))
   FROM test.ParamDetails
   WHERE tst_ty = 'INP';
   INSERT INTO @t (line) 
   SELECT
      CONCAT
      (
         @tab2, iif(ordinal=1, ' ', ',')
      , dbo.fnPadRight(test.fnGetParamWithSuffix(param_nm), @max_prm_len+4), ' = NULL')
   FROM test.ParamDetails
   WHERE tst_ty = 'EXP';
   RETURN;
END
/*
SELECT * FROM test.fnCrtMnCodeCallHlpr();
EXEC tSQLt.Run 'test.test_067_sp_crt_tst_mn';
SELECT * FROM test.RtnDetails
SELECT * FROM test.ParamDetails
*/
GO

