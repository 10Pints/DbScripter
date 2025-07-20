SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current tested fn name from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstdFn]()
RETURNS VARCHAR(60)
AS
BEGIN
   RETURN CONVERT(VARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTstdFnKey()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
