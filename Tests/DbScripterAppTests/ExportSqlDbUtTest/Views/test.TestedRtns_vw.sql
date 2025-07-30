SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================
-- Author:       Terry Watts
-- Create date:  02-MAY-2024
-- Description:  Lists the directly tested routines in the dbo schema
-- ===================================================================
CREATE VIEW [test].[TestedRtns_vw]
AS
      SELECT DISTINCT TOP 200
       a.schema_nm
      ,a.rtn_nm
      ,a.ty_code
      ,b.dep_schema
      ,b.dep_rtn
      --, b.n
      FROM 
      (
         SELECT schema_nm , rtn_nm, ty_code FROM dbo.fnSysRtnCfg('dbo', '%', NULL)
      ) A
      CROSS APPLY
      dbo.fnSysGetDependencies(schema_nm, rtn_nm) b
      WHERE A.schema_nm <> 'test'
      AND A.rtn_nm NOT IN ('sp_log','sp_log_exception')
      AND   b.dep_rtn LIKE 'hlpr_%'
      ;
/*
SELECT * FROM test.TestedRtns_vw;
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

