SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================================================
-- Author:      Terry Watts
-- Create date: 17-NOV-2024
-- Description: This validates the preconditions for sp_find_unmatched_dynamic_data
--
-- POSTCONDITIONS:
--    ChemicalStaging         populated or exception 63859, 'ChemicalStaging has null chemical_nm fields', 1;
--    ChemicalActionStaging   populated or exception 63859, 'ChemicalActionStaging has null chemical_nm or action_nm fields', 1;
--    ChemicalProductStaging  populated or exception 63859, 'ChemicalProductStaging has null  fields', 1;
--    ChemicalUseStaging      populated or exception 63859, 'ChemicalUseStaging has null chemical_nm or use_nm fields', 1;
--    CompanyStaging          populated or exception 63859, 'CompanyStaging has null  fields', 1;
--    CropPathogenStaging     populated or exception 63859, 'CropPathogenStaging has null crop_nm OR pathogen_nm fields', 1;
--    PathogenChemicalStaging populated or exception 63859, 'PathogenChemicalStaging has null pathogen_nm or chemical_nm fields', 1;
--    ProductCompanyStaging   populated or exception 63859, 'ProductCompanyStaging has null company_nm or product_nm fields', 1;
--    ProductStaging          populated or exception 63859, 'ProductStaging has null product_nm fields', 1;
--    ProductUseStaging       populated or exception 63859, 'ProductUseStaging has null product_nm OR use_nm fields', 1;
-- =============================================================================================
CREATE   PROCEDURE [dbo].[sp_fnd_unregistered_dyndta_chk_precndtns]
AS
BEGIN
   DECLARE
    @fn        VARCHAR(35)   = N'sp_fnd_unmtchd_dyndta_chk_precndtns'
   ;

   SET NOCOUNT ON;
   EXEC sp_log 2, @fn,'000: starting';

   --------------------------------------------------------------------
   -- Validate preconditions
   --------------------------------------------------------------------

   EXEC sp_log 1, @fn,'010: validating preconditions: dynamic data populated';

   IF EXISTS (SELECT 1 FROM ChemicalStaging           WHERE chemical_nm IS NULL)                         --THROW 63859, 'ChemicalStaging has null chemical_nm fields', 1;
   BEGIN
      SELECT * FROM ChemicalStaging  WHERE chemical_nm IS NULL;
      THROW 63859, 'ChemicalStaging has null chemical_nm fields', 1;
   END

   IF EXISTS (SELECT 1 FROM ChemicalActionStaging     WHERE chemical_nm IS NULL OR action_nm IS NULL)    --THROW 63859, 'ChemicalActionStaging has null chemical_nm or action_nm fields', 1;
   BEGIN
      SELECT* FROM ChemicalActionStaging     WHERE chemical_nm IS NULL OR action_nm IS NULL
   END

   IF EXISTS (SELECT 1 FROM ChemicalStaging           WHERE chemical_nm IS NULL)                         THROW 63859, 'ChemicalStaging has null chemical_nm fields', 1;
   IF EXISTS (SELECT 1 FROM ChemicalActionStaging     WHERE chemical_nm IS NULL OR action_nm IS NULL)    THROW 63859, 'ChemicalActionStaging has null chemical_nm or action_nm fields', 1;
   IF EXISTS (SELECT 1 FROM ChemicalProductStaging    WHERE chemical_nm IS NULL OR product_nm IS NULL)   THROW 63859, 'ChemicalProductStaging has null  fields', 1;
   IF EXISTS (SELECT 1 FROM ChemicalUseStaging        WHERE chemical_nm IS NULL OR use_nm IS NULL)       THROW 63859, 'ChemicalUseStaging has null chemical_nm or use_nm fields', 1;
   IF EXISTS (SELECT 1 FROM CompanyStaging            WHERE company_nm IS NULL )                         THROW 63859, 'CompanyStaging has null  fields', 1;
   IF EXISTS (SELECT 1 FROM CropPathogenStaging       WHERE crop_nm IS NULL OR pathogen_nm IS NULL  )    THROW 63859, 'CropPathogenStaging has null crop_nm OR pathogen_nm fields', 1;
   IF EXISTS (SELECT 1 FROM PathogenChemicalStaging   WHERE pathogen_nm IS NULL OR chemical_nm IS NULL)  THROW 63859, 'PathogenChemicalStaging has null pathogen_nm or chemical_nm fields', 1;
   IF EXISTS (SELECT 1 FROM ProductCompanyStaging     WHERE company_nm IS NULL OR product_nm IS NULL)    THROW 63859, 'ProductCompanyStaging has null company_nm or product_nm fields', 1;
   IF EXISTS (SELECT 1 FROM ProductStaging            WHERE product_nm IS NULL)                          THROW 63859, 'ProductStaging has null product_nm fields', 1;
   IF EXISTS (SELECT 1 FROM ProductUseStaging         WHERE product_nm IS NULL OR use_nm IS NULL)        THROW 63859, 'ProductUseStaging has null product_nm OR use_nm fields', 1;

   --------------------------------------------------------------------
   -- ASSERTION: sp_find_unmatched_dynamic_data preconditions valid
   --------------------------------------------------------------------
   EXEC sp_log 2, @fn, '999: leaving, ASSERTION: sp_find_unmatched_dynamic_data preconditions valid';
END
/*
EXEC sp_find_unmatched_dynamic_data;

SELECT COUNT(*) FROM ChemicalStaging        
SELECT COUNT(*) FROM ChemicalActionStaging  
SELECT COUNT(*) FROM ChemicalProductStaging 
SELECT COUNT(*) FROM ChemicalUseStaging     
SELECT COUNT(*) FROM CompanyStaging         
SELECT COUNT(*) FROM CropPathogenStaging    
SELECT COUNT(*) FROM PathogenChemicalStaging
SELECT COUNT(*) FROM ProductCompanyStaging  
SELECT COUNT(*) FROM ProductStaging         
SELECT COUNT(*) FROM ProductUseStaging      
*/
/* 6 rows
Insecticide,fungicide
Insecticide / Nematicide
-
Others*
Insecticide/ Nematicide
Pgr
*/


GO
