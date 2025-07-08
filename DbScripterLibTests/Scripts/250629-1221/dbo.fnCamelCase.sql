SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Author:      Terry Watts
-- Create date: 06-JUL-2023
-- Description: Make first character upper case
--              and all the subsequent chars lower case
--
-- Changes:
-- 241206: changed name from fnInitialCap to fnCamelCase
-- =====================================================
CREATE FUNCTION [dbo].[fnCamelCase]( @s VARCHAR(MAX))
  RETURNS VARCHAR(MAX)
AS
BEGIN 
   DECLARE @Position INT;

   IF (@s IS NULL) OR (@s='')
      RETURN @s;

   SET @s = CONCAT(Upper(Left(@s, 1)), LOWER(SUBSTRING(@s, 2, dbo.fnLen(@s)-1)));
   RETURN @s;
END;
/*
   PRINT CONCAT('[', dbo.InitialCap('this is a String'), ']');
   PRINT CONCAT('[', dbo.InitialCap(''), ']');
   PRINT CONCAT('[', dbo.InitialCap(NULL), ']');
   PRINT CONCAT('[', dbo.InitialCap('- this is a String'), ']');
*/

GO
