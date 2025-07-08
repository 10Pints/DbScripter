SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--===========================================================
-- Author:      Terry watts
-- Create date: 13-NOV-2024
-- Description: lists table or view and its details
-- ===========================================================
CREATE   VIEW [dbo].[SysTblView_vw]
AS
SELECT
    TABLE_SCHEMA                                AS schema_nm
   ,TABLE_NAME                                  AS table_nm
   ,iif(TABLE_TYPE = 'VIEW', 'VIEW', 'TABLE')   AS table_ty
FROM [INFORMATION_SCHEMA].[TABLES]
WHERE TABLE_SCHEMA IN ('dbo','test')
--ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION
;
/*
   SELECT * FROM SysTblView_vw WHERE table_nm IN ('RegisteredPesticideImport_221018_vw','Action','gaflink');
   SELECT DISTINCT ty FROM SysTblView_vw;
*/


GO
