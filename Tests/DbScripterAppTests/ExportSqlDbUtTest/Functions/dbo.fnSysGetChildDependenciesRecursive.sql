SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 01-MAY-2024
-- Description: Gets the rtn dependencies of @qrn
-- ===============================================
CREATE FUNCTION [dbo].[fnSysGetChildDependenciesRecursive]
(
    @schema_nm NVARCHAR(32)
   ,@rtn_nm    NVARCHAR(60)
)
RETURNS 
@t TABLE 
(
    n          INT
   ,schema_nm  NVARCHAR(32)
   ,rtn_nm     NVARCHAR(60)
   ,dep_schema NVARCHAR(32)
   ,dep_rtn    NVARCHAR(60)
)
AS
BEGIN
   WITH cte AS
   (
      SELECT
          1  as n
         ,schema_nm --= schema_nm
         ,rtn_nm    --= rtn_nm
         ,dep_schema-- = dep_schema
         ,dep_rtn   -- = dep_rtn
         FROM dbo.fnSysGetParentDependencies(@schema_nm, @rtn_nm)
      UNION ALL
      SELECT n+1, x.schema_nm, X.rtn_nm, X.dep_schema, X.dep_rtn
      FROM cte cross apply dbo.fnSysGetParentDependencies(cte.dep_schema, cte.dep_rtn) X
   WHERE n<95 
   )
   INSERT INTO @t (n, schema_nm, rtn_nm, dep_schema, dep_rtn) 
   SELECT n, schema_nm, rtn_nm, dep_schema, dep_rtn 
   FROM cte
   RETURN
END
/*
  SELECT * FROM dbo.fnSysGetParentDependencies('dbo','fnGetFnOutputCols');
  SELECT * FROM dbo.fnSysGetDependenciesRecursive('dbo','fnGetFnOutputCols');
  SELECT * FROM dbo.fnSysGetDependenciesRecursive('dbo','fnGetFnOutputCols') 
  WHERE dep_schema='test' AND dep_rtn LIKE 'hlpr_%';
* /
GO
   DECLARE 
    @schema_nm NVARCHAR(32) = 'dbo'
   ,@rtn_nm    NVARCHAR(60) = 'fnGetFnOutputCols';
   WITH cte AS
   (
      SELECT
          schema_nm = schema_nm
         ,rtn_nm    = rtn_nm
         FROM dbo.fnSysGetDependencies(@schema_nm, @rtn_nm)
      UNION ALL
      SELECT x.schema_nm, X.rtn_nm
   FROM cte cross apply dbo.fnSysGetDependencies(cte.schema_nm, cte.rtn_nm) X--schema_nm, rtn_nm
   )
   SELECT * FROM cte
   GO
*/
GO

