SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================================
-- Author:      Terry Watts
-- Create date: 20-NOV-2024
-- Description: Gets the current tst_num2 from the session context
--              This is the 3 digit int number only part of the sub test identifier
-- Key:         N'Test num'
-- Tests:       test.test 030 chkTestConfig
-- =================================================================================
CREATE FUNCTION [test].[fnGetCrntTstNum2]()
RETURNS VARCHAR(3)
AS
BEGIN
   RETURN CONVERT(VARCHAR(3), SESSION_CONTEXT(test.fnGetCrntTstNum2Key()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test_030_chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetCrntTstNumKey();
*/
GO

