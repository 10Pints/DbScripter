SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 26-JAN-2020
-- Description: increments @pos until a non whitespace charactes found
-- Returns:     1 based index of the first non space character in @txt from index @pos
--              or 0 if not found
-- =============================================
CREATE FUNCTION [dbo].[fnEatWhitespace](@txt NVARCHAR(MAX), @pos INT)
RETURNS INT
AS
BEGIN
   DECLARE
       @len    INT
      ,@c      NCHAR(1)
   -- 0 based
   SET @len = dbo.fnLen(@txt)
   IF (@txt IS NULL) OR (@len = 0)
   BEGIN
      RETURN 1;
   END
   IF (@pos IS NULL) OR (@pos < 0)
      SET @pos = 0;
   -- Remove any whitespace
   WHILE @pos <= @len
   BEGIN
      SET @c = SUBSTRING(@txt, @pos, 1);
      IF dbo.fnIsWhitespace( @c) = 0
         BREAK;
      SET @pos = @pos + 1
   END
   RETURN @pos
END
/*
EXEC tSQLt.Run 'test_053_fnEatWhitespace'
*/
GO

