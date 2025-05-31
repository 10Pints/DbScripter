SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================================================
-- Author:      Terry Watts
-- Create date: 14-DEC-2024
-- Description: imports all the corrections files
--              using the staging table to import a file then merges to the main corfiles table
--
-- Parameters:
-- @crtns_files:  comma separated list of file names without path
-- @import_root   the folder holding the files 
-- @clr_first     if set then clears the ImportCorrectionsStaging and ImportCorrectionsStaging tables
--
-- Notes:
-- @clr_first WILL only be applied ONCE , if specified, to ImportCorrections table
--
-- RESPONSIBILITIES:
-- R01: iniItially cleare the maIN IMPORTCORRECTION TABLE
-- R02: import all the specified corrections files
--
-- PRECONDITIONS:
-- PRE 01: ImportState and CorFiles table pop
--
-- POSTCONDITIONS:
-- POST 01: @clr_first ImportCorrectionsStaging and ImportCorrections clean populated else added
-- POST 02: updates CorFiles with the row count for each import file
--
-- Design
-- EA: Model.Use Case Model.LRAP Import.Import the LRAP Corrections files.Import the LRAP corrections files ACT
-- Import the LRAP corrections files_ActivityGraph
--
-- TESTS: test_006_sp_mn_imprt_stg_04_imp_ctrns
--
-- CHANGES:
-- =====================================================================================================
ALTER PROCEDURE [dbo].[sp_import_cor_files]
    @tot_cnt      INT         = 0    OUT -- total import correction rows from all cor files
   ,@file_cnt     INT         = NULL OUT
AS
BEGIN
   DECLARE
    @fn           VARCHAR(35)  = 'sp_import_cor_files'
   ,@import_root  VARCHAR(500)
   ,@cor_file     VARCHAR(100)
   ,@cor_path     VARCHAR(100)
   ,@cursor       CURSOR
   ,@file_row_cnt INT         = 0

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting';
      
      --------------------------------------------------------------
      -- Validate preconditions
      --------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: Validating preconditions';
      EXEC sp_assert_tbl_pop 'dbo.ImportState', @fn=@fn;
      EXEC sp_assert_tbl_pop 'dbo.CorFiles'   , @fn=@fn;

   SELECT
       @import_root = import_root
      ,@file_cnt    = cor_file_cnt
   FROM ImportState;

      --------------------------------------------------------------
      -- Validated preconditions
      --------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: ASSERTION: Validated preconditions';

   EXEC sp_log 1, @fn, '030: params:
import_root:[',@import_root,']
';

      --------------------------------------------------------------
      -- Process
      --------------------------------------------------------------
      EXEC sp_log 1, @fn, '040: Process';

      EXEC sp_log 1, @fn, '050: clearing ImportCorrections table';

      SET @tot_cnt  = 0;
      SET @file_cnt = 0;

      TRUNCATE TABLE ImportCorrections;

      -- Get the cor files 1 at a time in order and import them
      SET @cursor = CURSOR FOR SELECT [file] FROM CorFiles ORDER BY id;
      OPEN @cursor;

      EXEC sp_log 1, @fn, '060: about to import';

      -- For each file: add the import to the Import corrections Staging table
      FETCH NEXT FROM @cursor INTO @cor_file;
      WHILE (@@FETCH_STATUS = 0)
      BEGIN
         SET @file_cnt = @file_cnt + 1;
         -- Clear the staging table
         TRUNCATE TABLE ImportCorrectionsStaging;
         EXEC sp_log 1, @fn, '070: file[',@file_cnt,'] importing ',@cor_file;
         SET @cor_path = CONCAT(@import_root, '\', @cor_file);
         EXEC sp_log 1, @fn, '080: import file [', @file_cnt,']: ',@cor_path;

         ------------------------------------------------------
         -- Import the file to staging
         ------------------------------------------------------
         EXEC sp_log 1, @fn, '090: importing ', @cor_path;
         EXEC sp_import_cor_file @cor_path, @file_row_cnt OUT;
         EXEC sp_log 1, @fn, '100: imported. @row_cnt: ', @file_row_cnt, ' rows';
         SET @tot_cnt = @tot_cnt + @file_row_cnt; -- increment

         -- Set the file row cnt for the Import Summary Report
         UPDATE CorFiles SET row_cnt = @file_row_cnt WHERE [file] = @cor_file;

         EXEC sp_log 1, @fn, '110: imp file[', @file_cnt,'] completed ',@cor_path, ' import, ImportCorrections now has ', @tot_cnt, ' rows';
         FETCH NEXT FROM @cursor INTO @cor_file;
      END

         ------------------------------------------------------
      -- ASSERTION: ImportCorrections fully populated now
         ------------------------------------------------------

      SELECT @tot_cnt = COUNT(*) FROM ImportCorrections;
      -- PRE 01: at least 1 correction file passed in
      EXEC sp_assert_gtr_than @file_cnt, 0, '120: at least 1 correction file must be specified', @fn=@fn;

      --------------------------------------------------------------------
      -- Processing complete, get total corrections';
      --------------------------------------------------------------------
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, OK, ImportCorrections now has ',@tot_cnt, ' rows, there were ', @file_cnt,' imports';
END
/*
EXEC tSQLt.Run 'test.test_001_import_cor_files';

EXEC tSQLt.RunAll;
*/

GO
