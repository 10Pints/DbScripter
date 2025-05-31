SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 31-MAR-2024
-- Description: validates sp_merge_normalised_tables preconditions
--
-- PRECONDITIONS:
-- the following set of staging tables are populated and fixed up
--    PRE01: ActionStaging
--    PRE02: ChemicalStaging
--    PRE03: ChemicalActionStaging
--    PRE04: ChemicalProductStaging
--    PRE05: ChemicalUseStaging
--    PRE06: CompanyStaging
--    PRE07: CropStaging
--    PRE08: CropPathogenStaging
----    PRE09: PathogenStaging
--    PRE10: PathogenChemicalStagng
--    PRE11: PathogenTypeStaging
--    PRE12: PathogenPathogenStaging
--    PRE12: ProductStaging
--    PRE13: ProductCompanyStaging
--    PRE14: ProductUseStaging
--    PRE15: TypeStaging
--    PRE16: UseStaging
--    PRE17: DistributorStaging
--
-- TESTS:
--
-- CHANGES:
-- ==================================================================================================================================================
ALTER   PROCEDURE [dbo].[sp_mrg_mn_tbls_val_precndtns]
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE 
       @fn        VARCHAR(30)  = N'MRG_NORM_TBLS_VAL_PRE_CONDS'
      ,@error_msg VARCHAR(MAX)  = NULL
      ,@file_path VARCHAR(MAX)
      ,@id        INT = 1

   BEGIN TRY
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'000: starting, running postcondition validation checks';
      -----------------------------------------------------------------------------------
      -----------------------------------------------------------------------------------
      -- 22  PRECONDITION checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '005: checking preconditions';
--    PRE01: ActionStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ActionStaging';
--    PRE02: ChemicalStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ChemicalStaging';
--    PRE03: ChemicalActionStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ChemicalActionStaging';
--    PRE04: ChemicalProductStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ChemicalProductStaging';
--    PRE05: ChemicalUseStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ChemicalUseStaging';
--    PRE06: CompanyStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'CompanyStaging';
--    PRE07: CropStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'CropStaging';
--    PRE08: CropPathogenStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'CropPathogenStaging';
--    PRE09: PathogenStaging
--      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'PathogenStaging';
--    PRE10: PathogenChemicalStagng
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'PathogenChemicalStaging';
--    PRE11: PathogenTypeStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'PathogenTypeStaging';
--    PRE13: ProductStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ProductStaging';
--    PRE13: ProductCompanyStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ProductCompanyStaging';
--    PRE14: ProductUseStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'ProductUseStaging';
--    PRE15: TypeStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'TypeStaging';
--    PRE16: UseStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'UseStaging';
--    PRE17: DistributorStaging
      EXEC sp_mrg_mn_tbls_precndtn_hlpr @id OUTPUT, 'DistributorStaging';
      -----------------------------------------------------------------------------------
      -- 23: Completed processing OK
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '220: Completed processing OK';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving: OK';
END
/*
EXEC sp_merge_normalised_tables_val_preconditions
*/


GO
