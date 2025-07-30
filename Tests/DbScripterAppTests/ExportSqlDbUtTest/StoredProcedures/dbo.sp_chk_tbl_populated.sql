SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:      Terry Watts
-- Create Date: 06-AUG-2023
-- Description: Checks that the given table has at least 1 row
-- =================================================================
CREATE PROCEDURE [dbo].[sp_chk_tbl_populated]
    @table     NVARCHAR(60)
   ,@exp_cnt   INT            = NULL
   ,@ex_num    INT            = 56687
   ,@ex_msg    NVARCHAR(100)  = NULL
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
   EXEC sp_log 1, 'table ', @table, ' has ', @act_cnt, ' rows';
   IF @exp_cnt IS NOT null AND @exp_cnt <> @act_cnt
   BEGIN
      IF @ex_msg IS NULL
         SET @ex_msg = CONCAT('Table: ', @table, ' row count: exp ',@exp_cnt,'  act:', @act_cnt);
      THROW @ex_num, @ex_msg, 1;
   END
   ELSE
   BEGIN -- check at least 1 row
      IF @act_cnt = 0
      BEGIN
         IF @ex_msg IS NULL
            SET @ex_msg = CONCAT('Table: ', @table, ' does not have any rows');
         THROW @ex_num, @ex_msg, 1;
      END
   END
END
/*
   -- This should not creaet an exception as dummytable has rows
   EXEC dbo.sp_chk_tbl_populated 'dummytable'
   
   -- This should create the following exception:
   -- Msg 56687, Level 16, State 1, Procedure dbo.sp_chk_tbl_populated, Line 27 [Batch Start Line 37]
   -- Table: [AppLog] does not have any rows
    
   EXEC dbo.sp_chk_tbl_populated 'AppLog'
   IF EXISTS (SELECT 1 FROM [dummytable]) PRINT '1' ELSE PRINT '0'
*/
GO

