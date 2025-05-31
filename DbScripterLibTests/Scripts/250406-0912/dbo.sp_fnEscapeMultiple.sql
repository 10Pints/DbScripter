SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================
-- Author:      Terry Watts
-- Create date: 27-NOV-2024
-- Description: returns rex for multiple search special characters
-- Returns the input replaces using the replace cls upto ndx chars
-- ================================================================
ALTER   PROCEDURE [dbo].[sp_fnEscapeMultiple]
  @sc  VARCHAR(MAX) OUT
, @ndx int, @depth INT
--RETURNS VARCHAR(MAX)
AS
BEGIN
   DECLARE
    @fn            VARCHAR(35)
   ,@c             NCHAR(1) 
   ,@replC         NCHAR(2)
   ,@special_chars VARCHAR(35)='#&*()<>?-_!@$%^=+[]{}\\|;'':",./'
   ,@lenSCc         INT
   ,@lenSC         INT
   ,@sc_new        VARCHAR(MAX)
   ;

--   EXEC sp_log 1, @fn, '000: starting, @ndx: ', @ndx, ' @depth: ', @depth
   SET @lenSC = dbo.fnLen(@sc)

   SET @c = SUBSTRING(@sc, @ndx, 1);

   if @ndx<1 SET @ndx = 1;

   if(@depth>31)
   BEGIN
      SET @sc = CONCAT(@sc, 'too much recursion: ', @depth);
      EXEC sp_log 1, @fn, '010: too much recursion:  leaving';
      THROW 6000, '010: too much recursion', 1;
      RETURN;-- @sc;
   END

   SET @c = SUBSTRING(@sc, @ndx, 1);

   -- If the @ndx character of the @sc is a special character escape it
   IF CHARINDEX(@c, @special_chars) > 0
   BEGIN
      SET @replC = CONCAT('\\', @c);
      SET @sc = STUFF(@sc, @ndx, 1, @replC);
   END
   ELSE
   BEGIN
      SET @replC = ' '; -- not to be null
   END

   SET @ndx = @ndx + dbo.fnLen(@replC);
   SET @depth = @depth+1;
   SET @lenSCc = dbo.fnLen(@sc);

   -- Recursive: work forwards skipping over added escape characters
   IF(@ndx < @lenSC-1) AND @depth<20
   BEGIN
--      EXEC sp_log 1, @fn, '060: Recursive call, @ndx: ',@ndx, ' @depth: ', @depth ;
      EXEC sp_fnEscapeMultiple @sc OUT, @ndx , @depth;
   END
END
/*
------------------------------------------------------------------
DECLARE @sc VARCHAR(MAX) = 'the quick \brown fox'
EXEC sp_fnEscapeMultiple @sc OUT, 1, 1;
PRINT @sc
------------------------------------------------------------------
*/


GO
