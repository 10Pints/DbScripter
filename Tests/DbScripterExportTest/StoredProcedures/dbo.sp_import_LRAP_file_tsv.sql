SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
-- Description:
--    Imports the LRAP register tab separated data file based on format spec (@import_id)
--    Can be either .xlsx or tab separated file (.txt)
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
-- CHANGES:
-- ======================================================================================
CREATE   PROCEDURE [dbo].[sp_import_LRAP_file_tsv]
    @import_file  VARCHAR(500)        -- include path, (and range if XL)
   ,@import_id    INT  -- handles imports ids {1:221018, 2:230721} default: 221018
   ,@clr_first    BIT
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)   = 'sp_import_LRAP_file_tsv'
      ,@is_xl     BIT
   EXEC sp_log 2, @fn, '000: starting
import_file:[',@import_file,']
import_id:  [',@import_id  ,']
clr_first  :[',@clr_first  ,']
';
   --EXEC sp_register_call @fn;
   BEGIN TRY
      --------------------------------------------------------------------
      -- Processing start'
      --------------------------------------------------------------------
      ----------------------------------------------------------------------------
      -- 1. import the LRAP register file using the appropriate format importer
      ----------------------------------------------------------------------------
      -- 230721: new format
      IF      @import_id = 1 -- 221018
      BEGIN -- currently only 2 versions: 221018, 230721. default: 221018
         EXEC sp_log 2, @fn, '010: calling sp_bulk_insert_pesticide_register_221018 ', @import_file;
         EXEC sp_bulk_insert_pesticide_register_221018 @import_file,@clr_first;
      END
      ELSE IF @import_id = 2 -- 230721
      BEGIN
         EXEC sp_log 2, @fn, '020: calling sp_bulk_insert_pesticide_register_230721 ', @import_file;
         EXEC sp_bulk_insert_pesticide_register_230721 @import_file,@clr_first;
      END
      ELSE IF @import_id = 3 -- 230721
      BEGIN
         EXEC sp_log 2, @fn, '030: calling sp_bulk_insert_pesticide_register_240502 ', @import_file;
         EXEC sp_bulk_insert_pesticide_register_240502 @import_file,@clr_first;
      END
      ELSE -- Unrecognised import id
      BEGIN
         EXEC sp_raise_exception 56471, '500 Unrecognised import id: ', @import_id,@fn=@fn;
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   --------------------------------------------------------------------
   -- Processing complete'
   --------------------------------------------------------------------
   EXEC sp_log 2, @fn, '900: processing complete';
   EXEC sp_log 2, @fn, '999: leaving';
END
/*
EXEC sp_Reset_CallRegister;
EXEC sp_import_LRAP_file_tsv 'D:\Dev\Farming\Data\LRAP-240910.txt', 3;
*/
GO

