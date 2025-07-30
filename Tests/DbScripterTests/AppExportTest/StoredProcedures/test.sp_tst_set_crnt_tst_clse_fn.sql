SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 04-FEB-2021
-- Description: Accessor
-- Tests:       test_049_SetGetCrntTstValue
-- Oppo:        test.fnGetCrntTstClseFn
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_clse_fn] @val VARCHAR(80)
AS
BEGIN
   DECLARE
    @fn  VARCHAR(35) = N'sp_tst_set_crnt_tst_clse_fn'
   ,@key NVARCHAR(40);
   SET @key = test.fnGetCrntTstClsFnKey()
   EXEC sp_log 0, @fn,'000: starting, @val: ', @val;
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.test_049_SetGetCrntTstValue
EXEC tSQLt.RunAll
*/
GO

