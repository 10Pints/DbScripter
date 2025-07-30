SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: Gets the current test helper fn name from settings
-- Key:         N'Test num'
-- Tests:       test.test 030 chkTestConfig
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstNum]()
RETURNS VARCHAR(60)
AS
BEGIN
   RETURN CONVERT(VARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTstNumKey()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test_030_chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetCrntTstNumKey();
*/
GO

