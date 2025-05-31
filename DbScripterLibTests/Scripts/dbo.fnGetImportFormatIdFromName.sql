SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 06-NOV-2023
-- Description: returns the format id for provided import name (@import_nm)
--                or -1 if not recognised
--                import_nm can be part of a larger string
--
-- Tests: test.test_fnGetImportFormatIdFromName
--
-- Changes:
-- =============================================================================
ALTER FUNCTION [dbo].[fnGetImportFormatIdFromName]( @path NVARCHAR(250))
RETURNS int
AS
BEGIN
   DECLARE @file_nm NVARCHAR(MAX)
   SET @file_nm = ut.dbo.fnGetFileNameFromPath(@path, 1);

   RETURN
      IIF(@file_nm LIKE '%221018%', 1,
      IIF(@file_nm LIKE '%230721%', 2,
      IIF(@file_nm LIKE '%231025%', 2,   -- 231025 is the same format as 230721 but the corrections are different
                                   -1))) --  -1 =(Fmt not found) will stop the operations
;
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
