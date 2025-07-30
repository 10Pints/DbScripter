SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-DEC-2021
-- Description: Removes specific characters from 
--              the beginning end of a string
-- =============================================
CREATE FUNCTION [dbo].[fnLTrim2]
(
    @str VARCHAR(MAX)
   ,@trim_chr VARCHAR(1)
)
RETURNS  VARCHAR(MAX)
AS
BEGIN
   DECLARE @len INT;
   IF @str IS NOT NULL AND @trim_chr IS NOT NULL
      WHILE Left(@str, 1) = @trim_chr
      BEGIN
         SET @len = dbo.fnLen(@str)-1;
         IF @len < 0
            BREAK;
         SET @str = Substring(@str, 2, dbo.fnLen(@str)-1);
      END
   RETURN @str
END
/*
PRINT CONCAT('1: [',  dbo.fnLTrim2('  ', ' '), ']');
PRINT CONCAT('2: [',  dbo.fnLTrim2(' ', ' '), ']');
PRINT CONCAT('3: [',  dbo.fnLTrim2('', ' '), ']');
PRINT CONCAT('4: [', Right('', 1), ']');
PRINT CONCAT('5: [', dbo.fnLTrim2(' s 5   ', ' '), ']');
PRINT CONCAT('6: [', dbo.fnLTrim2(' ', ' '), ']');
PRINT CONCAT('7: [', dbo.fnLTrim2('', ' '), ']');
PRINT CONCAT('8: [', dbo.fnLTrim2(NULL, ' '), ']');
PRINT CONCAT('9: [', dbo.fnLTrim2(' ', NULL), ']');
PRINT CONCAT('10:[', dbo.fnLTrim2('', NULL), ']');
IF dbo.fnLTrim2(NULL, NULL) IS NULL PRINT 'IS NULL';
*/
GO

