SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================================================
-- Author:      Terry Watts
-- Create date: 28-JAN-2024
--
-- Description: imports all the static data
-- Tables:
--   {1. ActionStaging,       2. UseStaging, 3.Distributor
--   ,4. PathogenTypeStaging, 5. Pathogen*,  6. TypeStaging}
--
-- NB*** Pathogen is directly imported into - it is used as a primary data table and 
--       used to check the pathogens in S2
--
-- Responsibilities:
-- R01: clear dependent tables
-- R02: import all the static data tables
--
-- Preconditions: dependent tables cleared
--
-- Postconditions:
--   POST01: all the imported tables have at least one row
--
-- Called by: sp__main_import_pesticide_register
--
-- Tests:
--
-- Changes:
-- 240223: import PathogenTypeStaging table from either a tsv or xlsx file
-- 240225: removed precondition and made part of the processing so routine is easy to test 
-- 240321: treating Pathogen as a primary data table to check the lRAP import pathogens
-- =========================================================================================
ALTER PROCEDURE [dbo].[sp_import_static_data]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)  = N'IMPRT_STATIC_DATA'
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX) = NULL
      ,@rc        INT           =-1
      ;

   BEGIN TRY
      EXEC sp_log 1, @fn,'000: starting';
      EXEC sp_register_call @fn;

      --------------------------------------------------------------------------------------------
      -- R01: clear dependent tables
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'005: R01: clear dependent tables';
      EXEC sp_clear_staging_tables 1;

      --------------------------------------------------------------------------------------------
      -- R02: import all the static data tables
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'010: R02: import all the static data tables';

      --------------------------------------------------------------------------------------------
         -- 1. Import the import table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'015: import the Import table';
      EXEC sp_bulk_import 
          @import_file   = 'D:\Dev\Farming\Data\Import.xlsx'
         ,@table         = 'Import'
         ,@range         = 'Import$A:F'
         ,@clr_first     = 1
         ,@is_new        = 0;

      --------------------------------------------------------------------------------------------
         -- 1. Import the TableType table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'020: import the TableType table';
      EXEC sp_bulk_import 
          @import_file   = 'D:\Dev\Farming\Data\TableDef.xlsx'
         ,@table         = 'TableType'
         ,@range         = 'TableType$A:B'
         ,@clr_first     = 1
         ,@is_new        = 0;

      --------------------------------------------------------------------------------------------
         -- 2. Import the TableDef table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'025: import the TableDef table';
      EXEC sp_bulk_import 
          @import_file   = 'D:\Dev\Farming\Data\TableDef.xlsx'
         ,@table         = 'TableDef'
         ,@range         = 'TableDef$A:E'
         ,@clr_first     = 1
         ,@is_new        = 0;

      --------------------------------------------------------------------------------------------
         -- 2. Import the ForeignKeys table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'025: Import the ForeignKeys table';
      EXEC sp_import_ForeignKey_XL 'D:\Dev\Farming\Data\ForeignKey.xlsx', 'Sheet1$'

      --------------------------------------------------------------------------------------------
         -- 3. Import the Action staging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'030: Import the ActionStaging table';
      EXEC dbo.sp_bulk_import 
          @import_file   = 'D:\Dev\Farming\Data\Actions.xlsx'
         ,@table         = 'ActionStaging'
         ,@view          = 'ImportActionStaging_vw'
         ,@range         = 'Actions$A:B'
         ,@clr_first     = 1;

      --------------------------------------------------------------------------------------------
         -- 4. Import the Use staging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'035: Import the UseStaging table';
      EXEC dbo.sp_bulk_import 
          @import_file  = 'D:\Dev\Farming\Data\use.xlsx'
         ,@table        = 'UseStaging'
         ,@range        = 'Use$A:B'
         ,@clr_first    = 1
         ,@expect_rows  = 1

      --------------------------------------------------------------------------------------------
      -- 5. Import the Distributors table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'040: Import the Distributors table';
      EXEC dbo.sp_bulk_import 
          @import_file  = 'D:\Dev\Farming\Data\Distributors.xlsx'
         ,@table        = 'DistributorStaging'
         ,@range        = 'Distributors$A:H'
         ,@clr_first    = 1
         ,@expect_rows  = 1

      --------------------------------------------------------------------------------------------
      -- 6. Import the PathogenTypeStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'045: Import the PathogenTypeStaging table';
      EXEC dbo.sp_bulk_import 
          @import_file  = 'D:\Dev\Farming\Data\PathogenType.xlsx'
         ,@table        = 'PathogenTypeStaging'
         ,@range        = 'PathogenType$A:B'
         ,@clr_first    = 1
         ,@expect_rows  = 1

      --------------------------------------------------------------------------------------------
      -- 7. Import the Pathogen table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'050: Import the Pathogen table';
      DELETE FROM CropPathogen;
      DELETE FROM PathogenChemical;

      EXEC dbo.sp_bulk_import 
          @import_file  = 'D:\Dev\Farming\Data\Pathogen.xlsx'
         ,@table        = 'Pathogen'
         ,@range        = 'Pathogen$A:B'
         ,@clr_first    = 1
         ,@expect_rows  = 1

      --------------------------------------------------------------------------------------------
      -- 8. Import the TypeStaging table
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'055: Import the TypeStaging table';
      EXEC sp_import_TypeStaging 'D:\Dev\Farming\Data\Type.xlsx';

      --------------------------------------------------------------------------------------------
      -- 9. Post condition checks
      --------------------------------------------------------------------------------------------
      EXEC sp_chk_tbl_populated 'ActionStaging';
      EXEC sp_chk_tbl_populated 'Distributor';
      EXEC sp_chk_tbl_populated 'ForeignKey';
      EXEC sp_chk_tbl_populated 'Import';
      EXEC sp_chk_tbl_populated 'Pathogen';
      EXEC sp_chk_tbl_populated 'PathogenTypeStaging';
      EXEC sp_chk_tbl_populated 'TableDef';
      EXEC sp_chk_tbl_populated 'TableType';
      EXEC sp_chk_tbl_populated 'TypeStaging';
      EXEC sp_chk_tbl_populated 'UseStaging';

      --------------------------------------------------------------------------------------------
      -- Completed processing OK
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'995: Completed processing OK';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving OK';
   RETURN @RC;
END
/*
---------------------------------------------------------------------
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_009_sp_import_static_data';
---------------------------------------------------------------------
EXEC sp_reset_CallRegister;
EXEC sp_clear_staging_tables 1;
EXEC sp_import_typeStaging 'D:\Dev\Repos\Farming\Data\Type.xlsx';
EXEC sp_import_static_data;
SELECT * FROM PathogenStaging
---------------------------------------------------------------------
*/

GO
