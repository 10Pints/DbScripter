SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 31-MAR-2024
-- Description: validates sp_merge_normalised_tables postconditions
--       and do any main table fixup
--
-- POSTCONDITIONS
-- DEL01: This is the deliverable set of output tables populated by this routine
-- POST 01: Action table populated
-- POST 02: Chemical table populated
-- POST 03: ChemicalAction table populated
-- POST 04: ChemicalProduct table populated
-- POST 05: ChemicalUse table populated
-- POST 06: Company table populated
-- POST 07: Crop table populated
-- POST 08: CropPathogen table populated
-- POST 09: Distributor table populated
-- POST 10: Pathogen table populated
-- POST 11: PathogenChemical table populated
-- POST 12: PathogenType table populated
-- POST 13: Product table populated
-- POST 14: ProductCompany table populated
-- POST 15: ProductUse table populated
-- POST 16: Type table populated
-- POST 17: Use table populated
-- POST 18: DistributorManufacturer populated
--
-- TESTS:
--
-- CHANGES:
-- ==================================================================================================================================================
ALTER PROCEDURE [dbo].[sp_merge_normalised_tables_val_postconditions]
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE 
       @fn        NVARCHAR(30)  = N'MRG_NORM_TBLS_VAL_PCS'
      ,@error_msg NVARCHAR(MAX)  = NULL
      ,@file_path NVARCHAR(MAX)
      ,@id        INT = 1

   BEGIN TRY
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'000: starting, running postcondition validation checks';
      -----------------------------------------------------------------------------------
      -----------------------------------------------------------------------------------
      -- 22  POSTCONDITION checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '210: POSTCONDITION checks...';
      -- POST 01: Chemical table populated
      EXEC dbo.sp_chk_tbl_populated 'Action';
      EXEC dbo.sp_chk_tbl_populated 'Chemical';
      -- POST 02: ChemicalAction table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalAction';
      -- POST 03: ChemicalProduct table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalProduct';
      -- POST 04: ChemicalUse table populated
      EXEC dbo.sp_chk_tbl_populated 'ChemicalUse';
      -- POST 05 Company table populated
      EXEC dbo.sp_chk_tbl_populated 'Company';
      -- POST 06: Crop table populated
      EXEC dbo.sp_chk_tbl_populated 'Crop';
      -- POST 07: CropPathogen populated
      EXEC dbo.sp_chk_tbl_populated 'CropPathogen';
      -- POST 08: Distributor table populated
      EXEC dbo.sp_chk_tbl_populated 'Distributor';
      EXEC dbo.sp_chk_tbl_populated 'DistributorManufacturer';
      -- POST 09: Pathogen table populated
      EXEC dbo.sp_chk_tbl_populated 'Pathogen';
      -- POST 10: PathogenChemical table populated
      EXEC dbo.sp_chk_tbl_populated 'PathogenChemical';
      -- POST 11: PathogenType table populated
      EXEC dbo.sp_chk_tbl_populated 'PathogenType';
      -- POST 12: Product table populated
      EXEC dbo.sp_chk_tbl_populated 'Product';
      -- POST 13: ProductCompany table populated
      EXEC dbo.sp_chk_tbl_populated 'ProductCompany';
      -- POST 14: ProductUse table populated
      EXEC dbo.sp_chk_tbl_populated 'ProductUse';
      -- POST 15: Type table populated
      EXEC dbo.sp_chk_tbl_populated 'Type';
      -- POST 16: Use table populated
      EXEC dbo.sp_chk_tbl_populated 'Use';

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
EXEC sp_reset_CallRegister;
EXEC sp_merge_normalised_tables 1
*/

GO
