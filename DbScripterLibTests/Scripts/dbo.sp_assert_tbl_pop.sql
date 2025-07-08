SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================================
-- Author:      Terry Watts
-- Create Date: 06-AUG-2023
-- Description: Checks that the given table is populated    or not
-- Normal mode: this checks to see if the table has atleast 1 row
--
-- However it can be use to Checks that the given table is NOT populated
-- by setting @exp_cnt to 0
--
-- Called by sp_chk_tbl_not_pop
-- ======================================================================
CREATE PROCEDURE [dbo].[sp_assert_tbl_pop]
    @table        VARCHAR(60)
   ,@msg          VARCHAR(MAX)  = NULL
   ,@display_msgs BIT           = 0
   ,@exp_cnt      INT           = NULL
   ,@ex_num       INT           = 56687
   ,@ex_msg       VARCHAR(500)  = NULL
   ,@fn           VARCHAR(35)   = N'*'
   ,@log_level INT              = 0
AS
BEGIN
   DECLARE 
    @fnThis       VARCHAR(35)   = N'sp_assert_tbl_pop'
   ,@sql          NVARCHAR(MAX)
   ,@act_cnt      INT           = -1
   ,@schema_nm    VARCHAR(50)
   ;

   SET NOCOUNT ON;

   SELECT 
       @table     = rtn_nm 
      ,@schema_nm = schema_nm
   FROM dbo.fnSplitQualifiedName(@table)
   ;

   SET @sql = CONCAT('SELECT @act_cnt = COUNT(*) FROM [', @schema_nm, '].[', @table, ']');
   EXEC sp_executesql @sql, N'@act_cnt INT OUT', @act_cnt OUT

   --IF @display_msgs = 1
   --BEGIN
   EXEC sp_log 1, @fnThis, @msg, ' table:[', @table, '] has ', @act_cnt, ' rows';
   --END

   IF @exp_cnt IS NOT null
   BEGIN
      IF @exp_cnt <> @act_cnt
      BEGIN
         IF @ex_msg IS NULL
            SET @ex_msg = CONCAT('Table: ', @table, ' row count: exp ',@exp_cnt,'  act:', @act_cnt);

         EXEC sp_log 4, @fnThis ,'040: @exp_cnt (', @exp_cnt, ')<> @act_cnt (', @act_cnt, ') raising exception: ',@ex_msg;
         EXEC sp_raise_exception @ex_num, @ex_msg, 1, @fn=@fn;
      END
   END
   ELSE
   BEGIN -- Check at least 1 row
      IF @act_cnt = 0
      BEGIN
         IF @ex_msg IS NULL
            SET @ex_msg = CONCAT('Table: ', @table, ' does not have any rows');

         EXEC sp_log 4, '070: table ',@table,' has no rows: ', @ex_msg;
         THROW @ex_num, @ex_msg, 1;
      END
   END
END
/*
   -- This should not create an exception as dummytable has rows
   EXEC dbo.sp_assert_tbl_po 'use'
   EXEC dbo.sp_assert_tbl_po 'dummytable'
   
   -- This should create the following exception:
   -- Msg 56687, Level 16, State 1, Procedure dbo.sp_assert_tbl_po, Line 27 [Batch Start Line 37]
   -- Table: [AppLog] does not have any rows
    
   EXEC dbo.sp_assert_tbl_po 'AppLog'
   IF EXISTS (SELECT 1 FROM [dummytable]) PRINT '1' ELSE PRINT '0'
*/

GO
