SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: Sets the @tst_num in the session context
--              Key: fnGetCrntTstNumKey()->N'Test num'
-- Tests:       test.test 030 chkTestConfig
-- Oppo         test.fnGetCrntTstNum()
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_num] @tst_num NVARCHAR(60)
AS
BEGIN
   DECLARE @key NVARCHAR(40);
   SET @key = test.fnGetCrntTstNumKey();
   EXEC sp_set_session_context @key, @tst_num;
END
/*
EXEC tSQLt.Run 'test.test_030_chkTestConfig'
EXEC tSQLt.RunAll
EXEC test.sp_tst_set_crnt_tst_num '186'
PRINT test.fnGetCrntTstNum();
PRINT test.fnGetCrntTstNumKey();
*/
GO

