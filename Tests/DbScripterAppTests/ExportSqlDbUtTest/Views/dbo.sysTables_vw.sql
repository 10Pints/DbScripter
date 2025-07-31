SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[sysTables_vw]
AS 
SELECT TABLE_NAME as [name] FROM INFORMATION_SCHEMA.TABLES 
WHERE [table_schema] ='dbo' 
AND table_type = 'BASE TABLE' 
AND table_name NOT LIKE '%sysdiag%'
AND table_name NOT LIKE 'tsu%'
AND table_name NOT LIKE 'tmp%'
GO

