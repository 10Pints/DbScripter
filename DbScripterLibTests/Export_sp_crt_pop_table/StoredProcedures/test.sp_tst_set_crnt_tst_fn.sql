SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests: [test].[test 030 chkTestConfig]
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_fn] @val VARCHAR(80)
AS
BEGIN
   DECLARE @key NVARCHAR(40) = test.fnGetCrntTstFnKey();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/


GO
