SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===========================================================================
-- Author:      Terry
-- Create date: 20-NOV-2024
-- Description: gets the settings key for the current test number like T001
-- Tests: [test].[test 030 chkTestConfig]
-- ===========================================================================
CREATE FUNCTION [test].[fnGetCrntTstNum2Key]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Test num2';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
*/


GO
