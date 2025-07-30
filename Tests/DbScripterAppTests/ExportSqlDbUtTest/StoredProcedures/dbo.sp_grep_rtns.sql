SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================
-- Author:      Terry Watts
-- Create date: 12-FEB-2021
-- Description: lists routines
--   DEFAULT_CONSTRAINT
-- , SQL_SCALAR_FUNCTION, SQL_TABLE_VALUED_FUNCTION, SQL_INLINE_TABLE_VALUED_FUNCTION
-- , VIEW
-- , SQL_STORED_PROCEDURE, SQL_TRIGGER, USER_TABLE
-- =================================================
CREATE PROCEDURE [dbo].[sp_grep_rtns]
    @schema_filter   NVARCHAR(20)   = 'dbo'  -- comma separated list  like 'dbo.test'  default: dbol
   ,@type_filter     NVARCHAR(20)   = '%'    -- SQL_SCALAR_FUNCTION
   ,@rtn_nm_filter   NVARCHAR(99)   = '%'    --                                        default: all
AS
BEGIN
DECLARE
   @sql NVARCHAR(4000)
   IF @schema_filter IS NULL SET @schema_filter = 'dbo'
   IF @type_filter   IS NULL SET @type_filter   = '%'
   IF @rtn_nm_filter IS NULL SET @rtn_nm_filter = '%;'
   INSERT 
      INTO dbo.RtnInfo
   SELECT        so.name --as so_nm
      ,ss.name --as schema_nm
      ,object_id
      ,so.principal_id  -- AS so_principal_id
      ,ss.principal_id  -- AS ss_principal_id
      ,so.schema_id     -- AS so_schema_id
      ,parent_object_id
      ,so.[type]
      ,[type_desc]
      ,create_date
      ,modify_date
      ,is_ms_shipped
      ,is_published
      ,is_schema_published
   FROM sys.objects AS so JOIN sys.schemas AS ss ON so.schema_id = ss.schema_id
   WHERE
       ss.name       LIKE @schema_filter   OR @schema_filter IS NULL
   AND so.name       LIKE @rtn_nm_filter --OR @rtn_nm_filter IS NULL
   AND so.type_desc  LIKE @type_filter  -- OR @type_filter   IS NULL
   ORDER BY ss.name, so.name;
   SELECT * FROM RtnInfo;
END
/*
EXEC sp_grep_rtns 'dbo'
*/
GO

