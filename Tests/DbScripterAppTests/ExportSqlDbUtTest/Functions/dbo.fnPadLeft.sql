SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Pads Left
-- =============================================    
CREATE FUNCTION [dbo].[fnPadLeft]( @s NVARCHAR(500), @width INT)
RETURNS NVARCHAR (4000)
AS
BEGIN
   RETURN dbo.fnPadLeft2(@s, @width, ' ');
END
/*
PRINT CONCAT('[', dbo.fnPadLeft('abcd', 10), ']');
*/
GO

