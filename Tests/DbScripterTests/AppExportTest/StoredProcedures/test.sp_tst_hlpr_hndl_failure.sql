SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:      Terry Watts
-- Create date: 13-FEB-2021
-- Description: handles test failure
--
-- TESTS:
-- ================================================
CREATE PROCEDURE [test].[sp_tst_hlpr_hndl_failure]
 @msg1 VARCHAR(2000) = NULL
,@msg2 VARCHAR(2000) = NULL
,@msg3 VARCHAR(2000) = NULL
,@msg4 VARCHAR(2000) = NULL
AS
BEGIN
   DECLARE
      @fn       VARCHAR(35) = 'sp_tst_hlpr_hndl_failure'
     ,@tst_num2 VARCHAR(6) = test.fnGetCrntTstNum2()
     ,@msg      VARCHAR(500)
   ;
   SET NOCOUNT ON;
   -- Display applog up and down
   EXEC sp_log 0, @fn, '000: starting';
   EXEC sp_appLog_display;-- 0;
   --EXEC sp_appLog_display 1;
   SET @msg = 
      CONCAT
      (
        test.fnGetCrntTstFn(), '.', test.fnGetCrntSubTst()
       , @msg1
       ,iif(@msg1 IS NULL, '', CONCAT(' ', @msg2))
       ,iif(@msg2 IS NULL, '', CONCAT(' ', @msg3))
       ,iif(@msg3 IS NULL, '', CONCAT(' ', @msg4))
       );
   PRINT test.fnGetTstHdrFooterLine(1, 0, @msg, 'failed');
   EXEC sp_log 1, @fn, '900: leaving';
END
/*
EXEC tSQLt.Run 'test.test_013_sp_pop_AttendanceDates';
EXEC [test].[sp_tst_hlpr_st] 'MyFn', 'T010: MyFn'
EXEC test.sp_tst_hlpr_hndl_failure
PRINT test.fnGetCrntTstFn()
*/
GO

