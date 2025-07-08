SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description: gets the fields from the first row of a tsv file and returns as csl in the @fields out param
--
-- PRECONDITIONS:
-- PRE 01: @file_path must be specified   OR EXCEPTION 58000, 'file must be specified'
-- PRE 02: @file_path exists,             OR EXCEPTION 58001, 'file does not exist'
-- 
-- POSTCONDITIONS:
-- POST01: returns @file_type =
--          1    if tsv file
--          0    if csv file
--          NULL if undecided (when file has only 1 column)
--
-- CALLED BY: sp_get_get_hdr_flds
--
-- TESTS: test.test_sp_get_fields_from_tsv_hdr
--
-- CHANGES:
-- 05-MAR-2024: put brackets around the field names to handle spaces reserved words etc.
-- 05-MAR-2024: added parameter validation
-- 14-NOV-2024: changed the rtn name from s_get_fields_from_tsv_hdr to [sp_get_fields_from_txt_file_hdr
-- 02-DEC-2024: handling csv or tsv files, optionaly displaying the header,
--              returning the file type 0: txt, 1: tsv
-- ==========================================================================================================
CREATE PROCEDURE [dbo].[sp_get_flds_frm_hdr_txt]
    @file            VARCHAR(500)        -- include path
   ,@fields          VARCHAR(2000) OUT   -- comma separated list
   ,@display_tables  BIT = 0
   ,@file_type       BIT OUT -- 0:txt, 1: tsv
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)   = N'sp_get_flds_frm_hdr_txt'
      ,@cmd       VARCHAR(4000)
      ,@msg       VARCHAR(100)
      ,@row_cnt   INT
      ,@tab_cnt   INT            = 0
      ,@comma_cnt INT            = 0

   EXEC sp_log 2, @fn, '000: starting:
file          :[', @file,']
fields        :[',@fields        ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      SET @file_type = NULL -- initially
      -------------------------------------------------------
      -- Param validation, fixup
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '010: validating inputs';

      --------------------------------------------------------------------------------------------------------
      -- PRE 01: @file_path must be specified   OR EXCEPTION 58000, 'file must be specified'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: checking PRE 01';
      EXEC dbo.sp_assert_not_null_or_empty @file, 'file must be specified', @ex_num=58000--, @fn=@fn;

      --------------------------------------------------------------------------------------------------------
      -- PRE 02: @file_path exists,             OR EXCEPTION 58001, 'file does not exist'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: checking PRE 02: @file_path must exist';
      EXEC sp_assert_file_exists @file, @ex_num = 58001, @fn=@fn;

      -------------------------------------------------------
      -- ASSERTION: Passed parameter validation
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '040: ASSERTION: validation passed';

      -------------------------------------------------------
      -- Process
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '050: importing file hdr row';
      DROP TABLE IF EXISTS hdrCols;

      CREATE TABLE hdrCols
      (fields VARCHAR(MAX));

      ---------------------------------------------------------------
      -- Get the entire header row as 1 column in tmp.fields
      ---------------------------------------------------------------
      SET @cmd = 
         CONCAT
         (
'BULK INSERT [hdrCols] FROM ''', @file, '''
WITH
(
   DATAFILETYPE    = ''Char''
  ,FIRSTROW        = 1
  ,LASTROW         = 1
  ,ERRORFILE       = ''D:\Logs\GET_FLDS_FRM_HDR_TSV.log''
  ,FIELDTERMINATOR = ''\n''
  ,ROWTERMINATOR   = ''\n''
  ,CODEPAGE       = 65001  
);
   ');-- -- CODEPAGE = 1252

      EXEC sp_log 1, @fn, '060:sql: ',@cmd;
      EXEC(@cmd);

      IF @display_tables = 1 SELECT TOP 10 * FROM hdrCols;

      ---------------------------------------------------------------
      -- Tidy the hdr row up
      ---------------------------------------------------------------
      UPDATE hdrCols SET fields = REPLACE(fields, '"','');
      SET @row_cnt = (SELECT COUNT(*) FROM hdrCols);
      EXEC sp_log 1, @fn, '070: @row_cnt: ',@row_cnt;

       ---------------------------------------------------------------
      -- Which is more commas or tabs?
      -- NB: if only 1 column then it does not matter which
      -- but could use the file extension as a guide
      -- csv - comma, tsv: tab, txt ?? could be either
      ---------------------------------------------------------------
      SELECT @tab_cnt   = COUNT(*) FROM hdrCols CROSS APPLY string_split(fields, NCHAR(9)) ;
      SELECT @comma_cnt = COUNT(*) FROM hdrCols CROSS APPLY string_split(fields, ',');
      EXEC sp_log 1, @fn, '080';
      IF ((@tab_cnt = @comma_cnt) AND (@comma_cnt=0))
      BEGIN
      EXEC sp_log 1, @fn, '090';
         DECLARE @ext VARCHAR(10)
         -- implies 1 field so try to get from file extension
         SET @ext = dbo.fnGetFileExtension(@file);
         PRINT @ext;

         SELECT 
             @tab_cnt   = iif(@ext='tsv', 1, 0)
            ,@comma_cnt = iif(@ext='csv', 1, 0) -- .txt can be either - now way then of knowing csv or tsv with 1 col in file
         ;

         EXEC sp_log 3, @fn, '100: file only contains 1 column, so can only deduce from the file ext .tsv or .csv, else will return NULL';
      END

       EXEC sp_log 1, @fn, '110';
     -- Replace tabs with , this works ok with CSVs also
      UPDATE hdrCols SET fields = REPLACE(fields, NCHAR(9), ',');
      SET @fields = (SELECT TOP 1 fields FROM hdrCols);
      EXEC sp_log 1, @fn, '120: fields:[',@fields, ']';
      EXEC sp_assert_gtr_than @row_cnt, 0, 'header row not found (no rows inmported)';

      ---------------------------------------------------------------
      -- SET @file_type       BIT OUT -- 0:txt, 1: tsv, NULL: UNDECIDED
       ---------------------------------------------------------------
     SET @file_type = 
         case
            WHEN (@tab_cnt = @comma_cnt) THEN NULL -- TAB   separated file
            WHEN (@tab_cnt > @comma_cnt) THEN 1    -- COMMA separated file
            ELSE                              0    -- UNDECIDED
         END;

     set @msg       = iif(@file_type = 1, 'tsv', 'csv');

   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      EXEC sp_log 4, @fn, '500: bulk insert command was:
',@cmd;
      DROP TABLE IF EXISTS hdrCols;
      THROW;
   END CATCH

   DROP TABLE IF EXISTS hdrCols;
   EXEC sp_log 2, @fn, '999: leaving, OK, @file_type: ',@msg;
END
/*
EXEC tSQLt.Run 'test.test_020_sp_get_flds_frm_hdr_txt';

-----------------------------------------------------------
DECLARE
    @fields       VARCHAR(4000)
   ,@file_type    BIT
;
EXEC dbo.sp_get_flds_frm_hdr_txt 'D:\Dev\Farming\Data\LRAP-240910.txt', @fields  OUT, @file_type = @file_type, @display_tables=1; -- comma separated list
PRINT @fields;
-----------------------------------------------------------
*/

GO
