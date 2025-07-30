SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current per test fn name from settings
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstSetupFnKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'TSU fn';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/
GO

