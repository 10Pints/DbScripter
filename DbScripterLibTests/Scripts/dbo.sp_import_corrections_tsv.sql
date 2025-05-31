SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
-- 
-- Description: Imports the Ph Dep Ag Pesticide register
-- staging table 
-- This:
-- 1: truncates the ImportCorrections and ImportCorrectionsStaging tables
-- 2: imports the corrections data sheet: @imprt_tsv_file into the ImportCorrectionsStaging table
--
-- RETURNS:
--    0 if OK, else OS error code
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    POST01: ImportCorrectionsStaging table clean populated or error
--    POST02: ImportCorrections truncated
--    POST03: @import_tsv_file must exist OR exception 64871 thrown
--    POST04: bulk insert cmd succeeded   OR exception 64872 thrown
--    POST05: at least 1 row was imported OR exception 64873 thrown
--
-- THROWS:
-- 64871 if @import_tsv_file does not exist
-- 64872 if bulk insert cmd errored
-- 64873 if no rows were imported
-- 
-- Tests:
--    test.test_sp_import_correction_files
--
-- Changes:
-- 231109: added exceptions thrown if errors (see POSTCONDITIONS  )
-- ======================================================================
ALTER procedure [dbo].[sp_import_corrections_tsv]
    @import_tsv_file   NVARCHAR(360) -- Full path to import file
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)  = N'IMPRT_CRCTNS_TSV'
      ,@sql          NVARCHAR(MAX)
      ,@rc           INT   = 1
      ,@error_msg    NVARCHAR(500)
      ,@file_exists  INT
      ,@row_cnt      INT   = -1
      ;

   EXEC sp_log 2, @fn, '01: starting, file: [', @import_tsv_file, ']';

   BEGIN TRY
      /*
      TRUNCATE TABLE ImportCorrectionsStaging;
      TRUNCATE TABLE ImportCorrections;
      */
      --SET IDENTITY_INSERT ImportCorrections OFF;
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportCorrectionsErrors.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportCorrectionsErrors.log'          , NO_OUTPUT;
      --         ,LASTROW  = 7

      -- chk if file exists
      EXEC xp_fileexist @import_tsv_file, @file_exists OUT;

      -- POST03: @import_tsv_file must exist OR exception 64871 thrown
      IF @file_exists = 0
      BEGIN
         SET @error_msg = CONCAT(@import_tsv_file, ' does not exist');
         EXEC sp_log 4, @fn, '02: ', @error_msg;
         THROW 64871, '',1;
      END
      SET @sql = CONCAT(
      'BULK INSERT CorrectionsImport_Vw FROM ''', @import_tsv_file, '''
      WITH
      (
          FIRSTROW = 4
         ,FIELDTERMINATOR = ''\t''
         ,ROWTERMINATOR   = ''\n''   
         ,ERRORFILE       = ''D:\Logs\PesticideRegisterImportCorrectionsErrors.log''
      );'
      );
      --EXEC sp_log 2, @fn, '04: exec sp_executesql...';
      EXEC @RC = sp_executesql @sql;
      SET @row_cnt =  @@ROWCOUNT
      EXEC sp_log 2, @fn, '05: imported ', @row_cnt, ' rows';

      -- POST04: bulk insert cmd succeeded   OR exception 64872 thrown
      IF @RC <> 0
      BEGIN
         SET @error_msg = Ut.dbo.fnGetErrorMsg();
         EXEC sp_log 4, @fn, 'error raised during bulk insert cmd :', @RC, 'Error msg: ', @error_msg, ' File: ', @import_tsv_file;
         THROW 64872, @error_msg,1;
      END

      -- POST05: at least 1 row was imported OR exception 64873 thrown
      IF @row_cnt = 0
      BEGIN
         SET @error_msg = 'No rows were imported';
         EXEC sp_log 4, @fn, @error_msg;
         THROW 64873, @error_msg, 1;
      END

      --SET IDENTITY_INSERT ImportCorrections ON;
   END TRY
   BEGIN CATCH
      --SET IDENTITY_INSERT ImportCorrections ON;
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: caught exception: ',@error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: leaving';
   RETURN @RC;
END
/*
EXEC tSQLt.Run 'test.test_sp_import_correction_files'
TRUNCATE TABLE ImportCorrectionsStaging;
TRUNCATE TABLE ImportCorrections;
EXEC sp_import_corrections_file 'D:\Dev\Repos\Farming\Data\ImportCorrections 221008.txt'
SELECT * FROM CorrectionsImport_Vw;
EXEC sp_import_corrections_file 'D:\Dev\Repos\Farming\Data\ImportCorrections 231025.txt'
SELECT * FROM CorrectionsImport_Vw
*/

GO
