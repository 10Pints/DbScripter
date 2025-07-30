SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: Gets the current ErrorStateKey key
-- Tests: test_049_SetGetCrntTstValue
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstErrStKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'Error state';
END
/*
EXEC tSQLt.Run 'test_049_SetGetCrntTstValue'
EXEC tSQLt.RunAll
*/
GO

