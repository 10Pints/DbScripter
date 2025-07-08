SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry watts
-- Create date: 02-NOV-2024
-- Description: imports the system data

-- RESPONSIBILITIES:
-- R02: clean import the following tables:
--    Import
--    TableDef
--    TableType
--    TypeStaging
-- =============================================
CREATE PROCEDURE [dbo].[sp_import_system_static_data]
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)  = N'import_system_static_data'

   SET NOCOUNT ON;

   BEGIN TRY
      EXEC sp_log 1, @fn,'000: starting';

      --------------------------------------------------------------------------------------------
      -- 1. Import the Import table SYSTEM data
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'010: importing the Import table';
      EXEC sp_import_txt_file
          @file            = 'D:\Dev\Farming\Data\Import.txt'
         ,@table           = 'Import'
         ,@clr_first       = 1
         ,@non_null_flds   = 'import_id,import_nm,description,new_fields,dropped_fields,error_count'
         ;

      /*--------------------------------------------------------------------------------------------
      -- 2. Import the ForeignKey table SYSTEM data
      --------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'020: importing the ForeignKes table';
      EXEC sp_import_ForeignKey_tsv 'D:\Dev\Farming\Data\ForeignKey.txt'--, 'Sheet1$'
      */

      --------------------------------------------------------------------------------------------
      -- 3. Import the TypeStaging table SYSTEM data
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'030: importing the TypeStaging table';
      EXEC dbo.sp_import_txt_file
          @file         = 'D:\Dev\Farming\Data\Type.txt'
         ,@table        = 'TypeStaging'
         ,@clr_first    = 1
         ,@expect_rows  = 1
         ,@non_null_flds= 'type_id,type_nm'
         ;

      --------------------------------------------------------------------------------------------
      -- 4. Import the TableType table SYSTEM data
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'040: importing the TableType table';
      EXEC sp_import_txt_file
          @file         = 'D:\Dev\Farming\Data\TableType.txt'
         ,@table        = 'TableType'
         ,@clr_first    = 1
         ,@expect_rows  = 1
         ,@non_null_flds= 'id,name'
         ;

      --------------------------------------------------------------------------------------------
      -- 5. Import the TableDef table SYSTEM data
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'050: import the TableDef table';
      EXEC sp_import_txt_file
          @file         = 'D:\Dev\Farming\Data\TableDef.txt'
         ,@table        = 'TableDef'
         ,@clr_first    = 1
         ,@expect_rows  = 1
         ,@non_null_flds= 'table_id,table_nm,table_type,sub_type'
         ;

      --------------------------------------------------------------------------------------------
      -- 14. Postcondition checks - chk only primary tables
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'170: Postcondition checks';
      EXEC sp_assert_tbl_pop 'Import';
      EXEC sp_assert_tbl_pop 'TypeStaging';
      EXEC sp_assert_tbl_pop 'TableDef';

      --------------------------------------------------------------------------------------------
      -- Completed processing OK
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'800: Completed processing OK';

   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving OK';
END
/*
EXEC sp_import_system_static_data;
*/

GO
