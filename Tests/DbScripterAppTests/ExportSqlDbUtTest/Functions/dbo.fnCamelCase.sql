SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 24-OCT-2019
-- Description: CamelCase seps = {<spc>, ' -}
--=============================================
CREATE FUNCTION [dbo].[fnCamelCase](@str NVARCHAR(200))
RETURNS NVARCHAR(4000) AS
BEGIN
   DECLARE
    @res       NVARCHAR(200)
   ,@tmp       NVARCHAR(2000)
   ,@n         INT
   ,@FirstLen  INT
   ,@SEP       NVARCHAR(1)
   ,@len       INT
   ,@ndx       INT = 1
   ,@c         NVARCHAR(1)
   ,@seps      NVARCHAR(10) = ' -'''
   -- Init Set flag to true
   ,@flag      BIT     = 1
   ;
   IF @str IS NULL OR Len(@str) = 0
      RETURN @str;
   -- Make all charactesrs lower case
   SET @str = LOWER(dbo.fnTrim(@str));
   SET @len = dbo.fnLen(@str);
   -- For each character in string
   WHILE @ndx <= @len
   BEGIN
      SET @c = SUBSTRING(@str, @ndx, 1);
      SET @ndx = @ndx + 1;
      -- Is character a separator?
      IF CharIndex(@c, @seps, 1) >0
      BEGIN
         -- Set the flag true
         SET @flag = 1;
      END
      ELSE
      BEGIN
         -- ASSERTION: if here then we have a non seperator character
         -- Is flag set?
         IF @flag = 1
         BEGIN
         -- make uppercase
         SET @c = UPPER(@c);
         -- Set the flag false
         SET @flag = 0;
         END
      END -- end if else
      SET @res = CONCAT(@res, @c);
   END  -- WHILE
   RETURN @res;
END
/*
PRINT dbo.fnCamelCase('absd Eefg');
*/
GO

