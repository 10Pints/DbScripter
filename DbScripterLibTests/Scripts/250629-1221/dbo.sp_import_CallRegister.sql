SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =====================================================================================
-- AUTHOR       Terry Watts
-- CREATE DATE: 07-FEB-2024
-- DESCRIPTION: Registers a routine call and checks the call count against the limit
-- NOTE:        This should be called ASAP after the app start
-- CALLED BY:   sp_main_import_init
--
-- CHECKED PRECONDITIONS: PRE 01: @rtn must be registered
-- =====================================================================================
CREATE   PROCEDURE [dbo].[sp_import_CallRegister]
    @import_file  VARCHAR(500) -- if xls includes optioanl tange
AS
BEGIN
   DECLARE
        @fn       VARCHAR(35) = 'import_CallRegister'
       ,@is_XLS   BIT

   EXEC sp_log 2, @fn,'001: starting: 
import_file: [',@import_file,']';

   BEGIN TRY
      EXEC sp_log 2, @fn,'010: clearing existing records';
      DELETE FROM CallRegister;
      SET @is_XLS = iif( dbo.fnGetFileExtension(@import_file) = 'xlsx', 1 , 0);
      EXEC sp_log 2, @fn,'020: importing call configuration   @is_XLS: ', @is_XLS;

      IF @is_XLS = 1
      BEGIN
         EXEC sp_log 2, @fn,'030: is an XLS import, calling sp_import_XL_existing';
         EXEC sp_import_XL_existing @import_file, 'CallRegister';  --, 'id,rtn,limit'
         EXEC sp_log 2, @fn,'040: ret frm sp_import_XL_existing';
      END
      ELSE
      BEGIN
         EXEC sp_log 2, @fn,'050: is not an XLS import, calling sp_import_tsv';

         EXEC sp_import_txt_file
             @table = 'CallRegister'
            ,@view  = 'Import_CallRegister_vw'
            ,@file  = @import_file
            ;

         EXEC sp_log 2, @fn,'060: ret frm sp_import_tsv';
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log 2, @fn,'500: caught exception';
      EXEC sp_log_exception @fn;
      throw;
   END CATCH

   EXEC sp_log 2, @fn,'999: leaving OK';
END
/*
EXEC sp_import_CallRegister 'D:\Dev\Farming\Data\CallRegister.txt';
SELECT * FROM CallRegister;
*/


GO
