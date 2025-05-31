SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2024
-- Description: Excel sheet importer into a new table
-- returns the row count [optional]
-- 
-- Postconditions:
-- POST01: IF @expect_rows set then expect at least 1 row to be imported or EXCEPTION 56500 'expected some rows to be imported'
--
-- Changes:
-- 05-MAR-2024: parameter changes: made fields optional; swopped @table and @fields order
-- 08-MAR-2024: added @expect_rows parameter defult = yes(1)
-- ===========================================================================================
ALTER PROCEDURE [dbo].[sp_import_XL_new]
(
    @spreadsheet  NVARCHAR(400)        -- path to xls
   ,@range        NVARCHAR(100)        -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@table        NVARCHAR(60)         -- new table
   ,@fields       NVARCHAR(4000) = NULL-- comma separated list
   ,@row_cnt      INT            = NULL  OUT -- optional rowcount of imported rows
   ,@expect_rows  BIT            = 1
)
AS
BEGIN
   DECLARE 
    @fn           NVARCHAR(35)   = N'IMPRT_XL_NEW'
   ,@cmd          NVARCHAR(4000)

   EXEC sp_log 2, @fn,'00: starting:
@spreadsheet: ', @spreadsheet, '
@range      : ', @range, '
@table      : ', @table, '
@fields     : ', @fields
;

   SET @cmd = CONCAT('DROP table if exists [', @table, ']');
   EXEC( @cmd)

   IF @fields IS NULL EXEC sp_get_fields_from_xl_hdr @spreadsheet, @range, @fields OUT;

   EXEC sp_log 2, @fn,'10: importing data';
   SET @cmd = ut.dbo.fnCrtOpenRowsetSqlForXlsx(@table, @fields, @spreadsheet, @range, 1);
   PRINT @cmd;
   EXEC( @cmd);

   SET @row_cnt = @@rowcount;
   IF @expect_rows = 1 EXEC sp_assert_gtr_than @row_cnt, 0, 'expected some rows to be imported', @fn=@fn;

   EXEC sp_log 2, @fn, '99: leaving OK, imported ', @row_cnt,' rows';
END
/*
EXEC dbo.sp_import_XL_new 'D:\Dev\Repos\Farming_Dev\Data\ForeignKeys.xlsx', 'Sheet1$', 'ForeignKeys';
*/

GO
