SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 06-APR-2020
-- Description: Encapsulates the main test routine startup
-- ========================================================
CREATE PROCEDURE [test].[sp_tst_mn_cls] @err_msg NVARCHAR(4000) = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(30)   = N'sp_tst_mn_cls'
      ,@tested_fn    NVARCHAR(30)   = test.fnGetCrntTstdFn()
      ,@msg          NVARCHAR(2000)
      ,@NL           NVARCHAR(2)    = dbo.fnGetNL()
      ,@line         NVARCHAR(100)  = REPLICATE(N'-', 100)
      ,@tests_passed INT
      ,@error_st     BIT            = test.fnGetCrntTstErrSt()
   PRINT @Line;
   SET @msg = iif(@error_st = 0, 'All tests passed', CONCAT('Error: 1 or more tests failed', @err_msg, @NL));
   EXEC sp_log 1, @fn, @msg--,@dont_pad=1
   -- the disp log flag is set on startup
   -- Display Log both up and down ASC and DESC
   IF test.fnGetDisplayLogFlg() = 1
   BEGIN
      EXEC dbo.sp_app_log_display 1  -- descending order
      EXEC dbo.sp_app_log_display 0; -- ascending  order
   END
   -- Clear all flags and counters
   EXEC sp_log 2, @fn, '999: leaving'; -- 2=NOTE
   PRINT @line;
END
GO

