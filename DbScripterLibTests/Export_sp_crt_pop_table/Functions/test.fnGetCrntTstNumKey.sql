SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: settigns key for the current test number
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstNumKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Test num';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
