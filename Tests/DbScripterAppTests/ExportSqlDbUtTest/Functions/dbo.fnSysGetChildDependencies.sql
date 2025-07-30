SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:      Terry Watts
-- Create date: 01-MAY-2024
-- Description: Gets the rtn child dependencies of @qrn
-- =======================================================
CREATE FUNCTION [dbo].[fnSysGetChildDependencies]
(
   @qrn NVARCHAR(60)
   -- @schema_nm NVARCHAR(32)
  -- ,@rtn_nm    NVARCHAR(60)
)
RETURNS 
@t TABLE 
(
    schema_nm  NVARCHAR(32)
   ,rtn_nm     NVARCHAR(60)
   ,dep_schema NVARCHAR(32)
   ,dep_rtn    NVARCHAR(60)
)
AS
BEGIN
   DECLARE
    @schema_nm NVARCHAR(20)
   ,@rtn_nm    NVARCHAR(4000)
   SELECT
       @schema_nm = schema_nm
      ,@rtn_nm    = rtn_nm
   FROM test.fnSplitQualifiedName(@qrn);
   INSERT INTO @t(schema_nm, rtn_nm, dep_schema, dep_rtn)
   SELECT @schema_nm, @rtn_nm, referenced_schema_name, referenced_entity_name
   FROM sys.dm_sql_referenced_entities (@qrn, 'OBJECT');
   RETURN;
END
/*
  SELECT * FROM dbo.fnSysGetChildDependencies  ('test.test_086_sp_crt_tst_hlpr_script');
  SELECT * FROM sys.dm_sql_referenced_entities ('test.test_086_sp_crt_tst_hlpr_script', 'OBJECT');
*/
GO

