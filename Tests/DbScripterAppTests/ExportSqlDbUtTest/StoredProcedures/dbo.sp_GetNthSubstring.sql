SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 27-MAY-2020
-- Description: gets the n-th substring in str separated by sep
--              1 based numbering but [0] and [1] return 
--                the first element in the sequence
-- =============================================================
CREATE PROCEDURE [dbo].[sp_GetNthSubstring]
    @input_str    NVARCHAR(4000)
   ,@sep          NVARCHAR(100)
   ,@ndx          INT
   ,@sub          NVARCHAR(4000) OUT
AS
BEGIN
   DECLARE 
      @fn            NVARCHAR(50) = N'sp_GetNthSubstring'
     ,@s2            NVARCHAR(4000)
     ,@dblQuotePos   INT
     ,@sepPos        INT    = 0
     ,@p2            INT    = 0
     ,@len           INT    = 0
     ,@lenStr        INT
     ,@msg           NVARCHAR(100)
   WHILE 1=1
   BEGIN
         EXEC sp_log 1, @fn, '01: starting'
      -- Validation:
      -- 1: separator not empty or null
      EXEC sp_assert_not_null_or_empty @sep, 'separator must be specified'
      SET @lenStr = ut.dbo.fnLen(@input_str);
      EXEC sp_assert_not_equal 0, @lenStr, '@input_str must be specified';
      --------------------------------
      -- ASSERTION: input string is not empty
      --------------------------------
      -- Look for the separator in the @input_str
      SET @sepPos = CHARINDEX(@sep, @input_str);
      EXEC sp_log 1, @fn, '05: starting @input_str:[',@input_str,'] @ndx:[', @ndx,'] @sepPos: ',@sepPos
      -- if sep not found and this is the final section then return the @input_str as the required section
      IF (@sepPos = 0) AND (@ndx = 1)
      BEGIN
         SET @sub = @input_str;
         SET @msg = CONCAT(@sub, '] end separator not found');
         EXEC sp_log 4, @fn, '10: leaving 1: @sub:[', @sub, '] end separator not found'
         EXEC sp_raise_exception ;
         BREAK;
      END
      -- If sep is the last char and this is the final section: then return (final substr less the end sep) as the required section
      IF (@sepPos = @lenStr) AND (@ndx = 1)
      BEGIN
         SET @sub =  substring(@input_str, 1 , @lenStr-1);
         EXEC sp_log 1, @fn, '15: leaving 2: @sub:[', @sub, '] end separator at end of string'
         BREAK;
      END
      SET @len = iif(@sepPos > @lenStr ,@sepPos-1, @sepPos);
      EXEC sp_log 1, @fn, '20: @len:[', @len, ']'
      --------------------------------
      -- Handle double quotes
      --------------------------------
      SET @dblQuotePos = CHARINDEX('"', @input_str);
      EXEC sp_log 1, @fn, '25: first dblQuotePos: ', @dblQuotePos, ' @sepPos: ', @sepPos
      -- If dblQuotePos > snglQuotePos
      IF (@dblQuotePos > 0) AND (@dblQuotePos < @sepPos)
      BEGIN
         EXEC sp_log 1, @fn, '30: handling double quotes'
         -- Get the second dblQuotePos, must exist
         SET @dblQuotePos = CHARINDEX('"', @input_str, @dblQuotePos + 1);
         EXEC sp_assert_gtr_than @dblQuotePos, 1, ' end double quote not found'
         -- Set the singlQuotePos to the first single quote after the second dblQuotePos
         -- OR Len if no subsequent  singlQuotePos
         SET @sepPos = CHARINDEX(@sep, @input_str, @dblQuotePos);
         EXEC sp_log 1, @fn, '35: @dblQuotePos end dbl quote: ', @dblQuotePos, ' @sepPos: ', @sepPos
      END
      -------------------------------------------------------
      -- ASSERTION:  @snglQuotePos set and " Quote handled
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '40: @sepPos: ', @sepPos
      -- If this is the required section
      IF @ndx <= 1
      BEGIN
         -------------------------------------------------------
         -- ASSERTION: this is the required section
         -------------------------------------------------------
         -- If no more sections set @sepPos to len-1
         IF @sepPos = 0
         BEGIN
            EXEC sp_log 1, @fn, '45: no more sections, so set @sepPos to len+1'
            SET @sepPos = @lenStr + 1;
         END
         -- Return the substring from start to separator or the end of the string if sep not found
         EXEC sp_log 1, @fn, '50: End case: ndx: ', @ndx, ' @sepPos: ', @sepPos
         SET @sub  = SUBSTRING(@input_str, 1, @sepPos - 1);
      END
      ELSE
      BEGIN
         -- This is not the required section
         EXEC sp_log 1, @fn, '55: This is not the required section: @ndx: ', @ndx
      -- The end separator may not be present - may be the last section in which case pos: 0 so take the length of the string
      -- May be there are no more sections, if so return ''
         IF @sepPos = 0
         BEGIN
            EXEC sp_log 1, @fn, '60: no more sections, if so returning "" '
            SET @sub = '';
            RETURN;
         END
         -------------------------------------------------------
         -- ASSERTION: not the required sect and there are more sections
         -------------------------------------------------------
         -- Get rest of the string after the separator
         -- call  fnGetNthSubstring passing rest of the string after the separator,
         -- and the required index -1, and sep
         -- Recursive SUBSTRING(@s, @p1+len(@sep), len(@s)-@p1);
         SET @p2 = @sepPos + len(@sep);
         SET @s2 = SUBSTRING(@input_str, @p2, @lenStr-@p2+1);
         SET @ndx = @ndx-1
         -- callfnGetNthSubstring2 recursively decrementing the @ndx index
         EXEC sp_GetNthSubstring @s2, @sep, @ndx, @sub OUT;
      END
      BREAK;
   END -- WHILE 1=1
   EXEC sp_log 1, @fn, '99: leaving: @input_str:[',@input_str,'] @ndx:[', @ndx,'] @sub:[',  @input_str, ':[', @input_str,'] @ndx:', @ndx,' @sub:[',@sub, ']'
END
/*
exec test.testspGetNthSubstring
exec test.testspGetNthSubstring_2
exec test.testspGetNthSubstring_3
exec test.testspGetNthSubstring_4
exec test.testspGetNthSubstring_5
exec test.testspGetNthSubstring_4
tSQLt.Run 'test.testspGetNthSubstring'
tSQLt.Run 'test.testspGetNthSubstring_2'
tSQLt.Run 'test.testspGetNthSubstring_3'
tSQLt.Run 'test.testspGetNthSubstring_4'
*/
GO

