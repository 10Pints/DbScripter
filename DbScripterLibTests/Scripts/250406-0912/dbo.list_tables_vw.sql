SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================
-- Author:      Terry Watts
-- Create date: 03-DEc-2024
-- Description: lists the dbo and test tables
--
-- CHANGES:
--
-- SEE ALSO: dbo.fnListTables(@schema_nm)
-- ==============================================
ALTER   VIEW [dbo].[list_tables_vw]
AS
SELECT top 2000 
    TABLE_SCHEMA AS schema_nm
   ,TABLE_NAME   AS table_nm
FROM INFORMATION_SCHEMA.TABLES 
WHERE
    TABLE_TYPE='BASE TABLE' 
AND TABLE_SCHEMA IN('dbo', 'test')
AND TABLE_NAME NOT IN ('JapChemical','ImportCorrectionsStaging_bak','staging1_bak_221008','staging1_bak','staging1', 'staging2'
,'staging2_bak_221008', 'staging3', 'staging4', 'sysdiagrams') 
ORDER BY TABLE_SCHEMA,TABLE_NAME ASC;
/*
SELECT * FROM list_tables_vw;
*/


GO
