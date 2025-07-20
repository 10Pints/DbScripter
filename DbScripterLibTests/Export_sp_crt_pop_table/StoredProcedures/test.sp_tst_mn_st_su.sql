SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: main start set up
--
-- Responsibilities:
--    clear  test_pass_cnt= 0,
--
--    pop  the following:
--    crnt_tstd_fn
--    crnt_tst_fn
--    crnt_tst_hlpr_fn
--    rnt_tst_1_off_setup_fn
--    crnt_tst_setup_fn
--    crnt_tst_clse_fn
--
-- Validated preconditions:
--    PRE 01: @tst_fn must have at least 11 characters and be like: like ''test_nnn_<tested rtn mn>chkTestConfig''
--    PRE 02: the nnn @tst_fn must be a positive integer
--    PRE 02: @tst_fn must have no spaces
--
-- Postconditions 
-- CHANGES:
-- 241128: added paramater validation
-- =============================================
CREATE PROCEDURE [test].[sp_tst_mn_st_su]
       @tst_fn    VARCHAR(80)   = NULL   -- test fn like 'test 030 chkTestConfig'
      ,@log       BIT            = 1
AS
BEGIN
   DECLARE
       @tested_fn VARCHAR(60)            -- the tested function name
      ,@fn_num    VARCHAR(3)             
      ,@hlpr_fn   VARCHAR(60)            -- helper fn
      ,@tsu_fn    VARCHAR(60)            -- tsu    fn
      ,@tsu1_fn   VARCHAR(60)            -- tsu    fn
      ,@tcls_fn   VARCHAR(60)            -- close  fn
      ,@key       VARCHAR(40)
      ,@fn        VARCHAR(60) = N'sp_tst_mn_st_su'
      ,@len       INT
      ,@msg       VARCHAR(150)
      ,@is_num    BIT

   BEGIN TRY
      --PRINT CONCAT(@fn, ': 1')
      EXEC sp_log 0, @fn,'000: starting, @tst_fn:[',@tst_fn,']';
      --PRINT CONCAT(@fn, ': 2')
      ----------------------------------------------------------------------------------
      -- Validate inputs
      ----------------------------------------------------------------------------------
      EXEC sp_log 0, @fn,'010: Validate inputs';
--      PRINT CONCAT(@fn, ': 3')
      -- test fn like 'test 030 chkTestConfig'
      SET @len = dbo.fnLen(@tst_fn);
      --EXEC sp_log 0, @fn,'020: @len: ', @len;
      SET @msg = CONCAT(' ',@fn, ' @tst_fn: [',@tst_fn,'] must have at least 11 characters and be like: like ''test_nnn_<tested rtn mn>chkTestConfig'' and have no spaces,
      nnn must be a positive integer like 015');

      -- PRE 01: @tst_fn must have at least 11 characters and be like: like ''test_nnn_<tested rtn mn>chkTestConfig''
      --EXEC sp_log 0, @fn,'030 calling sp_assert_gtr_than @len: ', @len;
      EXEC sp_assert_gtr_than @len, 11, '011:', @msg;
      --EXEC sp_log 0, @fn,'040';
      SET @fn_num = SUBSTRING( @tst_fn, 6, 3 );
      --EXEC sp_log 0, @fn,'010.15';
--      PRINT CONCAT(@fn, ': 10')
      EXEC dbo.sp_assert_not_null_or_empty @fn_num, '012: @fn_num must not be null @test_fn: ', @msg2 = @tst_fn;
      --EXEC sp_log 0, @fn,'050: calling dbo.fnIsInt(',@fn_num,', 1);';
      SET @is_num = dbo.fnIsTxtInt(@fn_num, 1);

      --EXEC sp_log 0, @fn,'010.2 checking that @tst_fn has a positive integer';
--    PRE 02: the nnn @tst_fn must be a positive integer
      EXEC sp_assert_equal 1, @is_num, '060: @fn_num: [', @fn_num, '] must be a positive integer like ''015''';

      EXEC sp_log 0, @fn,'070';
      SET @tested_fn = SUBSTRING( @tst_fn, 10, 100);
      --EXEC sp_log 0, @fn, '080: @tested_fn:[', @tested_fn, ']';
      EXEC dbo.sp_assert_not_null_or_empty @tested_fn, '013: tested_fn must be specified - chars 10-100 of @tst_fn psram';
      --EXEC sp_log 0, @fn,'010.4';
  --    PRINT CONCAT(@fn, ': 20')

      -- PRE 03: @tst_fn must have no spaces
      IF CHARINDEX(' ', @tst_fn) > 0
      BEGIN
         EXEC sp_log 4, @fn,'090: @tst_fn must have no spaces';
         EXEC sp_raise_exception 56010, @fn, ' PRE 03: @tst_fn must have no spaces';
      END

      EXEC sp_log 0, @fn,'100';

      IF CHARINDEX('test_', @tst_fn )<> 1
      BEGIN
         EXEC sp_log 4, @fn,'110: test rtn nam should start with ''TEST_''';
         EXEC sp_raise_exception 53602, '100: ', @msg;
      END

      EXEC sp_log 0, @fn,'120: Validate inputs - OK';
      ----------------------------------------------------------------------------------
      -- Calc the test fn names for this test
      ----------------------------------------------------------------------------------
      -- Set the logging flag
      EXEC test.sp_tst_set_display_log_flg @log;

      SET @hlpr_fn = CONCAT(N'hlpr_', @fn_num, N' ', @tested_fn);
      SET @tsu_fn  = CONCAT(N'TSU ' , @fn_num, N' ', @tested_fn);
      SET @tsu1_fn = CONCAT(N'TSU1 ', @fn_num, N' ', @tested_fn);
      SET @tcls_fn = CONCAT(N'TCLS ', @fn_num, N' ', @tested_fn);

      ----------------------------------------------------------------------------------
      -- Validate
      ----------------------------------------------------------------------------------
      --EXEC sp_log 0, @fn, '130: @tested_fn:[', @tested_fn, ']';
      --EXEC sp_log 0, @fn, '140: @fn_num:[', @fn_num, ']';
      EXEC dbo.sp_assert_not_null_or_empty @hlpr_fn  , @msg1 = '140: @hlpr_fn  must be specified';
      EXEC dbo.sp_assert_not_null_or_empty @tsu_fn   , @msg1 = '150: @tsu_fn   must be specified';

      EXEC dbo.sp_assert_not_null_or_empty @tsu1_fn  , @msg1 = '160: @tsu1_fnm must be specified';
      EXEC dbo.sp_assert_not_null_or_empty @tcls_fn  , @msg1 = '170: @tcls_fn  must be specified';
      --EXEC sp_log 0, @fn,'909';
      SET @len = dbo.fnLen(@fn_num);

      EXEC dbo.sp_assert_equal 3, @len ,'200: @fn_num len should be 3';
      SET @len = dbo.fnContainsWhiteSpace(@fn_num);
      EXEC dbo.sp_assert_equal 0, @len ,'210: @fn_num len should not contain spaces';

      ----------------------------------------------------------------------------------
      -- Set the state:
      ----------------------------------------------------------------------------------
      EXEC test.sp_tst_clr_test_pass_cnt;
      EXEC test.sp_tst_set_crnt_tst_num @fn_num;               --  oppo: fnGetCrntTstNum()         KEY: N'Test num'
      EXEC test.sp_tst_set_crnt_tst_num2           @fn_num;    -- Just the 3 digit test number
      EXEC test.sp_tst_set_crnt_tstd_fn @tested_fn;            --  oppo: fnGetCrntTstdFn()         KEY: N'Tested fn'
      EXEC test.sp_tst_set_crnt_tst_fn @tst_fn;                -- oppo: fnGetCrntTstFn()           KEY: N'Test fn'
      EXEC test.sp_tst_set_crnt_tst_hlpr_fn @hlpr_fn;          -- oppo: fnGetCrntTstHlprFn()       KEY: N'Hlpr fn'
      EXEC test.sp_tst_set_crnt_tst_1_off_setup_fn @tsu1_fn;   -- oppo: fnGetCrntTst1OffSetupFn()  KEY: N'TSU1 fn'
      EXEC test.sp_tst_set_crnt_tst_setup_fn @tsu_fn;          -- oppo: fnGetCrntTstSetupFn()      KEY: N'TSU fn'

      EXEC test.sp_tst_set_crnt_tst_clse_fn @tcls_fn;          -- oppo: fnGetCrntTstCloseFn()      KEY: N'TCLS fn'
      EXEC sp_log 0, @fn,'400: Processing complete';
   END TRY
   BEGIN CATCH
      PRINT CONCAT(@fn, ': 499: Caught exception')
      EXEC sp_log 4, @fn,'500: Caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

--      PRINT CONCAT(@fn, ': 999')
   EXEC sp_log 0, @fn,'999: leaving OK'
END
/*
EXEC sp_Set_log_level 0
EXEC test.sp_tst_mn_st_su 'test_049_SetGetCrntTstValue'

ECEC test.sp_tst_mn_st 'test_049_SetGetCrntTstValue'
EXEC tSQLt.Run 'test.test_050_sp_assert_not_null_or_zero';
*/


GO
