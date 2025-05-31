SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:      Terry Watts
-- Create date: 02-AUG-2023
-- Description: Encapsulate all the main import routine init - not 
-- Called by:   sp_main__import_pesticide_register
--
-- Responsibilities:
-- 01: Determine the file type - xlsx or csv (txt)
-- 02: Clear the applog 
-- 03: Set the log level
-- 04: Configure routine call control to avoid multiple calls of single call routines
-- 05: Set session ctx vals: fixup count: 0, import_root
-- 06: Get the import id from the file name
-- 07: Override import_id with @import_id parameter if supplied
-- 08: Delete bulk import log files
-- 09: Postcondition checks
-- 10: Completed processing
-- 
-- POST CONDITIONS:
-- POST 1: session settings[fixup count] set to 0
-- POST 2: @import_root set 
-- POST 3: @import_id  AND session settings[IMPORT_ID] set and >1,
--         if import id < 0 exception thrown 
-- POST 4: if mode contains logging level the session settings[IMPORT_ID] set 
-- POST 5: clear the staging import logs
--
-- CHANGES:
-- 230811: Clean import then merge into the main tables, save the import_id as a session setting in import-init
-- 231013: Override @import_id if supplied
-- 231014: ADDED POST Condition CHKS: import_id NOT NULL AND > 0
--         Added support of table logging: clear the table before the main procedure starts
-- 231016: Truncate the AppLog table
-- 231108: removed params: @import_root which is now supplied to the main fn with a default
-- 240207: added call to sp_clear_call_register to clear the routine call register table
-- 240309: moved the tuncate applog to main as we dont get any logging of main import right now
-- 240323: added sp_write_results_to_cor_file validation now so as to waste time processing if bad p
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_main_import_init]
    @LRAP_data_file  NVARCHAR(150)  OUT
   ,@import_root     NVARCHAR(450)
   ,@log_level       INT
   ,@cor_file        NVARCHAR(450)
   ,@cor_range       NVARCHAR(40)
   ,@cor_file_path   NVARCHAR(450)  OUT
   ,@import_id       INT            OUT
   ,@file_type       NCHAR(4)       OUT -- 'txt' or 'xlsx'
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = N'MAIN_IMPORT_INIT'
   ,@msg             NVARCHAR(500)  = ''
   ,@ndx             INT
   ,@import_id_cpy   INT
   ,@import_file     NVARCHAR(500)

   -- Set nocount off so we can see the update counts
   SET NOCOUNT OFF
   -- Set the stop at first error flag
   SET XACT_ABORT ON;

   EXEC sp_log 2, @fn,'00: starting
   @LRAP_data_file:[',@LRAP_data_file,']
   @import_root:   [',@import_root,']
   @log_level:     [',@log_level,']
   @cor_file:      [',@cor_file,']
   @cor_range:     [',@cor_range,']'
   ;

   BEGIN TRY
      -----------------------------------------------------------------------------------
      -- 01: Determine the file type - xlsx or csv (txt)
      -----------------------------------------------------------------------------------
      SELECT @file_type = ext FROM  dbo.fnGetFileDetails(@LRAP_data_file);
      -----------------------------------------------------------------------------------
      -- 02: Clear the applog 
      -----------------------------------------------------------------------------------
      TRUNCATE TABLE Applog;

      -- Disable the staging2 on update trigger
      DISABLE TRIGGER staging2.sp_Staging2_update_trigger ON staging2;
      TRUNCATE TABLE S2UpdateLog;
      TRUNCATE TABLE S2UpdateSummary;

      -----------------------------------------------------------------------------------
      -- 03: Set the log level
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '05: setting minimum logging level to: ', @log_level, ' mode txt:[',@msg,']';
      EXEC sys.sp_set_session_context @key = N'LOG_LEVEL', @value = @log_level;-- POST 4: set the min log level

      --------------------------------------------------------------------------------------
      -- 04: Configure routine call control to avoid multiple calls of single call routines
      --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '10: calling sp_import_call_register';
      SET @import_file = CONCAT(@import_root, '\','CallRegister.txt');
      EXEC sp_import_CallRegister @import_file;
      EXEC sp_register_call @fn;
      EXEC sp_log 1, @fn, '12: setting context data';

      SET @import_id_cpy = @import_id;

      -----------------------------------------------------------------------------------
      -- 05: Set session ctx vals: fixup count: 0, import_root
      -----------------------------------------------------------------------------------
      EXEC ut.dbo.sp_set_session_context N'fixup count', 0;                    -- POST 1 init fixup cnt to 0
      EXEC ut.dbo.sp_set_session_context_import_root @import_root;             -- POST 2 KEY: 'Import Root'
      EXEC sp_set_session_context_cor_id 0;
      SET @LRAP_data_file = CONCAT(@import_root, NCHAR(92), @LRAP_data_file);

      -----------------------------------------------------------------------------------
      -- 06: Get the import id from the file name
      -----------------------------------------------------------------------------------
      SET @import_id = dbo.fnGetImportIdFromName(@LRAP_data_file);
      EXEC sp_log 1, @fn, '20: @import_id: ',@import_id;
      EXEC sp_assert_not_null @import_id, 'Import id must not be null';

      -----------------------------------------------------------------------------------
      -- 07: Override import_id with @import_id parameter if supplied
      -----------------------------------------------------------------------------------
      IF (@import_id = -1 OR @import_id IS NULL) AND (@LRAP_data_file IS NOT NULL)
         EXEC Ut.dbo.sp_raise_exception 51234, 'Unrecognised file format type for LRAP file:[', @LRAP_data_file, ']';

      IF @import_id_cpy IS NOT NULL
         SET @import_id = @import_id_cpy;

      -----------------------------------------------------------------------------------
      -- 08: Delete bulk import log files
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '25: Deleting bulk import log files, @import_id: ',@import_id;
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportErrors.log.Error.Txt', NO_OUTPUT; -- POST 5: clear the staging import logs
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportErrors.log'          , NO_OUTPUT; -- POST 5: clear the staging import logs

      -----------------------------------------------------------------------------------
      -- 09: Postcondition checks
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '30: Postcondition checks: @import_id must not be NUL and must be > 0, @import_id: [', @import_id,']';
      EXEC Ut.dbo.sp_assert_not_null @import_id,    '@import_id must not be NULL', @ex_num = 58100; 
      EXEC Ut.dbo.sp_assert_gtr_than @import_id, 0, '@import_id must be > 0'     , @ex_num = 58101;

      -- ASSERTION: @import_id id known and > 0
      EXEC sp_set_session_context_import_id @import_id;              -- POST 3: set import id

      -- Validate write back params now so as not to waste time
      SET @cor_file_path = CONCAT(@import_root, '\', @cor_file);

      EXEC sp_write_results_to_cor_file_param_val 
             @cor_file      = @cor_file
            ,@cor_file_path = @cor_file_path
            ,@cor_range     = @cor_range;

      -----------------------------------------------------------------------------------
      -- 10: Completed processing
      -----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'import_id:      ', @import_id;
      EXEC sp_log 2, @fn,'LRAP data file: ', @LRAP_data_file;
   END TRY
   BEGIN CATCH
      EXEC Ut.dbo.sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '99: Completed processing ok, leaving
   @LRAP_data_file:[',@LRAP_data_file,']
   @import_root:   [',@import_root,']
   @log_level:     [',@log_level,']
   @cor_file:      [',@cor_file,']
   @cor_range:     [',@cor_range,']
   @import_id     :[',@import_id,']
   @file_type     :[',@file_type,']'-- 'txt' or 'xlsx'
   ;
END
/*
/*00 init       */EXEC sp__main_import @start_stage = 0, @LRAP_data_file = 'LRAP-221018-230813.xlsx', @LRAP_range= 'LRAP-221018 230813$A:N', @cor_file= 'ImportCorrections 221018 230816-2000.xlsx',@cor_range='Sheet1$A:S', @log_level=1  -- D:\Dev\Repos\Farming_Dev\Data
*/

GO
