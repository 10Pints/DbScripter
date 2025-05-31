SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================
-- Author:      Terry Watts
-- Create Date: 21-JAN-2024
-- Description: Post condition chk for pop staging tables
--       Checks that the staging tables have at least 1 row each
--
-- POSTCONDITIONS: The following tables are populated:
-- POST 01: ActionStaging                populated
-- POST 02: ChemicalStaging              populated
-- POST 03: ChemicalActionStaging        populated
-- POST 04: ChemicalUseStaging           populated
-- POST 05: CompanyStaging               populated
-- POST 06: CropStaging                  populated
-- POST 07: CropPathogenStaging          populated
---- POST 08: PathogenStaging              populated
-- POST 09: PathogenChemicalStaging      populated
-- POST 10: PathogenTypeStaging          populated
-- POST 12: ProductStaging               populated
-- POST 13: ProductCompanyStaging        populated
-- POST 14: ProductUseStaging            populated
-- POST 15: TypeStaging                  populated
-- POST 16: UseStaging                   populated
--
-- CHANGES:
-- =====================================================================
ALTER PROCEDURE [dbo].[sp_pop_staging_tables_post_condition_checks]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'POP_STG_TBLS_POST_CNDTN_CHCK'

   EXEC sp_log 2, @fn,'01: starting';
   EXEC sp_register_call @fn;

   SELECT * FROM list_stging_tbl_counts_vw;

   EXEC sp_chk_tbl_populated 'ActionStaging'              ; -- 01 ActionStaging'
   EXEC sp_chk_tbl_populated 'ChemicalStaging'            ; -- 02 ChemicalStaging'
   EXEC sp_chk_tbl_populated 'ChemicalActionStaging'      ; -- 03 ChemicalActionStaging'
   EXEC sp_chk_tbl_populated 'ChemicalProductStaging'     ; -- 04 ChemicalProductStaging'
   EXEC sp_chk_tbl_populated 'ChemicalUseStaging'         ; -- 05 ChemicalUseStaging'
   EXEC sp_chk_tbl_populated 'CompanyStaging'             ; -- 06 CompanyStaging'
   EXEC sp_chk_tbl_populated 'CropStaging'                ; -- 07 CropStaging'
   EXEC sp_chk_tbl_populated 'CropPathogenStaging'        ; -- 08 CropPathogenStaging'
   --EXEC sp_chk_tbl_populated 'PathogenStaging        '    ; -- 09 PathogenStaging'
   EXEC sp_chk_tbl_populated 'PathogenChemicalStaging'    ; -- 10 PathogenChemicalStaging'
   EXEC sp_chk_tbl_populated 'PathogenTypeStaging'        ; -- 11 PathogenTypeStaging
   EXEC sp_chk_tbl_populated 'ProductStaging'             ; -- 13 ProductStaging'
   EXEC sp_chk_tbl_populated 'ProductCompanyStaging'      ; -- 14 ProductUseStaging'
   EXEC sp_chk_tbl_populated 'ProductUseStaging'          ; -- 15 TypeStaging'
   EXEC sp_chk_tbl_populated 'TypeStaging'                ; -- 16 UseStaging'
   EXEC sp_chk_tbl_populated 'UseStaging'                 ; -- 17  Import'

   EXEC sp_log 2, @fn, '99: leaving: OK';
END
/*
EXEC sp_reset_call_register;
EXEC sp_pop_staging_tables_post_condition_checks;
*/

GO
