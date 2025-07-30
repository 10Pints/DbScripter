SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================
-- Author:      Terry Watts
-- Create date: 12-FEB-2021
-- Description: lists routines and their defintion
--   DEFAULT_CONSTRAINT
-- , SQL_SCALAR_FUNCTION, SQL_TABLE_VALUED_FUNCTION, SQL_INLINE_TABLE_VALUED_FUNCTION
-- , VIEW
-- , SQL_STORED_PROCEDURE, SQL_TRIGGER, USER_TABLE
-- =================================================
CREATE PROCEDURE [dbo].[sp_grep_rtns_with_def]
    @db_nm           NVARCHAR(60)   = NULL   --                                        default: current database
   ,@schema_filter   NVARCHAR(20)   = 'dbo'  -- comma separated list  like 'dbo.test'  default: dbol
   ,@type_filter     NVARCHAR(20)   = '%'    -- SQL_SCALAR_FUNCTION
   ,@rtn_nm_filter   NVARCHAR(99)   = '%'    --                                        default: all
   ,@top             INT            = 2000
AS
BEGIN
DECLARE
   @sql NVARCHAR(4000)
   IF @db_nm IS NULL SET @db_nm = DB_NAME();
   SET @sql = CONCAT
   (
      'SELECT TOP ', @top, '
      ''', @db_nm, '''  AS db
      ,ss.name          AS [schema]
      ,so.name          AS rtn_name
      ,so.type_desc
      ,sc.colid         AS seq
      ,LEN(sc.text)     AS ln_len
      ,so.create_date
      ,sc.text          AS def
      FROM
                  ', @db_nm, '.sys.objects      AS so 
      INNER JOIN  ', @db_nm, '.sys.schemas      AS ss ON so.schema_id = ss.schema_id
      INNER JOIN  ', @db_nm, '.sys.syscomments  AS sc ON so.object_id = sc.id
   WHERE
       ss.name       LIKE ''', @schema_filter, '''
   AND so.name       LIKE ''', @rtn_nm_filter, '''
   AND so.type_desc  LIKE ''', @type_filter  , '''
   ORDER BY db, ss.name, so.type_desc, so.name;' 
   );
   PRINT @sql;
   EXEC sp_executesql @sql;
END
/*
--   DEFAULT_CONSTRAINT
-- , SQL_SCALAR_FUNCTION, SQL_TABLE_VALUED_FUNCTION, SQL_INLINE_TABLE_VALUED_FUNCTION
-- , VIEW
-- , SQL_STORED_PROCEDURE, SQL_TRIGGER, USER_TABLE
   EXEC ut.dbo.sp_grep_rtns 
    @db_nm           = 'Covid_T1'         -- default: current database
   ,@schema_filter   = 'dbo'        -- default: dbo
   ,@type_filter     = '%PROC%' -- default: all
   ,@rtn_nm_filter   = '%'--        -- default: all
   ,@top             = 2000
*/
GO

