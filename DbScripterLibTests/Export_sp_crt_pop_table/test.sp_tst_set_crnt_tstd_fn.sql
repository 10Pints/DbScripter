SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests:       test_030_chkTestConfig
-- Key:         'Tested fn'
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tstd_fn] @val VARCHAR(80)
AS
BEGIN
   DECLARE @key NVARCHAR(40) = test.fnGetCrntTstdFnKey();
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC tSQLt.Run 'test.test_030_chkTestConfig';
EXEC tSQLt.RunAll;
PRINT test.fnGetCrntTstdFnKey();
*/


GO
