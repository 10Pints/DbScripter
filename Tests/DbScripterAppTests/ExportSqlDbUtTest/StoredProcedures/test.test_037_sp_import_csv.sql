SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================
-- Author:           Terry Watts
-- Create date:      14-JAN-2023
-- Description:      tests dbo.sp_bulk_insert procedure
-- Tested rtn desc:  sp_bulk_insert procedure imports a csv to a table
--                   params: table, schema, db all in @table_spec param
-- ========================================================================
CREATE PROCEDURE [test].[test_037_sp_import_csv]
AS
BEGIN
   DECLARE
       @fn      NVARCHAR(60) = N'test_037_sp_import_csv'
   EXEC ut.test.sp_tst_mn_st @fn
   EXEC sp_log 1, @fn, '005: starting';
   EXEC test.hlpr_037_sp_import_csv
    @tst_num            = 'T001'
   ,@csv_file           = 'test_037.csv'
   ,@table_spec         = 'table'
   ,@view_spec          = NULL--'table'
   ,@format_file        = 'test_037.fmt'
   ,@exp_row_cnt        = 4001 -- rows

   EXEC sp_log 1, @fn, '010:';
   -- Edge cases:
   -- Empty table tests
   -- NULL string and token tests
   EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_037_sp_import_csv'
EXEC tSQLt.RunAll;
*/
GO

