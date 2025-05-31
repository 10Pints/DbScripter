SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 20-AUG-2023
--
-- Description: imports the Import table
-- RETURNS:
--    0 if OK, else OS error code
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--   Import table clean populated or error
--
-- Tests:
--
-- ========================================================
ALTER procedure [dbo].[sp_bulk_insert_import]
    @imprt_tsv_file   NVARCHAR(500)
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)  = N'BLK_INS_IMPORT'
      ,@sql       NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX) = NULL
      ,@rc        INT   =-1 
      ;

   EXEC sp_log 1, @fn,'00: starting';

   BEGIN TRY
      EXEC sp_log 2, @fn, '10: deleting bulk import log files'
      EXEC xp_cmdshell 'DEL D:\Logs\ImportImportErrors.log.Error.Txt', NO_OUTPUT; -- POST 5: clear the staging import logs
      EXEC xp_cmdshell 'DEL D:\Logs\ImportImportErrors.log'          , NO_OUTPUT; -- POST 5: clear the staging import logs

      EXEC sp_log 2, @fn, '20: truncating table'
      TRUNCATE TABLE dbo.Import;

      SET @sql = CONCAT(
     'BULK INSERT [dbo].[import] FROM ''', @imprt_tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs\ImportImportErrors.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''   
      );
   ');

      EXEC sp_log 2, @fn, '30: running bulk insert cmd'
      EXEC @rc = sp_executesql @sql;
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '40: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, 'leaving'
   RETURN @RC;
END
/*
EXEC sp_bulk_insert_Import 'D:\Dev\Repos\Farming\Data\Import.tsv.txt'
SELECT * FROM Import;
*/

GO
