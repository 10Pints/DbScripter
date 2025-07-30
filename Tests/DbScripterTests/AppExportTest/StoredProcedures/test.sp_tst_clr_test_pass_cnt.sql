SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:      Terry watts
-- Create date: 06-FEB-2021
-- Description: Setter, clears the test pass count
-- Tests: test.test_030_chkTestConfig
-- ================================================
CREATE PROCEDURE [test].[sp_tst_clr_test_pass_cnt]
AS
BEGIN
   DECLARE @key NVARCHAR(40) = test.fnGetTstPassCntKey()
   EXEC sp_set_session_context @key, 0;
END
/*
EXEC test.test 030 chkTestConfig;
*/
GO

