SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: Sets the @tst_num in the session context
--              Key: fnGetCrntTstNumKey()->N'Test num'
--
-- Tests:       test.test_049_SetGetCrntTstValue
-- Oppo         test.fnGetCrntTstNum()
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_num] @tst_num VARCHAR(60)
AS
BEGIN
DECLARE
    @fn     VARCHAR(35) = 'sp_tst_set_crnt_tst_num'
   ,@key    NVARCHAR(60);
   SET @key = test.fnGetCrntTstNumKey();
   EXEC sp_log 0, @fn,'000: starting, fn: ', @fn, ' key:[', @key,'] @tst_num:[',@tst_num,']';
   EXEC sp_set_session_context @key, @tst_num;
END
/*
EXEC tSQLt.Run 'test.test_030_chkTestConfig'
EXEC tSQLt.RunAll
*/
GO

