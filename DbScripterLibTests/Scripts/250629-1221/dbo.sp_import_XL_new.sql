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
CREATE   PROCEDURE [dbo].[sp_import_XL_new]
(
    @import_file  VARCHAR(400)        -- path to xls
   ,@range        VARCHAR(100)        -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@table        VARCHAR(60)         -- new table
   ,@fields       VARCHAR(4000) = NULL-- comma separated list
   ,@row_cnt      INT            = NULL  OUT -- optional rowcount of imported rows
   ,@expect_rows  BIT            = 1
   ,@start_row    INT            = NULL
   ,@end_row      INT            = NULL
)
AS
BEGIN
   DECLARE 
    @fn           VARCHAR(35)   = N'IMPRT_XL_NEW'
   ,@cmd          VARCHAR(4000)

   EXEC sp_log 2, @fn,'000: starting:
@import_file:[', @import_file, ']
@range      :[', @range, ']
@table      :[', @table, ']
@fields     :[', @fields, ']
@start_row  :[', @start_row,']
@end_row    :[', @end_row  ,']'
;

   SET @cmd = CONCAT('DROP table if exists [', @table, ']');
   EXEC( @cmd)

   IF @fields IS NULL EXEC sp_get_flds_frm_hdr_xl @import_file, @range, @fields OUT; -- , @range

   EXEC sp_log 2, @fn,'010: importing data';
   SET @cmd = ut.dbo.fnCrtOpenRowsetSqlForXlsx(@table, @fields, @import_file, @range, 1);
   EXEC sp_log 2, @fn,'020: import cmd:
', @cmd;
   EXEC( @cmd);

   SET @row_cnt = @@rowcount;
   IF @expect_rows = 1 EXEC sp_assert_gtr_than @row_cnt, 0, 'expected some rows to be imported';

   EXEC sp_log 2, @fn, '999: leaving OK, imported ', @row_cnt,' rows';
END
/*
EXEC dbo.sp_import_XL_new 'D:\Dev\Repos\Farming_Dev\Data\ForeignKeys.xlsx', 'Sheet1$', 'ForeignKeys';
*/


GO
