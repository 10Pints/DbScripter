SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 17-Apr-2024
-- Description: creates the helper sig parameter list
--
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions: return table with the tst, inp and exp prms
-- =============================================================
CREATE FUNCTION [test].[fnCrtHlprSigParams]()
RETURNS @t TABLE
(
    id    INT
   ,line  NVARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab                NVARCHAR(3) = '   '
   ,@rtn_ty_code        NCHAR(2)
   ,@tst_proc_hlpr_nm   NVARCHAR(60)
   ,@detld_rtn_ty_code  NVARCHAR(2)
   ,@qrn                NVARCHAR(100)
   ,@sc_fn_ret_ty       NVARCHAR(50)
   ,@ad_stp             BIT         = 0
   ,@tst_rtn_nm         NVARCHAR(60)
   ,@max_prm_len        INT
   SELECT
       @tst_rtn_nm = tst_rtn_nm
      ,@ad_stp     = ad_stp
      ,@max_prm_len= max_prm_len
   FROM test.RtnDetails;
   SELECT @max_prm_len = MAX(dbo.fnLen(param_nm)) + 5 
   FROM test.ParamDetails;
   INSERT INTO @t (line)
   SELECT
      CONCAT
      (
          @tab
         ,iif(param_nm = 'tst_num', ' ',',')
         ,'@',IIF(tst_ty = 'INP', 'inp_',IIF(tst_ty = 'EXP', 'exp_',''))
         ,dbo.fnPadRight(lower(param_nm), IIF(tst_ty IN ('INP', 'EXP'), @max_prm_len, @max_prm_len+4))
         , ' ', type_nm
 --     , iif(is_output=1, ' OUT','')
      , iif(param_nm = 'tst_num', CONCAT(' -- fnCrtHlprSigParams ',@max_prm_len), '')
      )
   FROM test.ParamDetails
   WHERE tst_ty IN ('TST', 'INP')
   ;
   INSERT INTO @t (line)
   SELECT
      CONCAT
      (
          @tab
         ,iif(param_nm = 'tst_num', ' ',',')
         ,'@',IIF(tst_ty = 'INP', 'inp_',IIF(tst_ty = 'EXP', 'exp_',''))
         ,dbo.fnPadRight(lower(param_nm), IIF(tst_ty IN ('INP', 'EXP'), @max_prm_len, @max_prm_len+4))
         , ' ', type_nm
 --     , iif(is_output=1, ' OUT','')
      , iif(param_nm = 'tst_num', CONCAT(' -- fnCrtHlprSigParams ',@max_prm_len), '')
      )
   FROM test.ParamDetails
   WHERE tst_ty IN ('EXP')
   ;
   RETURN;
END
/*
EXEC test.sp_get_rtn_details 'dbo.AsFloat', @display_tables=1;
SELECT * FROM test.fnCrtHlprSigParams()
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
*/
GO

