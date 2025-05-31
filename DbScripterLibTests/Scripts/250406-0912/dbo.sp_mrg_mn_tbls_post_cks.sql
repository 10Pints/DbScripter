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
ALTER PROCEDURE [dbo].[sp_mrg_mn_tbls_post_cks]
AS
BEGIN
   SET NOCOUNT OFF;

   DECLARE 
       @fn        VARCHAR(30)  = N'MRG_MN_TBLS_POST_CHKS'
      ,@error_msg VARCHAR(MAX)  = NULL
      ,@file_path VARCHAR(MAX)
      ,@id        INT = 1

   BEGIN TRY
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'000: starting, running postcondition validation checks';
      -----------------------------------------------------------------------------------
      -----------------------------------------------------------------------------------
      -- 1: Table pop chks
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'010: table pop chks';
      EXEC sp_assert_tbl_pop 'Action';
      EXEC sp_assert_tbl_pop 'Chemical';
      EXEC sp_assert_tbl_pop 'ChemicalAction';
      EXEC sp_assert_tbl_pop 'ChemicalProduct';
      EXEC sp_assert_tbl_pop 'ChemicalUse';
      EXEC sp_assert_tbl_pop 'Company';
      EXEC sp_assert_tbl_pop 'Crop';
      EXEC sp_assert_tbl_pop 'CropPathogen';
      EXEC sp_assert_tbl_pop 'Distributor';
      EXEC sp_assert_tbl_pop 'DistributorManufacturer';
      EXEC sp_assert_tbl_pop 'Pathogen';
      EXEC sp_assert_tbl_pop 'PathogenChemical';
      EXEC sp_assert_tbl_pop 'PathogenType';
      EXEC sp_assert_tbl_pop 'Product';
      EXEC sp_assert_tbl_pop 'ProductCompany';
      EXEC sp_assert_tbl_pop 'ProductUse';
      EXEC sp_assert_tbl_pop 'Use';

      -----------------------------------------------------------------------------------
      -- 2: Detailed checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'020: detailed chks';
      EXEC sp_log 2, @fn,'005: Action';
      EXEC sp_check_field_not_null 'Action','action_id';
      EXEC sp_check_field_not_null 'Action','action_nm';

      EXEC sp_log 2, @fn,'010: Chemical';
      EXEC sp_check_field_not_null 'Chemical','chemical_id';
      EXEC sp_check_field_not_null 'Chemical','chemical_nm';

      EXEC sp_log 2, @fn,'015: Company';
      EXEC sp_check_field_not_null 'Company','company_id';
      EXEC sp_check_field_not_null 'Company','company_nm';

      EXEC sp_log 2, @fn,'020: Crop';
      EXEC sp_check_field_not_null 'Crop','crop_id';
      EXEC sp_check_field_not_null 'Crop','crop_nm';

      EXEC sp_log 2, @fn,'025: Distributor';
      EXEC sp_check_field_not_null 'Distributor','distributor_id';
      EXEC sp_check_field_not_null 'Distributor','distributor_name';

      EXEC sp_log 2, @fn,'030: Pathogen';
      EXEC sp_check_field_not_null 'Pathogen','pathogen_id';
      EXEC sp_check_field_not_null 'Pathogen','pathogen_nm';
      EXEC sp_check_field_not_null 'Pathogen','pathogenType_nm';
      EXEC sp_check_field_not_null 'Pathogen','pathogenType_id';
      EXEC sp_check_field_not_null 'Pathogen','crops';
      EXEC sp_check_field_not_null 'Pathogen','taxonomy';
      EXEC sp_check_field_not_null 'Pathogen','biological_cure';
      EXEC sp_check_field_not_null 'Pathogen','notes';
      EXEC sp_check_field_not_null 'Pathogen','urls';

      EXEC sp_log 2, @fn,'035: PathogenType';
      EXEC sp_check_field_not_null 'PathogenType','pathogenType_id';
      EXEC sp_check_field_not_null 'PathogenType','pathogenType_nm';

      EXEC sp_log 2, @fn,'040: Product';
      EXEC sp_check_field_not_null 'Product','product_id';
      EXEC sp_check_field_not_null 'Product','product_nm';

      EXEC sp_log 2, @fn,'045: Type';
      EXEC sp_check_field_not_null 'Type','type_id';
      EXEC sp_check_field_not_null 'Type','type_nm';

      EXEC sp_log 2, @fn,'050: Use';
      EXEC sp_check_field_not_null 'Use','use_id';
      EXEC sp_check_field_not_null 'Use','use_nm';

      EXEC sp_log 2, @fn,'060: ChemicalAction';
      EXEC sp_check_field_not_null 'ChemicalAction','chemical_id';
      EXEC sp_check_field_not_null 'ChemicalAction','action_id';
      EXEC sp_check_field_not_null 'ChemicalAction','chemical_nm';
      EXEC sp_check_field_not_null 'ChemicalAction','action_nm';
      EXEC sp_check_field_not_null 'ChemicalAction','created';

      EXEC sp_log 2, @fn,'065: ChemicalProduct';
      EXEC sp_check_field_not_null 'ChemicalProduct','chemical_id';
      EXEC sp_check_field_not_null 'ChemicalProduct','product_id';
      EXEC sp_check_field_not_null 'ChemicalProduct','chemical_nm';
      EXEC sp_check_field_not_null 'ChemicalProduct','product_nm';

      EXEC sp_log 2, @fn,'070: ChemicalUse';
      EXEC sp_check_field_not_null 'ChemicalUse','chemical_id';
      EXEC sp_check_field_not_null 'ChemicalUse','use_id';
      EXEC sp_check_field_not_null 'ChemicalUse','chemical_nm';
      EXEC sp_check_field_not_null 'ChemicalUse','use_nm';

      EXEC sp_log 2, @fn,'075: CropPathogen';
      EXEC sp_check_field_not_null 'CropPathogen','crop_id';
      EXEC sp_check_field_not_null 'CropPathogen','pathogen_id';
      EXEC sp_check_field_not_null 'CropPathogen','crop_nm';
      EXEC sp_check_field_not_null 'CropPathogen','pathogen_nm';

      EXEC sp_log 2, @fn,'080: PathogenChemical';
      EXEC sp_check_field_not_null 'PathogenChemical','pathogen_id';
      EXEC sp_check_field_not_null 'PathogenChemical','chemical_id';
      EXEC sp_check_field_not_null 'PathogenChemical','pathogenType_id';
      EXEC sp_check_field_not_null 'PathogenChemical','pathogen_nm';
      EXEC sp_check_field_not_null 'PathogenChemical','chemical_nm';
      EXEC sp_check_field_not_null 'PathogenChemical','created';

      EXEC sp_log 2, @fn,'085: ProductCompany';
      EXEC sp_check_field_not_null 'ProductCompany','product_id';
      EXEC sp_check_field_not_null 'ProductCompany','company_id';
      EXEC sp_check_field_not_null 'ProductCompany','product_nm';
      EXEC sp_check_field_not_null 'ProductCompany','company_nm';

      EXEC sp_log 2, @fn,'090: ProductUse';
      EXEC sp_check_field_not_null 'ProductUse','product_id';
      EXEC sp_check_field_not_null 'ProductUse','use_id';

      EXEC sp_log 2, @fn,'095: ProductUse';
      EXEC sp_check_field_not_null 'ProductUse','product_nm';
      EXEC sp_check_field_not_null 'ProductUse','use_nm';
      EXEC sp_check_field_not_null 'ProductUse','created';
      -----------------------------------------------------------------------------------
      -- Detailed checks
      -----------------------------------------------------------------------------------

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
EXEC sp_sp_mrg_mn_tbls_post_cks;
*/

GO
