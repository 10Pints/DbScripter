SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 05-FEB-2021
-- Description: Setter
-- Tests: [test].[test 030 chkTestConfig]
-- Key: N'Failed test num'
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_failed_tst_num] @val NVARCHAR(60)
AS
BEGIN
   DECLARE @key NVARCHAR(60);
   SET @key = test.fnGetCrntFailedTstNumKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/
GO

