SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================    
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Pads Left
-- =============================================    
CREATE   FUNCTION [dbo].[fnPadLeft2]( @s VARCHAR(500), @width INT, @pad VARCHAR(1)=' ')
RETURNS VARCHAR (1000)
AS
BEGIN
   DECLARE 
    @ret  VARCHAR(1000)
   ,@len INT

   IF @s IS null
      SET @s = '';

   SET @len = dbo.fnLen(@s);

   RETURN iif(@len < @width
      , RIGHT( CONCAT( REPLICATE( @pad, @width-@len), @s), @width)
      , RIGHT(@s, @width))
END
/*
SELECT CONCAT('[', dbo.fnPadLeft2('', 25, '.'), ']  ');
SELECT CONCAT('[', dbo.fnPadLeft2(NULL, 25, '.'), ']  ');
PRINT CONCAT('[', dbo.fnPadLeft2(NULL, 12, 'x'),']')
PRINT CONCAT('[', dbo.fnPadLeft2('', 12, 'x'),']')
PRINT CONCAT('[', dbo.fnPadLeft2('asdfg', 12, 'x'),']')
PRINT CONCAT('[', dbo.fnPadLeft2('asdfg', 3, 'x'),']')
*/


GO
