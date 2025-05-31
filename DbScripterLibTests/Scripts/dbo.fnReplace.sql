SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================
-- Author:		 Terry Watts>
-- Create date: 01-JUL-2023
-- Description: Replace alternatie for hanling wsp, comma
-- ==========================================================
ALTER FUNCTION [dbo].[fnReplace](@src NVARCHAR(MAX), @old NVARCHAR(MAX), @new NVARCHAR(MAX)) 
RETURNS NVARCHAR(MAX)
AS
BEGIN

DECLARE 
    @ndx INT
   ,@len INT

   IF(@src IS NULL)
      return @src;

   SET @len = Ut.dbo.fnLen(@old);
   SET @ndx = CHARINDEX(@old, @src);

   IF(@ndx = 0)
      return @src;

   WHILE @ndx > 0
   BEGIN
      SET @src = STUFF(@src, @ndx, @len, @new);
      SET @ndx = CHARINDEX(@old, @src);
   END

   RETURN @src;
END

/*
SELECT dbo.fnReplace('ab ,cde ,def, ghi,jk', ' ,', ',' );   
SELECT dbo.fnReplace('ab ,cde ,def, ghi,jk, lmnp', ', ', ',' );   
SELECT dbo.fnReplace('abcdefgh', 'def', 'xyz' );   -- abcxyzgh
SELECT dbo.fnReplace(null, 'cd', 'xyz' );          -- null
SELECT dbo.fnReplace('', 'cd', 'xyz' );            -- ''
SELECT dbo.fnReplace('as', '', 'xyz' );            -- 'as'
*/

GO
