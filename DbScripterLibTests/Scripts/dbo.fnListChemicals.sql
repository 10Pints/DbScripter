SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================
-- Author:		 Terry Watts
-- Create date: 26-JUL-20223
-- Description: List the Chemicals (Ingredients)
-- ===================================================
ALTER FUNCTION [dbo].[fnListChemicals]()
RETURNS @t TABLE (chemical NVARCHAR(250)) --, [type] NVARCHAR(35))
AS
BEGIN
   INSERT INTO @t
   SELECT DISTINCT TOP 1000
   cs.value AS chemical 
   FROM Staging2 
   CROSS APPLY string_split(ingredient, '+') cs
   WHERE cs.value <> ''
   ORDER BY cs.value;

	RETURN 
END
/*
SELECT chemical FROM dbo.fnListChemicals() --ORDER BY chemical
SELECT distinct ingredient AS chemical FROM Staging2 ORDER BY ingredient
*/


GO
