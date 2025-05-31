SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 31-OCT-2023
-- Description: Handles the bulk import of the [use] table
--
-- ALGORITHM:
-- 1: delete the log files if they exist
-- 2: bulk insert the UseStaging file
-- 3: do any fixup
-- 4: Check postconditions: ActionStaging has rows
--
-- PRECONDITIONS:
--   PRE 01: UseStaging table and its dependants have been cleared
--
-- POSTCONDITIONS:
-- POST01: UseStaging table must have rows
-- POST02: ChemicalUse and ProductUse will be truncated
-- TESTS: test.sp_import_use_staging
--
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- ==========================================================================================================
ALTER PROCEDURE [dbo].[sp_import_UseStaging]
    @imprt_tsv_file   NVARCHAR(500)
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'IMPRT_UseStaging'
      ,@sql                NVARCHAR(MAX)
      ,@error_msg          NVARCHAR(MAX)  = NULL
      ,@rc                 INT            = -1
      ,@import_root        NVARCHAR(MAX)
      ,@pathogen_row_cnt   INT            = -1
      ,@update_row_cnt     INT            = -1
      ,@null_type_row_cnt  INT            = -1
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '01: starting, @import_root:[',@import_root,']';
      EXEC sp_register_call @fn;

      ---------------------------------------------------------------------------------
      -- Validation
      ---------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '02: validation';

      -- PRE 01: UseStaging table dependants have been cleared
      DELETE FROM UseStaging;
      EXEC sp_chk_tbl_not_populated 'UseStaging';

      ---------------------------------------------------------------------------------
      -- Init
      ---------------------------------------------------------------------------------

      SET @import_root = Ut.dbo.fnGetImportRoot();
      EXEC sp_log 1, @fn, '03: deleting bulk import log files:  D:\Logs\UseStagingImport.log and .log.Error.Txt'

      EXEC xp_cmdshell 'DEL D:\Logs\UseStagingImport.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\UseStagingImport.log'          , NO_OUTPUT;

      --EXEC sp_log 1, @fn, '02: Clearing the staging tables';
      --EXEC sp_clear_staging_tables;

      ---------------------------------------------------------------------------------
      -- Import
      ---------------------------------------------------------------------------------
      SET @sql = CONCAT(
   'BULK INSERT dbo.Import_UseStaging_vw FROM ''', @imprt_tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs\UseStagingImport.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''   
      );
   ');

      PRINT @sql;
      EXEC sp_log 1, @fn, '05: running bulk insert cmd';
      EXEC @rc = sp_executesql @sql;

      IF @rc <> 0 THROW 56874, '06: sp_executesql failed', 1;

      EXEC sp_log 1, @fn, '07: completed bulk import cmd OK';
      -- Do any fixup

      ---------------------------------------------------------------------------------
      -- Postcondition checks
      ---------------------------------------------------------------------------------
      -- POST01: UseStaging must have rows
      EXEC sp_chk_tbl_populated 'UseStaging';

      ---------------------------------------------------------------------------------
      -- Processing completed OK
      ---------------------------------------------------------------------------------
      SET @rc = 0; -- OK
      EXEC sp_log 1, @fn, '95:completed UseStaging import and fixup OK';
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      --SET IDENTITY_INSERT [Use] ON;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving OK, RC: ', @rc
   RETURN @RC;
END
/*
EXEC tSQLt.Run 'test.test_sp_import_useStaging';
EXEC sp_import_useStaging 'D:\Dev\Repos\Farming\Data\Use.txt'
SELECT * FROM useStaging;
*/

GO
