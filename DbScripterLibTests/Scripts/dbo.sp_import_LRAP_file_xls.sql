SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 15-MAR-2024
--    2. imports the LRAP register Excel file
--
-- PRECNDITIONS: S1, S2 truncated
--
-- POSTCONDITIONS:
-- POST 01:
--
-- TESTS:
--
-- CHANGES:
--
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_import_LRAP_file_xls]
    @LRAP_data_file  NVARCHAR(150)
   ,@range           NVARCHAR(100)
   ,@import_id       INT = 1-- handles imports ids: acceptable values: (1,2) {1:221018, 2:230721} default: 221018
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = 'IMPRT_LRAP_FILE_XLS'
   ,@error_msg       NVARCHAR(500)
   ,@is_xl           BIT

   SET @import_id = dbo.fnGetImportIdFromName(@LRAP_data_file);


   EXEC sp_log 1, @fn, '00: starting
LRAP_data_file:[',@LRAP_data_file,']
import_id:     [',@import_id     ,']';

   BEGIN TRY
      EXEC sp_register_call @fn;

      --------------------------------------------------------------------
      -- Processing start'
      --------------------------------------------------------------------
      --SET @range = ut.dbo.fnFixupXlRange(@range);

      ------------------------------------------------------------------------------
      -- 3. import the LRAP register file using the appropriate format importer
      ------------------------------------------------------------------------------
      ----------------------------------------------------------------------------
      -- 1. import the LRAP register file using the appropriate format importer
      ----------------------------------------------------------------------------
      -- 230721: new format
      IF      @import_id = 1 -- 221018
      BEGIN -- currently only 2 versions: 221018, 230721. default: 221018
         EXEC sp_log 2, @fn, '15: import the LRAP register file (221018 fmt)';
         EXEC sp_import_LRAP_file_xls_221018 @LRAP_data_file, @range;
      END
      ELSE IF @import_id = 2 -- 230721
      BEGIN
         EXEC sp_log 2, @fn, '20: import the LRAP register file (230721 fmt)';
         EXEC sp_import_LRAP_file_xls_221018 @LRAP_data_file, @range;
      END
      ELSE -- Unrecognised import id
      BEGIN
         SET @error_msg = CONCAT('Unrecognised import id: ', @import_id);
         EXEC sp_log 4, @fn, '25: ', @error_msg;
         EXEC sp_raise_exception 56471, @error_msg, @fn=@fn;
      END

      --------------------------------------------------------------------
      -- Processing complete';
      --------------------------------------------------------------------
      EXEC sp_log 2, @fn,'80: processing complete';
      END TRY
      BEGIN CATCH
         EXEC Ut.dbo.sp_log_exception @fn;
         THROW;
      END CATCH
END
   EXEC sp_log 1, @fn, '99: leaving';
/*
EXEC sp_Reset_CallRegister;
EXEC sp_import_LRAP_file_xls 
    @LRAP_data_file  = 'D:\Dev\Repos\Farming_Dev\Data\LRAP-221018-230813.xlsx'
   ,@range           = 'LRAP-221018 230813$A:N'
   ,@import_id       = 221018;
*/

GO
