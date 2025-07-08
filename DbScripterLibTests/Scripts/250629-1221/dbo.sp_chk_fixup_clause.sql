SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 01-JUL-2023
-- Description: Helper fn to test a fixup
-- operation
-- =============================================
CREATE PROCEDURE [dbo].[sp_chk_fixup_clause]
    @fixup_clause VARCHAR(200)
   ,@col          VARCHAR(60) = 'pathogens'
   ,@table        VARCHAR(60) = 'staging2'
   
AS
BEGIN
   DECLARE 
       @cnt INT
      ,@msg VARCHAR(200)
      ,@sql NVARCHAR(MAX)

   SET NOCOUNT OFF;

   SET @sql = CONCAT('SELECT @cnt = COUNT(*) FROM ',@table, ' WHERE ', @col, ' LIKE ''', @fixup_clause, '''');
   PRINT CONCAT('sql: ', @sql);

   EXEC sp_executesql 
      @sql
      ,N'@cnt INT OUT'
      ,@cnt OUT;
   
   IF @cnt > 0 
   BEGIN
      SET @msg = CONCAT(' there are ', @cnt,' instances of [', @fixup_clause, '] in ', @table);
      THROW 50130, @msg, 1;
   END

   PRINT CONCAT('[',@fixup_clause, '] does not exist in ', @table);
END

GO
