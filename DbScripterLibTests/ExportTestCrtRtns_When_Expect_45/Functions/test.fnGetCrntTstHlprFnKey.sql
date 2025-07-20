SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current close fn name from settings
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstHlprFnKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Hlpr fn';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
