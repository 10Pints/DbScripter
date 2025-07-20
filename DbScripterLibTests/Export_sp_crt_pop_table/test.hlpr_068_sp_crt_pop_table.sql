SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--=======================================================================================
-- Author:           Terry Watts
-- Create date:      12-Jun-2025
-- Rtn:              test.hlpr_068_sp_crt_pop_table
-- Description: test helper for the dbo.sp_crt_pop_table routine tests 
--
-- Tested rtn description:
-- Create and populate a table from a data file
--
-- Design:      EA: Model.Use Case Model.Create and populate a table from a data file
-- Define the import data file path
-- Table name = file name
-- Reads the header for the column names
-- Create a table with table name, columns = field names, type = text
-- Create a staging table
-- Create a format file using BCP and the table
-- Generate the import routine using the table and the format file
--
-- Parameters:
--    @file_path     VARCHAR(500) -- the import data file path
--
-- Test strategy:
-- Test 01. Check no error occurred
-- Test 02: Check the table exists
-- Test 03: Check the columns match the file columns
-- Test 04: Check the data matches
-- Test 04.01: check the row count of the table matches that of the file
-- Test 04.02: check the first row all columns
-- Test 04.03: check the last row all columns
--=======================================================================================
CREATE PROCEDURE [test].[hlpr_068_sp_crt_pop_table]
    @tst_num            VARCHAR(50)
   ,@display_tables     BIT
   ,@inp_file_path      VARCHAR(250)
   ,@inp_sep            VARCHAR(6)
   ,@inp_codepage       INT
   ,@inp_display_tables BIT
   ,@exp_row_cnt        INT             = NULL
   ,@exp_ex_num         INT             = NULL
   ,@exp_ex_msg         VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn                 VARCHAR(35)    = N'hlpr_068_sp_crt_pop_table'
   ,@error_msg          VARCHAR(1000)
   ,@NL                 CHAR = CHAR(13)
   ,@tab                CHAR = CHAR(9)
   ,@act_row_cnt        INT
   ,@act_RC             INT
   ,@act_ex_num         INT
   ,@act_ex_msg         VARCHAR(500)
   ,@act_tbl_cols       VARCHAR(8000)
   ,@exp_file_cols      VARCHAR(8000)
   ,@act_file_cols      VARCHAR(8000)
   ,@exp_table_nm       VARCHAR(60 )    = NULL

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;
      SET @exp_table_nm = dbo.fnGetFileNameFromPath(@inp_file_path, 0); -- 0:ignore extension

      EXEC sp_log 1, @fn ,' starting
tst_num           :[', @tst_num           ,']
display_tables    :[', @display_tables    ,']
inp_file_path     :[', @inp_file_path     ,']
inp_sep           :[', @inp_sep           ,']
inp_codepage      :[', @inp_codepage      ,']
inp_display_tables:[', @inp_display_tables,']
@exp_table_nm     :[', @exp_table_nm      ,']
exp_row_cnt       :[', @exp_row_cnt       ,']
ex_num            :[', @exp_ex_num        ,']
ex_msg            :[', @exp_ex_msg        ,']
';

      -- SETUP: ??

      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_crt_pop_table';
            ------------------------------------------------------------
            EXEC @act_RC = dbo.sp_crt_pop_table
                @file_path       = @inp_file_path
               ,@sep             = @inp_sep
               ,@codepage        = @inp_codepage
               ,@display_tables  = @inp_display_tables
               ;
  
            SELECT @act_row_cnt = @@ROWCOUNT;
            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_crt_pop_table';

            IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
            BEGIN
               EXEC sp_log 4, @fn, '030: oops! Expected exception was not thrown';
               THROW 51000, ' Expected exception was not thrown', 1;
            END
         END TRY
         BEGIN CATCH
            SET @act_ex_num = ERROR_NUMBER();
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC sp_log 1, @fn, '040: caught  exception: ', @act_ex_num, ' ',      @act_ex_msg;
            EXEC sp_log 1, @fn, '050: check ex num: exp: ', @exp_ex_num, ' act: ', @act_ex_num;

            IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL
            BEGIN
               EXEC sp_log 4, @fn, '060: an unexpected exception was raised';
               THROW;
            END

            ------------------------------------------------------------
            -- ASSERTION: if here then expected exception
            ------------------------------------------------------------
            IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals      @exp_ex_num, @act_ex_num, 'ex_num mismatch';
            IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertIsSubString @exp_ex_msg, @act_ex_msg, 'ex_msg mismatch';
            
            EXEC sp_log 2, @fn, '070 test# ',@tst_num, ': exception test PASSED;'
            BREAK
         END CATCH

         -- TEST:
         EXEC sp_log 2, @fn, '075: running tests   ';

         -- Test 01. Check no error occurred - implicit with the exception handler here
         -- Test 02: Check the table exists
         EXEC sp_assert_tbl_exists @exp_table_nm, 1, '080: expected table'

         -- Test 03: Check the columns match the file columns
         -- Get the table cols
         SELECT @act_tbl_cols = string_agg( column_name, ',') FROM dbo.fnGetTableColumns(@exp_table_nm, NULL);

         -- Get the file cols
         EXEC sp_log 2, @fn, '085: Get the file cols, @inp_file_path:[',@inp_file_path,']';
         TRUNCATE TABLE GenericStaging;
         --RETURN;

         EXEC @act_row_cnt = sp_import_txt_file
             @table           = 'GenericStaging'
            ,@file            = @inp_file_path
            ,@folder          = NULL
            ,@first_row       = 1
            ,@last_row        = 1
            ,@field_terminator= @NL
            ,@view            = 'ImportGenericStaging_vw'
            ,@codepage        = @inp_codepage
            ,@display_table   = 0
         ;

         EXEC tSQLt.AssertEquals 1, @act_row_cnt, '090 exp 1 hdr row';
         SELECT @act_file_cols = staging FROM GenericStaging;
         EXEC sp_log 2, @fn, '095: checking header cols in GenericStaging',@NL
               , '@act_file_cols:',@act_file_cols,@NL
               , '@act_file_cols:',@act_file_cols;

         SELECT @act_file_cols = REPLACE(@act_file_cols, @tab, ',');
         EXEC sp_log 2, @fn, '100: checking header cols in GenericStaging',@NL
               , '@act_file_cols:',@act_file_cols,@NL
               , '@act_tbl_cols :',@act_tbl_cols;

         EXEC tSQLt.AssertEquals @act_file_cols, @act_tbl_cols, '105: file/tbl col names match?', @detailed_tst=1;
         EXEC sp_log 2, @fn, '102: TRUNCATE TABLE GenericStaging';
         TRUNCATE TABLE GenericStaging;

         -- Test 04: Check the data matches
         -- Read the file data rows into GenericStaging (ex hdr row)
         EXEC sp_log 2, @fn, '105: Read the file data rows into GenericStaging file: ',sp_import_txt_file;
         EXEC @exp_row_cnt = sp_import_txt_file
             @table           = 'GenericStaging'
            ,@file            = @inp_file_path
            ,@folder          = NULL
            ,@first_row       = 2
            ,@last_row        = 100
            ,@field_terminator= @NL
            ,@view            = 'ImportGenericStaging_vw'
            ,@codepage        = @inp_codepage
            ,@display_table   = 0
         ;

         -- Test 04.01: check the row count of the table matches that of the file
         EXEC tSQLt.AssertEquals @exp_row_cnt, @act_row_cnt,'110 row_cnt';

         -- Test 04.02: check the first row all columns
         SELECT @exp_file_cols = staging FROM (SELECT TOP 1 staging FROM GenericStaging) A;
         EXEC sp_aggregate_row_to_string @exp_table_nm,'ID = 1',',', @act_file_cols OUTPUT;

         EXEC sp_log 2, @fn, '111: ', @NL, '@exp_file_cols:[', @exp_file_cols,']', @NL
         ,'@act_file_cols:[',@act_file_cols,']'
        ;

         EXEC tSQLt.AssertEquals @exp_file_cols, @act_file_cols, '115 first row exp/act';

         -- Test 04.03: check the last row all columns
         SELECT @exp_file_cols = staging FROM (SELECT TOP 1 staging FROM GenericStaging ORDER BY id DESC) A;
         EXEC sp_log 2, @fn, '120: @exp_file_cols:[', @exp_file_cols,'] before replace';
         SELECT @exp_file_cols = REPLACE(@exp_file_cols, @tab, ',');
         EXEC sp_log 2, @fn, '125: @exp_file_cols:[', @exp_file_cols,'] after replace ';
         EXEC sp_aggregate_row_to_string @exp_table_nm,'ID = 1',',',@act_file_cols OUTPUT;
         EXEC tSQLt.AssertEquals @exp_file_cols, @act_file_cols, '130 last row exp/act';

         ------------------------------------------------------------
         -- Passed tests
         ------------------------------------------------------------
         BREAK
      END --WHILE

      -- CLEANUP: ??

      EXEC sp_log 1, @fn, '990: all subtests PASSED';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, 'Caught exception';
      EXEC test.sp_tst_hlpr_hndl_failure;
      THROW;
   END CATCH

   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_068_sp_crt_pop_table';
*/

GO
