SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =====================================================================
-- Author:      Terry Watts
-- Create date: 27-JUN-20223
-- Description: List the individual chemical (ingredient) from Staging2
-- =====================================================================
CREATE   VIEW [dbo].[Ingredient_staging_vw]
AS
   SELECT id, cs.value as chemical_nm 
   FROM Staging2 
   CROSS Apply string_split(ingredient, '+') cs;

/*
SELECT TOP 50 * FROM Ingredient_staging_vw;
*/


GO
