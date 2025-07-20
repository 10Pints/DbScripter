SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================
-- Author:      Terry
-- Create date: 04-FEB-2021
-- Description: Gets the current tested fn name from settings
-- Key:         N'Tested fn'
-- Tests:       test.test 030 chkTestConfig
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstdFnKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Tested fn';
END


GO
