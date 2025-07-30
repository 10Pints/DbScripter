SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: Gets the current test sub number from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstSubNum]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN CONVERT(NVARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTstSubNumKey()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/
GO

