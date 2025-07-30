SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================
-- Author:      Terry watts
-- Create date: 02-NOV-2024
-- Description: imports the system data staging tables
--
-- Responsibilities:
-- ActionStaging           -- 1
-- ChemicalStaging         -- 2
-- CompanyStaging          -- 3
-- CropStaging             -- 4
-- CropPathogenStaging     -- 5
-- DistributorStaging      -- 6
-- FertHandler             -- 7
-- MosaicVirusStaging      -- 8
-- PathogenTypeStaging     -- 9
-- PathogenStaging         -- 10
-- PestHandlerStaging      -- 11
-- UseStaging              -- 12
-- WareHouse               -- 13
-- 
-- Preconditions:
-- PRE 01: import_root must be specified
-- =========================================================================================
CREATE PROCEDURE [dbo].[sp_import_static_data_staging]
    @import_root     VARCHAR(500)
   ,@display_tables  BIT         = 0
AS
BEGIN
   DECLARE
       @fn           VARCHAR(35) = N'import_static_data_staging'
      ,@file_path    VARCHAR(600)
   SET NOCOUNT ON;  -- default: 'D:\Dev\Farming\Data'
   BEGIN TRY
      EXEC sp_log 1, @fn,'000: starting
@import_root   :[',@import_root, ']
@display_tables:[',@display_tables,']
';
   -- PRE 01: import_root specified
      EXEC sp_assert_not_null_or_empty @import_root, 'PRE 01: @import_root must be specified';
      --------------------------------------------------------------------------------------------
      -- 1. Import the ActionStaging table
      --------------------------------------------------------------------------------------------
      EXEC dbo.sp_import_txt_file
          @table        = 'ActionStaging'
         ,@file         = 'Actions.txt'
         ,@folder       = @import_root
         ,@non_null_flds= ' action_id,action_nm '
         ,@display_table= @display_tables
         ;
      --------------------------------------------------------------------------------------------
      -- 2. Import the ChemicalStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_import_txt_file
          @table        = 'ChemicalStaging'
         ,@file         = 'Chemical.txt'
         ,@folder       = @import_root
         ,@non_null_flds= 'chemical_nm'
         ,@display_table= @display_tables
         ;
      --------------------------------------------------------------------------------------------
      -- 3. Import the CompanyStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_import_txt_file
          @table        = 'CompanyStaging'
         ,@file         = 'Company.txt'
         ,@folder       = @import_root
         ,@non_null_flds= 'company_nm'
         ,@display_table= @display_tables
         ;
      --------------------------------------------------------------------------------------------
      -- 4. Import the CropStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_import_txt_file
          @table        = 'CropStaging'
         ,@file         = 'Crops.txt'
         ,@folder       = @import_root
         ,@non_null_flds= 'crop_nm'
         ,@display_table= @display_tables
         ;
      --------------------------------------------------------------------------------------------
      -- 5. Import the CropPathogenStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_import_txt_file
          @table        = 'CropPathogenStaging'
         ,@file         = 'CropPathogens.txt'
         ,@folder       = @import_root
         ,@non_null_flds= 'crop_nm,pathogen_nm'
         ,@display_table= @display_tables
         ;
  --------------------------------------------------------------------------------------------
      -- 6. Import the DistributorStaging table
      --------------------------------------------------------------------------------------------
      EXEC dbo.sp_import_txt_file
          @table        = 'DistributorStaging'
         ,@file         = 'Distributors.txt'
         ,@folder       = @import_root
         ,@non_null_flds= 'distributor_id,distributor_nm,region,province,address'
         ,@display_table= @display_tables
         ;
      --------------------------------------------------------------------------------------------
      -- 7. Import the FertHandlerStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_import_Fert_Handlers 'Fert-Handlers-20240930.txt' , @import_root, @display_tables = @display_tables;
      --------------------------------------------------------------------------------------------
      -- 8. Import the MosaicVirusStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_import_MosaicVirus
          @file          = 'MosaicViruses.txt'
         ,@folder        = @import_root
         ,@display_tables= @display_tables
         ;
      --------------------------------------------------------------------------------------------
      -- 9. Import the PathogenTypeStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'060: importing the PathogenTypeStaging table';
      EXEC dbo.sp_import_txt_file
          @table        = 'PathogenTypeStaging'
         ,@file         = 'PathogenType.txt'
         ,@folder       = @import_root
         ,@non_null_flds= 'pathogenType_id,pathogenType_nm'
         ,@display_table= @display_tables
        ;
      --------------------------------------------------------------------------------------------
      -- 10. Import the PathogenStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'070: Import the PathogenStaging table';
      EXEC dbo.sp_import_txt_file
          @table        = 'PathogenStaging'
         ,@file         = 'Pathogen.txt'
         ,@folder       = @import_root
         ,@first_row    = 3
         ,@non_null_flds= 'pathogen_nm,pathogenType_nm'
         ,@display_table= @display_tables
         ;
      --------------------------------------------------------------------------------------------
      -- 11. Import the PestHandler table satging and mn
      --------------------------------------------------------------------------------------------
      EXEC sp_import_PestHandlers
           @file          ='Pest-Handlers-May-10-2023.txt'
          ,@folder        = @import_root
          ,@display_tables= @display_tables
          ;
      --------------------------------------------------------------------------------------------
      -- 12. Import the UseStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'080: importing the UseStaging table';
      EXEC dbo.sp_import_txt_file
          @table        = 'UseStaging'
         ,@file         = 'use.txt'
         ,@folder       = @import_root
         ,@non_null_flds= 'use_id,use_nm'
         ,@display_table= @display_tables
         ;
      --------------------------------------------------------------------------------------------
      -- 13. Import the WareHouseStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_import_WareHouse     'Fert-Warehouse-20231231.txt', @import_root, @display_tables = @display_tables;
      --------------------------------------------------------------------------------------------
      -- Postcondition checks - chk only primary tables
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'600: Postcondition checks'; 
      EXEC sp_assert_tbl_pop 'ActionStaging';         -- 1
      EXEC sp_assert_tbl_pop 'ChemicalStaging';       -- 2
      EXEC sp_assert_tbl_pop 'CompanyStaging';        -- 3
      EXEC sp_assert_tbl_pop 'CropStaging';           -- 4
      EXEC sp_assert_tbl_pop 'CropPathogenStaging';   -- 5
      EXEC sp_assert_tbl_pop 'DistributorStaging';    -- 6
      EXEC sp_assert_tbl_pop 'FertHandlerStaging';    -- 7
      EXEC sp_assert_tbl_pop 'FertHandler';           -- 7
      EXEC sp_assert_tbl_pop 'MosaicVirusStaging';    -- 8
      EXEC sp_assert_tbl_pop 'PathogenTypeStaging';   -- 9
      EXEC sp_assert_tbl_pop 'PathogenStaging';       -- 10
      EXEC sp_assert_tbl_pop 'PestHandlerstaging';    -- 11
      EXEC sp_assert_tbl_pop 'PestHandler';           -- 11
      EXEC sp_assert_tbl_pop 'UseStaging';            -- 12
      EXEC sp_assert_tbl_pop 'Use';                   -- 12
      EXEC sp_assert_tbl_pop 'WareHouseStaging';      -- 13
      EXEC sp_assert_tbl_pop 'WareHouse';             -- 13
      --------------------------------------------------------------------------------------------
      -- Completed processing OK
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'800: Completed processing OK';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 1, @fn, '999: leaving OK';
END
/*
EXEC sp_import_static_data_staging 'D:\Dev\Farming\Data';
*/
GO

