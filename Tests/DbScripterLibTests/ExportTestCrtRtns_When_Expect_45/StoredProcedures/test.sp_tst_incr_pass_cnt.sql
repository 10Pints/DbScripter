SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 06-FEB-2021
-- Description: Setter, clears the test pass count
-- Tests: [test].[test 030 chkTestConfig]
-- Returns: the cremented test count
-- =============================================
CREATE PROCEDURE [test].[sp_tst_incr_pass_cnt]
AS
BEGIN
   DECLARE @key NVARCHAR(60)
         , @cnt INT;
   SET @key = test.fnGetTstPassCntKey();
   SET @cnt = test.fnGetTstPassCnt() + 1;
   EXEC sp_set_session_context @key, @cnt;
   RETURN @cnt;
END
GO

