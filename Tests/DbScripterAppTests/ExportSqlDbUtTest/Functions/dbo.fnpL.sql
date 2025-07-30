SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================
-- Author:      Terry Watts
-- Create date: 20-MAY-2020
-- Description: Pads left shorthand version
-- dbo.fnpL( , )
-- ===========================================
CREATE FUNCTION [dbo].[fnpL]( @s NVARCHAR(500), @width INT)
RETURNS NVARCHAR (4000)
AS
BEGIN
   RETURN [dbo].[fnPadLeft]( @s, @width);
END
GO

