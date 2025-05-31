SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================
-- Author:      Terry Watts
-- Create date: 29-MAR-2024
-- Description: returns the import root key
--
-- Tests:
--
-- Changes:
-- ===========================================================================================================
ALTER FUNCTION [dbo].[fnGetSessionKeyImportRoot]()
RETURNS NVARCHAR(500)
AS
BEGIN
   RETURN N'Import Root';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.fnGetImportFormatIdFromName';
PRINT dbo.fnGetImportFormatIdFromName('asdf221008zyz'); -- should be  1
PRINT dbo.fnGetImportFormatIdFromName('230721zyz');     -- should be  2
PRINT dbo.fnGetImportFormatIdFromName('231025zyz');     -- should be  2
PRINT dbo.fnGetImportFormatIdFromName('230722zyz');     -- should be -1
PRINT dbo.fnGetImportFormatIdFromName('23072zyz');      -- should be -1
PRINT ut.dbo.fnGetFileNameFromPath(@path); 
*/

GO
