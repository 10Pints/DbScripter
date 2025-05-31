SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Author:       Terry Watts
-- Create date:  01-AUG-2023
-- Description:  imports the extra data productUse table
--               do this after the main import pops the productUse table
--
-- Info Sources:
--
-- Tests:
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_bulk_insert_productUseStaging]
    @imprt_tsv_file   NVARCHAR(500)
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35)  = N'BLK_IMPRT PROD-USE STGING'
      ,@sql NVARCHAR(MAX)
      ,@error_msg NVARCHAR(MAX) = NULL
      ,@rc  INT    =-1
      ,@import_root NVARCHAR(MAX)  
      ;

   SET NOCOUNT OFF;
   BEGIN TRY
      SET @import_root = Ut.dbo.fnGetImportRoot();
      EXEC sp_log 1, @fn, '01: starting, @import_root:[',@import_root,']';
      EXEC sp_register_call @fn;
      EXEC sp_log 1, @fn, '02: deleting bulk import log files';
      EXEC xp_cmdshell 'DEL D:\Logs\ProductUse.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\ProductUse.log'          , NO_OUTPUT;

      SET @sql = CONCAT(
   'BULK INSERT [dbo].[ProductUseStaging] FROM ''', @imprt_tsv_file, '''
      WITH
      (
         FIRSTROW        = 4
        ,ERRORFILE       = ''D:\Logs\ProductUse.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''   
        ,FORMATFILE      = ''D:\Dev\Repos\Farming\Data\ProductUse.FMT''
      );
   ');
      
;      PRINT @sql;
      EXEC sp_log 1, @fn, '04: running bulk insert cmd';
      EXEC @rc = sp_executesql @sql;
      EXEC sp_log 1, @fn, '05: completed processing OK';
      SET @rc = 0; -- OK
   END TRY
   BEGIN CATCH
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving OK, RC: ', @rc;
   RETURN @RC;
END
/*
TRUNCATE TABLE productUseStaging;
EXEC sp_bulk_insert_productUseStaging 'D:\Dev\Repos\Farming\Data\ProductUse.tsv'
SELECT * FROM ProductUseStaging;
SELECT * FROM all_vw_with_nulls
*/ 


GO
