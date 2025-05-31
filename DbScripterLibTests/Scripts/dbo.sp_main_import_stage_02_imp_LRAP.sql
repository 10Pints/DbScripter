SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2024
-- Description: does the stage 1 processing:
--    1. clears the staging 1  and staging2 tables
--    2. imports the LRAP register file using the appropriate importer
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
-- POST 01: handles imports ids {1:221018, 2:230721} default: 221018
--
-- TESTS:
--
-- CHANGES:
-- 240315: param name change: @import_file -> @LRAP_data_file
-- ======================================================================================
ALTER PROCEDURE [dbo].[sp_main_import_stage_02_imp_LRAP]
    @LRAP_file  NVARCHAR(150)
   ,@LRAP_range      NVARCHAR(100)  -- LRAP-221018 230813
   ,@import_id       INT            -- handles imports ids {1:221018, 2:230721} default: 221018
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = 'MN_IMPRT_STG_02'

   EXEC sp_log 1, @fn, '00: starting
LRAP_file:[',@LRAP_file,']
LRAP_range:    [',@LRAP_range,    ']
import_id:     [',@import_id     ,']';


   BEGIN TRY
      EXEC sp_register_call @fn;
      EXEC sp_log 2, @fn,'05: import the LRAP register file and do some basic fixup';

      EXEC sp_import_LRAP_file 
          @LRAP_file = @LRAP_file
         ,@LRAP_range= @LRAP_range
         ,@import_id = @import_id;

      --------------------------------------------------------------------
      -- Processing complete';
      --------------------------------------------------------------------
      EXEC sp_log 2, @fn,'80: processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving, OK';
END
/*
EXEC sp_Reset_CallRegister;
EXEC sp_main_import_stage_02_imp_LRAP 'D:\Dev\Repos\Farming_Dev\Data\LRAP-221018-230813.xlsx', 'LRAP-221018 230813$A:N', 1;
*/

GO
