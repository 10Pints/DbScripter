SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:       TerryWatts
-- Create date: 06-AUG-2023
-- Description: Get first number from string
-- =============================================
ALTER   FUNCTION [dbo].[fnGetFirstNumberFromString](@s VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
   DECLARE @ret INT;
   SET @ret = (SELECT TOP 1 value from dbo.fnGetNumbersFromString(@s) where ISNUMERIC(value)=1);
   RETURN @ret;

END
/*
PRINT dbo.fnGetFirstNumberFromString('some other text 14 days before harvest fpr potato. 7 days before harvest for onion');
PRINT dbo.fnGetFirstNumberFromString('One (1) days after each spraying');
SELECT distinct phi from staging2 where phi like '%(%'

SELECT * FROM dbo.fnGetNumbersFromString('Harvest is generally 4-7 days');

 SELECT id, dbo.fnGetFirstNumberFromString(phi), phi 
 FROM staging2
 WHERE phi like '%[0-9]-[0-9]%'

*/


GO
