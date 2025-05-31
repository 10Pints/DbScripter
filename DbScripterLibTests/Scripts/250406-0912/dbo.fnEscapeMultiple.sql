SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================
-- Author:      Terry Watts
-- Create date: 27-NOV-2024
-- Description: returns rex for multiple search special characters
-- Returns the input replaces using the replace cls upto ndx chars
-- ================================================================
ALTER   FUNCTION [dbo].[fnEscapeMultiple]( @search_clause VARCHAR(MAX), @ndx int, @depth INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
   DECLARE
    @c NCHAR(1) 
   ,@replC         NCHAR(2)
   ,@special_chars VARCHAR(35)='#&*()<>?-_!@$%^=+[]{}\\|;'':",./'
   ;

   SET @c = SUBSTRING(@search_clause, @ndx, 1);

   if @ndx<1 SET @ndx = 1;

   if(@depth>31)
   BEGIN
      SET @search_clause = CONCAT(@search_clause, 'too much recursion: ', @depth);
      return @search_clause;
   END

   SET @c = SUBSTRING(@search_clause, @ndx, 1);

   /*
   if dbo.fnLen(@c) = 0 
   BEGIN
      --SET @ndx = @ndx/0;
      SET @search_clause = CONCAT(@search_clause, '@ndx: ', @ndx, ' null char');
      RETURN @search_clause;
   END
   */

   -- If the @ndx character of the @search_clause is a special character escape it
   IF CHARINDEX(@c, @special_chars) > 0
   BEGIN
      SET @replC = CONCAT('\\', @c);
      SET @search_clause = STUFF(@search_clause, @ndx, 1, @replC);
      SET @search_clause = CONCAT(@search_clause, 'found special character: ', @replC);
--      return @search_clause;
   END
   SET @search_clause = CONCAT(@search_clause, ':',@c)
   --SET @search_clause = CONCAT(@search_clause, ' ndx: ', @ndx, ' c:[',@c,'] depth: ',@depth);

   -- Recursive: work forwards skipping over added escape characters
   IF(@ndx < dbo.fnLen(@search_clause)-1) AND @depth<20
      SET @search_clause = dbo.fnEscapeMultiple( @search_clause, @ndx + dbo.fnLen(@replC)+2, @depth+1)

   RETURN @search_clause;
END
/*
SELECT 'the quick \brown fox' as old, dbo.fnEscapeMultiple('the quick \brown fox', 1, 1) as new;
SELECT '\#&*()<>?-_!@$%^=+[]{}/|;'':",.' as pattern, dbo.fnEscapeMultiple('unused', '\#&*()<>?-_!@$%^=+[]{}/|;'':",.', 'unused2', 29) as new;
SELECT '\#&*()<>?-_!@$%^=+[]{}/|;'':",.' as pattern, dbo.fnEscapeMultiple('unused', '\#&*()<>?-_!@$%^=+[]{}/|;'':",.', 'unused2', 28) as new;
SELECT '\#&*()<>?-_!@$%^=+[]{}/|;'':",.' as pattern, dbo.fnEscapeMultiple('unused', '\#&*()<>?-_!@$%^=+[]{}/|;'':",.', 'unused2', 27) as new;
SELECT '\#&*()<>?-_!@$%^=+[]{}/|;'':",.' as pattern, dbo.fnEscapeMultiple('unused', '\#&*()<>?-_!@$%^=+[]{}/|;'':",.', 'unused2', 26) as new;
SELECT '\#&*()<>?-_!@$%^=+[]{}/|;'':",.' as pattern, dbo.fnEscapeMultiple('unused', '\#&*()<>?-_!@$%^=+[]{}/|;'':",.', 'unused2', 25) as new;
SELECT '\#&*()<>?-_!@$%^=+[]{}/|;'':",.' as pattern, dbo.fnEscapeMultiple('unused', '\#&*()<>?-_!@$%^=+[]{}/|;'':",.', 'unused2', 24) as new;
SELECT '\#&*()<>?-_!@$%^=+[]{}/|;'':",.' as pattern, dbo.fnEscapeMultiple('unused', '\#&*()<>?-_!@$%^=+[]{}/|;'':",.', 'unused2', 23) as new;
SELECT '\#&*()<>?-_!@$%^=+[]{}/|;'':",.' as pattern, dbo.fnEscapeMultiple('unused', '\#&*()<>?-_!@$%^=+[]{}/|;'':",.', 'unused2', 22) as new;
SELECT '\#&*()<>?-_!@$%^=+[]{}/|;'':",.' as pattern, dbo.fnEscapeMultiple('unused', '\#&*()<>?-_!@$%^=+[]{}/|;'':",.', 'unused2', 21) as new;
SELECT '\#&*()<>?-_!@$%^=+[]{}/|;'':",.' as pattern, dbo.fnEscapeMultiple('unused', '\#&*()<>?-_!@$%^=+[]{}/|;'':",.', 'unused2', 20) as new;

*/


GO
