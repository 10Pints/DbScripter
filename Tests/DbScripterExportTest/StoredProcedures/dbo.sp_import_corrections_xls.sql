SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2024
-- 
-- Description: Imports the corrections Excel file for the Ph Dep Ag Pesticide register
-- staging table 
-- This:
-- 1: imports the corrections data sheet: @imprt_xls_file into the ImportCorrectionsStaging table
-- NB does NOT truncate tables as it may be used many times with different files incrementally
-- RETURNS:
--    0 if OK, else OS error code
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    POST01: ImportCorrectionsStaging table clean populated or error
--    POST02: ImportCorrections truncated
--    POST03: @import_xls_file must exist OR exception 64871 thrown
--    POST04: openrowset cmd succeeded    OR exception 64872 thrown
--    POST05: at least 1 row was imported OR exception 64873 thrown
--
-- THROWS:
-- 64871 if @import_xls_file does not exist
-- 64872 if openrowset cmd errored
-- 64873 if no rows were imported
--
-- Tests:
--
-- Changes:
--    240201: changed to use direct XL import: sp_import_XL_existing
-- ==================================================================================================
CREATE   PROCEDURE [dbo].[sp_import_corrections_xls]
    @import_xls_file VARCHAR(360) -- Full path to import file
   ,@range           VARCHAR(100) = 'Sheet1$A:S'
   ,@row_cnt         INT           = -1   OUT
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)  = N'sp_import_corrections_xls'
   ,@sql             VARCHAR(MAX)
   ,@error_msg       VARCHAR(500)
   ,@file_exists     INT
   ;
   EXEC sp_log 2, @fn, '000: starting, 
file:  [', @import_xls_file, ']
@range:[',@range,']';
   BEGIN TRY
      -- Set defaults
      IF @range IS NULL SET @range = 'Sheet1$A:S'
      ----------------------------------------------------------------------------
      -- Parameter validation
      ----------------------------------------------------------------------------
      -- chk if file exists
      EXEC sp_log 1, @fn, '005: chk if file exists';
      EXEC xp_fileexist @import_xls_file, @file_exists OUT;
      -- POST03: @import_xls_file must exist OR exception 64871 thrown
      IF @file_exists = 0
      BEGIN
         SET @error_msg = CONCAT(@import_xls_file, ' does not exist');
         EXEC sp_log 4, @fn, '010: ', @error_msg;
         THROW 64871, '',1;
      END
      ----------------------------------------------------------------------------
      -- ASSERTION: file exists
      ----------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '015: ASSERTION: file exists';
      ----------------------------------------------------------------------------
      -- Import file
      ----------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: importig file: calling sp_import_XL_existing';
      EXEC sp_import_XL_existing
          @import_file  = @import_xls_file
 --        ,@range        = @range
         ,@table        = 'ImportCorrectionsStaging'
         ,@clr_first    = 1
         ,@fields       = 'id,command,search_clause,search_clause_cont,not_clause,replace_clause, case_sensitive, Latin_name, common_name, local_name, alt_names, note_clause, crops, doit, must_update, comments'
         ,@row_cnt      = @row_cnt OUT
         ,@expect_rows  = 1
         ;
      EXEC sp_log 1, @fn, '021';
      EXEC sp_log 1, @fn, '025: imported file OK (', @row_cnt, ' rows)';
      ----------------------------------------------------------------------------
      -- Checking post conditions
      -- POST04: openrowset cmd succeeded   OR exception 64872 thrown
      ----------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: Checking post conditions';
      -- POST01: ImportCorrectionsStaging table clean populated or error:  sp_import_XL_existing @clr_first = 1
      -- POST02: ImportCorrections truncated
      -- POST03: @import_xls_file must exist OR exception 64871 thrown     sp_import_XL_existing 
      -- POST04: openrowset cmd succeeded    OR exception 64872 thrown     sp_import_XL_existing 
      -- POST05: at least 1 row was imported OR exception 64873 thrown     sp_import_XL_existing @expect_rows  = 1
      IF @row_cnt = 0
      BEGIN
         SET @error_msg = 'No rows were imported';
         EXEC sp_log 4, @fn, @error_msg;
         THROW 64873, @error_msg, 1;
      END
   END TRY
   BEGIN CATCH
      SET @error_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn, '50: caught exception: ',@error_msg;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '99: leaving, OK';
   RETURN;
END
/*
EXEC sp_import_corrections_xls 'D:\Dev\Repos\Farming\Data\ImportCorrections 221018 230816-2000.xlsx'
SELECT * FROM ImportCorrectionsStaging
EXEC sp_import_corrections_xls 'D:\Dev\Repos\Farming\Data\ImportCorrections 231025 231106-0000.xlsx'
EXEC tSQLt.Run 'test.test_sp_import_correction_files_xls'
TRUNCATE TABLE ImportCorrectionsStaging;
TRUNCATE TABLE ImportCorrections;
*/
GO

