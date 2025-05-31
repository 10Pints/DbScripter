SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 08-FEB-2020
-- Description: returns true (1) if table exists else false (0)
-- Parameters:
--    @table_spec <db>.<schema>.<table>
--
-- Returns 1 if exists, 0 otherwuse
-- db default is DB_NAME()
-- schema default is dbo
-- =============================================
ALTER   PROCEDURE [dbo].[sp_table_exists]
       @table_spec   VARCHAR(60)
AS
BEGIN
   DECLARE
       @db        VARCHAR(20)   = DB_NAME()
      ,@schema    VARCHAR(20)   = 'dbo'
      ,@table     VARCHAR(60)
      ,@sql       VARCHAR(200)
      ,@n         INT
      ,@exists    BIT

   SET @table_spec = REVERSE(@table_spec);
   -- expect table name
   SET @n          = CHARINDEX( '.', @table_spec);
   SET @table      = REVERSE(iif(@n > 0, LEFT(@table_spec, @n-1), @table_spec));

   IF @n > 0
   BEGIN
      -- optional schema
      SET @table_spec = SUBSTRING(@table_spec, @n+1, LEN(@table_spec)-@n);
      SET @n          = CHARINDEX( '.', @table_spec);
      SET @schema     = REVERSE( iif(@n>0, LEFT(@table_spec, @n-1), @table_spec))

      IF @n > 0
      BEGIN
         SET @table_spec = SUBSTRING(@table_spec, @n+1, LEN(@table_spec)-@n);
         SET @db         = iif(@n>0, REVERSE( @table_spec), DB_NAME())
      END
   END

   SET @sql = CONCAT
   (
         'SELECT @exists = CASE 
         WHEN EXISTS (SELECT 1 FROM ', @db,'.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''',@table,''' AND TABLE_SCHEMA = ''', @schema,''') 
         THEN 1 ELSE 0 END;'
   );

   --PRINT @sql
   EXEC sp_executesql @query=@sql, @params=N'@exists BIT OUT', @exists=@exists OUT
   RETURN @exists;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_036_spTableExists';
*/


GO
