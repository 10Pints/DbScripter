SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-DEC-2021
-- Description: Removes specific characters from the right end of a string
-- =============================================
ALTER FUNCTION [dbo].[fnRTrim2]
(
    @str NVARCHAR(MAX)
   ,@trim_chr NVARCHAR(1)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   IF @str IS NOT NULL AND @trim_chr IS NOT NULL
      WHILE Right(@str, 1)= @trim_chr AND dbo.fnLen(@str) > 0
         SET @str = Left(@str, dbo.fnLen(@str)-1);

   RETURN @str
END
/*
PRINT CONCAT('[',  dbo.fnRTrim2('  ', ' '), ']');
PRINT CONCAT('[',  dbo.fnRTrim2(' ', ' '), ']');
PRINT CONCAT('[',  dbo.fnRTrim2('', ' '), ']');
PRINT CONCAT('[', Right('', 1), ']');
PRINT CONCAT('[', dbo.fnRTrim2(' s 5   ', ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2(' ', ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2('', ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2(NULL, ' '), ']');
PRINT CONCAT('[', dbo.fnRTrim2(' ', NULL), ']
PRINT CONCAT('[', dbo.fnRTrim2('', NULL), ']');
IF dbo.fnRTrim2(NULL, NULL) IS NULL PRINT 'IS NULL';
*/

GO
