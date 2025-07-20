SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--=======================================================================================
-- Author:           Terry Watts
-- Create date:      12-Jun-2025
-- Rtn:              test.test_068_sp_crt_pop_table
-- Description: main test routine for the dbo.sp_crt_pop_table routine 
--
-- Tested rtn description:
-- Create and populate a table from a data file
-- 
-- Requirement:
-- R06.01: the table with the same name as the file is created:
-- R06.02: the table has the same column names as the column names in the file
-- R06.03: table is populated exactly from the rows and columns from the file
--
-- Design: EA: Dorsu.eap: Dorsu Model.Conceptual Model.Create and populate a table from a data file
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
-- 01. Check no error occurred
-- 02: Check the table exists
-- 03: Check the columns match the file columns
-- 04: Check the data matches
-- 04.01: check the row count of the table matches that of the file
-- 04.02: check the first row all columns
-- 04.03: check the last row all columns
--=======================================================================================
CREATE PROCEDURE [test].[test_068_sp_crt_pop_table]
AS
BEGIN
DECLARE
    @fn  VARCHAR(35) = 'test_068_sp_crt_pop_table'
   ,@tab CHAR        = CHAR(9)

   BEGIN TRY
      EXEC test.sp_tst_mn_st @fn;

      EXEC test.hlpr_068_sp_crt_pop_table
          @tst_num            = '002'
         ,@display_tables     = 1
         ,@inp_file_path      = 'D:\Dorsu\Data\FileActivityLog.tsv'
         ,@inp_sep            = '0x09'
         ,@inp_codepage       = NULL
         ,@inp_display_tables = 1
         ,@exp_row_cnt        = 60286
         ,@exp_ex_num         = NULL
         ,@exp_ex_msg         = NULL
      ;
      EXEC sp_log 2, @fn, '990: LEAVING EARLY'
      RETURN;

      EXEC test.hlpr_068_sp_crt_pop_table
          @tst_num            = '001'
         ,@display_tables     = 1
         ,@inp_file_path      = 'D:\Dev\Property\Data\PropertySales.txt'
         ,@inp_sep            = '0x09'
         ,@inp_codepage       = NULL
         ,@inp_display_tables = 1
         ,@exp_row_cnt        = NULL
         ,@exp_ex_num         = NULL
         ,@exp_ex_msg         = NULL
      ;

      EXEC sp_log 2, @fn, '999: All subtests PASSED';
   END TRY
   BEGIN CATCH
      EXEC sp_log 2, @fn, '520: caught exception -> sp_log_exception';
      EXEC sp_log_exception @fn;
      EXEC sp_log 2, @fn, '540: rethrowing exception';
      THROW;
   END CATCH

   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_068_sp_crt_pop_table;
SELECT TOP 200 * FROM GenericStaging;

EXEC tSQLt.Run 'test.test_068_sp_crt_pop_table';
EXEC sp_crt_pop_table 'D:\Dev\Property\Data\PropertySales.txt';

EXEC sp_AppLog_Display 'hlpr_068_sp_crt_pop_table';
EXEC sp_AppLog_Display;
SELECT COUNT(*) FROM GenericStaging;
SELECT TOP 200 * FROM GenericStaging;
*/

GO
