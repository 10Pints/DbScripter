SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================
-- Author:      Terry Watts
-- Create date: 28-JAN-2024
--
-- DESCRIPTION:
-- Imports the static data, comprising of PRIMARY and SYSTEM static data
-- Imports the statging tables
-- Merges to the Main static tables
-- EXEC tSQLt.Run 'test.test_009_sp_import_static_data';
--
-- Static SYSTEM data are:
-- CallRegister : imported by sp_main_import_init
-- Import       : imported here
-- ForeignKey   : imported here
-- TypeStaging  : imported here
-- TableType    : imported here
-- TableDef     : imported here
-- 
-- Static data are:
-- ActionStaging
-- CropPathogenStaging
-- CropStaging
-- DistributorStaging: non LRAP data like address
-- MosaicVirusStaging
-- PathogenStaging
-- PathogenTypeStaging
-- UseStaging
--
-- The dynamic data are created from LRAP Staging2
-- *** These tables are NOT IMPORTED as static data before the LRAP load
-- *** But after the LRAP load and fixup
-- It is comprised of the following:
-- ChemicalActionStaging
-- ChemicalStaging
-- ChemicalProductStaging
-- ChemicalUseStaging
-- CompanyStaging
-- ImportCorrectionsStaging
-- PathogenChemicalStaging
-- ProductStaging
-- ProductCompanyStaging
-- ProductUseStaging: non LRAP data
-- RESPONSIBILITIES:
-- R01: clear dependent tables
-- R02: import the following tables:
-- ActionStaging
-- CropStaging
-- CropPathogenStaging
-- DistributorStaging
-- 12 Eppo Staging tables(, als fixup and merge to the main Eppo tables) - delegated to sp_import_eppo
-- FertHandler
-- ForeignKey
-- Import
-- PathogenStaging
-- PathogenTypeStaging
-- TableDef
-- TableType
-- TypeStaging
-- UseStaging
--
-- R03: populates the following Main static tables
-- Action
-- Crop
-- CropPathogen
-- Distributor
-- Eppo tables - see import eppo as the eppo data are a conditional import
-- PathogenType
-- Pathogen
-- TableDef
-- TableType
-- Type
-- Use
--
-- PRECONDITIONS: dependent tables cleared
-- 
-- POSTCONDITIONS:
--   POST01: all the imported tables have at least one row
--
-- CALLED BY: sp__main_import
--
-- TESTS:
--
-- CHANGES:
-- 240223: import PathogenTypeStaging table from either a tsv or xlsx file
-- 240225: removed precondition and made part of the processing so routine is easy to test 
-- 240321: treating Pathogen as a primary data table to check the lRAP import pathogens
-- 241130: optionally import the eppo files
-- =========================================================================================
CREATE PROCEDURE [dbo].[sp_import_static_data]
    @import_root     VARCHAR(500)   = NULL  -- default: 'D:\Dev\Farming\Data'
   ,@display_tables  BIT            = 0
   ,@import_eppo     BIT            = 0
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)    = N'sp_import_static_data'
   ,@sql             VARCHAR(MAX)   
   ,@error_msg       VARCHAR(MAX)   = NULL
   ;
   BEGIN TRY
      IF dbo.fnLen(@import_root) = 0 SET @import_root = 'D:\Dev\Farming\Data';
      EXEC sp_log 1, @fn,'000: starting
@import_root   :[',@import_root   ,']
@display_tables:[',@display_tables,']
@import_eppo   :[',@import_eppo   ,']
';
      --------------------------------------------------------------------------------------------
      -- R01: import system static data tables
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'010: calling sp_import_system_static_data';
      EXEC sp_import_system_static_data;
      --------------------------------------------------------------------------------------------
      -- R02: import primary static data staging tables
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'020: R02: importing the primary static data tables';
      EXEC sp_import_static_data_staging @import_root, @display_tables = @display_tables;
      --------------------------------------------------------------------------------------------
      -- R02.2 import Eppo Staging tables
      --------------------------------------------------------------------------------------------
      IF @import_eppo = 1
      BEGIN
         EXEC sp_log 1, @fn,'030: import Eppo Staging tables';
         EXEC sp_import_eppo @display_tables = @display_tables;
      END
      --------------------------------------------------------------------------------------------
      -- R03 Fixup and Merge to main static data tables
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'040: Merge to main tables';
      EXEC sp_merge_static_tbls;
      --------------------------------------------------------------------------------------------
      -- Postcondition checks
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'050: Postcondition checks: staging tables';
      --------------------------------------------------------------------------------------------
      -- Postcondition checks - staging tables
      --------------------------------------------------------------------------------------------
      EXEC sp_assert_tbl_pop 'ActionStaging';
      EXEC sp_assert_tbl_pop 'CropStaging';
      EXEC sp_assert_tbl_pop 'MosaicVirusStaging';
      EXEC sp_assert_tbl_pop 'PathogenStaging';
      EXEC sp_assert_tbl_pop 'PathogenTypeStaging';
      EXEC sp_assert_tbl_pop 'TypeStaging';
      EXEC sp_assert_tbl_pop 'UseStaging';
         --------------------------------------------------------------------------------------------
   -- R03:  Postcondition checks - main static tables
         --------------------------------------------------------------------------------------------
   -- Action
   -- Crop
   -- CropPathogen
   -- Distributor
   -- Eppo tables - see import eppo as the eppo data are a conditional import
   -- PathogenType
   -- Pathogen
   -- TableDef
   -- TableType
   -- Use
      EXEC sp_log 1, @fn,'60: Postcondition checks: main static tables';
      EXEC sp_assert_tbl_pop 'Action';
      EXEC sp_assert_tbl_pop 'Crop';
      EXEC sp_assert_tbl_pop 'FertHandler';
      EXEC sp_assert_tbl_pop 'Import';
      EXEC sp_assert_tbl_pop 'MosaicVirus';
      EXEC sp_assert_tbl_pop 'Pathogen';
      EXEC sp_assert_tbl_pop 'PathogenType';
      EXEC sp_assert_tbl_pop 'TableDef';
      EXEC sp_assert_tbl_pop 'TableType';
      EXEC sp_assert_tbl_pop 'Type';
      EXEC sp_assert_tbl_pop 'Use';
      EXEC sp_assert_tbl_pop 'WareHouse';
      --------------------------------------------------------------------------------------------
      -- Completed processing OK
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'400: Completed processing OK';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 1, @fn, '999: leaving OK';
END
/*
EXEC sp_import_static_data 1,0; -- disp tbls, no eppo
EXEC tSQLt.RunAll;
*/
GO

