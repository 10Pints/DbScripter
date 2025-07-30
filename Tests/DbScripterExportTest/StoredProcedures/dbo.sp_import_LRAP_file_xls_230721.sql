SET ANSI_NULLS ON
GO
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
CREATE PROCEDURE [dbo].[sp_import_LRAP_file_xls_230721]
    @import_file  VARCHAR(500)  -- include path, (and range if XL)
   ,@clr_first    BIT
   --    ,@range        VARCHAR(100)  = N'Sheet1$'
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)   = 'IMPRT_LRAP_FILE_XLS_230721'
   ,@row_cnt         INT
   EXEC sp_log 1, @fn, '00: starting
import_file:[',@import_file,']
clr_first  :[', @clr_first  , ']
';
   --EXEC sp_register_call @fn;
   --------------------------------------------------------------------
   -- Processing start'
   --------------------------------------------------------------------
--   SET @range = ut.dbo.fnFixupXlRange(@range);
   ----------------------------------------------------------------------------
   -- 1. import the LRAP register file using the appropriate format importer
   ----------------------------------------------------------------------------
   -- 230721: new format
      EXEC sp_log 2, @fn, '15: import the LRAP register file (221018 fmt)';
      EXEC sp_import_file
          @import_file  = @import_file
         ,@table        = 'Staging1'
--         ,@range        = @range
         ,@fields       = NULL         -- for XL: comma separated list
         ,@clr_first    = 1            -- if 1 then delete the table contents first
         ,@is_new       = 0            -- if 1 then create the table - this is a double check
         ,@expect_rows  = 1            -- optional @expect_rows to assert has imported rows
         ,@row_cnt      = @row_cnt OUT  -- optional count of imported rows
         ;
   --------------------------------------------------------------------
   -- Processing complete'
   --------------------------------------------------------------------
   EXEC sp_log 2, @fn,'80: processing complete';
END
   EXEC sp_log 1, @fn, '99: leaving';
/*
EXEC sp_import_LRAP_file_xls_230721 'D:\Dev\Repos\Farming\Data\LRAP-231025-231103.xlsx';
SELECT * FROM staging1;
*/
GO

