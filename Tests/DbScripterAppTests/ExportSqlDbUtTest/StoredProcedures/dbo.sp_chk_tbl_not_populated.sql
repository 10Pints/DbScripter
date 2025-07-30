SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================
-- Author:      Terry Watts
-- Create Date: 05-FEB-2024
-- Description: Checks that the given table does not have any rows
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_chk_tbl_not_populated]
    @table        NVARCHAR(60)
AS
BEGIN
   DECLARE 
       @fn        NVARCHAR(35)   = N'sp_chk_tbl_populated'
      ,@sql       NVARCHAR(MAX)
      ,@act_cnt   INT = -1
      ,@msg       NVARCHAR(200);
   SET NOCOUNT ON;
   SET  @sql = CONCAT('SELECT @act_cnt = COUNT(*) FROM ', @table);
   PRINT CONCAT('@sql: ', @sql);
   EXEC sp_executesql @sql, N'@act_cnt INT OUT', @act_cnt OUT
   -- PRINT CONCAT('@act_cnt: ', @act_cnt);
   IF @act_cnt <> 0
   BEGIN
      BEGIN
         SET @msg = CONCAT('Table: ', @table, ' has ',@act_cnt, ' rows when it is expected to have none');
         THROW 56689, @msg, 1;
      END
   END
END
/*
EXEC tSQLt.Run test.test_sp_chk_tbl_not_populated';
TRUNCATE TABLE AppLog;
EXEC dbo.sp_chk_tbl_not_populated 'AppLog'; -- ok no rows
EXEC sp_log 2, 'test fn', 'test msg'
EXEC dbo.sp_chk_tbl_not_populated 'AppLog'; -- Table: AppLog has 1 rows when it is expected to have none
*/
GO

