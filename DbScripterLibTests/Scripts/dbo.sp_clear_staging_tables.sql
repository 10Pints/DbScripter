SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================================================================================================
-- Author:       Terry Watts
-- Create date:  06-NOV-2023
-- Description:  clears the staging tables
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:                                                Exception:
--    POST 01: (
--                all link and core tables cleared and not primary tables cleared and @clr_primary_tables = 0 OR
--                all tables cleared and @clr_primary_tables = 0
--             )
--             OR 
--             (
--                @clr_primary_tables     set and exception 50720, 'Error in sp_clear_staging_tables: Not all staging tables were cleared', 1;
--                OR 
--                @clr_primary_tables not set and exception 50721, 'Error in sp_clear_staging_tables: Not all non primary staging tables were cleared', 1;
--             )
--
-- CHANGES:
-- 240128: do not clear the ActionStaging Table
-- 240228: added a parameter @clr_primary_tables to signal to clear the PRIMARY staging tables that are imported from table specific imports
--         and not derivable from the LRAP import things like Action, Type that are used to validate and assign an id as an FK
-- ===========================================================================================================================================
ALTER PROCEDURE [dbo].[sp_clear_staging_tables]
   @clr_primary_tables BIT = 0
AS
BEGIN
   SET NOCOUNT ON
   DECLARE
       @fn        NVARCHAR(30)   = 'CLR_STG_TBLS'
      ,@error_msg NVARCHAR(MAX)  = NULL

   BEGIN TRY
      EXEC sp_log 2, @fn, '000: starting
@clr_primary_tables: [',@clr_primary_tables,']'

      --------------------------------------------------------------------------------------------------------
      -- Clear link staging tables
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '005: clearing link tables'
      EXEC sp_log 1, @fn, '010: clearing link table ChemicalProductStaging     '; DELETE FROM ChemicalActionStaging;
      EXEC sp_log 1, @fn, '015: clearing link table ChemicalProductStaging     '; DELETE FROM ChemicalProductStaging;
      EXEC sp_log 1, @fn, '020: clearing link table ChemicalUseStaging         '; DELETE FROM ChemicalUseStaging;
      EXEC sp_log 1, @fn, '025: clearing link table CropPathogenStaging        '; DELETE FROM CropPathogenStaging;
      EXEC sp_log 1, @fn, '030: clearing link table PathogenChemicalStaging    '; DELETE FROM PathogenChemicalStaging;
      EXEC sp_log 1, @fn, '035: clearing link table ProductCompanyStaging      '; DELETE FROM ProductCompanyStaging;
      EXEC sp_log 1, @fn, '040: clearing link table ProductUseStaging          '; DELETE FROM ProductUseStaging;

      --------------------------------------------------------------------------------------------------------
      -- Clear core staging tables
      --------------------------------------------------------------------------------------------------------
      -- 240128: do not clear the core staging tables
      EXEC sp_log 2, @fn, '045: clearing core staging tables'
      EXEC sp_log 2, @fn, '046: clearing core table ChemicalStaging            '; DELETE FROM ChemicalStaging;
      EXEC sp_log 2, @fn, '050: clearing core table CropStaging                '; DELETE FROM CropStaging;
      EXEC sp_log 2, @fn, '055: clearing core table ImportCorrectionsStaging   '; DELETE FROM ImportCorrectionsStaging;
 --     EXEC sp_log 2, @fn, '060: clearing core table PathogenPathogenTypeStaging'; DELETE FROM PathogenPathogenTypeStaging;
      EXEC sp_log 2, @fn, '065: clearing core table PathogenStaging            '; DELETE FROM PathogenStaging;
      EXEC sp_log 2, @fn, '070: clearing core table CompanyStaging             '; DELETE FROM CompanyStaging;
      EXEC sp_log 2, @fn, '075: clearing core table ProductStaging             '; DELETE FROM ProductStaging;

      --------------------------------------------------------------------------------------------------------
      -- Clear primary tables
      --------------------------------------------------------------------------------------------------------
      IF @clr_primary_tables = 1
      BEGIN
         EXEC sp_log 2, @fn, '080: clearing core staging tables'
         EXEC sp_log 2, @fn, '085: clearing core table ActionStaging              '; DELETE FROM ActionStaging;
         EXEC sp_log 2, @fn, '085: clearing core table PathogenTypeStaging        '; DELETE FROM PathogenTypeStaging;
         EXEC sp_log 2, @fn, '090: clearing core table TypeStaging                '; DELETE FROM TypeStaging;
         EXEC sp_log 2, @fn, '095: clearing core table UseStaging                 '; DELETE FROM UseStaging;
         EXEC  sp_chk_tbl_not_populated 'ActionStaging';
         EXEC  sp_chk_tbl_not_populated 'PathogenTypeStaging';
         EXEC  sp_chk_tbl_not_populated 'TypeStaging';
         EXEC  sp_chk_tbl_not_populated 'UseStaging';
      END

      --------------------------------------------------------------------------------------------------------
      -- Postcondition checks
      --------------------------------------------------------------------------------------------------------
      -- POST 01: all tables cleared
      EXEC sp_log 2, @fn, '100: checking all non primary tables are cleared';
      EXEC  sp_chk_tbl_not_populated 'ChemicalActionStaging';
      EXEC  sp_chk_tbl_not_populated 'ChemicalProductStaging';
      EXEC  sp_chk_tbl_not_populated 'ChemicalUseStaging';
      EXEC  sp_chk_tbl_not_populated 'CropPathogenStaging';
      EXEC  sp_chk_tbl_not_populated 'PathogenChemicalStaging';
      EXEC  sp_chk_tbl_not_populated 'ProductCompanyStaging';
      EXEC  sp_chk_tbl_not_populated 'ProductUseStaging';
      EXEC  sp_chk_tbl_not_populated 'ChemicalStaging';
      EXEC  sp_chk_tbl_not_populated 'CropStaging';
      EXEC  sp_chk_tbl_not_populated 'ImportCorrectionsStaging';
      EXEC  sp_chk_tbl_not_populated 'PathogenStaging';
      EXEC  sp_chk_tbl_not_populated 'CompanyStaging';
      EXEC  sp_chk_tbl_not_populated 'ProductStaging';

      IF @clr_primary_tables = 0
      BEGIN
         EXEC sp_log 2, @fn, '110: checking no primary tables are cleared';
         EXEC  sp_chk_tbl_populated 'ActionStaging';
         EXEC  sp_chk_tbl_populated 'PathogenTypeStaging';
         EXEC  sp_chk_tbl_populated 'TypeStaging';
         EXEC  sp_chk_tbl_populated 'UseStaging';
      END

      ---------------------------------------------------------------
      -- Processing complete
      ---------------------------------------------------------------
     EXEC sp_log 2, @fn, '400: processing complete';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving OK'
END
/*
   EXEC sp_clear_staging_tables
*/

GO
