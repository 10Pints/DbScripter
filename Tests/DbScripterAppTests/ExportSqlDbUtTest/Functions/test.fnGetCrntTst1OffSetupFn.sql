SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current 1 off test fn name from settings
-- Tests: test 030 chkTestConfig
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTst1OffSetupFn]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN CONVERT(NVARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTst1OffSetupFnKey()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/
GO

