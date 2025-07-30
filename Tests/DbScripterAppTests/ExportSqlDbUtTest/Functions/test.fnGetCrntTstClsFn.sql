SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current close fn name from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstClsFn]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN CONVERT(NVARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTstClsFnKey()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/
GO

