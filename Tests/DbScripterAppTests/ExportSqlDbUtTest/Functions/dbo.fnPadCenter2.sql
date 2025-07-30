SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Pads center
-- leftpad  = (pad-len)/2 or 0
-- right pad = pad - (left pad + len) or 0
-- =============================================    
CREATE FUNCTION [dbo].[fnPadCenter2]( @s NVARCHAR(500), @width INT, @pad NVARCHAR(1)=' ')
RETURNS NVARCHAR (1000)
AS
BEGIN
   DECLARE 
    @ret          NVARCHAR(1000)
   ,@len          INT
   ,@leftpadSz    INT
   ,@rightpadSz   INT
   ,@leftpad      NVARCHAR(1000)
   ,@rightpad     NVARCHAR(1000)
   IF @s IS null
      SET @s = '';
   SET @len = ut.dbo.fnLen(@s);
   -- leftpad  = (pad-len)/2 or 0
   SET @leftpadSz = (@width - @len)/2;
   
   IF @leftpadSz < 0 SET @leftpadSz = 0;
   -- right pad = pad - (left pad + len) or 0
   SET @rightpadSz = @width - (@leftpadSz + @len);
   IF @rightpadSz < 0 SET @rightpadSz = 0;
   SET @leftpad  = REPLICATE(@pad, @leftpadSz);
   SET @rightpad = REPLICATE(@pad, @rightpadSz);
   SET @s = CONCAT(@leftpad, @s, @rightpad);
   RETURN @s;
END
/*
PRINT CONCAT('[', ut.dbo.[fnPadCenter2]('abc', 25, ' '), ']  ');
PRINT CONCAT('[', ut.dbo.[fnPadCenter2]('abcd', 25, ' '), ']  ');
PRINT CONCAT('[', ut.dbo.[fnPadCenter2]('', 25, 'x'), ']  ');
PRINT CONCAT('[', ut.dbo.[fnPadCenter2](NULL, 25, '.'), ']  ');
PRINT CONCAT('[', dbo.[fnPadCenter2](NULL, 12, 'x'),']')
PRINT CONCAT('[', dbo.[fnPadCenter2]('', 12, 'x'),']')
PRINT CONCAT('[', dbo.[fnPadCenter2]('asdfg', 12, 'x'),']')
PRINT CONCAT('[', dbo.[fnPadCenter2]('asdfg', 3, 'x'),']')
*/
GO

