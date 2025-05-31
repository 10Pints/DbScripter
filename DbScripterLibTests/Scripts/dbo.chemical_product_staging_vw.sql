SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 20-SEP-2023
-- Description: lists the products and their constituent chemicals  
--              from the staging tables
--
-- CHANGES:
--    231007: uses the main tables now
--    240121: removed import_id
-- ==============================================================================
ALTER VIEW [dbo].[chemical_product_staging_vw]
AS
SELECT TOP 200000 chemical_nm, product_nm
FROM
          ChemicalProductStaging    cp 
--LEFT JOIN ChemicalStaging           ch    ON cp.chemical_id   = ch.chemical_id
--LEFT JOIN ProductStaging            p     ON p.product_id     = cp.product_id
--LEFT join CropPathogenStaging       crpp  ON crpp.pathogen_id = p.product_id
ORDER BY chemical_nm, product_nm

/*
SELECT * FROM chemical_product_staging_vw
*/

GO
