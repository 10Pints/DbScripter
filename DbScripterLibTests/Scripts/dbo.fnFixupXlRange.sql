SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: returns the fixed up range
-- =============================================
CREATE FUNCTION [dbo].[fnFixupXlRange](@range VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
   SET @range = dbo.fnTrim2(dbo.fnTrim2(@range, '['), ']');

   IF @range IS NULL OR @range='' SET @range = 'Sheet1$';

   IF CHARINDEX('$', @range) = 0
      SET @range = CONCAT( @range, '$');

   SET @range = CONCAT('[', @range, ']');
   RETURN @range;
END
/*
PRINT dbo.fnFixupXlRange(NULL);
PRINT dbo.fnFixupXlRange('');
PRINT dbo.fnFixupXlRange('Sheet1$');
PRINT dbo.fnFixupXlRange('[Sheet1$]');
PRINT dbo.fnFixupXlRange('Call Register');
PRINT dbo.fnFixupXlRange('Call Register$]');
PRINT dbo.fnFixupXlRange('[Call Register$]');
PRINT dbo.fnFixupXlRange('[Call Register$A:B]');
PRINT dbo.fnFixupXlRange('Call Register$A:B]');
PRINT dbo.fnFixupXlRange('[Call Register$A:B');
PRINT dbo.fnFixupXlRange('Call Register$A:B');
*/

GO
