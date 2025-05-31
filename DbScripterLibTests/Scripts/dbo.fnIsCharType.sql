SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =======================================================================
-- Author:      Terry Watts
-- Create date: 06-FEB-2020
-- Description: Returns true if a character type
--              Handles single and array types like INT and NVARCHAR(MAX)
-- =======================================================================
ALTER FUNCTION [dbo].[fnIsCharType]
(
   @type    NVARCHAR(15)
)
RETURNS BIT
AS
BEGIN
   DECLARE 
    @rc     BIT
   ,@n      INT

   -- Trim possible aray (num) like NVARCHAR(100)
   SET @n = CHARINDEX('(', @type);

   IF @n > 0
      SET @type = SUBSTRING( @type, 1, @n-1);

   SET @rc = CASE
      WHEN @type = 'CHAR'     THEN 1
      WHEN @type = 'NCHAR'    THEN 1
      WHEN @type = 'VARCHAR'  THEN 1
      WHEN @type = 'NVARCHAR' THEN 1

      ELSE 0
   END

   RETURN @rc;
END

GO
