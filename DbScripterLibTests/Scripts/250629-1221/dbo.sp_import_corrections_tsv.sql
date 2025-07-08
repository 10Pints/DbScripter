SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================
-- Author:      Terry Watts
-- Create date: 28-JUN-2023
-- 
-- Description: Imports the ImportCorrectionsStaging table
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
--    POST06: @row_cnt contains the number of rows imported from @import_tsv_file
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
CREATE PROCEDURE [dbo].[sp_import_corrections_tsv]
    @import_tsv_file VARCHAR(360) -- Full path to import file
   ,@row_cnt         INT   = NULL      OUT
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)  = N'import_corrections_tsv'
   ,@sql             NVARCHAR(MAX)
   ,@rc              INT   = 1
   ,@error_msg       VARCHAR(1000)
   ,@file_exists     INT
   ,@nl              NCHAR(2) = NCHAR(13)+NCHAR(10)
   ;

   EXEC sp_log 2, @fn, '000: starting, file: [', @import_tsv_file, ']';

   BEGIN TRY

      EXEC sp_log 1, @fn, '010: deleting import log files';

      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportCorrectionsErrors.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportCorrectionsErrors.log'          , NO_OUTPUT;

      -- chk if file exists
      EXEC sp_log 1, @fn, '020: checking the import file exists';
      EXEC xp_fileexist @import_tsv_file, @file_exists OUT;

      -- POST03: @import_tsv_file must exist OR exception 64871 thrown
      IF @file_exists = 0
      BEGIN
         SET @error_msg = CONCAT(@import_tsv_file, ' does not exist');
         EXEC sp_log 4, @fn, '030: ', @error_msg;
         THROW 64871, '',1;
      END

      EXEC sp_log 1, @fn, '040: import file exists';

      SET @sql = CONCAT
      (
         'BULK INSERT ImportCorrectionsStaging_vw FROM ''', @import_tsv_file, '''
         WITH
         (
             FIRSTROW        = 2
            ,FIELDTERMINATOR = ''\t''
            ,ROWTERMINATOR   = ''\n''
            ,ERRORFILE       = ''D:\Logs\PesticideRegisterImportCorrectionsErrors.log''
         );'
      );

      EXEC sp_log 2, @fn, '050: exec import sql:',@nl,
@sql;

      EXEC @RC = sp_executesql @sql;
      SET @row_cnt = @@ROWCOUNT
      EXEC sp_log 2, @fn, '050: imported ', @row_cnt, ' rows';

      -- POST04: bulk insert cmd succeeded   OR exception 64872 thrown
      IF @RC <> 0
      BEGIN
         SET @error_msg = ERROR_MESSAGE();
         EXEC sp_log 4, @fn, '060: error raised during bulk insert cmd :', @RC, ' Error msg: ', @error_msg, ' File: ', @import_tsv_file;
         THROW 64872, @error_msg,1;
      END

      -- POST05: at least 1 row was imported OR exception 64873 thrown
      IF @row_cnt = 0
      BEGIN
         SET @error_msg = '070: No rows were imported';
         EXEC sp_log 4, @fn, @error_msg;
         THROW 64873, @error_msg, 1;
      END

      --SET IDENTITY_INSERT ImportCorrections ON;
   END TRY
   BEGIN CATCH
       EXEC sp_log 4, @fn, '500: caught exception'
      --SET IDENTITY_INSERT ImportCorrections ON;
      SET @error_msg = CONCAT('import file: ',@import_tsv_file,' ', ERROR_MESSAGE());
      EXEC sp_log 4, @fn, '501: caught exception: ',@error_msg, ' see the import log files: D:\Logs\PesticideRegisterImportCorrectionsErrors.log*';
      EXEC sp_log 4, @fn, '510: @sql:
     ', @sql;

     DECLARE @ex_num INT = ERROR_NUMBER();

      THROW @ex_num, @error_msg, 1;
   END CATCH

   EXEC sp_log 2, @fn, '999: leaving';
   RETURN @RC;
END
/*
EXEC tSQLt.Run 'test.test_sp_import_correction_files'

----------------------------------------------------------------------------------------------
EXEC sp_Reset_CallRegister;
TRUNCATE TABLE ImportCorrectionsStaging;
TRUNCATE TABLE ImportCorrections;
EXEC sp_import_corrections_file 'D:\Dev\Farming\Data\ImportCorrections 240910.txt'
SELECT * FROM ImportCorrections_vw;
SELECT * FROM ImportCorrectionsStaging;
SELECT * FROM ImportCorrections;
----------------------------------------------------------------------------------------------
*/

GO
