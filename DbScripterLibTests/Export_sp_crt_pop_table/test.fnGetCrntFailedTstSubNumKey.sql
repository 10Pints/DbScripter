SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: settings key for the current failed test number
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntFailedTstSubNumKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Failed test sub num';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/



GO
