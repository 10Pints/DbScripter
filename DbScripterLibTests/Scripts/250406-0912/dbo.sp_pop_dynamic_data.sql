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
-- RESPONSIBILITIES:
--    ChemicalStaging'          -- 01
--    ChemicalActionStaging'    -- 02
--    ChemicalProductStaging'   -- 03
--    ChemicalUseStaging'       -- 04
--    CompanyStaging'           -- 05
--    ImportCorrectionsStaging' -- 06
--    PathogenChemicalStaging'  -- 07
--    ProductStaging'           -- 08
--    ProductCompanyStaging'    -- 09
--    ProductUseStaging'        -- 10
--
-- PRECONDITIONS:
-- ActionStaging        populated
-- CropStaging          populated
-- CropPathogenStaging  populated
-- DistributorStaging   populated
-- Import               populated
-- PathogenStaging      populated
-- PathogenTypeStaging  populated
-- Staging2             populated
-- TableDef             populated
-- TableType            populated
-- TypeStaging          populated
-- UseStaging           populated
--
-- POSTCONDITIONS: ALL staging tables are populated:
-- (checks are delegated to sp_pop_dynamic_data_postcondition_checks)
-- POST 01: ChemicalStaging'            populated-- 01
-- POST 02: ChemicalActionStaging'      populated-- 02
-- POST 03: ChemicalProductStaging'     populated-- 03
-- POST 04: ChemicalUseStaging'         populated-- 04
-- POST 05: CompanyStaging'             populated-- 05
-- POST 06: ImportCorrectionsStaging'   populated-- 06
-- POST 07: PathogenChemicalStaging'    populated-- 07
-- POST 08: ProductStaging'             populated-- 08
-- POST 09: ProductCompanyStaging'      populated-- 09
-- POST 10: ProductUseStaging'          populated-- 10
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
ALTER PROCEDURE [dbo].[sp_pop_dynamic_data]
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn        VARCHAR(30)   = 'sp_pop_dynamic_data'
      ,@error_msg VARCHAR(MAX)  = NULL
      ,@file_path VARCHAR(MAX)

   BEGIN TRY
      EXEC sp_log 2, @fn, '000: starting, chking preconditions';
      EXEC sp_assert_tbl_pop 'ActionStaging';
      EXEC sp_assert_tbl_pop 'CropStaging';
      EXEC sp_assert_tbl_pop 'DistributorStaging';
      EXEC sp_assert_tbl_pop 'Import';
      EXEC sp_assert_tbl_pop 'PathogenStaging';
      EXEC sp_assert_tbl_pop 'PathogenTypeStaging';
      EXEC sp_assert_tbl_pop 'Staging2';
      EXEC sp_assert_tbl_pop 'TableDef';
      EXEC sp_assert_tbl_pop 'TypeStaging';
      EXEC sp_assert_tbl_pop 'UseStaging';

      ---------------------------------------------------------------------------------
      -- ASSERTION: ActionStaging, UseStaging, PathogenTypeStaging tables imported
      ---------------------------------------------------------------------------------

      ---------------------------------------------------------------------------------
      --Clear out old data now, dependencies first
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '010: deleting all rows from all the staging tables';

      -- Dependencies first
      EXEC sp_delete_table ChemicalStaging;           -- 01
      EXEC sp_delete_table ChemicalActionStaging;     -- 02
      EXEC sp_delete_table ChemicalProductStaging;    -- 03
      EXEC sp_delete_table ChemicalUseStaging;        -- 04
      EXEC sp_delete_table CompanyStaging    ;        -- 05
      EXEC sp_delete_table CropPathogenStaging;       -- 05
      EXEC sp_delete_table ImportCorrectionsStaging;  -- 06
      EXEC sp_delete_table PathogenChemicalStaging;   -- 08
      EXEC sp_delete_table ProductStaging       ;     -- 09
      EXEC sp_delete_table ProductCompanyStaging;     -- 10
      EXEC sp_delete_table ProductUseStaging;         -- 11

      ---------------------------------------------------------------------------------
      -- Assertion: all staging tables cleared
      ---------------------------------------------------------------------------------
      EXEC sp_assert_tbl_not_pop 'ChemicalStaging';         -- 01
      EXEC sp_assert_tbl_not_pop 'ChemicalActionStaging';   -- 02
      EXEC sp_assert_tbl_not_pop 'ChemicalProductStaging';  -- 03
      EXEC sp_assert_tbl_not_pop 'ChemicalUseStaging';      -- 04
      EXEC sp_assert_tbl_not_pop 'CompanyStaging';          -- 05
      EXEC sp_assert_tbl_not_pop 'CropPathogenStaging';     -- 05
      EXEC sp_assert_tbl_not_pop 'ImportCorrectionsStaging';-- 06
      EXEC sp_assert_tbl_not_pop 'PathogenChemicalStaging'; -- 08
      EXEC sp_assert_tbl_not_pop 'ProductStaging';          -- 09
      EXEC sp_assert_tbl_not_pop 'ProductCompanyStaging';   -- 10
      EXEC sp_assert_tbl_not_pop 'ProductUseStaging';       -- 11

      ---------------------------------------------------------------------------------
      -- Populate the normalised primary staging tables
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '020: Populate the normalised primary staging tables';

      ---------------------------------------------------------------------------------
      -- Pop ChemicalStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: Pop ChemicalStaging table';
      INSERT INTO ChemicalStaging(chemical_nm)
      SELECT DISTINCT cs.value as chemical
      FROM Staging2 s CROSS APPLY string_split(ingredient,'+') cs
      ORDER BY cs.value;

      EXEC sp_assert_tbl_pop 'dbo.ChemicalStaging'
      ---------------------------------------------------------------------------------
      -- Pop CompanyStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '040: Pop CompanyStaging table';
      INSERT INTO CompanyStaging(company_nm) 
      SELECT company FROM dbo.fnListS2Companies();

      ---------------------------------------------------------------------------------
      -- Pop ProductStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '050: Pop ProductStaging table from the S2 info';
      INSERT INTO ProductStaging(product_nm) SELECT distinct product From staging2 WHERE product IS NOT NULL ORDER by product;

       --------------------------------------------------------------------------------
       -- Populate the staging link tables
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '060: Populate the staging link tables';

      ---------------------------------------------------------------------------------
      -- Pop PathogenChemicalStaging table from LRAP data
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '070: Pop PathogenChemicalStaging staging table';
      INSERT INTO PathogenChemicalStaging (pathogen_nm, chemical_nm)
      SELECT distinct top 10000 pathogen_nm, chemical_nm
      FROM all_vw
      WHERE pathogen_nm <> ''
      ORDER BY pathogen_nm, chemical_nm;

     --  CropPathogenStaging
      EXEC sp_log 1, @fn, '80: Pop CropPathogenStaging staging table';
      INSERT INTO CropPathogenStaging(crop_nm,pathogen_nm)
      SELECT DISTINCT
crop_nm, pathogen_nm
FROM all_vw
WHERE crop_nm IS NOT NULL AND crop_nm not in ('','-')
AND dbo.fnLen(crop_nm) < 35
AND dbo.fnLen(pathogen_nm) < 50
AND crop_nm NOT LIKE '(%'
AND crop_nm NOT LIKE 'As %'
AND pathogen_nm IS NOT NULL AND pathogen_nm not in ('','-','and wheat')
AND pathogen_nm NOT LIKE 'As %'
ORDER BY crop_nm, pathogen_nm
;

--SELECT MAX( dbo.fnLen(pathogen_nm)) FROM Pathogen

      ---------------------------------------------------------------------------------
      -- 08: POP the ChemicalActionStaging table
      -- dependencies: ActionStaging, ChemicalStaging

      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '090: chking sp_pop_ChemicalActionStaging dependencies';
      EXEC sp_assert_tbl_pop 'ActionStaging';
      EXEC sp_assert_tbl_pop 'ChemicalStaging';
      EXEC sp_log 1, @fn, '100: calling sp_pop_ChemicalActionStaging';

      EXEC sp_pop_ChemicalActionStaging;

      ---------------------------------------------------------------------------------
      -- 09: Pop the ChemicalProductStaging table - 231005: added nm fields for ease of merging
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '110: Pop ChemicalProductStaging table';
     -- 231007 fix: Violation of PRIMARY KEY constraint 'PK_ChemicalProductStaging'. Cannot insert duplicate key in object 'dbo.ChemicalProductStaging'.
      INSERT INTO ChemicalProductStaging(chemical_nm, product_nm)
      SELECT distinct chemical_nm, product_nm
      FROM all_vw;
      EXEC sp_assert_tbl_pop 'ChemicalProductStaging';

      ---------------------------------------------------------------------------------
      -- 10: Pop the ChemicalUseStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '120: Pop ChemicalUseStaging table, calling sp_pop_chemical_use_staging';
      EXEC sp_pop_ChemicalUseStaging;

      -- 231008:
      ---------------------------------------------------------------------------------
      -- 11: Pop ProductCompanyStaging table
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '130: Pop ProductCompanyStaging table';
      INSERT INTO ProductCompanyStaging (product_nm, company_nm)
      SELECT distinct product_nm, company
      FROM all_vw;

      ---------------------------------------------------------------------------------
      -- 12: Pop ProductUseStaging table ids
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '140: pop ProductUseStaging table';
      INSERT INTO ProductUseStaging (product_nm, use_nm)
      SELECT distinct product_nm, use_nm
      FROM all_vw
      ORDER BY product_nm, use_nm ASC;

     ---------------------------------------------------------------------------------
      -- 16: Validate postconditions - ALL staging tables populated
      ---------------------------------------------------------------------------------
      -- POST 01: ActionStaging populated
      -- POST 02: ChemicalActionStaging populated
      -- POST 03: ChemicalProductStaging populated
      -- POST 04: ChemicalStaging populated
      -- POST 05: ChemicalUseStaging populated
      -- POST 06: CompanyStaging populated
      -- POST 07: CropPathogenStaging populated
      -- POST 08: CropStaging populated
      -- POST 09: DistributorStaging populated
      -- POST 10: PathogenChemicalStaging populated
      -- POST 11: PathogenStaging populated
      -- POST 12: PathogenTypeStaging populated
      -- POST 13: ProductCompanyStaging populated
      -- POST 14: ProductStaging populated
      -- POST 15: ProductUseStaging populated
      -- POST 16: TypeStaging populated
      -- POST 17: UseStaging populated--

      -----------------------------------------------------------------------------------
      -- Populate the staging tables post condition check
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '300: table population completed checking postconditions';
      EXEC sp_pop_dyn_dta_post_chks;     -- Post condition chk
      EXEC sp_log 2, @fn, '310: postcondition checks complete';

      ---------------------------------------------------------------------------------
      -- COMPLETED PROCESSING
      ---------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,  '800: completed processing OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '500: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving OK';
END
/*
EXEC tsqlt.Run 'test.test_098_sp_pop_dynamic_data';
EXEC sp_pop_dynamic_data;
*/


GO
