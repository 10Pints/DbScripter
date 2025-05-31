SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description:
--    Imports the LRAP register tab separated data file based on format spec (@import_id)
--
-- PRECONDITIONS: 
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
ALTER PROCEDURE [dbo].[sp_import_LRAP_file_tsv]
    @LRAP_data_file  NVARCHAR(150) -- the tab separated LRAP data file
   ,@import_id       INT = 221018  -- handles imports ids {1:221018, 2:230721} default: 221018
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'IMPRT_LRAP_FILE_TSV'
      ,@is_xl     BIT

   EXEC sp_log 1, @fn, '00: starting
LRAP_data_file:[',@LRAP_data_file,']
import_id:     [',@import_id     ,']';

   EXEC sp_register_call @fn;
   --------------------------------------------------------------------
   -- Processing start'
   --------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- 1. import the LRAP register file using the appropriate format importer
   ----------------------------------------------------------------------------
   -- 230721: new format
   IF      @import_id = 1 -- 221018
   BEGIN -- currently only 2 versions: 221018, 230721. default: 221018
      EXEC sp_log 2, @fn, '15: import the LRAP register file (221018 fmt)';
      EXEC sp_bulk_insert_pesticide_register_221018 @LRAP_data_file;
   END
   ELSE IF @import_id = 2 -- 230721
   BEGIN
      EXEC sp_log 2, @fn, '20: import the LRAP register file (230721 fmt)';
      EXEC sp_bulk_insert_pesticide_register_230721 @LRAP_data_file;
   END
   ELSE -- Unrecognised import id
   BEGIN
      EXEC Ut.dbo.sp_raise_exception 56471, 'Unrecognised import id: ', @import_id, @fn=@fn;
   END

   --------------------------------------------------------------------
   -- Processing complete'
   --------------------------------------------------------------------
   EXEC sp_log 2, @fn,'80: processing complete';
END
   EXEC sp_log 1, @fn, '99: leaving';
/*
EXEC sp_import_LRAP_file_tsv;
*/

GO
