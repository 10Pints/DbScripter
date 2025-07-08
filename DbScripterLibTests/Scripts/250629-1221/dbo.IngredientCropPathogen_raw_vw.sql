SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 29-JUL-2023
-- Description: this view lists company, product, ingrediant, cops and pathogens
--    from staging2             
-- ======================================================================================================
CREATE   VIEW [dbo].[IngredientCropPathogen_raw_vw]
AS
SELECT id,company, product,ingredient, crops, pathogens
FROM staging2

/*
SELECT TOP 50 * FROM IngredientCropPathogen_raw_vw;
*/


GO
