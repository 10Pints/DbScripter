SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 01-JUL-2023
-- Description: deletes rows from the given table
-- where the col @col is like @delete_clause
-- =============================================
CREATE PROC [dbo].[sp_delete]
    @delete_clause   VARCHAR(500) 
   ,@col             VARCHAR(60) = 'pathogens'
   ,@table           VARCHAR(60) = 'staging2'
AS
BEGIN
   DECLARE 
       @cnt INT
      ,@msg VARCHAR(200)
      ,@sql NVARCHAR(MAX)

   SET NOCOUNT OFF;

   PRINT CONCAT('Removing ',@delete_clause,' from col:[', @col, ' table: [', @table, ']');
   SET @sql = CONCAT('DELETE FROM [', @table, '] WHERE [', @col, '] LIKE ''', @delete_clause, '''');
   PRINT @sql;

   EXEC sp_executesql 
      @sql
      ,N'@cnt INT OUT'
      ,@cnt OUT;
   
   PRINT CONCAT('Deleted ', @@ROWCOUNT, ' rows');
   EXEC sp_chk_fixup_clause @delete_clause, @col,@table;
END
/*
EXEC sp_delete '%NAME OF COMPANY%', 'company', 'staging2'
DELETE FROM [pathogens] WHERE [company] LIKE '%NAME OF COMPANY%'
*/

GO
