SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description:
--    Imports the LRAP data xls file, format spec = 221018
--
-- PRECONDITIONS:
-- file format spec = 221018
-- S1 and S2 are truncted
--
-- POSTCONDITIONS:
-- POST 01: S1 populated, s2 not
--
-- RESPONSIBILITIES:
-- R01: Clear the S1 and S2 tables
-- R02: Import the LRAP data file
-- R03: assign the import id to new data
--
-- TESTS:
--
-- CHANGES:
-- 
-- ======================================================================================
CREATE PROCEDURE [dbo].[sp_import_LRAP_file_xls_221018]
    @import_file  VARCHAR(500)  -- include path, (and range if XL)
   ,@clr_first    BIT
AS
BEGIN
   DECLARE
    @fn           VARCHAR(35)   = 'IMPRT_LRAP_FILE_XLS_221018'
   ,@row_cnt      INT
   ,@table        VARCHAR(35)   = 'Staging1'
   ,@table_exists INT

   EXEC sp_log 1, @fn, '00: starting
import_file:[', @import_file, ']
clr_first  :[', @clr_first  , ']
';

   --EXEC sp_register_call @fn;
   --------------------------------------------------------------------
   -- Processing start'
   --------------------------------------------------------------------
   SET @table_exists = dbo.fnTableExists(@table);
   EXEC sp_assert_equal 1, @table_exists, 'table ', @table, ' does not exist';

   ----------------------------------------------------------------------------
   -- 1. import the LRAP register file using the appropriate format importer
   ----------------------------------------------------------------------------
   -- 230721: new format
      EXEC sp_log 2, @fn, '15: import the LRAP register file (221018 fmt)';
      EXEC sp_import_file
          @import_file  = @import_file
         ,@table        = @table
--         ,@range        = @range
         ,@fields       = NULL         -- for XL: comma separated list
         ,@clr_first    = 1            -- if 1 then delete the table contents first
         ,@is_new       = 0            -- if 1 then create the table - this is a double check
         ,@expect_rows  = @clr_first   -- optional @expect_rows to assert has imported rows
         ,@row_cnt      = @row_cnt OUT  -- optional count of imported rows
         ;

   --------------------------------------------------------------------
   -- Processing complete'
   --------------------------------------------------------------------
   EXEC sp_log 2, @fn,'80: processing complete';
END
   EXEC sp_log 1, @fn, '99: leaving';
/*
EXEC sp_Import_CallRegister 'D:\Dev\Repos\Farming\Data\CallRegister.xlsx';
EXEC sp_reset_CallRegister;
EXEC sp_import_LRAP_file_xls_221018 'D:\Dev\Repos\Farming\Data\LRAP-221018-230813.xlsx', 'LRAP-221018 230813$A:N';
SELECT * FROM staging1;
*/

GO
