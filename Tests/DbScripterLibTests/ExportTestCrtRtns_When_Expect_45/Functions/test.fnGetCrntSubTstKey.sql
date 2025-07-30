SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry
-- Create date: 03-DEC-2024
-- Description: gets the current sub test id key
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntSubTstKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Current sub test';
END
/*
PRINT test.fnGetCrntSubTstKey()
*/
GO

