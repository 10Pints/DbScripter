SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:      Terry Watts
-- Create date: 01-MAY-2024
-- Description: Gets the rtn parent dependencies of @qrn
-- =======================================================
CREATE FUNCTION [dbo].[fnSysGetParentDependencies]
(
    @schema_nm NVARCHAR(32)
   ,@rtn_nm    NVARCHAR(60)
)
RETURNS
@t TABLE
(
    child_schema     NVARCHAR(32)
   ,child_rtn        NVARCHAR(60)
   ,parent_schema    NVARCHAR(32)
   ,parent_rtn       NVARCHAR(60)
)
AS
BEGIN
   INSERT INTO @t(child_schema, child_rtn, parent_schema, parent_rtn)
   SELECT @schema_nm, @rtn_nm, referencing_schema_name, referencing_entity_name
   FROM sys.dm_sql_referencing_entities (CONCAT(@schema_nm,'.',@rtn_nm), 'OBJECT')
   RETURN
END
/*
  SELECT * FROM dbo.fnSysGetParentDependencies('dbo','fnGetFnOutputCols');
  SELECT * FROM sys.dm_sql_referencing_entities ('dbo.fnGetFnOutputCols', 'OBJECT');
*/
GO

