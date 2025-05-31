SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2024
-- Description: imports an Excel sheet into an existing table
-- returns the row count [optional]
-- 
-- Postconditions:
-- POST01: IF @expect_rows set then expect at least 1 row to be imported or EXCEPTION 56500 'expected some rows to be imported'
--
-- Changes:
-- 05-MAR-2024: parameter changes: made fields optional; swopped @table and @fields order
-- 08-MAR-2024: added @expect_rows parameter defult = yes(1)
-- ===========================================================
ALTER PROCEDURE [dbo].[sp_import_XL_existing]
(
    @spreadsheet  NVARCHAR(400)              -- path to xls
   ,@range        NVARCHAR(100)              -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@table        NVARCHAR(60)               -- existing table
   ,@clr_first    BIT            = 1         -- if 1 then delete the table contets first
   ,@fields       NVARCHAR(4000) = NULL      -- comma separated list
   ,@expect_rows  BIT            = 1
   ,@row_cnt      INT            = NULL  OUT -- optional rowcount of imported rows
)
AS
BEGIN
   DECLARE 
    @fn           NVARCHAR(35)   = N'IMPORT_XL_EXISTNG'
   ,@cmd          NVARCHAR(4000)

   EXEC sp_log 0, @fn,'000: starting';

   ----------------------------------------------------------------------------------
   -- Process
   ----------------------------------------------------------------------------------
   BEGIN TRY

      EXEC sp_log 1, @fn,'510: parameters:
         spreadsheet:[', @spreadsheet, ']
         range      :[', @range, ']
         table      :[', @table, ']
         clr_first  :[', @clr_first, ']
         fields     :[', @fields,']
         expect_rows:[',@expect_rows,']'
         ;

      IF @clr_first = 1
      BEGIN
         EXEC sp_log 1, @fn,'005: clearing data from table';
         SET @cmd = CONCAT('DELETE FROM [', @table,']');
         EXEC( @cmd)
      END
      EXEC sp_log 1, @fn,'007';

      IF @fields IS NULL
      BEGIN
         EXEC sp_log 1, @fn,'010: getting fields from XL hdr';
         EXEC sp_get_fields_from_xl_hdr @spreadsheet, @range, @fields OUT;
      END

      EXEC sp_log 1, @fn,'015: importing data';
      SET @cmd = ut.dbo.fnCrtOpenRowsetSqlForXlsx(@table, @fields, @spreadsheet, @range, 0);
      EXEC sp_log 1, @fn, '020 open rowset sql:
   ', @cmd;
      EXEC( @cmd);

      SET @row_cnt = @@rowcount;
      EXEC sp_log 0, @fn, '22: imported ', @row_cnt,' rows';

      ----------------------------------------------------------------------------------
      -- Check post conditions
      ----------------------------------------------------------------------------------
      EXEC sp_log 0, @fn,'025: Checking post conditions';
      IF @expect_rows = 1 EXEC sp_assert_gtr_than @row_cnt, 0, 'expected some rows to be imported';--, @fn=@fn;

      ----------------------------------------------------------------------------------
      -- Processing complete
      ----------------------------------------------------------------------------------
      EXEC sp_log 0, @fn, '950: processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving OK, imported ', @row_cnt,' rows';
END
/*
EXEC sp_import_XL_existing 
    @spreadsheet = 'D:\Dev\Farming\Data\ImportCorrections 221018 230816-2000.xlsx'
   ,@range       = 'ImportCorrections'
   ,@table       = 'ImportCorrectionsStaging'
   ,@clr_first   = 1
   ,@fields      = 'id,command,search_clause,search_clause_cont,not_clause,replace_clause, case_sensitive, Latin_name, common_name, local_name, alt_names, note_clause, crops, doit, must_update, comments'
   ,@expect_rows = 1
   ,@row_cnt     = NULL
EXEC sp_import_XL_existing 
    @spreadsheet = 'D:\Dev\Repos\Farming\Data\CallRegister.xlsx'
   ,@range       = 'Call Register$A:C'
   ,@table       = 'CallRegister'
   ,@clr_first   = 1
   ,@fields      = 'id,rtn,limit'
   ,@expect_rows = 1
   ,@row_cnt     = NULL
*/

GO
