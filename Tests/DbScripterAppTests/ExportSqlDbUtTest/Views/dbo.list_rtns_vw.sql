SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================================
-- Author:      Terry Watts
-- Create date: 12-MAY-2024
-- Description: Lists the rtns and tables in the dbo,test, tSQLt schemas the drop script for the given schema
-- ====================================================================================
CREATE VIEW [dbo].[list_rtns_vw]
AS
   SELECT
       specific_schema     AS schema_nm
      ,routine_name        AS rtn_nm
      ,LOWER(routine_type) AS rtn_ty
   FROM INFORMATION_SCHEMA.ROUTINES
   WHERE specific_schema IN ('dbo','test', 'tSQLt')
   UNION ALL
   SELECT 
       table_schema AS schema_nm
      ,table_name    AS rtn_nm
      ,iif(table_type='BASE TABLE', 'table', 'view')    AS rtn_ty
   FROM INFORMATION_SCHEMA.TABLES
   ;
/*
SELECT * FROM dbo.list_rtns_vw;
*/
GO

