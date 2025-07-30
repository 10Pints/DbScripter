SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:       Terry Watts
-- Create date:  05-JAN-2024
-- Description:  Lists the untested routines in dbo and test schemas
-- =================================================================
CREATE VIEW [test].[UntestedRtns_vw]
AS
   SELECT schema_nm , rtn_nm, ty_code 
   FROM dbo.fnSysRtnCfg('dbo', '%', NULL)
   WHERE rtn_nm NOT IN
      (SELECT rtn_nm FROM test.TestedRtns_vw)
   UNION ALL
   SELECT schema_nm , rtn_nm, ty_code 
   FROM dbo.fnSysRtnCfg('test', '%', NULL)
   WHERE rtn_nm NOT IN
      (SELECT rtn_nm FROM test.TestedRtns_vw)
   ;
/*
SELECT * FROM test.UntestedRtns_vw;
SELECT * FROM dbo.fnSysGetDependencies('dbo','fnGetFnOutputCols');
   SELECT TOP 1000 schema_nm, rtn_nm, ty_code
   FROM
   (
      SELECT DISTINCT a.schema_nm , a.rtn_nm, a.ty_code
      FROM dbo.fnSysRtnCfg('dbo', '%', 'P ') A
      CROSS APPLY dbo.fnSysGetDependencies(schema_nm, rtn_nm) B
      UNION ALL
      SELECT DISTINCT c.schema_nm, c.rtn_nm, c.ty_code
      FROM dbo.fnSysRtnCfg('dbo', '%', 'F%') C
      CROSS APPLY dbo.fnSysGetDependencies(schema_nm, rtn_nm) D
      UNION ALL
      SELECT DISTINCT a.schema_nm , a.rtn_nm, a.ty_code
      FROM dbo.fnSysRtnCfg('test', '%', 'P ') A
      CROSS APPLY dbo.fnSysGetDependencies(schema_nm, rtn_nm) B
      UNION ALL
      SELECT DISTINCT c.schema_nm, c.rtn_nm, c.ty_code
      FROM dbo.fnSysRtnCfg('test', '%', 'F%') C
      CROSS APPLY dbo.fnSysGetDependencies(schema_nm, rtn_nm) D
  ) X
  ORDER BY schema_nm, rtn_nm;
*/
GO

