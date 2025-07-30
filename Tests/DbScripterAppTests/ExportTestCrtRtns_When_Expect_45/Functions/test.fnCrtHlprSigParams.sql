SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:        Terry Watts
-- Create date:   17-Apr-2024
-- Description:   creates the helper sig parameter list
-- Design:        
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
-- Postconditions: return table with the tst, inp and exp prms
-- Tests:
--    test_042_sp_pop_param_details
--    test_041_fnCrtHlprSigParams
-- =============================================================
CREATE FUNCTION [test].[fnCrtHlprSigParams]()
RETURNS @t TABLE
(
    id    INT IDENTITY(1,1)
   ,line  VARCHAR(500)
)
AS
BEGIN
   DECLARE
    @tab                VARCHAR(3) = '   '
   ,@rtn_ty_code        NCHAR(2)
   ,@tst_proc_hlpr_nm   VARCHAR(60)
   ,@detld_rtn_ty_code  VARCHAR(2)
   ,@qrn                VARCHAR(100)
   ,@sc_fn_ret_ty       VARCHAR(50)
   ,@ad_stp             BIT         = 0
   ,@tst_rtn_nm         VARCHAR(60)
   ,@max_prm_len        INT
   SELECT
       @tst_rtn_nm   = tst_rtn_nm
      ,@ad_stp       = ad_stp
      ,@rtn_ty_code  = rtn_ty_code
      ,@max_prm_len  = max_prm_len
   FROM test.RtnDetails;
   SELECT @max_prm_len = MAX(dbo.fnLen(param_nm)) + 5 
   FROM test.ParamDetails;
   ------------------------------------------
   -- Create the input paams
   ------------------------------------------
   INSERT INTO @t (line)
   SELECT
      CONCAT
      (
          @tab
         ,iif(param_nm = 'tst_num' AND tst_ty='TST', ' ',',')
         ,'@',IIF(tst_ty = 'INP', 'inp_',IIF(tst_ty = 'EXP', 'exp_',''))
         ,dbo.fnPadRight(lower(param_nm), IIF(tst_ty IN ('INP', 'EXP'), @max_prm_len, @max_prm_len+4))
         ,' ', type_nm
         ,iif(@ad_stp = 1 AND param_nm = 'tst_num', ' -- fnCrtHlprSigParams', '')
      )
   FROM test.ParamDetails
   WHERE tst_ty IN ('TST', 'INP')
   ;
   ------------------------------------------
   -- Create the exp paams
   ------------------------------------------
   INSERT INTO @t (line)
   SELECT
      CONCAT
      (
          @tab
         ,iif(param_nm = 'tst_num', ' ',',')
         ,'@',IIF(tst_ty = 'INP', 'inp_',IIF(tst_ty = 'EXP', 'exp_',''))
         ,dbo.fnPadRight(lower(param_nm)
         ,IIF(tst_ty IN ('INP', 'EXP'), @max_prm_len, @max_prm_len+4))
         ,' ', type_nm
         ,iif(tst_ty = 'EXP', dbo.fnPadLeft('= NULL', 22 - dbo.fnLen(type_nm)),'')
         ,iif(param_nm = 'tst_num', CONCAT(' -- fnCrtHlprSigParams ',@max_prm_len+6), '')
      )
   FROM test.ParamDetails
   WHERE tst_ty ='EXP' AND is_exception = 0
   ;
   ----------------------------------------------------
   -- If tstd rtn is a procedure then add @exp_RC param
   ----------------------------------------------------
   /*IF(@rtn_ty_code = 'P')
   INSERT INTO @t (line) VALUES
   (CONCAT(@tab, dbo.fnPadRight(',@exp_RC', @max_prm_len + 6), ' INT'))
   */
   INSERT INTO @t (line)
   SELECT
      CONCAT
      (
          @tab
         ,iif(param_nm = 'tst_num', ' ',',')
         ,'@',IIF(tst_ty = 'INP', 'inp_',IIF(tst_ty = 'EXP', 'exp_',''))
         ,dbo.fnPadRight(lower(param_nm), IIF(tst_ty IN ('INP', 'EXP'), @max_prm_len, @max_prm_len+4))
         , ' ', type_nm
         ,iif(tst_ty = 'EXP', dbo.fnPadLeft('= NULL', 22 - dbo.fnLen(type_nm)),'')
         ,iif(param_nm = 'tst_num', CONCAT(' -- fnCrtHlprSigParams ',@max_prm_len+6), '')
      )
   FROM test.ParamDetails
   WHERE tst_ty ='EXP' AND is_exception = 1
   ;
   RETURN;
END
/*
EXEC test.test_041_fnCrtHlprSigParams;
EXEC test.sp_set_rtn_details 'test.sp_tst_hlpr_st', @display_tables=1;
SELECT * FROM test.RtnDetails;
SELECT * FROM test.ParamDetails;
SELECT * FROM test.fnCrtHlprSigParams()
*/
GO

