SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry
-- Create date: 03-DEC-2024
-- Description: Gets the current failed test num from settings
-- Tests: test_049_SetGetCrntTstValue
-- =============================================================
CREATE FUNCTION [test].[fnGetCrntTst1OffSetupFnKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Tst1OffSetupFn';
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/
GO

