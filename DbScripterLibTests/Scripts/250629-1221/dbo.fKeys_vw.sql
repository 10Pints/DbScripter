SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================================
-- Author:       Terry Watts
-- Create date:  12-OCT-2023
-- Description:  Lists the table FKs - both tables
--  N.B.: only suitable for single field keys in the relationship
--  if more than 1 field in the key then it will return a row for each field
--  in which case use select distinct or string_agg
-- ============================================================================
CREATE   VIEW [dbo].[fKeys_vw] AS
SELECT TOP 10000 
    fk.name                   AS fk_nm
   ,ft.name                   AS foreign_table_nm
   ,pt.name                   AS primary_tbl_nm
   ,so.name                   AS schema_nm
   ,cu.COLUMN_NAME            AS fk_col_nm
   ,cupt.column_name          AS pk_col_nm
   ,r. UNIQUE_CONSTRAINT_NAME AS unique_constraint_name
   ,cu.ORDINAL_POSITION       AS ordinal
FROM [sys].[foreign_keys] fk 
join sys.objects o ON fk.object_id=o.object_id
join sys.foreign_key_columns c on c.constraint_object_id=fk.object_id
join sys.objects pt ON pt.object_id=c.referenced_object_id
join sys.schemas so ON so.schema_id=pt.schema_id
join sys.objects ft ON ft.object_id=c.parent_object_id
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE cu ON fk.name=cu.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS r ON r.CONSTRAINT_NAME = fk.name
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE cupt ON cupt.CONSTRAINT_NAME=r.CONSTRAINT_NAME
ORDER BY foreign_table_nm, fk_nm, cu.ordinal_position
;
/*
SELECT * FROM fKeys_vw 
WHERE primary_tbl_nm = 'Chemical'
SELECT CONSTRAINT_NAME, UNIQUE_CONSTRAINT_NAME FROM [INFORMATION_SCHEMA].[REFERENTIAL_CONSTRAINTS]

SELECT column_name FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE constraint_name='PK_CHEMICAL'
*/


GO
