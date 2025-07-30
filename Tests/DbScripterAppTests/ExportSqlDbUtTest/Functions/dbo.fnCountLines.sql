SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================
-- Author:      Terry Watts
-- Create date: 19-JAN-2020
-- Description: Counts the lines in a block of text
-- ==================================================
CREATE FUNCTION [dbo].[fnCountLines](@txt NVARCHAR(4000))
RETURNS INT
AS
BEGIN
   -- Declare the return variable here
   DECLARE
       @NL        NVARCHAR(2) = NCHAR(13)+NCHAR(10)
      ,@ln_num    INT         = 0
      ,@len       INT         = LEN(@txt)
      ,@ln_end    INT         = -1
   IF(@txt IS NULL) OR (@len = 0)
      RETURN 0;
   -- If the text does not end in a NL append one
   IF SUBSTRING(@txt, @len-2,2) <> @NL
      SET @txt = CONCAT(@txt, @NL);
   -- Iterate the text taking line by line
   -- foreach line
   WHILE ( @ln_end < @len)
   BEGIN
      -- ASSERTION at the beginning of the Line
      -- Get  the start and end pos
      --SET @ln_start = @ln_end + 2
      SET @ln_end   = CHARINDEX(@NL, @txt, @ln_end + 2);
      -- If no more lines
      IF @ln_end = 0
         BREAK;
      -- Increment the line counter
      SET @ln_num = @ln_num + 1;
   END
   RETURN @ln_num;
END
GO

