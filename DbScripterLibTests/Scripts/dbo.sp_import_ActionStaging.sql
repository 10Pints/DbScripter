SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 08-OCT-2023
-- Description: Handles the bulk import of the Actions.txt file
-- It does the following:
-- 1: delete the log files
-- 2: clear the ActionStaging table
-- 3: import the the @imprt_tsv_file into the Action table
-- 4: do any fixup
-- 5: Check postconditions: ActionStaging has rows
--
-- ALGORITHM:
-- Parameter validation
-- Delete the log files if they exist
-- Clear the ActionStaging table
-- Import the file
-- Do any fixup
-- Check postconditions
--
-- PRECONDITIONS:
--    ActionStaging table dependents have been creared
--
-- POSTCONDITIONS:
-- POST01: ActionStaging must have rows
--
-- Called by: sp__main_import_pesticide_register
--
-- TESTS:
--
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 240225: import from either tsv or xlsx file
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_import_ActionStaging]
    @import_file     NVARCHAR(500)
   ,@range           NVARCHAR(100)  = N'Sheet1$'  -- for XL: like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@fields          NVARCHAR(4000) = NULL  -- for XL: comma separated list
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'IMPRT_ActionStaging'
      ,@sql                NVARCHAR(MAX)
      ,@error_msg          NVARCHAR(MAX)  = NULL
      ,@pathogen_row_cnt   INT            = -1
      ,@update_row_cnt     INT            = -1
      ,@null_type_row_cnt  INT            = -1
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '00: starting, 
@import_root:[',@import_file,']
@range      :[',@range,']
@fields     :[',@fields,']
';

      EXEC sp_register_call @fn;

      ---------------------------------------------------------------------
      -- Parameter validation
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '10: validation';
      EXEC sp_log 1, @fn, '20: deleting bulk import log files: D:\Logs\ActionStagingImport.log and .log.Error.Txt';

      ---------------------------------------------------------------------
      -- Process
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '30: process';

      EXEC sp_bulk_import 
          @import_file   = @import_file
         ,@table         = 'ActionStaging'
         ,@view          = 'Import_ActionStaging_vw'
         ,@range         = @range
         ,@fields        = 'action_id,action_nm'
         ,@clr_first     = 1;

      EXEC sp_log 1, @fn, '40: completed import OK';

      ---------------------------------------------------------------------
      -- fixup
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '50: Fixup';
      EXEC sp_log 1, @fn, '50: Fixup: currently no Fixup';
      -- Remove trailing tabs

      ---------------------------------------------------------------------
      -- Check postconditions
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '80: Check postconditions';
      -- POST01: ActionStaging must have rows
      EXEC sp_chk_tbl_populated 'ActionStaging';

      ---------------------------------------------------------------------
      -- ASSERTION: imported at least 1 row into ActionStaging
      ---------------------------------------------------------------------

      ---------------------------------------------------------------------
      -- Completed processing OK
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '90: completed processing OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving, OK';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_sp_import_ActionStaging';

EXEC sp_import_ActionStaging 'D:\Dev\Repos\Farming\Data\Actions.txt';
SELECT * FROM [ActionStaging] ORDER by action_id;
SELECT * FROM ImportActionStaging_vw
3	Early post-emergent	1
Show errors in the [Action] import....
SELECT * FROM  [Action]   WHERE [type_id] IS NULL;
SELECT * FROM  [Action]   WHERE [type_nm] IS NULL;


      EXEC xp_cmdshell 'DEL D:\Logs\ActionStagingImport.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\ActionStagingImport.log'          , NO_OUTPUT;

      ---------------------------------------------------------------------
      -- Clear the ActionStaging table
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '40: clearing ActionStaging table';
      DELETE FROM ActionStaging;

      ---------------------------------------------------------------------
      -- Import the file
      ---------------------------------------------------------------------
      EXEC sp_log 1, @fn, '50: Import the file';
      SET @sql = CONCAT(
      'BULK INSERT dbo.ImportActionStaging_vw FROM ''', @imprt_tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs\ActionStagingImport.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''   
      );
   ');

      PRINT @sql;
      EXEC sp_log 1, @fn, '60: running bulk insert cmd';
      EXEC sp_executesql @sql;
*/

GO
