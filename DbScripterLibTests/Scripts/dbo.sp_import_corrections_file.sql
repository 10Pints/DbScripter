SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================================================
-- Author:      Terry Watts
-- Create date: 08-NOV-2023
--
-- Description:
--    imports 1 file, either a tsv or excel file
--    initially cleans out ImportCorrectionsStaging and ImportCorrections (resets stging id2 key)
--    imports all the correction files to ImportCorrectionsStaging
--    does fixup of ImportCorrectionsStaging
--    copies ImportCorrectionsStaging to ImportCorrections
--
-- Parameters:
--    @import_root:               the directory holding the file
--    @correction_file_inc_range: holds the file name and the possible excel range like <file path>!<sheet nm>$<range>
--
-- PRECONDITIONS - none?
--
-- POSTCONDITIONS:
-- POST 01: must be at least 1 corrections file import.                           EX 52410
-- POST 02: import root must be specified                                         EX 52411
-- POST 03: import file name must be specified                                    EX 52412
-- POST 04: import root folder must exist                                         EX 52413
-- POST 05: ImportCorrectionsStaging search_clause_cont merged into search_clause EX 60000
--
-- CHANGES:
-- 240322: only handles 1 file: either a tsv or excel file
-- ===============================================================================================
ALTER PROCEDURE [dbo].[sp_import_corrections_file]
    @import_root               NVARCHAR(450)
   ,@correction_file_inc_range NVARCHAR(MAX) -- file path includng range if an Excel file
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'IMPRT_CRTN_FILE'
      ,@correction_file    NVARCHAR(250)  = NULL -- 1 import file from the import files parameter list
      ,@range              NVARCHAR(32)
      ,@error_msg          NVARCHAR(200)
      ,@import_id          INT            = NULL
      ,@msg                NVARCHAR(500)  = ''
      ,@file_exists        INT            = -1
      ,@folder_exists      INT            = -1
      ,@is_csv_file        BIT

   SET NOCOUNT ON;

   BEGIN TRY
      EXEC sp_log 2, @fn,'000: starting
import_root              :[',@import_root,']
correction_file_inc_range:[',@correction_file_inc_range,']'
;
      EXEC sp_register_call @fn;

      --------------------------------------------------------------------------------------------------------
      -- Validate params
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '005: Validating params...';
      -- POST 02: import root must be specified
      IF ((@import_root IS NULL ) OR( Ut.dbo.fnLen(@import_root)=0))
         THROW 52411,'import root must be specified',1;

      --------------------------------------------------------------------------------------------------------
      -- Process
      --------------------------------------------------------------------------------------------------------
      -- Get the file path and the possible excel range from the @correction_file_inc_range parameter
      SELECT
          @correction_file = file_path
         ,@range           = [range]
      FROM ut.dbo.fnGetRangeFromFileName(@correction_file_inc_range);

      -- POST04: import root folder must exist               EX 52413
      EXEC Ut.dbo.sp_file_exists @import_root,@file_exists OUT ,@folder_exists OUT;

      IF @folder_exists < 1
      BEGIN
         SET @error_msg = CONCAT('010: POST04: import root folder [',@import_root,'] must exist');
         EXEC sp_log 4, @error_msg;
         THROW 52413, @error_msg, 1;
      END

      EXEC sp_log 1, @fn, '015: Validated params ok';

      EXEC sp_log 1, @fn,'020: Clean ImportCorrections table';
      TRUNCATE TABLE ImportCorrections;
      EXEC sp_log 1, @fn, '025: truncating staging table ready for this batch';
      TRUNCATE TABLE ImportCorrectionsStaging;
      SET @is_csv_file = IIF(CHARINDEX('.csv', @correction_file)>0, 1, 0);
      EXEC sp_log 1, @fn, '035: fetch OK, processing Corrections file: [',@correction_file, ']';

      -- POST 03: import file must be specified
      IF ((@correction_file IS NULL) OR (Ut.dbo.fnLen(@correction_file) = 0)) THROW 52412, 'import file name must be specified',1;
      --SET @correction_file = CONCAT(@import_root, '\', @correction_file);
      EXEC sp_log 1, @fn, '040: correction_file:', @correction_file

      --------------------------------------------------------------------------------------------------------
      -- Run the import
      --------------------------------------------------------------------------------------------------------
      --EXEC sp_log @fn, 1, '30: calling sp_bulk_insert_pesticide_import_corrections ', @correction_file
      EXEC sp_log 1, @fn, '045: run the import ', @correction_file, @range, ' @is_csv_file: ', @is_csv_file;

      -- Handle either TSV or Excel file
      IF @is_csv_file = 1
         EXEC sp_import_corrections_tsv @correction_file;
      ELSE
         EXEC sp_import_corrections_xls @correction_file, @range;

      EXEC sp_log 1, @fn, '050: returned frm the import_corrections rtn ', @correction_file

      --------------------------------------------------------------------------------------------------------
      -- Fixup import_corrections  like the XL 255 bug
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '055: fixup import_corrections like the XL 255 buge...';
      EXEC sp_fixup_import_corrections_staging;

      EXEC sp_log 1, @fn, '060: copying correction staging to corrections table...';
      EXEC sp_copy_corrections_staging_to_mn;

      --------------------------------------------------------------------------------------------------------
      -- Check postconditions
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'800: checking postconditions';
      -- POST 01: must be at least 1 corrections file import.                           EX 52410
      EXEC sp_chk_tbl_populated 'ImportCorrections';

      --------------------------------------------------------------------------------------------------------
      -- Completed processing
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'950: Completed processing';
   END TRY
   BEGIN CATCH
      EXEC Ut.dbo.sp_get_error_msg @error_msg OUT
      EXEC sp_log 4, @fn, '500: caught exception:  error: ', @error_msg;
      --SELECT * FROM AppLog;
      THROW;
   END CATCH

   -- SELECT * FROM AppLog;
   EXEC sp_log 2, @fn,'999: leaving';
END
/*
EXEC sp_reset_CallRegister;
EXEC sp_import_corrections_file 'D:\Dev\Repos\Farming\Data\', 'ImportCorrections 221018 230816-2000.xlsx!ImportCorrections$A:S';

EXEC tSQLt.Run 'test.test_sp_import_correction_files';
Select * FROM AppLog;
EXEC tSQLt.RunAll;
*/

GO
