SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




-- =============================================    
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Pads Right with specified padding character
-- =============================================    
CREATE FUNCTION [dbo].[fnPadRight2]
(
    @s      VARCHAR(MAX)
   ,@width  INT
   ,@pad    VARCHAR(1)
)
RETURNS VARCHAR (1000)
AS
BEGIN
   DECLARE 
      @ret  VARCHAR(1000)
     ,@len  INT

   IF @s IS null
      SET @s = '';

   SET @len = ut.dbo.fnLen(@s)
   RETURN LEFT( CONCAT( @s, REPLICATE( @pad, @width-@len)), @width)
END
/*
SELECT CONCAT('[', dbo.fnPadRight2('a very long string indeed - its about time we had a beer', 25, '.'), ']  ');
SELECT CONCAT('[', dbo.fnPadRight2('', 25, '.'), ']  ');
SELECT CONCAT('[', dbo.fnPadRight2(NULL, 25, '.'), ']  ');
*/


GO
