SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================================================
-- Author:      Terry Watts
-- Create date: 12-FEB-2024
-- Description: helper rtn to check a table does not  contain any items in the given field
--    If it does logs an error and adds to the error table
-- ============================================================================================
CREATE   PROCEDURE [dbo].[sp_chk_table_not_contains]
    @table              VARCHAR(60)
   ,@field_nm           VARCHAR(50)
   ,@operator           VARCHAR(30) -- 'LIKE', 'IN', 'IS NULL'
   ,@item_list          VARCHAR(MAX) = NULL
   ,@err_cnt_total      INT OUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn                 VARCHAR(35)   = N'CHK_TABLE_NOT_CONTAINS'
   ,@err_cnt            INT            = 0
   ,@err_msg            VARCHAR(250)  = NULL
   ,@msg                VARCHAR(250)  = NULL
   ,@sql_phrase         VARCHAR(MAX)  = NULL
   ,@sql                NVARCHAR(MAX)  = NULL
   ,@value              VARCHAR(100)  = NULL

   EXEC sp_log 2, @fn,'00: starting';

   -- Validation
   IF @operator NOT IN ('LIKE', 'IN', 'IS NULL')
   BEGIN
      SET @err_msg = CONCAT('sp_chk_table_not_contains bad operator parameter:[',@operator,']');
      THROW 71500, @err_msg, 1;
   END

      SET @sql_phrase = CONCAT( ' FROM [',@table,'] WHERE [',@field_nm,'] ');
   -- -- 'LIKE', 'IN', 'IS NULL'
   IF @operator = 'LIKE'
   BEGIN
      EXEC sp_log 2, @fn,'05: LIKE';
      SET @sql_phrase = CONCAT( @sql_phrase, 'LIKE ''%', @item_list,'%''');
   END
   ELSE IF @operator = 'IN'
   BEGIN
      EXEC sp_log 2, @fn,'10: IN';
      SET @sql_phrase = CONCAT(  @sql_phrase, 'IN (', @item_list,')');
   END
   ELSE --IF IS NULL
   BEGIN
      EXEC sp_log 2, @fn,'15: IS NULL';
      SET @sql_phrase = CONCAT( @sql_phrase, 'IS NULL');
   END

   EXEC sp_log 2, @fn,'20: ';
   SET @sql = CONCAT('SELECT @err_cnt = COUNT(*)', @sql_phrase);
   PRINT @sql;
   EXEC sp_executesql @sql, N'@err_cnt INT OUT', @err_cnt OUT;
   EXEC sp_log 2, @fn,'25: @err_cnt: ',@err_cnt;

   IF @err_cnt > 0
   BEGIN
      IF @operator = 'IS NULL'
         SET @msg = CONCAT('[', @table, '].[', @field_nm, '] has ',@err_cnt,' rows with NULL values');
      ELSE
         SET @msg = CONCAT('[', @table, '].[', @field_nm, '] has ',@err_cnt,' rows with one or more of these values: (', @item_list, ')');

      EXEC sp_log 4, @fn,'30: oops: ', @msg;
      INSERT INTO importErrors ([table],field, msg, cnt) VALUES (@table, @field_nm, @msg, @err_cnt);
      EXEC sp_log 2, @fn,'35: ';
      SET @err_cnt_total = @err_cnt_total + @err_cnt;
   END

   EXEC sp_log 2, @fn, '99: returning, count: ', @err_cnt_total;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_017_sp_chk_table_not_contains';
EXEC test.test_017_sp_chk_table_not_contains;
*/


GO
