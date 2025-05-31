SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================================================
-- Routine:     dbo.sp_pop_staging_tables
-- Author:      Terry Watts
-- Create date: 25-AUG-2023
-- Description: clears out the staging tables in order
--
-- Called by: sp_main_import_stage_6, sp_main_import
--
-- PRECONDITIONS:
-- PRE 01: ActionStaging               imported
-- PRE 02: UseStaging                  imported
-- PRE 03: PathogenTypeStaging         imported
-- PRE 04: PathogenPathogenTypeStaging populated
-- PRE 05: TypeStaging                 populated
--
-- POSTCONDITIONS: ALL staging tables are populated:
-- POST 01: ActionStaging                populated
-- POST 02: ChemicalStaging              populated
-- POST 03: ChemicalActionStaging        populated
-- POST 04: ChemicalUseStaging           populated
-- POST 05: CompanyStaging               populated
-- POST 06: CropStaging                  populated
-- POST 07: CropPathogenStaging          populated
-- POST 08: PathogenStaging              populated
-- POST 09: PathogenChemicalStaging      populated
-- POST 10: PathogenTypeStaging          populated
-- POST 11: PathogenPathogenTypeStaging  populated
-- POST 12: ProductStaging               populated
-- POST 13: ProductCompanyStaging        populated
-- POST 14: ProductUseStaging            populated
-- POST 15: TypeStaging                  populated
-- POST 16: UseStaging                   populated
--
-- TESTS:
--
-- CALLED BY: sp_main_import_stage_07_pop_stging
--
-- CHANGES:
-- 231007: fix: Violation of PRIMARY KEY constraint 'PK_ChemicalProductStaging'. Cannot insert duplicate key in object 'dbo.ChemicalProductStaging'.
-- 231008: added company nm info to the product staging table
-- 231013: added PRE 01: import_id must be passed as a parameter or be part of the session context
--         made @import_id a parameter for ease of testing
-- 231014: changed name from sp_pop_normalised_tables to sp_pop_normalised_staging_tables
--         added order by clause to INSERT INTO PathogenStaging(pathogen_nm, import_id) SELECT pathogen, @import_id from dbo.fnListPathogens()
-- 231104: added PathogenChemicalStaging
-- 240124: removed import id parameter - this is common accross all import staging tables
-- 240209: tidy up and refactor to valid postconditions at end.
-- ==================================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_pop_staging_tables]
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn        NVARCHAR(30)   = 'POP STG TBLS'
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@file_path NVARCHAR(MAX)

   BEGIN TRY
      EXEC sp_log 2, @fn, '00: starting, chking preconditions';
      EXEC sp_register_call @fn;

      ---------------------------------------------------------------------------------
      -- PRE 01: ActionStaging               imported
      -- PRE 02: UseStaging                  imported
      -- PRE 03: PathogenTypeStaging         imported
      -- PRE 04: PathogenPathogenTypeStaging populated
      -- PRE 05: TypeStaging                 populated
      ---------------------------------------------------------------------------------
      EXEC sp_chk_tbl_populated 'ActionStaging';
      EXEC sp_chk_tbl_populated 'UseStaging';
      EXEC sp_chk_tbl_populated 'PathogenTypeStaging';
      EXEC sp_chk_tbl_populated 'TypeStaging';

      ---------------------------------------------------------------------------------
      -- ASSERTION: ActionStaging, UseStaging, PathogenTypeStaging tables imported
      ---------------------------------------------------------------------------------

      ---------------------------------------------------------------------------------
      -- 1. Clear out old data now, dependencies first
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '01: deleting all rows from all the staging tables';
      -- Dependencies first
      EXEC sp_delete_table ChemicalActionStaging;
      EXEC sp_delete_table ChemicalProductStaging;
      EXEC sp_delete_table ChemicalUseStaging;
      EXEC sp_delete_table PathogenChemicalStaging;
      EXEC sp_delete_table CropPathogenStaging;
      EXEC sp_delete_table ImportCorrectionsStaging;
      EXEC sp_delete_table PathogenChemicalStaging;
      EXEC sp_delete_table ProductCompanyStaging;
      EXEC sp_delete_table ProductUseStaging;

      -- Primary table next
      EXEC sp_delete_table ChemicalStaging;
      EXEC sp_delete_table CompanyStaging;
      EXEC sp_delete_table CropStaging;
      EXEC sp_delete_table PathogenStaging;
      EXEC sp_delete_table ProductStaging;

      ---------------------------------------------------------------------------------
      -- 02: Asertion: all staging tables cleared
      ---------------------------------------------------------------------------------
      EXEC sp_chk_tbl_not_populated 'ChemicalStaging';
      EXEC sp_chk_tbl_not_populated 'ChemicalActionStaging';
      EXEC sp_chk_tbl_not_populated 'ChemicalProductStaging';
      EXEC sp_chk_tbl_not_populated 'ChemicalUseStaging';
      EXEC sp_chk_tbl_not_populated 'CompanyStaging';
      EXEC sp_chk_tbl_not_populated 'CropStaging';
      EXEC sp_chk_tbl_not_populated 'CropPathogenStaging';
      EXEC sp_chk_tbl_not_populated 'PathogenStaging';
      EXEC sp_chk_tbl_not_populated 'PathogenChemicalStaging';
      EXEC sp_chk_tbl_not_populated 'ProductStaging';
      EXEC sp_chk_tbl_not_populated 'ProductCompanyStaging';
      EXEC sp_chk_tbl_not_populated 'ProductCompanyStaging';

      ---------------------------------------------------------------------------------
      -- 02: Populate the normalised primary staging tables
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '02: Populate the normalised primary staging tables';

      ---------------------------------------------------------------------------------
      -- 03: Pop ChemicalStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '02: Pop ChemicalStaging table';
      INSERT INTO ChemicalStaging(chemical_nm)
         SELECT distinct cs.value as chemical
         FROM Staging2 s CROSS APPLY string_split(ingredient,'+') cs
         ORDER BY cs.value;

      -- POST 05.1: ChemicalStaging table populated

      ---------------------------------------------------------------------------------
      -- 04: Pop CompanyStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '04: Pop PathogenStaging table';
      INSERT INTO CompanyStaging(company_nm) select company from dbo.fnListCompanies();

      ---------------------------------------------------------------------------------
      -- 05: Pop CropStaging table
      ---------------------------------------------------------------------------------
      -- Violation of UNIQUE KEY constraint 'UQ_CropStaging_nm'. Cannot insert duplicate key in object 'dbo.CropStaging'. The duplicate key value is (Green Peas (Legumes)).
      EXEC sp_log 1, @fn, '05: Pop CropStaging table';
      INSERT INTO CropStaging(crop_nm) SELECT crop FROM dbo.fnListCrops() WHERE crop NOT IN ('','-','--') AND crop IS NOT NULL;


      ---------------------------------------------------------------------------------
      -- 06: Pop PathogenStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '06: Pop PathogenStaging table';
      INSERT INTO PathogenStaging(pathogen_nm)
      SELECT pathogen
      FROM dbo.list_unregistered_pathogens_vw
      ORDER BY pathogen;

      -- Import and update the pathogen type
      UPDATE PathogenStaging
      SET pathogenType_nm = S.pathogenType_nm
      FROM OPENROWSET ( 'Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;IMEX=1; Database=D:\Dev\Repos\Farming\Data\Pathogen.xlsx',
'SELECT *
FROM [Pathogen$A:B]') S JOIN PathogenStaging P ON S.pathogen_nm = P.pathogen_nm;

      ---------------------------------------------------------------------------------
      -- 07: Pop ProductStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '07: Pop ProductStaging table from the S2 info';
      INSERT INTO ProductStaging(product_nm) SELECT distinct product From staging2 WHERE product IS NOT NULL ORDER by product;

       --------------------------------------------------------------------------------
       -- 08: Populate the staging link tables
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '08: Populate the staging link tables';

      ---------------------------------------------------------------------------------
      -- 09: Pop PathogenChemicalStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '09: Pop PathogenChemicalStaging staging table';

      EXEC sp_log 1, @fn, '09.2: INSERT INTO PathogenChemicalStaging';
      INSERT INTO PathogenChemicalStaging (pathogen_nm, chemical_nm)
      SELECT distinct pathogen_nm, chemical_nm
      FROM all_vw
      WHERE pathogen_nm <> '';

      ---------------------------------------------------------------------------------
      -- 10: POP the ChemicalActionStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '10: calling sp_pop_ChemicalActionStaging';
      EXEC sp_pop_ChemicalActionStaging;

      ---------------------------------------------------------------------------------
      -- 11: Pop the ChemicalProductStaging table - 231005: added nm fields for ease of merging
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '11: Pop ChemicalProductStaging table';
     -- 231007 fix: Violation of PRIMARY KEY constraint 'PK_ChemicalProductStaging'. Cannot insert duplicate key in object 'dbo.ChemicalProductStaging'.
      INSERT INTO ChemicalProductStaging(chemical_nm, product_nm)
      SELECT distinct chemical_nm, product_nm
      FROM all_vw;

      ---------------------------------------------------------------------------------
      -- 12: Pop the ChemicalUseStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '12: Pop ChemicalUseStaging table, calling sp_pop_chemical_use_staging';
      EXEC sp_pop_ChemicalUseStaging;

      ---------------------------------------------------------------------------------
      -- 13: Pop CropPathogenStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '13: Pop CropPathogenStaging table';

      INSERT INTO CropPathogenStaging (crop_nm, pathogen_nm)
      SELECT crop_nm, pathogen_nm
      FROM crop_pathogen_staging_vw;

      -- POST 06.4: CropPathogenStaging table populated
      -- 231008:
      ---------------------------------------------------------------------------------
      -- 14.: Pop ProductCompanyStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '14: Pop ProductCompanyStaging table';
      INSERT INTO ProductCompanyStaging (product_nm, company_nm)
      SELECT distinct product_nm, company
      FROM all_vw;

      EXEC sp_chk_tbl_populated 'ProductCompanyStaging';
      -- POST 06.7: ProductCompanyStaging table populated

      ---------------------------------------------------------------------------------
      -- 15: Pop ProductUseStaging table ids
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '15: pop ProductUseStaging table';
      INSERT INTO ProductUseStaging (product_nm, use_nm)
      SELECT distinct product_nm, use_nm
      FROM all_vw
      ORDER BY product_nm, use_nm ASC;

      ---------------------------------------------------------------------------------
      -- 16: Validate postconditions - ALL staging tables populated
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '16: table population completed checking postconditions';
      EXEC sp_chk_tbl_populated 'ActionStaging';
      EXEC sp_chk_tbl_populated 'ChemicalStaging';
      EXEC sp_chk_tbl_populated 'ChemicalActionStaging';
      EXEC sp_chk_tbl_populated 'ChemicalProductStaging';
      EXEC sp_chk_tbl_populated 'ChemicalUseStaging';
      EXEC sp_chk_tbl_populated 'CompanyStaging';
      EXEC sp_chk_tbl_populated 'CropStaging';
      EXEC sp_chk_tbl_populated 'CropPathogenStaging';
--      EXEC sp_chk_tbl_populated 'PathogenStaging';
      EXEC sp_chk_tbl_populated 'PathogenTypeStaging';
      EXEC sp_chk_tbl_populated 'PathogenChemicalStaging';
      EXEC sp_chk_tbl_populated 'ProductStaging';
      EXEC sp_chk_tbl_populated 'ProductCompanyStaging';
      EXEC sp_chk_tbl_populated 'ProductCompanyStaging';
      EXEC sp_chk_tbl_populated 'TypeStaging';
      EXEC sp_chk_tbl_populated 'UseStaging';

      ---------------------------------------------------------------------------------
      -- COMPLETED PROCESSING
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,  '49: completed processing OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK';
END
/*
EXEC sp_reset_callRegister
EXEC sp_pop_staging_tables;
*/

GO
