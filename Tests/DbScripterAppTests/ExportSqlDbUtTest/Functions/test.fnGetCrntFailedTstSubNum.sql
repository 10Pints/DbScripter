SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets current the failed test sub number from settings
-- Tests:       test 030 chkTestConfig
-- Key:         N'Failed test sub num'
-- ====================================================================
CREATE FUNCTION [test].[fnGetCrntFailedTstSubNum]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN CONVERT(NVARCHAR(60), SESSION_CONTEXT(test.fnGetCrntFailedTstSubNumKey()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetCrntFailedTstSubNumKey();
EXEC test.sp_tst_set_crnt_failed_tst_sub_num N'04.18'
PRINT test.fnGetCrntFailedTstSubNum();
*/
GO

