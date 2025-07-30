SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 20-NOV-2024
-- Description: Sets the @tst_num2 ctx this is the numeirc part of the sub test name
--              Key: fnGetCrntTstNum2Key()->N'Test num2'
-- Tests:       test.test_049_SetGetCrntTstValue
-- Oppo         test.fnGetCrntTstNum()
-- ==================================================================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_num2] @tst_num VARCHAR(3)
AS
BEGIN
   DECLARE
    @fn     VARCHAR(35) = 'sp_tst_set_crnt_tst_num2'
   ,@key    NVARCHAR(60);
   SET @key = test.fnGetCrntTstNum2Key();
   EXEC sp_log 0, @fn,'000: starting, fn: ', @fn, ' key:[', @key,'] @tst_num:[',@tst_num,']';
   EXEC sp_set_session_context @key, @tst_num;
   EXEC sp_log 0, @fn,'999: leaving';
END
/*
EXEC tSQLt.Run 'test.test_049_SetGetCrntTstValue'
EXEC tSQLt.RunAll
*/
GO

