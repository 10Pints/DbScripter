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
-- 241006: increased max error count from default 10 to 1000
-- =============================================================================
ALTER   PROCEDURE [dbo].[sp_bulk_insert_LRAP]
    @import_tsv_file VARCHAR(360)
   ,@view            VARCHAR(60)
   ,@clr_first       BIT
AS
BEGIN
DECLARE
    @fn              VARCHAR(35)   = N'sp_bulk_insert_LRAP'
   ,@sql             NVARCHAR(4000)
   ,@RC              INT            = -1
   ,@error_msg       VARCHAR(500)
   ,@rowcnt          INT            = -1
   ,@cmd             NVARCHAR(4000)
   ,@notepad_path    VARCHAR(500)  = '"C:\Program Files\Notepad++\notepad++.exe" '
   ,@bckslsh         VARCHAR(1)    = NCHAR(92)
   ,@tab             VARCHAR(1)    = NCHAR(9)
   ,@nl              VARCHAR(2)    = NCHAR(13) + NCHAR(10)
   ;

   EXEC sp_log 2, @fn, '000:starting:
@import_tsv_file:[', @import_tsv_file, ']
@view           :[',@view            , ']
clr_first       :[',@clr_first       ,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '010: deleting log files';
      SET @cmd = CONCAT('DEL D:',@bckslsh,'Logs',@bckslsh,'LRAPImportErrors.log.Error.Txt');
      EXEC xp_cmdshell @cmd, NO_OUTPUT;
      SET @cmd = CONCAT('DEL D:',@bckslsh,'Logs',@bckslsh,'LRAPImportErrors.log');
      EXEC xp_cmdshell @cmd, NO_OUTPUT;
      EXEC sp_log 2, @fn, '020: about to import ',@import_tsv_file;

      SET @sql = CONCAT(
         'BULK INSERT ',@view,' FROM ''', @import_tsv_file, '''
          WITH
          (
             FIRSTROW = 2
            ,FIELDTERMINATOR = ''',@tab,'''
            ,ROWTERMINATOR   = ''',@nl,'''   
            ,ERRORFILE       = ''D:',@bckslsh,'Logs',@bckslsh,'LRAPImportErrors.log''
            ,MAXERRORS       = 30
          );'
         );

         EXEC sp_log 2, @fn, '025: import sql:
', @sql;

        EXEC @RC = sp_executesql @sql;
        SET @rowcnt = @@ROWCOUNT;
        EXEC sp_log 2, @fn, '030: imported ',@import_tsv_file, ' ', @rowcnt, ' rows',@row_count=@rowcnt;

        IF @RC <> 0
        BEGIN
            SET @error_msg = CONCAT('import had errors: :', @RC, '
            Error mmsg: ', ERROR_MESSAGE(),
            ' File: ', @import_tsv_file);

            EXEC sp_log 4, @fn, '10: ', @error_msg;
            RETURN @RC;

            SET @cmd = CONCAT(@notepad_path, 'D:',@bckslsh,'Logs',@bckslsh,'LRAPImportErrors.log.Error.Txt')
            EXEC xp_cmdshell @cmd;
            SET @cmd = CONCAT(@notepad_path, 'D:',@bckslsh,'Logs',@bckslsh,'LRAPImportErrors.log')
            EXEC xp_cmdshell @cmd;
        END

      UPDATE staging1 
      SET created = FORMAT (getdate(), 'yyyy-MM-dd hh:mm')

   END TRY
   BEGIN CATCH
      SET @error_msg = Error_Message();
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
