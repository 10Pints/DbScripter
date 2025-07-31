SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Author:      Terry Watts
-- Create date: 14-JAN-2023
-- Description: helper procedure for sp_bulk_insert tests
-- ==========================================================
CREATE PROCEDURE [test].[hlpr_037_sp_import_csv]
    @tst_num      NVARCHAR(50)
   ,@csv_file     NVARCHAR(500)  -- file name only expect if folder D:\Dev\Repos\Ut\Tests\
   ,@table_spec   NVARCHAR(50)
   ,@view_spec    NVARCHAR(50)
   ,@format_file  NVARCHAR(500)
   ,@exp_row_cnt  INT           = NULL
AS
BEGIN
   DECLARE
        @fn                NVARCHAR(30)  = N'hlpr_037_sp_import_csv'
       ,@msg               NVARCHAR(200)
       ,@act_row_cnt       INT
       ,@tst_dir           NVARCHAR(1000) = N'D:\Dev\Repos\Ut\Tests' + NCHAR(92) -- backslash
       ,@csv_file_path     NVARCHAR(1000)
       ,@format_file_path  NVARCHAR(1000)
   EXEC ut.test.sp_tst_hlpr_st @fn, @tst_num;
   SET @csv_file_path    = CONCAT(@tst_dir, @csv_file)
   SET @format_file_path = CONCAT(@tst_dir, @format_file)
   EXEC sp_log 1, @fn, '005: calling sp_bulk_insert_csv...';
   -- Call tested routine
   EXEC @act_row_cnt = dbo.sp_import_csv 
       @csv_file   = @csv_file_path
      ,@table_spec = @table_spec
      ,@view_spec  = @view_spec
      ,@format_file= @format_file_path
   EXEC sp_log 1, @fn, '010: ret frm sp_bulk_insert_csv...';
   -- Perform tests
   EXEC sp_log 1, @fn, '015: running tests.';
   IF @exp_row_cnt IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt, @act_row_cnt, @tst_num
   EXEC sp_log 0, @fn, '999: leaving test passed';
END
/*
EXEC tSQLt.Run 'test.test_037_sp_import_csv'
*/
GO

