SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================================
-- Author:      Terry Watts
-- Create date: 08-AUG-2023
-- Description: General import rtn for all LRAP imports
--
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
--    Ready to call the fixup routne
--
-- ERROR HANDLING by exception handling
--
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- =============================================================================
ALTER procedure [dbo].[sp_bulk_insert_LRAP]
      @import_tsv_file  NVARCHAR(360)
     ,@view             NVARCHAR(60)
     ,@import_nm        NVARCHAR(60)
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(35)   = N'BLK INSRT LRAP'
      ,@sql             NVARCHAR(4000)
      ,@RC              INT            = -1
      ,@error_msg       NVARCHAR(500)
      ,@rowcnt          INT = -1;
      ;

   EXEC sp_log 2, @fn, '01: Bulk_insert of [', @import_tsv_file, '] starting';

   BEGIN TRY
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportErrors.log.Error.Txt', NO_OUTPUT;
      EXEC xp_cmdshell 'DEL D:\Logs\PesticideRegisterImportErrors.log'          , NO_OUTPUT;
      --SET IDENTITY_INSERT Staging1 OFF;
      EXEC sp_log 2, @fn, '02: about to import ',@import_tsv_file;

      SET @sql = CONCAT(
         'BULK INSERT ',@view,' FROM ''', @import_tsv_file, '''
          WITH
          (
             FIRSTROW = 2
            ,FIELDTERMINATOR = ''\t''
            ,ROWTERMINATOR   = ''\n''   
            ,ERRORFILE       = ''D:\Logs\PesticideRegisterImportErrors.log''
          );'
         );

        EXEC @RC = sp_executesql @sql;
        SET @rowcnt = @@ROWCOUNT;
        EXEC sp_log 2, @fn, 'imported ',@import_tsv_file, ' ', @rowcnt, ' rows',@row_count=@rowcnt;

        IF @RC <> 0
        BEGIN
            SET @error_msg = CONCAT('sp_bulk import_Registered Pesticides file failed error: :', @RC, '
            Error mmsg: ', ERROR_MESSAGE(),
            'File: ', @import_tsv_file);

            EXEC sp_log 4, @fn, '10: ', @error_msg;
            THROW 53874, @error_msg,1;
        END

      --SET IDENTITY_INSERT Staging1 ON;
      UPDATE staging1 
      SET created = FORMAT (getdate(), 'yyyy-MM-dd hh:mm')

   END TRY
   BEGIN CATCH
      --SET IDENTITY_INSERT Staging1 ON;
      SET @error_msg = Ut.dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, '50: caught exception: ',@error_msg;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: Bulk_insert of [', @import_tsv_file, ' leaving';
   RETURN @RC;
END
/*
TRUNCATE TABLE Staging1 
EXEC sp_bulk_insert_LRAP 'D:\Dev\Repos\Farming\Data\LRAP-231025-231103.txt', 'RegisteredPesticideImport_230721_vw', '2'
SELECT * FROM staging1 -- WHERE Id > 5710;
SELECT * FROM RegisteredPesticideImport_230721_vw
*/

GO
