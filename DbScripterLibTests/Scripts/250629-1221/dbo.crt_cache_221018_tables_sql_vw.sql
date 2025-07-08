SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================================
-- Author:      Terry Watts
-- Create date: 06-NOV-2023
-- Description: Creates the SQL to cache the test state to the 221018 cache
-- ===============================================================================
CREATE   VIEW [dbo].[crt_cache_221018_tables_sql_vw]
AS
SELECT CONCAT('INSERT INTO [',S.TABLE_NAME, '] (',cols,') SELECT ',cols,' FROM ', REPLACE(S.TABLE_NAME, '_221018', '')) AS [sql]
FROM 
(
SELECT TABLE_NAME, CONCAT('[',string_agg(column_name, '], ['),']') as cols--, tcv.table_oid
FROM list_table_columns_vw tcv 
WHERE is_computed = 0
GROUP BY TABLE_NAME--, so.[object_id], so.[name] 
) AS S --ON S.TABLE_NAME = o.[name]
JOIN 
(
  SELECT TABLE_NAME, column_name
  FROM list_table_columns_vw WHERE ORDINAL_POSITION = 1
) AS T ON T.TABLE_NAME = S.TABLE_NAME
WHERE  S.TABLE_NAME LIKE '%221018%'
/*
SELECT * FROM crt_cache_221018_tables_sql_vw
*/


GO
