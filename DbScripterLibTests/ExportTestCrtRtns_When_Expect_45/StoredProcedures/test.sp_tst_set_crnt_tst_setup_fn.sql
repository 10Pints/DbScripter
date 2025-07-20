SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests:       test 030 chkTestConfig
-- Key:         N'TSU fn'
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_setup_fn] @val VARCHAR(80)
AS
BEGIN
   DECLARE @key NVARCHAR(40) = test.fnGetCrntTstSetupFnKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetCrntTstSetupFnKey()
*/



GO
