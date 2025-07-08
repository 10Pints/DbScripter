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
--    merges ImportCorrectionsStaging to ImportCorrections
--
-- Notes:
-- Incrementally add to ImportCorrections as this may be part of a multiple corrections file import
--
-- Parameters:
--    @cor_file_ir:      holds the file name and the possible excel range like <file path>!<sheet nm>$<range>
--    @cor_file_row_cnt: cor rows from the cor file
--
-- PRECONDITIONS - none?
--
-- POSTCONDITIONS:     ASSERTION                                                 OR
-- POST 01: import file must be specified                                        EX 52412
-- POST 02: import file must exist                                               EX 64871
-- POST 03: Import data has either replace clause, a cmd is IN ('SKIP','SQL','STOP') or a notes clause   EX 52413
-- POST 04: @row_cnt contains the count of rows for this file only (not inceremental)
--
-- CHANGES:
-- 240322: only handles 1 file: either a tsv or excel file
-- 241130: check that corrections import data has either replace clause, a SQL cmd or a notes clause
-- ===============================================================================================
CREATE PROCEDURE [dbo].[sp_import_cor_file]
    @cor_file_ir        VARCHAR(MAX) -- file path including range if an Excel file
   ,@cor_file_row_cnt   INT =NULL OUT
AS
BEGIN
DECLARE
    @fn           VARCHAR(35)   = N'sp_import_cor_file'
   ,@file_path    VARCHAR(250)  = NULL -- 1 import file from the import files parameter list
   ,@file_nm      VARCHAR(60)
   ,@range        VARCHAR(32)
   ,@error_msg    VARCHAR(200)
   ,@ext          VARCHAR(20)
   ,@import_id    INT            = NULL
   ,@msg          VARCHAR(500)  = ''
   ,@file_exists  INT            = -1
   ,@row_id       INT
   ,@is_csv_file  BIT

   SET NOCOUNT ON;

   BEGIN TRY
      EXEC sp_log 1, @fn,'000: starting:
cor_file_ir:[',@cor_file_ir,'] -- optionally includes range 
';

      ------------------------------------------------------------------------------------------------
      -- Get the file path and the possible excel range from the @cor_file_ir parameter
      ------------------------------------------------------------------------------------------------
      SELECT
          @file_path = file_path
         ,@range     = [range]
         ,@ext       = ext
         ,@file_nm   = file_nm
      FROM dbo.fnGetRangeFromFileName(@cor_file_ir);

      --SELECT * FROM dbo.fnGetRangeFromFileName(@cor_file_ir);
      SET @is_csv_file = IIF(@ext='txt', 1, 0);

      --------------------------------------------------------------------------------------------------------
      -- Modified params
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: Modified params
file_path:  :[',@file_path  ,']
range:      :[',@range      ,']
ext:        :[',@ext        ,']
is_csv_file :[',@is_csv_file,']
';

      EXEC sp_log 1, @fn, '020: truncating staging table ready for this batch';
      TRUNCATE TABLE ImportCorrectionsStaging;

      --------------------------------------------------------------------------------------------------------
      -- Validating params
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: validating params';

      -- POST 01: import file must be specified                                        EX 52412
      EXEC sp_assert_not_null_or_empty @file_path, ',import file must be specified', @ex_num=52412;

      -- POST 02: import file must exist or EX 64871
      -- POST06: @row_cnt contains the number of rows imported from @import_tsv_file
      EXEC sp_assert_file_exists @file_path,'import file ', @ex_num=64871;

      --------------------------------------------------------------------------------------------------------
      -- ASSERTION: params validated
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '040: ASSERTION: params validated';

      --------------------------------------------------------------------------------------------------------
      -- Process
      --------------------------------------------------------------------------------------------------------
      -- Run the import

      EXEC sp_log 1, @fn, '050: run the import ', @cor_file_ir, @range, ' @is_csv_file: ', @is_csv_file;

      -- Handle either TSV or Excel file
      -- POST 03: import file must exist OR EX 64871
      --    delegated to sp_import_corrections_tsv,sp_import_corrections_xls
      IF @is_csv_file = 1
         EXEC sp_import_corrections_tsv @file_path, @row_cnt = @cor_file_row_cnt OUT;
      ELSE
         EXEC sp_import_corrections_xls @file_path, @range, @cor_file_row_cnt OUT;

      EXEC sp_log 1, @fn, '060: returned frm the import_corrections rtn @cor_file_row_cnt: ', @cor_file_row_cnt;

      --------------------------------------------------------------------------------------------------------
      -- Fixup import_corrections  like the XL 255 bug
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '070: fixup import_corrections like the XL 255 buge   ';
      EXEC sp_fixup_import_corrections;

      EXEC sp_log 1, @fn, '080: copying correction staging to corrections table   ';

      -- Incrementally add to ImportCorrections as this may be part of a multiple corrections file import
      INSERT INTO ImportCorrections
                 ( [action],command, table_nm, field_nm, search_clause, filter_field_nm, filter_clause, not_clause, exact_match, replace_clause, field2_nm, field2_clause, must_update, comments, created, row_id, stg_file)
      SELECT       [action],command, table_nm, field_nm, search_clause, filter_field_nm, filter_clause, not_clause, exact_match, replace_clause, field2_nm, field2_clause, must_update, comments, created, id,     @file_nm
      FROM ImportCorrectionsStaging;

      --------------------------------------------------------------------------------------------------------
      -- Check postconditions
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'800: checking postconditions';
      -- POST 01: must be at least 1 corrections file import.                           EX 52410
      EXEC sp_assert_tbl_pop 'ImportCorrections';

      SET @row_id =
      (
         SELECT TOP 1 id FROM ImportCorrections
         WHERE replace_clause IS NULL AND field2_clause IS NULL AND ([action] NOT IN ('SKIP','SQL','STOP') AND command NOT IN ('SKIP','SQL','STOP'))
      );

      -- POST 04: Import data has either replace clause, a cmd is IN ('SKIP','SQL','STOP') a notes clause   EX 52413
      IF @row_id IS NOT NULL
      BEGIN
         -- Display the offending row
         SELECT * FROM ImportCorrections WHERE id = @row_id;
         EXEC sp_raise_exception 52413, 'import row: ', @row_id, ' Either replace_clause must be specified or (command=(''SKIP'',''SQL'',''STOP'') or notes field is specified)',@fn=@fn;
      END

      --------------------------------------------------------------------------------------------------------
      -- Completed processing
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'950: Completed processing';
   END TRY
   BEGIN CATCH
      SET @error_msg =  ERROR_MESSAGE()
      EXEC sp_log 4, @fn, '500: caught exception: ', @error_msg;
      THROW;
   END CATCH

   -- SELECT * FROM AppLog;
   EXEC sp_log 2, @fn,'999: leaving';
END
/*
EXEC tSQLt.Run'test.test_039_sp_import_cor_file';
*/


GO
