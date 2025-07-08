SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Pads Left
-- =============================================    
CREATE FUNCTION [dbo].[fnPadLeft]( @s VARCHAR(500), @width INT)
RETURNS VARCHAR (4000)
AS
BEGIN
   RETURN dbo.fnPadLeft2(@s, @width, ' ');
END
/*
PRINT CONCAT('[', dbo.fnPadLeft('abcd', 10), ']');
*/

GO
