SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================
-- Author:      Terry watts
-- Create date: 05-FEB-2021
-- Description: Setter
-- Tests: test_049_SetGetCrntTstValue
-- ====================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_failed_tst_sub_num] @val VARCHAR(60)
AS
BEGIN
   DECLARE @key NVARCHAR(40);
   SET @key = test.fnGetCrntFailedTstSubNumKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
*/
GO

