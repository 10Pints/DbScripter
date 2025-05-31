SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 04-NOV-2023
-- Description:  lists the dbo views names and create/modify dates
--
-- CHANGES:
-- ==============================================================================
ALTER   VIEW [dbo].[list_objects_vw]
AS
SELECT TOP (1000) 
       [name]
      ,[type]
      ,[type_desc]
      ,[create_date]
      ,[modify_date]
    ,[is_ms_shipped]
  FROM sys.objects
  WHERE  [schema_id] =1
  AND [type] IN ('F','FN','IF','P','PK','TF','TR','U','UQ','V')
  ORDER BY [type],[name];

/*
SELECT CONCAT('SELECT TOP 20 ''',name,''' AS ',name,', * FROM ', name ) FROM list_objects_vw WHERE [type]='U' AND name LIKE '%221008'
SELECT CONCAT('SELECT COUNT(*) FROM [',name, '];')  FROM list_objects_vw WHERE [type]='U' AND name NOT like '%221008%' AND name NOT like '%staging%'
AND name NOT IN ('JapChemical','sysdiagrams');

*/


GO
