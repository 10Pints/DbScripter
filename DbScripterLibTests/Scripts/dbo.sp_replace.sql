SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- ==============================================================
-- Author:		 Terry Watts>
-- Create date: 01-JUL-2023
-- Description: Replace alternative for handling wsp, comma
-- See also dbo.fnReplace(@src, @old, @new)
-- This routine is used to debug dbo.fnReplace(@src, @old, @new)
-- ==============================================================
CREATE PROC [dbo].[sp_replace]
   @src NVARCHAR(MAX), 
   @old NVARCHAR(MAX), 
   @new NVARCHAR(MAX),
   @out NVARCHAR(MAX) OUT
AS
BEGIN
   SET @out = dbo.fnReplace(@src, @old, @new);
   PRINT CONCAT('spReplace: @src:[', @src, '], @old:[', @old, '] @new:[', @new, '] @out:[', @out, ']');
END
/*
DECLARE @out NVARCHAR(MAX);
EXEC sp_replace 'ab ,cde ,def, ghi,jk', ' ,', ',', @out OUT;   
EXEC sp_replace 'ab ,cde ,def, ghi,jk, lmnp', ', ', ',' , @out OUT;   
EXEC sp_replace 'abcdefgh', 'def', 'xyz', @out OUT;   -- abcxyzgh
EXEC sp_replace null, 'cd', 'xyz', @out OUT;          -- null
EXEC sp_replace '', 'cd', 'xyz', @out OUT;           -- ''
EXEC sp_replace 'as', '', 'xyz', @out OUT;           -- 'as'

SELECT dbo.fnReplace('ab ,cde ,def, ghi,jk', ' ,', ',' );   
SELECT dbo.fnReplace('ab ,cde ,def, ghi,jk, lmnp', ', ', ',' );   
SELECT dbo.fnReplace('abcdefgh', 'def', 'xyz' );   -- abcxyzgh
SELECT dbo.fnReplace(null, 'cd', 'xyz' );          -- null
SELECT dbo.fnReplace('', 'cd', 'xyz' );            -- ''
SELECT dbo.fnReplace('as', '', 'xyz' );            -- 'as'
*/

GO
