SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2023
-- Description:
--list the new and old chemical names and ids and product names and ids
--
-- CHANGES:
--    
-- ==============================================================================
CREATE   VIEW [dbo].[Chemical_Product_full_vw] AS
SELECT ccsv.existing_chemical_nm, cps.chemical_nm as new_chemical_nm, cps.product_nm as new_product_nm
, ppsv.existing_product_nm as ppsv_existing_product_nm, ppsv.new_product_nm as ppsv_new_product_nm
FROM Chemical_Chemical_staging_vw ccsv 
JOIN ChemicalProductStaging cps ON ccsv.existing_chemical_nm=cps.chemical_nm
JOIN Product_Product_staging_vw ppsv ON ppsv.existing_product_nm = cps.product_nm
;
/*
SELECT TOP 200 * FROM Chemical_Product_full_vw
*/


GO
