SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 06-APR-2020
-- Description: Encapsulates the main test routine startup
-- ========================================================
CREATE PROCEDURE [test].[sp_tst_mn_cls] @err_msg VARCHAR(4000) = NULL
AS
BEGIN
   DECLARE
       @fn           VARCHAR(30)   = N'sp_tst_mn_cls'
      ,@tested_fn    VARCHAR(50)   = test.fnGetCrntTstdFn()
      ,@tst_fn       VARCHAR(50)   = test.fnGetCrntTstFn()
      ,@msg          VARCHAR(2000)
      ,@nl           VARCHAR(2)    = dbo.fnGetNL()
      ,@tests_passed INT
      ,@error_st     BIT            = test.fnGetCrntTstErrSt()
      ,@is_short_msg BIT
   SET @is_short_msg = iif(dbo.fnGetLogLevel()>1, 1,0);
   SET @msg = iif(@error_st = 0, 'Test: All sub tests passed', CONCAT('Error: 1 or more sub tests failed', @NL));
   EXEC sp_log 2, @fn, @tst_fn, ' finished, ', @msg, @short_msg = @is_short_msg;
   -- The disp log flag is set on startup
   -- Display Log both up and down ASC and DESC
   IF test.fnGetDisplayLogFlg() = 1
   BEGIN
      EXEC dbo.sp_appLog_display 1  -- descending order
      EXEC dbo.sp_appLog_display 0; -- ascending  order
   END
   -- Clear all flags and counters
   PRINT test.fnGetTstHdrFooterLine(1, 0, @tst_fn, CONCAT('', iif(@error_st = 0, 'PASSED', 'FAILED')));
END
/*
EXEC test.sp_tst_mn_st 'test_011_sp_import_UseStaging';
EXEC test.sp_tst_mn_cls;
*/
GO

