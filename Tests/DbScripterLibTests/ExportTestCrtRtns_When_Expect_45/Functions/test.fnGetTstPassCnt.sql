SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry
-- Create date: 06-FEB-2021
-- Description: Gets the failed test number  from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetTstPassCnt]()
RETURNS INT
AS
BEGIN
   DECLARE @cnt INT;
   SET @cnt = CONVERT(INT, SESSION_CONTEXT(test.[fnGetTstPassCntKey]()));
   IF @cnt IS NULL  -- handle null as we are incrmenting this
      SET @cnt = 0;
   RETURN @cnt
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/
GO

