SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_xyz] @qrn NVARCHAR(60)
AS
BEGIN
DECLARE 
    @schema_nm NVARCHAR(20)
   ,@rtn_nm    NVARCHAR(4000)
   SELECT
       @schema_nm = schema_nm
      ,@rtn_nm    = rtn_nm
   FROM test.fnSplitQualifiedName(@qrn);
   --INSERT INTO @t(schema_nm, rtn_nm, dep_schema, dep_rtn)
   SELECT @schema_nm, @rtn_nm, referenced_schema_name, referenced_entity_name
   FROM sys.dm_sql_referenced_entities (@qrn, 'OBJECT');
END
/*
EXEC sp_xyz 'test.test_086_sp_crt_tst_hlpr_script'
*/
GO

