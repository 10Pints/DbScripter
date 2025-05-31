SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2023
-- Description: lists the useful tables rows
--
-- CHANGES:
-- 231007:removd row limit, added order by clause
-- 231007: added views where ids only
-- =============================================
ALTER PROCEDURE [dbo].[sp_list_useful_table_rows]
AS
BEGIN
   SET NOCOUNT ON;

   SELECT 'Chemical'                      AS [table/view], * FROM Chemical                            ORDER BY chemical_nm
   SELECT 'ChemicalStaging'               AS [table/view], * FROM ChemicalStaging                     ORDER BY chemical_nm
   SELECT 'CrpPathChem stg vw'            AS [table/view], * FROM crop_pathogen_chemical_staging_vw   ORDER BY crop_nm, pathogen_nm, chemical_nm
   SELECT 'ChemPathCrp vw'                AS [table/view], * FROM chemical_pathogen_crop_vw           ORDER BY chemical_nm, pathogen_nm
   SELECT 'Chemical_Product_Staging_vw'   AS [table/view], * FROM Chemical_Product_Staging_vw         ORDER BY chemical_nm, product_nm
   SELECT 'ChemicalProduct_vw'            AS [table/view], * FROM ChemicalProduct_vw                  ORDER BY chemical_nm, product_nm
   SELECT 'ChemicalProduct_vw'            AS [table/view], * FROM ChemicalUseStaging                  ORDER BY chemical_nm, use_nm
   SELECT 'ChemicalUse'                   AS [table/view], * FROM ChemicalUse                         ORDER BY chemical_nm, use_nm
   SELECT 'CompanyStaging'                AS [table/view], * FROM CompanyStaging                      ORDER BY company_nm
   SELECT 'Company'                       AS [table/view], * FROM Company                             ORDER BY company_nm
   SELECT 'CropStaging'                   AS [table/view], * FROM CropStaging                         ORDER BY crop_nm
   SELECT 'Crop'                          AS [table/view], * FROM Crop                                ORDER BY crop_nm
   SELECT 'crop_pathogen_staging_vw'      AS [table/view], * FROM crop_pathogen_staging_vw            ORDER BY crop_nm, pathogen_nm
   SELECT 'crop_pathogen_vw'              AS [table/view], * FROM crop_pathogen_vw                    ORDER BY crop_nm, pathogen_nm
   SELECT 'Import'                        AS [table/view], * FROM Import                              ORDER BY import_nm
   SELECT 'ProductChemical_vw'            AS [table/view], * FROM ProductChemical_vw                  ORDER BY product_nm, chemical_nm
   SELECT 'PathogenStaging'               AS [table/view], * FROM PathogenStaging                     ORDER BY pathogen_nm
   SELECT 'Pathogen'                      AS [table/view], * FROM Pathogen                            ORDER BY pathogen_nm
   SELECT 'ProductStaging'                AS [table/view], * FROM ProductStaging                      ORDER BY product_nm
   SELECT 'Product'                       AS [table/view], * FROM Product                             ORDER BY product_nm
   SELECT 'ProductUseStaging_vw'          AS [table/view], * FROM ProductUseStaging_vw                ORDER BY product_nm, use_nm
   SELECT 'ProductUse_vw'                 AS [table/view], * FROM ProductUse_vw                       ORDER BY product_nm, use_nm
   SELECT 'Type'                          AS [table/view], * FROM [Type]                              ORDER BY type_nm
   SELECT 'Use'                           AS [table/view], * FROM [Use]                               ORDER BY use_nm
END

/*
EXEC sp_list_useful_table_rows 
*/

GO
