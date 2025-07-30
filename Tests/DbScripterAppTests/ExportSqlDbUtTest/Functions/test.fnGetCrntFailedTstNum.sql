SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the failed test number  from settings
-- Tests: [test].[test 030 chkTestConfig]
-- Key: N'Failed test num'
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntFailedTstNum]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN CONVERT(NVARCHAR(80), SESSION_CONTEXT(test.fnGetCrntFailedTstNumKey()));
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
EXEC [test].[sp_tst_set_crnt_failed_tst_num] N'xyz';
PRINT [test].[fnGetCrntFailedTstNum]();
DECLARE @v NVARCHAR(60)=N'qabcd'
EXEC sp_set_session_context N'Failed test num', @v;
PRINT CONVERT(NVARCHAR(60), SESSION_CONTEXT(N'Failed test num'));
*/
GO

