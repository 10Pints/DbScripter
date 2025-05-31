SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================================
-- Author:      Terry Watts
-- Create date: 06-NOV-2023
-- Description: lists the columns for the tables
-- =============================================================
ALTER VIEW [dbo].[list_table_columns_vw]
AS
SELECT TOP 10000 
    TABLE_SCHEMA
   ,TABLE_NAME
   ,COLUMN_NAME
   ,ORDINAL_POSITION
   ,DATA_TYPE
   ,CHARACTER_MAXIMUM_LENGTH
   ,isc.COLLATION_NAME
   ,is_computed
   ,so.[object_id] AS table_oid
   ,so.[type_desc]
   ,so.[type]
FROM [INFORMATION_SCHEMA].[COLUMNS] isc
JOIN sys.objects     so ON so.[name]        = isc.TABLE_NAME
JOIN sys.all_columns sac ON sac.[object_id] =  so.[object_id] AND sac.[name]=isc.column_name
ORDER BY TABLE_NAME, ORDINAL_POSITION;
/*
SELECT *FROM list_table_columns_vw;
*/

GO
