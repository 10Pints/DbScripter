SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 06-FEB-2021
-- Description: settings key for the failes test sub number
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetTstPassCntKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Passed test count';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
