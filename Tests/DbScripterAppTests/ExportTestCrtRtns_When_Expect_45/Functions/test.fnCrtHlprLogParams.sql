SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 17-Apr-2024
-- Description: creates the log parameter list for a test helper
-- when listing the paramaters intially with sp_log
-- Preconditions: Test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions: return table with the tst, inp and exp prms
-- =============================================================
CREATE FUNCTION [test].[fnCrtHlprLogParams]()
RETURNS @t TABLE
(
    id    INT
   ,line  VARCHAR(80)
)
AS
BEGIN
   DECLARE
    @fn                 VARCHAR(35)= 'fnCrtHlprLogParams'
   ,@tab                VARCHAR(3) = '   '
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
   ------------------------------------------
   -- Create the input params
   ------------------------------------------
   SELECT @max_prm_len = MAX(dbo.fnLen(param_nm)) FROM test.paramDetails
   --INSERT INTO @t (line) SELECT @max_prm_len as max_prm_len;
   INSERT INTO @t (line)
   SELECT
      CONCAT
      (
          dbo.fnPadRight(lower(param_nm), @max_prm_len+4)
         ,':['', @'
         ,dbo.fnPadRight(lower(param_nm), @max_prm_len+4)
         ,','']', iif(@ad_stp = 1, ' -- TST', '')
       --  ,iif(ordinal = 1, CONCAT('-- ', @fn), '')
      )
   FROM test.ParamDetails
   WHERE tst_ty = 'TST'
   ;
   INSERT INTO @t (line)
   SELECT
      CONCAT
      (
          'inp_'
         ,dbo.fnPadRight(lower(param_nm), @max_prm_len)
         ,':['', @inp_'
         ,dbo.fnPadRight(lower(param_nm), @max_prm_len)
         ,','']', iif(@ad_stp = 1, ' -- INP', '')
      )
   FROM test.ParamDetails
   WHERE tst_ty = 'INP'
   ;
   ------------------------------------------
   -- Create the exp paams
   ------------------------------------------
   INSERT INTO @t (line)
   SELECT
      CONCAT
      (
          'exp_'
         ,dbo.fnPadRight(lower(param_nm), @max_prm_len)
         ,':['', @exp_'
         ,dbo.fnPadRight(lower(param_nm), @max_prm_len)
         ,','']', iif(@ad_stp = 1, ' -- EXP 1', '')
      )
   FROM test.ParamDetails
   WHERE tst_ty ='EXP' AND is_exception = 0
   ;
   ----------------------------------------------------
   -- Add @exp_RC param if tstd rtn is a procedure
   ----------------------------------------------------
   IF(@rtn_ty_code = 'P')
   INSERT INTO @t (line) VALUES
   (
      CONCAT
      (
          dbo.fnPadRight('exp_RC', @max_prm_len + 4)
         ,':['', @exp_'
         ,dbo.fnPadRight('RC', @max_prm_len)
         ,','']', iif(@ad_stp = 1, ' -- SP', '')
      )
   )
   INSERT INTO @t (line)
   SELECT
      CONCAT
      (
          dbo.fnPadRight(lower(param_nm), @max_prm_len+4)
         ,':['', @exp_'
         ,dbo.fnPadRight(lower(param_nm), @max_prm_len)
         ,','']', iif(@ad_stp = 1, ' -- EXP 2', '')
      )
   FROM test.ParamDetails
   WHERE tst_ty ='EXP' AND is_exception = 1
   ;
   INSERT INTO @t (line) VALUES
    (''';')
    ;
   RETURN;
END
/*
   EXEC tSQLt.Run 'test.test_056_fnCrtHlprLogParams';
select line FROM test.fnCrtHlprLogParams()
EXEC tSQLt.Run 'test.test_051_fnCrtHlprLogParams';
EXEC test.sp__crt_tst_rtns 'dbo].[fnSplitKeyValuePairs'
*/
GO

