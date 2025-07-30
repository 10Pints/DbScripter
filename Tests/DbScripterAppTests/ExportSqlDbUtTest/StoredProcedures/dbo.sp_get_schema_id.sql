SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 14-JUL-2020
-- Description: returns schema id if schema exists, 0 otherwise
-- =============================================================
CREATE PROCEDURE [dbo].[sp_get_schema_id]
       @db           NVARCHAR(40)
      ,@schema       NVARCHAR(20)
AS
BEGIN
   DECLARE
       @sql          NVARCHAR(4000)
      ,@schema_id    INT
   SET NOCOUNT ON;
   SET @sql = CONCAT(N'SELECT @schema_id = schema_id FROM [',@db,'].sys.schemas WHERE [name] = ''', @schema, '''');
   --PRINT @sql;
   EXEC sp_executesql @query=@sql, @params=N'@schema_id INT OUT', @schema_id=@schema_id OUT;
   IF @schema_id IS NULL SET @schema_id = 0;
   --PRINT @schema_id;
   RETURN @schema_id;
END
GO

