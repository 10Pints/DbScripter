SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 06-APR-2020
-- Description: Encapsulates the main test routine startup
-- Parameters:  @tfn: the test function name
--
-- Session Keys:
--    Test fn           : 'Test fn'
--    Tested fn         : 'Tested fn'
--    Helper fn         : 'Helper fn'
--    per test setup fn : 'TSU fn'
--    1 off setup fn    : 'TSU1 fn'
--    per test close fn : 'TCLS fn'
--
-- POSTCONDITIONS:
-- POST 01: if @test_fn null or empty -> ex:
-- ===========================================================
CREATE PROCEDURE [test].[sp_tst_mn_st]
       @tst_fn NVARCHAR(80)   = NULL   -- test fn
      ,@log    BIT            = 0      -- default not to display the log
AS
BEGIN
   DECLARE
       @fn                    NVARCHAR(60) = N'sp_tst_mn_st'
      ,@fn_tst_pass_cnt_key   NVARCHAR(50)
      ,@NL                    NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@Line                  NVARCHAR(100)  = REPLICATE('-', 100)
      ,@tested_fn             NVARCHAR(60)      -- the tested function name
      ,@hlpr_fn               NVARCHAR(60)      -- helper fn
      ,@tsu_fn                NVARCHAR(60)      -- tsu    fn
      ,@tsu1_fn               NVARCHAR(60)      -- tsu    fn
      ,@tcls_fn               NVARCHAR(60)      -- close  fn
   BEGIN TRY
      SET NOCOUNT ON
      PRINT @Line;
      EXEC sp_log 0, @fn, '000: starting (',@tst_fn,')';
      -- Validate Parameters
      EXEC dbo.sp_assert_not_null_or_empty @tst_fn, @msg1 = '@test_fn parameter must be specified';
      EXEC sp_log 0, @fn, '005';
      SET @tested_fn = SUBSTRING(@fn, 10, 99);
      EXEC sp_log 0, @fn, '006';
      -- Stop any more logging in this fn
      EXEC sp_set_session_context N'TST_MN_ST'        , 1;
      EXEC sp_log 0, @fn, '007';
      -- set up all test fn names and initial state
      EXEC sp_log 0, @fn,'010: calling sp_tst_mn_tst_st_su';
      EXEC test.sp_tst_mn_tst_st_su
       @tst_fn = @tst_fn
      ,@log    = @log;
      EXEC sp_log 0, @fn,'015: setting context state';
      -- ASSERTION: all test fn names set up and initial state initialised properly
      EXEC sp_set_session_context N'NL'   , @NL;
      EXEC sp_set_session_context N'TAB1', N'   ';
      EXEC sp_set_session_context N'TAB2', N'      ';
      EXEC sp_set_session_context N'TAB3', N'         ';
      EXEC sp_set_session_context N'TAB4', N'            ';
      EXEC sp_set_session_context N'TAB5', N'               ';
      EXEC sp_set_session_context N'TABSTOP1', 3;
      EXEC sp_set_session_context N'TABSTOP2', 13;
      EXEC sp_set_session_context N'TABSTOP3', 40;
      EXEC sp_set_session_context N'TABSTOP4', 55;
      EXEC sp_set_session_context N'TABSTOP5', 62;
      -- Add static test passed count
      SET @fn_tst_pass_cnt_key  = CONCAT(@fn, N' tests passed');
      EXEC sp_set_session_context   @fn_tst_pass_cnt_key , 0;
      EXEC sp_set_session_context N'DISP_TST_RES'        , 1;
      EXEC test.sp_tst_set_crnt_tst_err_st 0;
      END TRY
   BEGIN CATCH
      DECLARE @ex_msg     NVARCHAR(500) = ut.dbo.fnGetErrorMsg()
      -- Check the expected exception
      EXEC sp_log 4, @fn, '950: Caught exception', @NL
          ,'@tst_fn=[', @tst_fn,']', @NL
          ,'@ex_msg=[', @ex_msg,']';
      THROW;
   END CATCH
   EXEC sp_log 0, @fn,'999: leaving OK';
END
/*
EXEC tSQLt.Run 'test.test_050_sp_assert_not_null_or_zero';
EXEC test.test_003_fnCompare;
EXEC test.sp_tst_mn_st
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
---------------------------------------------------------------------
DECLARE @test_fn               NVARCHAR(80)   = NULL;
EXEC dbo.sp_assert_not_null_or_empty @test_fn, @msg='@test_fn';
---------------------------------------------------------------------
EXEC test.sp_tst_clr_test_pass_cnt;
EXEC test.sp_tst_set_crnt_tstd_fn            @tested_fn;
EXEC test.sp_tst_set_crnt_tst_fn             @test_fn;
EXEC test.sp_tst_set_crnt_tst_hlpr_fn        @hlpr_fn;
EXEC test.sp_tst_set_crnt_tst_1_off_setup_fn @tsu1_fn;
EXEC test.sp_tst_set_crnt_tst_setup_fn       @tsu_fn;
EXEC test.sp_tst_set_crnt_tst_clse_fn        @tcls_fn;
*/
GO

