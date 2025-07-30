SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 Terry Watts
-- Create date: 09-NOV-2023
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnSquashSpaces](@s NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
   WHILE CHARINDEX('  ', @s) > 0
   BEGIN
      SET @s = REPLACE(@s, '  ', ' ')
   END
   RETURN @s;
END
/*
PRINT CONCAT('[', dbo.fnSquashSpaces('this   is  a    test'), ']');
*/
GO

