SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 15-FEB-2021
-- Description: Tests the sp_tst_hlp_chk function
-- TESTED RTN DESC: 
-- Description: handles the exp/act assertion and logs message etc.
--
-- IF PASSED:
--    increment the test count
--
-- IF FAILED
--    log msg
--    if the continue on error flag is not set then 
--       raise exception
-- ===============================================
CREATE PROCEDURE [test].[hlpr_032_sp_tst_gen_chk]
       @test_num     NVARCHAR(80)
      ,@test_sub_num NVARCHAR(30)
      ,@inp_exp      SQL_VARIANT
      ,@inp_act      SQL_VARIANT
      ,@fail_msg     NVARCHAR(500)
      ,@cmp_mode     NCHAR         -- = N'=' -- can be =, <, >
      ,@exp_ex_num   INT
      ,@exp_ex_msg   NVARCHAR(500)
      ,@exp_ex_st    INT
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = 'hlpr_032_sp_tst_gen_chk'
      ,@NL           NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@strInpExp    NVARCHAR(4000)
      ,@strInpAct    NVARCHAR(4000)
      ,@tpc_init     INT = test.fnGetTstPassCnt()
      ,@tpc_exp      INT
      ,@tpc_post     INT
   BEGIN TRY
      SET @strInpExp = CONVERT(NVARCHAR(4000), @inp_exp);
      SET @strInpAct = CONVERT(NVARCHAR(4000), @inp_act);
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
      -- Populate the IN/OUT params
      -- Run test specific setup
      -- Call the tested routine
      EXEC test.sp_tst_gen_chk 
             @test_sub_num = @test_sub_num
            ,@exp          = @inp_act
            ,@act          = @inp_act
            ,@fail_msg     = @fail_msg
            ,@cmp_mode     = @cmp_mode  -- = N'=' -- can be =, <, >
      EXEC sp_log 1, @fn, '005: ret frm tested routine';
      -- ASSERTION: if here then sp_tst_gen_chk passed the inp_exp/act params
      SET @tpc_exp = @tpc_init + 1
      -- sub tests
      -- 1: check the tst apssed counter incremented
      SET @tpc_post = test.fnGetTstPassCnt();
      EXEC dbo.sp_assert_equal @tpc_exp, @tpc_post, @msg = 'should have incremented pass count'
      EXEC sp_log 1, @fn, '010: calling sp_tst_hlpr_try_end';
      EXEC ut.test.sp_tst_hlpr_try_end @exp_ex_num, @exp_ex_msg,@exp_ex_st;
      EXEC sp_log 1, @fn, '015: ret frm sp_tst_hlpr_try_end';
   END TRY
   BEGIN CATCH
      DECLARE @_tmp     NVARCHAR(500)  = ut.dbo.fnGetErrorMsg()
             ,@params   NVARCHAR(4000)
     -- sub tests
      -- 1: check the tst passed counter incremented
      EXEC sp_log 1, @fn, '020: caught exception';
      SET @tpc_exp  = @tpc_init
      SET @tpc_post = test.fnGetTstPassCnt();
      SET @strInpExp = iif(@strInpExp IS NULL, '<null>', @strInpExp);
      SET @strInpAct = iif(@strInpAct IS NULL, '<null>', @strInpAct);
      SET @params = CONCAT( 
          '@test_num     =', @test_num    ,'', @NL
         ,'@test_sub_num =', @test_sub_num,'', @NL
         ,'@strInpExp    =', @strInpExp   ,'', @NL
         ,'@strInpAct    =', @strInpAct   ,'', @NL
         ,'@tpc_exp      =', @tpc_exp     ,'', @NL
         ,'@tpc_post     =', @tpc_post    ,'', @NL
         ,'@fail_msg     =', @fail_msg    ,'', @NL
         ,'@cmp_mode     =', @cmp_mode    ,'', @NL
         ,'@exp_ex_num   =', @exp_ex_num  ,'', @NL
         ,'@exp_ex_msg   =', @exp_ex_msg  ,'', @NL
         ,'@exp_ex_st    =', @exp_ex_st   ,'', @NL
         );
      -- Check the expected exception
      EXEC sp_log 1, @fn, '025 calling sp_tst_hlpr_hndl_ex';
      EXEC ut.test.sp_tst_hlpr_hndl_ex 
          @exp_ex_num   = @exp_ex_num
         ,@exp_ex_msg   = @exp_ex_msg
         ,@exp_ex_st    = @exp_ex_st
         ,@params       = @params
      EXEC sp_log 1, @fn, '030 ret frm sp_tst_hlpr_hndl_ex';
   END CATCH
      EXEC sp_log 1, @fn, '035 calling sp_tst_hlpr_hndl_success';
   EXEC test.sp_tst_hlpr_hndl_success;
   EXEC sp_log 1, @fn, 'leaving, test ',@test_num, ' PASSED'
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_032_sp_tst_gen_chk'
*/
GO

