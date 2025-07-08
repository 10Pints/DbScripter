SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 06-OCT-2023
-- Description: Populates the chemical use table from 2 sources:
--              1: once the S2 table use ALL_vw
--              2: add the extra product use data to the chemical use table from the spreadsheet tsv
--
-- PRECONDITIONS:
--       PRE01: UseStaging table       must be populated
--       PRE02: ChemicalStaging table  must be populated
--
-- POSTCONDITIONS:
--       POST01: ProductUse table populated
--
-- ALGORITHM:
--    0: PRECONDITION VALIDATION CHECKS
--    1: TRUNCATE the staging table
--    2: we can pop the Chemical Use staging table using All_vw
--
-- CALLED BY: -- CALLED BY: sp_main_import_stage_07_pop_stging
--
-- CHANGES:
-- 240124: removed import id parameter
--
-- Tests:
-- ======================================================================================================
CREATE   PROCEDURE [dbo].[sp_pop_ChemicalUseStaging]
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)   = N'POP CHEM USE STAGING'
      ,@sql       VARCHAR(MAX)
      ,@error_msg VARCHAR(MAX)  = NULL
      ,@rc        INT            =-1
      ,@cnt       INT            = 0
      ;

   BEGIN TRY
      EXEC sp_log 2, @fn,'01: starting, running precondition checks';
      --EXEC sp_register_call @fn;

      --------------------------------------------------------------------------------
      -- PRECONDITION checks
      --------------------------------------------------------------------------------

      -- PRE02: UseStaging must be populated
      EXEC sp_log 1, @fn,'03: PRE02: UseStaging must be populated';
      EXEC sp_assert_tbl_pop 'UseStaging';

      -- PRE03: ChemicalStaging table must be populated
      EXEC sp_assert_tbl_pop 'ChemicalStaging';

      --------------------------------------------------------------------------------
      -- ASSERTION: @import_id known and not NULL or ''
      -- ASSERTION chemicalStaging and [Use] tables are populated
      --------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'04: truncating ChemicalUseStaging table';
      TRUNCATE TABLE dbo.ChemicalUseStaging;

      -- 2: pop the ChemicalUse staging table using the distinct all_vw
      EXEC sp_log 1, @fn,'05: populating the ChemicalUseStaging table from ALL_vw ';

      INSERT INTO ChemicalUseStaging (chemical_nm, use_nm)
      SELECT DISTINCT chemical_nm, use_nm
      FROM ALL_vw
      WHERE chemical_nm IS NOT NULL AND use_nm IS NOT NULL
      ORDER BY chemical_nm, use_nm;

      --------------------------------------------------------------------------------
      -- POSTECONDITION checks
      --------------------------------------------------------------------------------
      -- Chk POST01: ProductUse table populated
      EXEC sp_assert_tbl_pop 'ChemicalUseStaging';
   END TRY
   BEGIN CATCH
      SET @error_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving OK';
   RETURN @RC;
END
/*
EXEC sp_pop_ChemicalUseStaging
SELECT * FROM ChemicalUseStaging
*/


GO
