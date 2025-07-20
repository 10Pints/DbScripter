SET ANSI_NULLS ON

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
       @tst_fn VARCHAR(80)   = NULL   -- test fn
      ,@log    BIT            = 0      -- default not to display the log
AS
BEGIN
   DECLARE
       @fn                    VARCHAR(60) = N'sp_tst_mn_st'
      ,@fn_tst_pass_cnt_key   VARCHAR(50)
      ,@NL                    VARCHAR(2)    = NCHAR(13) + NCHAR(10)
      ,@Line                  VARCHAR(100)  = REPLICATE('-', 100)
      ,@tested_fn             VARCHAR(60)      -- the tested function name
      ,@is_short_msg          BIT
      ,@tsu_fn                VARCHAR(60)      -- tsu    fn
      ,@tsu1_fn               VARCHAR(60)      -- tsu    fn
      ,@tcls_fn               VARCHAR(60)      -- close  fn

   BEGIN TRY
      SET NOCOUNT ON
      PRINT test.fnGetTstHdrFooterLine(1, 1, @tst_fn, 'starting');
      DELETE FROM AppLog;
      SET @is_short_msg = iif(dbo.fnGetLogLevel()>1, 1,0);
      EXEC sp_log 0, @fn, '000: starting (',@tst_fn,')';

      -- Validate Parameters
      EXEC dbo.sp_assert_not_null_or_empty @tst_fn, '@test_fn parameter must be specified';
      EXEC sp_log 0, @fn, '005';
      SET @tested_fn = SUBSTRING(@fn, 10, 99);
      EXEC sp_log 0, @fn, '006';

      -- Stop any more logging in this fn
      EXEC sp_set_session_context N'TST_MN_ST'        , 1;
      EXEC sp_log 0, @fn, '007';

      -- set up all test fn names and initial state
      EXEC sp_log 0, @fn,'010: calling sp_tst_mn_tst_st_su';
      EXEC test.sp_tst_mn_st_su
       @tst_fn = @tst_fn
      ,@log    = @log;

      EXEC sp_log 0, @fn,'015: setting context state';
      -- ASSERTION: all test fn names set up and initial state initialised properly
      -- Add static test passed count
      SET @fn_tst_pass_cnt_key  = CONCAT(@fn, N' tests passed');
      EXEC sp_set_session_context   @fn_tst_pass_cnt_key , 0;
      EXEC sp_set_session_context N'DISP_TST_RES'        , 1;
      EXEC test.sp_tst_set_crnt_tst_err_st 0;
      END TRY
   BEGIN CATCH
      PRINT CONCAT('ERROR ', @fn, ' 500: caught exception');
      EXEC sp_log 4, @fn, '500: caught exception';
      PRINT CONCAT('ERROR ', @fn, ' 510: caught exception');
      EXEC sp_log_exception @fn;
      PRINT CONCAT('ERROR ', @fn, ' 520: caught exception');
      THROW;
   END CATCH

   EXEC sp_log 0, @fn,'999: leaving OK';
END
/*
EXEC tSQLt.Run 'test.test_059_sp_tst_mn_st'
EXEC 
EXEC tSQLt.RunAll
*/



GO
