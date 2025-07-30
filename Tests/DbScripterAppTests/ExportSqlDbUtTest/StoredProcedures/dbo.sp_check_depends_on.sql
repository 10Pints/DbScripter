SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2019
-- Description: Checks if an object depends on another object
-- =============================================
CREATE PROCEDURE [dbo].[sp_check_depends_on]
     @parent        NVARCHAR(100)
   ,@child         NVARCHAR(100)
AS
BEGIN
   DECLARE
             @res   INT
         ,@sql   NVARCHAR(MAX)
   --IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='tmptble' AND xtype='U')  
   CREATE TABLE #tmptble
   (
         [NAME]     NVARCHAR(100)
      ,[TYPE]     NVARCHAR(100)
   )
   --DELETE FROM #tmptble;
   SET @sql = CONCAT('INSERT INTO #tmptble EXEC [dbo].[sp_they_depend_on_me] ''', @parent, '''')
   PRINT @sql;
   EXEC sp_executesql @sql
   SELECT * FROM #tmptble WHERE [name] = @child
   SELECT @res = CASE WHEN
   EXISTS
   (
      SELECT 1 FROM #tmptble
      WHERE [name] = @child
   ) THEN 1
   ELSE 0
   END;
   RETURN @res
END
/*
EXEC sp_depends 'dbo.REgion'
SELECT * FROM DM_SQL_REFERENCED_ENTITIES
SELECT referencing_schema_name, referencing_entity_name,
referencing_id, referencing_class_desc, is_caller_dependent
FROM sys.dm_sql_referencing_entities ('YourObject', 'OBJECT');
EXEC sp_helptext 'sys.dm_sql_referenced_entities'
SELECT * FROM sys.dm_sql_referenced_entities('dbo.PersonView', N'OBJECT') WHERE referenced_minor_name IS NULL
DECLARE @rc INT
EXEC @rc = [sp_check_depends_on] 'Region', 'RegionView'
PRINT @rc
EXEC [sp_check_depends_on] 'City'
EXEC sp_they_depend_on_me 'Region'
DECLARE @objid INT = 776389835
select @objid = object_id('sp_export_type')  
PRINT @objid
*/
GO

