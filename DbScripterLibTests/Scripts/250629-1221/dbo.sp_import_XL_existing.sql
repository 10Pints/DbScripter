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
CREATE   PROCEDURE [dbo].[sp_import_XL_existing]
(
    @import_file  VARCHAR(500)              -- include path, (and range if XL)
   ,@range        VARCHAR(100)              -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@table        VARCHAR(60)               -- existing table
   ,@clr_first    BIT            = 1         -- if 1 then delete the table contets first
   ,@fields       VARCHAR(4000)  = NULL      -- comma separated list
   ,@expect_rows  BIT            = 1
   ,@row_cnt      INT            = NULL  OUT -- optional rowcount of imported rows
   ,@start_row    INT            = NULL
   ,@end_row      INT            = NULL
)
AS
BEGIN
   DECLARE 
    @fn           VARCHAR(35)   = N'sp_import_XL_existing'
   ,@cmd          VARCHAR(4000)

   EXEC sp_log 1, @fn,'005: starting
import_file:[', @import_file,']
range      :[', @range      ,']
table      :[', @table      ,']
clr_first  :[', @clr_first  ,']
fields     :[', @fields     ,']
expect_rows:[', @expect_rows,']
start_row  :[', @start_row  ,']
end_row    :[', @end_row    ,']'
;

   ----------------------------------------------------------------------------------
   -- Process
   ----------------------------------------------------------------------------------
   BEGIN TRY
      IF @clr_first = 1
      BEGIN
         EXEC sp_log 1, @fn,'010: clearing data from table';
         SET @cmd = CONCAT('DELETE FROM [', @table,']');
         EXEC( @cmd)
      END
      EXEC sp_log 1, @fn,'007';

      IF @fields IS NULL
      BEGIN
         EXEC sp_log 1, @fn,'010: getting fields from XL hdr';
         IF @fields IS NULL 
            EXEC sp_get_flds_frm_hdr_xl @import_file, @fields OUT, @range; -- , @range
      END

      EXEC sp_log 1, @fn,'015: importing data';
      SET @cmd = dbo.fnCrtOpenRowsetSqlForXlsx(@table, @fields, @import_file, @range, 0);
      EXEC sp_log 1, @fn, '020 open rowset sql:
', @cmd;

      EXEC( @cmd);
      SET @row_cnt = @@rowcount;
      EXEC sp_log 1, @fn, '22: imported ', @row_cnt,' rows';

      ----------------------------------------------------------------------------------
      -- Check post conditions
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'025: Checking post conditions';
      IF @expect_rows = 1 EXEC sp_assert_gtr_than @row_cnt, 0, 'expected some rows to be imported';--, @fn=@fn;

      ----------------------------------------------------------------------------------
      -- Processing complete
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '950: processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      EXEC sp_log 4, @fn, '510:';
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving OK, imported ', @row_cnt,' rows';
END
/*
EXEC tSQLt.Run 'test.test_010_sp_import_TypeStaging';
*/


GO
