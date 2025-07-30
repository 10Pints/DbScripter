SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 10-MAY-2012
-- Description: returns the substring in sql starting at pos until 
--              depending on @req_len
--              if 0  then to the new line or if NL not found then, or the remaining string
--              if -1 then the entire string from and includng @pos
--
-- Called by dbo.fnGetLine
--
-- Tests:
-- =========================================================================
CREATE FUNCTION [dbo].[fnGetLine2]( @sql NVARCHAR(MAX), @pos INT, @req_len INT = 0)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE
    @len             INT         = 0 
   ,@ln_end          INT
   ,@NL              NVARCHAR(2) = NCHAR(13) + NCHAR(10)
   SET @len = LEN(@sql) - @pos + 1;
   IF @len<1
      SET @len = 1;
   SET @ln_end = CHARINDEX(@NL, @sql, @pos);
   SET @req_len =
      CASE
         WHEN @req_len IS NULL OR @req_len = 0
            THEN IIF( @ln_end <> 0, @ln_end-@pos, 100)
         WHEN @req_len = -1
            THEN @len
         ELSE @req_len
         END;
   RETURN CONCAT('[', SUBSTRING(@sql, @pos, @req_len), ']');
END
/*
Print dbo.fnGetLine2('1234567890asd'+NCHAR(13) + NCHAR(10)+'fghjkl', 3,2)
Print dbo.fnGetLine2('1234567890asd'+NCHAR(13) + NCHAR(10)+'fghjkl', 3,0)
*/
GO

