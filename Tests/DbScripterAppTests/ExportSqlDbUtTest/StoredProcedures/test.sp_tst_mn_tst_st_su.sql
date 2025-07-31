SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: main start set up
--
-- Responsibilitiers:   
--    clear  test_pass_cnt= 0,
--
--    pop  the following:
--    crnt_tstd_fn
--    crnt_tst_fn
--    crnt_tst_hlpr_fn
--    rnt_tst_1_off_setup_fn
--    crnt_tst_setup_fn
--    crnt_tst_clse_fn
-- =============================================
CREATE PROCEDURE [test].[sp_tst_mn_tst_st_su]
       @tst_fn      NVARCHAR(80)   = NULL   -- test fn like 'test 030 chkTestConfig'
      ,@log          BIT            = 1
AS
BEGIN
   DECLARE
       @tested_fn    NVARCHAR(60)            -- the tested function name
      ,@fn_num       NVARCHAR(3)             
      ,@hlpr_fn      NVARCHAR(60)            -- helper fn
      ,@tsu_fn       NVARCHAR(60)            -- tsu    fn
      ,@tsu1_fn      NVARCHAR(60)            -- tsu    fn
      ,@tcls_fn      NVARCHAR(60)            -- close  fn
      ,@key          NVARCHAR(40)
      ,@fn           NVARCHAR(60) = N'sp_tst_mn_tst_st_su'
      ,@len          INT
   BEGIN TRY
      EXEC sp_log 0, @fn,'000: starting';
      ----------------------------------------------------------------------------------
      -- Calc the test fn namrs for this test
      ----------------------------------------------------------------------------------
      -- Set the logging flag
      EXEC test.sp_tst_set_display_log_flg @log;
      SET @tested_fn = substring( @tst_fn, 10, 100);
      EXEC dbo.sp_assert_not_null_or_empty @tested_fn, @msg1 = 'tested_fn must be specified';
      SET @fn_num = substring( @tst_fn, 6, 3 );
      EXEC sp_log 0, @fn, '005: @tested_fn:[', @tested_fn, ']';
      EXEC dbo.sp_assert_not_null_or_empty @fn_num, @msg1 = '@fn_num must not be null @test_fn: ', @msg2 = @tst_fn;
      SET @hlpr_fn = CONCAT(N'h '   , @fn_num, N' ', @tested_fn);
      SET @tsu_fn  = CONCAT(N'TSU ' , @fn_num, N' ', @tested_fn);
      SET @tsu1_fn = CONCAT(N'TSU1 ', @fn_num, N' ', @tested_fn);
      SET @tcls_fn = CONCAT(N'TCLS ', @fn_num, N' ', @tested_fn);
      --EXEC sp_log 0, @fn, 'hlpr_fn: ', @hlpr_fn, '';
      --EXEC sp_log 0, @fn, 'tsu_fn:  ', @tsu_fn,  '';
      --EXEC sp_log 0, @fn, 'tsu1_fn: ', @tsu1_fn, '';
      --EXEC sp_log 0, @fn, 'tcls_fn: ', @tcls_fn, '';
      ----------------------------------------------------------------------------------
      -- Validate
      ----------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '010: @tested_fn:[', @tested_fn, ']';
      EXEC sp_log 0, @fn, '015: @fn_num:[', @fn_num, ']';
      EXEC dbo.sp_assert_not_null_or_empty @hlpr_fn  , @msg1 = '@hlpr_fn  must be specified';
      EXEC dbo.sp_assert_not_null_or_empty @tsu_fn   , @msg1 = '@tsu_fn   must be specified';
      EXEC dbo.sp_assert_not_null_or_empty @tsu1_fn  , @msg1 = '@tsu1_fnm must be specified';
      EXEC dbo.sp_assert_not_null_or_empty @tcls_fn  , @msg1 = '@tcls_fn  must be specified';
      EXEC sp_log 0, @fn,'020';
      SET @len = dbo.fnLen(@fn_num);
      EXEC dbo.sp_assert_equal 3, @len ,@msg='@fn_num len should be 3';
      SET @len = dbo.fnContainsWhiteSpace(@fn_num);
      EXEC dbo.sp_assert_equal 0, @len ,@msg='@fn_num len should not contain spaces';
      ----------------------------------------------------------------------------------
      -- Set the state:
      ----------------------------------------------------------------------------------
      EXEC test.sp_tst_clr_test_pass_cnt;
      EXEC test.sp_tst_set_crnt_tst_num @fn_num;               --  oppo: fnGetCrntTstNum()         KEY: N'Test num'
      EXEC test.sp_tst_set_crnt_tstd_fn @tested_fn;            --  oppo: fnGetCrntTstdFn()         KEY: N'Tested fn'
      EXEC sp_log 2, @fn,'025';
      EXEC test.sp_tst_set_crnt_tst_fn @tst_fn;                -- oppo: fnGetCrntTstFn()           KEY: N'Test fn'
      EXEC test.sp_tst_set_crnt_tst_hlpr_fn @hlpr_fn;          -- oppo: fnGetCrntTstHlprFn()       KEY: N'Hlpr fn'
      EXEC test.sp_tst_set_crnt_tst_1_off_setup_fn @tsu1_fn;   -- oppo: fnGetCrntTst1OffSetupFn()  KEY: N'TSU1 fn'
      EXEC test.sp_tst_set_crnt_tst_setup_fn @tsu_fn;          -- oppo: fnGetCrntTstSetupFn()      KEY: N'TSU fn'
      EXEC test.sp_tst_set_crnt_tst_clse_fn @tcls_fn;          -- oppo: fnGetCrntTstCloseFn()      KEY: N'TCLS fn'
      --EXEC sp_log 2, @fn,'20';
   END TRY
   BEGIN CATCH
      DECLARE @msg NVARCHAR(4000)= CONCAT(@fn, ' for test method:',@tst_fn,' caught exception: ', ut.dbo.fnGetErrorMsg());
      EXEC sp_log 4, @fn, @msg;
      THROW;
   END CATCH
   EXEC sp_log 0, @fn,'99: leaving OK'
END
/*
EXEC tSQLt.Run 'test.test_050_sp_assert_not_null_or_zero';
*/
GO

