SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: Gets the current ErrorStateMsg
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstErrMsg]()
RETURNS NVARCHAR(4000)
AS
BEGIN
   RETURN CONVERT( NVARCHAR(4000), SESSION_CONTEXT(test.fnGetCrntTstErrMsgKey()));
END
/*
PRINT test.fnGetCrntTstErrMsg();
*/
GO

