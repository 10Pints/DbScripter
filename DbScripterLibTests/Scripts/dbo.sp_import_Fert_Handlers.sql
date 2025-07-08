SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 05-NOV-2024
-- Description: Imports the Pg Gov Ag LRAP Fert handlers tsv file
--     into FertHandlerStaging then does fixup before copying to FertHandler.
-- PRECONDITIONS:
-- PRE01: none
--
-- POSTCONDITIONS:
-- POST01: FertHandler table must have rows
-- POST02: no double quotes exists in any column
-- POST03: no leaading/trailing wsp exists in any column
--
-- BCP create (DOS_:
-- bcp Farming_dev.dbo.cropstaging format nul -c -T -f FertHandler.fmt
--
-- TESTS:
--
-- CHANGES:
-- ==============================================================================
CREATE PROCEDURE [dbo].[sp_import_Fert_Handlers]
    @file           VARCHAR(500)
   ,@folder         VARCHAR(600) = NULL
   ,@display_tables BIT          = 0
AS
BEGIN
   DECLARE
       @fn                 VARCHAR(35)   = N'import_Fert_Handlers'
      ,@bkslsh             CHAR(1)       = CHAR(92)
      ,@sql                VARCHAR(MAX)
      ,@cmd                VARCHAR(MAX)
      ,@error_file         VARCHAR(400)  = NULL
      ,@error_msg          VARCHAR(MAX)  = NULL
      ,@table_nm           VARCHAR(35)   = 'Distributor'
      ,@rc                 INT            = -1
      ,@import_root        VARCHAR(MAX)  
      ,@pathogen_row_cnt   INT            = -1
      ,@update_row_cnt     INT            = -1
      ,@null_type_row_cnt  INT            = -1
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting:
file  :[', @file  ,']
folder:[', @folder,']
';

      ---------------------------------------
      -- Validate inputs
      ---------------------------------------
      IF @folder IS NOT NULL
         SET @file = CONCAT(@folder, @bkslsh, @file);

      ---------------------------------------
      -- Setup
      ---------------------------------------

      ---------------------------------------
      -- Process
      ---------------------------------------
      EXEC sp_log 1, @fn, '010: calling sp_bulk_import_tsv2';
      EXEC sp_import_txt_file
         @table      = 'FertHandlerStaging'
        ,@file       = @file
        ,@clr_first  = 1
        ;

      ---------------------------------------
      -- Do any fixup
      ---------------------------------------
      EXEC sp_log 1, @fn, '020: performing fixup = currently none';

      ---------------------------------------
      -- Copy to main table
      ---------------------------------------
      EXEC sp_log 1, @fn, '030: Clean copy to FertHandler main table';
      DELETE FROM FertHandler;

      INSERT INTO FertHandler
      (
          [region]
         ,[company_nm]
         ,[address]
         ,[type]
         ,[license]
         ,[expiry_date]
      )
      SELECT 
          [region]
         ,[company_nm]
         ,[address]
         ,[type]
         ,[license]
         ,[expiry_date]
      FROM FertHandlerStaging
      ;

      ---------------------------------------
      -- Postcondition checks
      ---------------------------------------
      EXEC sp_log 1, @fn, '040: Performing postcondition checks';
      EXEC sp_assert_tbl_pop 'FertHandler';

      ---------------------------------------
      -- Completed processing OK
      ---------------------------------------

      SET @rc = 0; -- OK
      IF @display_tables = 1 SELECT * FROM FertHandler;
      EXEC sp_log 1, @fn, '300:completed import and fixup'
   END TRY
   BEGIN CATCH
      SET @error_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn, '500: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '996: leaving, RC: ', @rc
   RETURN @RC;
END
/*
EXEC sp_import_Fert_Handlers 'D:\Dev\Farming\Data\Fert-Handlers-20240930.txt', 1;
*/

GO
