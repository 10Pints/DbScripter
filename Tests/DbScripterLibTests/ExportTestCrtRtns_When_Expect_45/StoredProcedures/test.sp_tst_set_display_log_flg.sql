SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests:       test_030_chkTestConfig
-- Key:         Display Log Flag
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_display_log_flg] @val BIT
AS
BEGIN
   DECLARE @key NVARCHAR(6) = test.fnGetDisplayLogFlgKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetDisplayLogFlgKey()
*/
GO

