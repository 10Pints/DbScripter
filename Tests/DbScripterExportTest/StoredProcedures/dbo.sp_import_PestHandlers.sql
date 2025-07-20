SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 05-NOV-2024
-- Description: Imports the Pg Gov Ag LRAP Pest handlers tsv file
--
-- PRECONDITIONS:
-- PRE01: none
--
-- POSTCONDITIONS:
-- POST01: PestHandler table must have rows
-- POST02: no double quotes exists in any column
-- POST03: no leading/trailing wsp exists in any column
--
-- BCP create (DOS_:
-- bcp Farming_dev.dbo.cropstaging format nul -c -T -f FertHandler.fmt
--
-- TESTS:
--
-- CHANGES:
-- ==========================================================================================================
CREATE PROCEDURE [dbo].[sp_import_PestHandlers]
    @file            VARCHAR(500)
   ,@folder          VARCHAR(600) = NULL
   ,@display_tables  BIT          = 0
AS
BEGIN
   DECLARE
    @fn                 VARCHAR(35)    = N'import_Pest_Handlers'
   ,@sql                VARCHAR(MAX)
   ,@bkslsh             CHAR(1)       = CHAR(92)
   ,@cmd                VARCHAR(MAX)
   ,@error_file         VARCHAR(400)   = NULL
   ,@error_msg          VARCHAR(MAX)   = NULL
   ,@table_nm           VARCHAR(35)    = 'Distributor'
   ,@rc                 INT            = -1
   ,@import_root        VARCHAR(MAX)
   ,@pathogen_row_cnt   INT            = -1
   ,@update_row_cnt     INT            = -1
   ,@null_type_row_cnt  INT            = -1
   ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting:
file          :[', @file  ,']
folder        :[', @folder,']
display_tables:[', @display_tables,']
';

      ---------------------------------------
      -- Validate inputs
      ---------------------------------------
      IF @folder IS NOT NULL
         SET @file = CONCAT(@folder, @bkslsh, @file);

      ----------------------------------------------------------------------------------
      -- Process
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: calling sp_bulk_import_tsv2';

      EXEC sp_import_txt_file -- sp_import_tsv
          @table         = PestHandlerStaging
         ,@view          = NULL
         ,@file          = @file
         ,@format_file   = NULL
         ,@non_null_flds = 'id,region,province,city,address,company_nm,activity,type,license_app_ty,expiry,license_num'
        ;

      ----------------------------------------------------------------------------------
      -- Do any fixup
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020:Fixup: none currently';

      ----------------------------------------------------------------------------------
      -- Copy to main
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030:copy to main';
      DELETE FROM PestHandler;
      INSERT INTO PestHandler
      (
         [id]
         ,[region]
         ,[province]
         ,[city]
         ,[address]
         ,[company_nm]
         ,[owner]
         ,[activity]
         ,[type]
         ,[license_app_ty]
         ,[expiry]
         ,[license_num]
      )
      SELECT 
         [id]
         ,[region]
         ,[province]
         ,[city]
         ,[address]
         ,[company_nm]
         ,[owner]
         ,[activity]
         ,[type]
         ,[license_app_ty]
         ,CONVERT(DATE,[expiry])
         ,[license_num]
      FROM PestHandlerStaging;

      IF @display_tables = 1
         SELECT * FROM PestHandler;

      ----------------------------------------------------------------------------------
      -- Chk postconditions
      ----------------------------------------------------------------------------------
      EXEC sp_assert_tbl_pop 'PestHandler';
      ----------------------------------------------------------------------------------
      -- Completed processing OK
      ----------------------------------------------------------------------------------
      SET @rc = 0; -- OK
      EXEC sp_log 1, @fn, '499:completed import and fixup OK'
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, @ex_msg = @error_msg OUT;
      EXEC sp_log 4, @fn, '500: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, RC: ', @rc
   RETURN @RC;
END
/*
EXEC sp_import_Pest_Handlers 'Pest-Handlers-May-10-2023.txt', 'D:\dev\farming\data';
*/

GO
