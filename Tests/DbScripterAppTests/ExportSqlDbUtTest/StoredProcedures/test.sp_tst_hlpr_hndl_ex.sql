SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 05-APR-2020
-- Description: tests the ex num and msg is exp val specified.
--              Treats ex 50000 (test framework ex) as fatal - and rethrows them
--              This routine only Fails is exp/act mismatch
--
-- POSTCONDITION: will rethrow the exception if is unexepected in the test
-- RETURNS: 1 IF Error, 0 if expected
-- ==============================================================================
CREATE PROCEDURE [test].[sp_tst_hlpr_hndl_ex]
       @exp_ex_num   INT            = NULL
      ,@exp_ex_msg   NVARCHAR(500)  = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(30)  = N'TST_HLPR_HNDL_EX'
      ,@test_sub_num NVARCHAR(100)
      ,@msg          NVARCHAR(1000)
      ,@tst_num      NVARCHAR(100)
      ,@act_ex_num   INT            = ERROR_NUMBER()
      ,@act_ex_msg   NVARCHAR(1000) = ERROR_MESSAGE()
      ,@act_ex_st    INT            = ERROR_STATE()
      ,@pos          INT
   EXEC sp_log 1, @fn, '000: starting';
   SET @tst_num      = test.fnGetCrntTstNum();
   SET @test_sub_num = test.fnGetCrntTstSubNum();
   -- Set the failed test state
   EXEC test.sp_tst_set_crnt_tst_err_st 1;
   EXEC test.sp_tst_set_crnt_failed_tst_num     @tst_num;
   EXEC test.sp_tst_set_crnt_failed_tst_sub_num @test_sub_num;
   -- Ignore Test Framework raised exceptions
   IF (@act_ex_num = 50000)
   BEGIN
      EXEC sp_log 4, @fn, '005: caught ex 50000 which is the standard tSQLt Assert/Fail exception - this is an error';
      THROW @act_ex_num, @act_ex_num, @act_ex_st;
   END
   -- If expected @exp_ex_num is not specified then not expecting an exception - so rethrow it
   IF @exp_ex_num IS NULL
      THROW @act_ex_num, @act_ex_msg, @act_ex_st;
   ELSE
   BEGIN
      -- check the exp/act ex num
      EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num, ' exp/act ex num mismatch'; --, @fn
      EXEC sp_log 1, @fn, '010: exp/act ex_num match OK';
   END
   -- if @act_ex_msg speifie4d then check it
   IF @act_ex_msg IS NOT NULL
   BEGIN
      -- check the exp/act ex msg
      SET @pos = CHARINDEX(@exp_ex_msg, @act_ex_msg)
      EXEC tSQLt.AssertNotEquals 0, @pos, ' exp/act ex msg mismatch'; --, @fn
      EXEC sp_log 1, @fn, '015: exp/act ex_msg match OK';
   END
   EXEC sp_log 1, @fn, '900: leaving, OK';
END
/*
EXEC tSQLt.Run 'test.test_032_sp_tst_gen_chk';
EXEC tSQLt.RunAll
*/
GO

