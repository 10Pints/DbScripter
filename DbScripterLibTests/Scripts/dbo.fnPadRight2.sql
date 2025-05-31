SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================    
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Pads Right with specified padding character
-- =============================================    
ALTER FUNCTION [dbo].[fnPadRight2]
(
    @s      NVARCHAR(MAX)
   ,@width  INT
   ,@pad    NVARCHAR(1)
)
RETURNS NVARCHAR (1000)
AS
BEGIN
   DECLARE 
      @ret  NVARCHAR(1000)
     ,@len  INT

   IF @s IS null
      SET @s = '';

   SET @len = ut.dbo.fnLen(@s)
   RETURN LEFT( CONCAT( @s, REPLICATE( @pad, @width-@len)), @width)
END
/*
SELECT CONCAT('[', ut.dbo.fnPadRight2('a very long string indeed - its about time we had a beer', 25, '.'), ']  ');
SELECT CONCAT('[', ut.dbo.fnPadRight2('', 25, '.'), ']  ');
SELECT CONCAT('[', ut.dbo.fnPadRight2(NULL, 25, '.'), ']  ');
*/

GO
