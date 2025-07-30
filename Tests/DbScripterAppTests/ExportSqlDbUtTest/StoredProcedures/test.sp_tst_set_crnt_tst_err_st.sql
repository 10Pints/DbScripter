SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:      Terry watts
-- Create date: 05-FEB-2021
-- Description: setter: error_state
-- Tests: [test].[test 030 chkTestConfig]
-- =================================================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_err_st] @val BIT
AS
BEGIN
   DECLARE @key NVARCHAR(40);
   SET @key = test.fnGetCrntTstErrStKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/
GO

