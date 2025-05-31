SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================================================================================
-- Author:      Terry Watts
-- Create date: 29-MAR-2024
-- Description: returns the import root
--
-- Tests:
--
-- Changes:
-- ===========================================================================================================
ALTER   FUNCTION [dbo].[fnGetImportRoot]()
RETURNS VARCHAR(500)
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsString(dbo.fnGetSessionKeyImportRoot());
END
/*
EXEC tSQLt.RunAll;
*/


GO
