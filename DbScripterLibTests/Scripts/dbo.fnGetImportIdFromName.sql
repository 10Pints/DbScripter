SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================================================
-- Author:      Terry Watts
-- Create date: 21-AUG-2023
-- Description: returns the id for provided import name (@import_nm)
--                or -1 if not recognised
--                import_nm can be part of a larger string
--
-- Tests: test.test_fnGetImportIdFromName
--
-- Changes:
-- 231103: added a new import name 231025  Format: 2; same as 230721
-- 231103: just use the file name not the whole path to determine the type
-- 231106: made 231025 a new format. It is the same format as 230721 but the set of corrections are different
-- ===========================================================================================================
ALTER FUNCTION [dbo].[fnGetImportIdFromName]( @path NVARCHAR(250))
RETURNS int
AS
BEGIN
   DECLARE @file_nm NVARCHAR(MAX)
   SET @file_nm = ut.dbo.fnGetFileNameFromPath(@path, 0);

   RETURN
      IIF(@file_nm LIKE '%221018%', 1,
      IIF(@file_nm LIKE '%230721%', 2,
      IIF(@file_nm LIKE '%231025%', 3, -1))) --  -1 =(Fmt not found) will stop the operations
;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_fnGetImportIdFromName';
PRINT dbo.fnGetImportIdFromName('asdf221008zyz'); -- should be  1
PRINT dbo.fnGetImportIdFromName('230721zyz');     -- should be  2
PRINT dbo.fnGetImportIdFromName('230722zyz');     -- should be -1
PRINT ut.dbo.fnGetFileNameFromPath(@path); 
*/

GO
