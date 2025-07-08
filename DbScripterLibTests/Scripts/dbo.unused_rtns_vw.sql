SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 05-FEB-2025
-- Description: displays the list of unused routines in dbo and test
-- ==============================================================================
CREATE VIEW [dbo].[unused_rtns_vw] AS
SELECT TOP 2000 schema_nm, rtn_nm, ty_code, ordinal
FROM
(
SELECT schema_nm, rtn_nm, ty_code, iif(ty_code='P', 1, iif(ty_code='FN', 2, iif(ty_code='TF', 3, iif(ty_code='IF', 4, 5)))) AS ordinal
FROM SysRtns_vw
WHERE NOT EXISTS (SELECT 1 FROM sys.dm_sql_referencing_entities (CONCAT(schema_nm,'.',rtn_nm), 'OBJECT'))
AND schema_nm IN ('dbo','test')
AND rtn_nm NOT IN ('fn_diagramobjects','sp_alterdiagram','sp_creatediagram','sp_dropdiagram','sp_helpdiagramdefinition','sp_helpdiagrams','sp_renamediagram','sp_upgraddiagrams')
AND rtn_nm NOT IN (SELECT rtn_nm FROM ReqUnusedRtns)
AND rtn_nm NOT LIKE 'test_%'
) X
ORDER BY ordinal,ty_code, schema_nm, rtn_nm;
/*
SELECT * FROM unused_rtns_vw where rtn_nm like '%Private_ValidateThatAllDataTypesInTableAreSupporte%';
*/

GO
