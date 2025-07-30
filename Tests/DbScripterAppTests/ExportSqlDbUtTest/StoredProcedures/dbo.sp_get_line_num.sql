SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 18-JAN-2020
-- Description: Returns the 1 based line number for the offset into a string 
--              containing lines (ending in /r/n)
-- Method:
-- If the text does not end in a NL append one
-- Iterate the text taking line by line
-- foreach line
-- get  the start and end pos
-- if end is > required offset 
-- calculate the line column offset from the line staart and the and the required offset
-- return the line offset, column offfset and line end
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_line_num] 
          @txt                       NVARCHAR(4000)
         ,@offset                    INT
         ,@ln_num                    INT OUT
         ,@ln_start                  INT OUT -- points to the furst characer in the line after NL
         ,@ln_end                    INT OUT
         ,@col                       INT OUT -- column is the offset in line (from line start pos)
AS
BEGIN
   DECLARE
          @fn                        NVARCHAR(30)    =   'TST HLP GEN                : '
         ,@NL                        NVARCHAR(2)     =   NCHAR(13)+NCHAR(10)
         ,@tmp                       NVARCHAR(1000)
         ,@len                       INT = LEN(@txt)
   SET @ln_num      = -1
   SET @ln_start    = -1
   SET @ln_end      = -1
   SET @col         = -1
   IF (@txt IS NULL) OR (@len = 0) OR (@offset < 0) OR (@offset > @len)
      RETURN 
   -- ASSERTION: if here then a valid offset
   SET @tmp = SUBSTRING(@txt, @len-2,2)
   -- If the text does not end in a NL append one
   IF SUBSTRING(@tmp, @len-2,2) <> @NL
      SET @txt = CONCAT(@txt, @NL)
   SET @ln_start   = 1
   SET @ln_num     = 1
   -- Iterate the text taking line by line
   -- foreach line
   WHILE ( @ln_end < @len)
   BEGIN
      -- ASSERTION at the beginning of the Line
      -- Get  the start and end pos
      SET @ln_start = @ln_end + 2
      SET @ln_end   = CHARINDEX(@NL, @txt, @ln_start)
      -- If no more lines
      IF @ln_end = 0
         BREAK;
      -- If end is > required offset 
      IF @ln_end > @offset
      BEGIN
         -- Calculate the column offset from the line staart and the and the required offset
         -- Return the line offset, column offfset and line end
         -- subtract the line start from the required offset
         -- dont error on values less than 1 just return the start pos - this is for test purposes
         SET @col = dbo.fnMax((@offset - @ln_start) + 1, 1)
         RETURN
      END
      -- Increment the line counter
      SET @ln_num   = @ln_num + 1
   END
   -- IF not found
   SET @ln_num     = -1;
   SET @ln_start   = -1;
   SET @ln_end     = -1
   SET @col        = -1
END
GO

