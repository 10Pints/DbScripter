SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ================================================================
-- Author:      Terry Watts
-- Create date: 27-NOV-2024
-- Description: returns rex for multiple search special characters
-- Returns the input replaces using the replace cls upto ndx chars
-- ================================================================
CREATE FUNCTION [dbo].[fnRegExMultiple]( @input VARCHAR(MAX), @pattern VARCHAR(1000), @replace_clause VARCHAR(MAX), @ndx int)
RETURNS VARCHAR(MAX)
AS
BEGIN
   DECLARE
    @v VARCHAR(MAX)
   ,@c NCHAR(1) = SUBSTRING(@pattern, @ndx, 1)
   ,@special_chars VARCHAR(35)='#&*()<>?-_!@$%^=+[]{}'+ NCHAR(92) +'|;'':",./'
   ,@replaceChar NCHAR(2)
   ;

   --SET @pattern = CONCAT(@pattern, ' @ndx: ', @ndx); -- debug

   IF CHARINDEX(@c, @special_chars) > 0
   BEGIN
   SET @replaceChar =  CONCAT(NCHAR(92), @c);
   SET @v = STUFF(@pattern, @ndx, len(@c), @replaceChar);
   END
   ELSE
      SET @v =  CONCAT('log: ',@c); --@pattern;@pattern; --

   -- Reucrsive
   IF(@ndx < LEN(@pattern))
      SET @v = dbo.fnRegExMultiple(@input, @v, @replace_clause,  @ndx + LEN(@replaceChar))

   RETURN @v;
END
/*
*/

GO
