SET ANSI_NULLS ON
GO
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
CREATE PROC [dbo].[spTableExists] @table_spec NVARCHAR(60)
AS
BEGIN
   DECLARE
       @db        NVARCHAR(60)
      ,@schema    NVARCHAR(60) = 'dbo'
      ,@table_nm  NVARCHAR(60)
      ,@sql       NVARCHAR(MAX)
      ,@dot       NVARCHAR(1) = '.'
      ,@n         INT
      ,@pos       INT -- position of current .
      ,@ret       BIT
   SET @n        = ut.dbo.fnCountOccurrences(@table_spec, @dot);
   SET @db = DB_NAME(); -- default
   PRINT CONCAT('@table_spec 1: [', @table_spec, ']  @n: ', @n);
   IF @n > 1 -- db:  ut.dbo.fnGetApp
   BEGIN
      PRINT '@n > 1: Parsing db '
      SET @pos= CHARINDEX(@dot, @table_spec);
      PRINT CONCAT('@pos 1: [', @pos, ']');
      SET @db = SUBSTRING(@table_spec, 1, @pos);
      SET @pos= CHARINDEX(@dot, @table_spec, @pos);
      PRINT CONCAT('@pos 2: [', @pos, ']');
      SET  @table_spec = SUBSTRING(@table_spec, 1, @pos);
      SET @n = @n - 1;
   END
    
   PRINT CONCAT('@table_spec 2: [', @table_spec, '] @n: ', @n);
   IF @n > 0 -- schema:  ut.dbo.fnGetApp
   BEGIN
      PRINT '@n > 0: Parsing schema '
      SET @pos      = CHARINDEX(@dot, @table_spec);
      SET @schema   = SUBSTRING(@table_spec, 1, @pos);
      SET @table_nm = SUBSTRING(@table_spec, @pos, 100);
   END
   ELSE
      SET @table_nm = @table_spec;
     
   PRINT CONCAT('@db:        [', @db,       ']', NCHAR(13)
               ,'@schema:    [', @schema,   ']', NCHAR(13)
               ,'@table_nm:  [', @table_nm, ']'
               );
   SET @sql = CONCAT(
   N'SET @ret = 
      CASE 
         WHEN EXISTS (SELECT * FROM ', @db, N'.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_nm AND TABLE_SCHEMA = @schema AND TABLE_TYPE = ''BASE TABLE'') 
         THEN 1 
         ELSE 0 
      END;');
   --PRINT @sql
   EXEC sp_executesql @sql, N'@schema NVARCHAR(60), @table_nm NVARCHAR(60), @ret INT OUTPUT',  @schema=@schema, @table_nm=@table_nm, @ret = @ret OUTPUT 
   PRINT CONCAT(@table_nm, ' EXISTS?: ', @ret);
   return @ret
END
/*
EXEC tSQLt.Run 'test.test_036_spTableExists'
*/
GO

