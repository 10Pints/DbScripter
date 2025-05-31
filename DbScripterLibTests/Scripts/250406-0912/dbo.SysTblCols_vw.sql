SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--===========================================================
-- Author:      Terry watts
-- Create date: 13-NOV-2024
-- Description: lists table column details
-- ===========================================================
ALTER   VIEW [dbo].[SysTblCols_vw]
AS
SELECT
    TABLE_SCHEMA     AS schema_nm
   ,TABLE_NAME       AS table_nm
   ,table_ty 
   ,COLUMN_NAME      AS col_nm
   ,ORDINAL_POSITION AS ordinal
   ,iif(is_nullable ='YES', 1, 0) AS is_nullable
   ,dbo.fnGetFullTypeName(DATA_TYPE, CHARACTER_MAXIMUM_LENGTH) as data_ty
   ,dbo.fnIsTextType(DATA_TYPE) as is_char_ty
   ,iif(CHARACTER_MAXIMUM_LENGTH = -1, 4000, CHARACTER_MAXIMUM_LENGTH) as col_len
   ,CHARACTER_SET_NAME
   ,COLLATION_NAME
FROM INFORMATION_SCHEMA.COLUMNS c JOIN SysTblView_vw t ON c.TABLE_SCHEMA = t.schema_nm AND c.TABLE_NAME = t.table_nm
WHERE TABLE_SCHEMA IN ('dbo','test')
;
/*
SELECT * FROM SysTblCols_vw WHERE table_nm = 'gafgroupStaging'
*/


GO
