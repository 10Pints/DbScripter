SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--========================================================================================
-- Author:      Terry Watts
-- Create date: 21-Nov-2024
-- Description: Checks staging tables not populated
-- POSTCONDITIONS
--    if @clr_primary_tables is clear then checks all staging tables bar the primary staging tables:
--       'ActionStaging','PathogenTypeStaging','TypeStaging','UseStaging'
--    else checks all staging tables
--========================================================================================
CREATE PROCEDURE [dbo].[sp_assert_stgng_tbls_not_pop]
   @clr_primary_tables BIT = 0
AS
BEGIN
   DECLARE
       @fn        VARCHAR(30)   = 'sp_chk_stgng_tbls_not_pop'
      ,@error_msg VARCHAR(MAX)  = NULL
      ;

   SET NOCOUNT ON;
   EXEC sp_log 2, @fn, '000: starting
@clr_primary_tables: [',@clr_primary_tables,']'

   --------------------------------------------------------------------------------------------------------
   -- Postcondition checks
   --------------------------------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '100: checking all non primary tables are cleared';
   EXEC  sp_assert_tbl_not_pop 'ChemicalActionStaging';
   EXEC  sp_assert_tbl_not_pop 'ChemicalProductStaging';
   EXEC  sp_assert_tbl_not_pop 'ChemicalUseStaging';
   EXEC  sp_assert_tbl_not_pop 'CropPathogenStaging';
   EXEC  sp_assert_tbl_not_pop 'PathogenChemicalStaging';
   EXEC  sp_assert_tbl_not_pop 'ProductCompanyStaging';
   EXEC  sp_assert_tbl_not_pop 'ProductUseStaging';
   EXEC  sp_assert_tbl_not_pop 'ChemicalStaging';
   EXEC  sp_assert_tbl_not_pop 'CropStaging';
   EXEC  sp_assert_tbl_not_pop 'ImportCorrectionsStaging';
   EXEC  sp_assert_tbl_not_pop 'PathogenStaging';
   EXEC  sp_assert_tbl_not_pop 'CompanyStaging';
   EXEC  sp_assert_tbl_not_pop 'ProductStaging';

   IF @clr_primary_tables = 0
   BEGIN
      EXEC sp_log 2, @fn, '110: checking no primary tables are cleared';
      EXEC  sp_assert_tbl_pop 'ActionStaging';
      EXEC  sp_assert_tbl_pop 'PathogenTypeStaging';
      EXEC  sp_assert_tbl_pop 'TypeStaging';
      EXEC  sp_assert_tbl_pop 'UseStaging';
   END

   EXEC sp_log 2, @fn, '999: leaving OK'
END

GO
