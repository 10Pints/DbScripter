SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--===========================================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine definitions in rows 
-- overcoming the 4000 char limit of dbo.SysRoutinesView
-- or any method based on INFORMATION_SCHEMA.ROUTINES
-- ===========================================================
CREATE VIEW [dbo].[SysRtns2_vw]
AS
SELECT
    ss.name          AS schema_nm
   ,so.name          AS rtn_nm
   ,[type]           AS ty_code
   ,[type_desc]      AS ty_nm
   ,so.create_date   AS created
   ,so.modify_date   AS modified
   ,sc.colid         AS seq
   ,LEN(sc.text)     AS len
   ,sc.text          AS def
FROM   sys.objects      AS so INNER JOIN
       sys.schemas      AS ss ON so.schema_id = ss.schema_id INNER JOIN
       sys.syscomments  AS sc ON so.object_id = sc.id
/*
SELECT TOP 500 * FROM dbo.SysRtns_vw  WHERE rtn_nm = 'fnGetRtnDef'
SELECT TOP 500 * FROM dbo.SysRtns2_vw WHERE rtn_nm = 'fnGetRtnDef'
*/
GO

