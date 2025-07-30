SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:      Terry Watts
-- Create date: 01-MAY-2024
-- Description: Gets the rtn dependencies of @qrn
-- ===============================================
CREATE FUNCTION [dbo].[fnSysGetDependenciesRecursive]
(
    @schema_nm NVARCHAR(32)
   ,@rtn_nm    NVARCHAR(60)
)
RETURNS 
@t TABLE 
(
    n                INT
   ,child_schema_nm  NVARCHAR(32)
   ,child_rtn_nm     NVARCHAR(60)
   ,parent_schema    NVARCHAR(32)
   ,parent_rtn       NVARCHAR(60)
)
AS
BEGIN
   WITH cte AS
   (
      SELECT
          1 AS n
         ,child_schema_nm
         ,child_rtn_nm
         ,parent_schema
         ,parent_rtn
         FROM dbo.fnSysGetParentDependencies(@schema_nm, @rtn_nm)
      UNION ALL
      SELECT n+1, x.parent_schema, X.parent_rtn, X.child_schema_nm, X.child_rtn_nm
      FROM cte cross apply dbo.fnSysGetParentDependencies(cte.parent_schema, cte.parent_rtn) X
   WHERE n<95
   )
   INSERT INTO @t (n, child_schema_nm, child_rtn_nm, parent_schema, parent_rtn) 
   SELECT n, child_schema_nm, child_rtn_nm, parent_schema, parent_rtn
   FROM cte
   ;
   RETURN
END
/*
  SELECT * FROM dbo.fnSysGetParentDependencies('dbo','fnGetFnOutputCols');
  SELECT * FROM dbo.fnSysGetDependenciesRecursive('dbo','fnGetFnOutputCols');
  SELECT * FROM dbo.fnSysGetDependenciesRecursive('dbo','fnGetFnOutputCols') 
  WHERE dep_schema='test' AND dep_rtn LIKE 'hlpr_%';
*/
GO

