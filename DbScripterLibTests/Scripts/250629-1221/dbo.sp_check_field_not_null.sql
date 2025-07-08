SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================================
-- Author:      Terry watts
-- Create date: 28-OCT-2024
-- Description: checks the field @field in table @table has no null entries
-- =========================================================================
CREATE   PROCEDURE [dbo].[sp_check_field_not_null]
    @table VARCHAR(60)
   ,@field VARCHAR(60)
AS
BEGIN
   DECLARE @sql VARCHAR(MAX)
   SET NOCOUNT ON;

   SET @sql = CONCAT('IF EXISTS (SELECT 1 FROM [', @table, '] WHERE [',@field,'] IS NULL OR [',@field,'] IS NULL) EXEC sp_raise_exception 53621,  ''', @table, '.', @field,' has a null entry;'';');
   --PRINT @sql
   EXEC( @sql);
END
/*
EXEC tSQLt.RunAll;
*/


GO
