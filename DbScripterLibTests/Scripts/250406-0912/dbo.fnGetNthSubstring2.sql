SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 27-MAY-2020
-- Description: gets the n-th substring in str separated by sep
--              1 based numbering but [0] and [1] return 
--                the first element in the sequence
-- =============================================================
ALTER FUNCTION [dbo].[fnGetNthSubstring2]
(
    @input_str    NVARCHAR(4000)
   ,@sep          NVARCHAR(100)
   ,@ndx          INT
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE
      @s             NVARCHAR(4000) = @input_str
     ,@s2            NVARCHAR(4000)
     ,@dblQuotePos   INT
     ,@separatorPos  INT    = 0
     ,@p2            INT    = 0
     ,@len           INT    = 0
     ,@lenStr        INT    = ut.dbo.fnLen(@input_str)
     ,@sub           NVARCHAR(4000)

   WHILE 1=1
   BEGIN
      -- Validation:
      -- 1: separator not empty or null
      -- Look for the separator in the @input_str
      SET @separatorPos  = CHARINDEX(@sep, @s);

      -- if not found then return the final substr
      IF @separatorPos = 0
      BEGIN
         SET @sub = @input_str;
         BREAK;
      END

      -- if is last char then return the final substr less the end sep
      IF @separatorPos = @lenStr
      BEGIN
         SET @sub =  substring(@input_str, 1 , @lenStr-1);
         BREAK;
      END

      SET @len = iif(@separatorPos > @lenStr ,@separatorPos-1, @separatorPos);

      -- Look for a double quote in the current section, - note dblQuotePos
      SET @dblQuotePos = CHARINDEX('"', @s);

      -- If dblQuotePos > snglQuotePos
      IF @dblQuotePos < @separatorPos
      BEGIN
         -- Get the second dblQuotePos, must exist
         SET @dblQuotePos = CHARINDEX('"', @s, @dblQuotePos + 1);
         -- Set the singlQuotePos to the first single quote after the second dblQuotePos
         -- OR Len if no subsequent  singlQuotePos
         SET @separatorPos = CHARINDEX(@sep, @s, @dblQuotePos);

         -- The end separator may not be present - may be the last in which case pos: 0 so take the length of the string
         -- May be its the last section
         IF @separatorPos = 0
         BEGIN
            SET @separatorPos = @lenStr + 1;
         END
      END

      -- ASSERTION:  @snglQuotePos set and " Quote handled

      IF @ndx > 1
      BEGIN
         -- call  fnGetNthSubstring passing rest of the string after the separator,
         -- and the required index -1, and sep
         -- Recursive SUBSTRING(@s, @p1+len(@sep), len(@s)-@p1);
         SET @p2 = @separatorPos + len(@sep);

         -- May be no more sections in the string
         IF @p2>@lenStr
         BEGIN
            SET @sub = '';
            BREAK;
         END

         SET @s2 = SUBSTRING(@s, @p2, len(@s)-@p2+1);
         SET @ndx = @ndx-1
         -- callfnGetNthSubstring2 decrementing the @ndx index
         SET @sub = dbo.fnGetNthSubstring2( @s2, @sep, @ndx);
      END
      ELSE
      BEGIN
         -- End case:
         -- Return the substring from start to separator
         SET @sub  = SUBSTRING(@s, 1, @separatorPos - 1);
      END

      BREAK;
   END

   RETURN @sub
END

/*
EXEC test.testfnGetNthSubstring2
EXEC test.testfnGetNthSubstring2_4
*/

GO
