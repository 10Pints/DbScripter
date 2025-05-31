SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2021
-- Description: determines if the string contains whitespace
--
-- whitespace is: 
-- (NCHAR(9), NCHAR(10), NCHAR(11), NCHAR(12), NCHAR(13), NCHAR(14), NCHAR(32), NCHAR(160))
--
-- RETURNS: 1 if string contains whitspace, 0 otherwise
-- ==========================================================================================
ALTER FUNCTION [dbo].[fnContainsWhitespace]( @s NVARCHAR(4000))
RETURNS BIT
AS
BEGIN
   DECLARE
       @res       BIT = 0
      ,@i         INT = 1
      ,@len       INT = dbo.fnLen(@s)

   WHILE @i <= @len
   BEGIN
      IF dbo.fnIswhitespace(SUBSTRING(@s, @i, 1))=1
      BEGIN
         SET @res = 1;
         break;
      END

      SET @i = @i + 1;
   END

   RETURN @res;
END

GO
