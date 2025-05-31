SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================================
-- Author       Terry Watts
-- Create date: 07-FEB-2024
-- Description: Registers a routine call and checks the call count against the limit
--
-- CHECKED PRECONDITIONS: PRE 01: @rtn must be registered
-- =====================================================================================
ALTER PROCEDURE [dbo].[sp_import_CallRegister]
    @spreadsheet  NVARCHAR(500)
   ,@range        NVARCHAR(60) = 'Call Register$A:C'
AS
BEGIN
   DECLARE
        @fn       NVARCHAR(35) = 'IMPRT_CALL_REGISTER'
       ,@is_XLS   BIT

   EXEC sp_log 2, @fn,'00: starting: 
@spreadsheet: [',@spreadsheet,']
@range:       [',@range,']';

   EXEC sp_log 2, @fn,'10: clearing existing records';
   DELETE FROM CallRegister;
   SET @is_XLS = iif( dbo.fnGetFileExtension(@spreadsheet) = 'xlsx', 1 , 0);
   EXEC sp_log 2, @fn,'20: importing call configuration...@is_XLS: ', @is_XLS;

   IF @is_XLS = 1
   BEGIN
      EXEC sp_log 2, @fn,'25: ';
      EXEC sp_import_XL_existing @spreadsheet, @range, 'CallRegister';  --, 'id,rtn,limit'
   END
   ELSE
   BEGIN
      EXEC sp_log 2, @fn,'30: ';
      EXEC sp_import_tsv @spreadsheet, 'Import_CallRegister_vw', 'CallRegister';
   END

   EXEC sp_log 2, @fn,'99: leaving OK';
END
/*
EXEC sp_import_call_register 'D:\Dev\Repos\Farming\Data\CallRegister.xlsx';
*/

GO
