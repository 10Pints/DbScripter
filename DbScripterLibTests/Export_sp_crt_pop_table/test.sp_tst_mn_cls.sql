SET ANSI_NULLS ON

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
--      ,@line         VARCHAR(180)  = REPLICATE(N'*', 180)
      ,@tests_passed INT
      ,@error_st     BIT            = test.fnGetCrntTstErrSt()

--   PRINT CONCAT(@nl,@line);
   SET @msg = iif(@error_st = 0, 'Test: All sub tests passed', CONCAT('Error: 1 or more sub tests failed', @NL));
   EXEC sp_log 2, @fn, '000: Main test ', @tst_fn, ' finished, ', @msg, ' @tst_fn:[',@tst_fn,']';

   -- The disp log flag is set on startup
   -- Display Log both up and down ASC and DESC
   IF test.fnGetDisplayLogFlg() = 1
   BEGIN
      EXEC dbo.sp_appLog_display 1  -- descending order
      EXEC dbo.sp_appLog_display 0; -- ascending  order
   END

   -- Clear all flags and counters
   PRINT test.fnGetTstHdrFooterLine(1, 0, @tst_fn, CONCAT('', iif(@error_st = 0, 'PASSED', 'FAILED')));
   EXEC sp_log 0, @fn, '99: leaving';
--   PRINT CONCAT(@line, @nl);
END
/*
EXEC test.sp_tst_mn_st 'test_011_sp_import_UseStaging';
EXEC test.sp_tst_mn_cls;
*/


GO
