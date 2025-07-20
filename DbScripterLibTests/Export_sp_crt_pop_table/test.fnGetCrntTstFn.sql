SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current test fn name from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstFn]()
RETURNS VARCHAR(60)
AS
BEGIN
   RETURN CONVERT(VARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTstFnKey()));
END

/*
PRINT [test].[fnGetCurrentTestFnName]()

EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
