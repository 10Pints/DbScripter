SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:      Terry Watts
-- Create date: 23-JUN-2023
-- Description: Pads Right with spc
-- =============================================    
CREATE FUNCTION [dbo].[fnPadCenter]
(
    @s      NVARCHAR(MAX)
   ,@width  INT
)
RETURNS NVARCHAR (1000)
AS
BEGIN
   RETURN dbo.fnPadCenter2(@s, @width, ' ');
END
/*
SELECT CONCAT('[', ut.dbo.fnPadCenter('a very long string indeed - its about time we had a beer', 25), ']  ');
SELECT CONCAT('[', ut.dbo.fnPadCenter('', 25), ']  ');
SELECT CONCAT('[', ut.dbo.fnPadCenter(NULL, 25), ']  ');
*/
GO

