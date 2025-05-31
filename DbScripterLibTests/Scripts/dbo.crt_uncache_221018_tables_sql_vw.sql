SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================================
-- Author:		 Terry Watts
-- Create date: 06-NOV-2023
-- Description: Creates the SQL to uncache the test state from the 221018 cache
-- ===============================================================================
ALTER VIEW [dbo].[crt_uncache_221018_tables_sql_vw]
AS
SELECT CONCAT('INSERT INTO [',REPLACE(S.TABLE_NAME, '_221018', ''), '] (',cols,') SELECT ',cols,' FROM ', S.TABLE_NAME, ' ORDER BY [', T.COLUMN_NAME,'];') as [sql]
FROM
(
SELECT TABLE_NAME, CONCAT('[',string_agg(column_name, '], ['),']') as cols--, tcv.table_oid
FROM list_table_columns_vw tcv 
WHERE is_computed = 0 AND [type]='U'
GROUP BY TABLE_NAME
) AS S
JOIN 
(
  SELECT TABLE_NAME, column_name
  FROM list_table_columns_vw WHERE ORDINAL_POSITION = 1
) AS T ON T.TABLE_NAME = S.TABLE_NAME
WHERE  S.TABLE_NAME LIKE '%221018%'

/*
SELECT * FROM crt_uncache_221018_tables_sql_vw
*/

GO
