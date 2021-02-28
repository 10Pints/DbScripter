-- create standard stored procedures template.sql
USE [<DB_NAME>]
GO

CREATE FUNCTION [dbo].[fn_min_date]()
RETURNS datetime2
AS
BEGIN
   return CONVERT(datetime2, '0001-01-01 00:00:00.0')
END
GO

CREATE FUNCTION fn_max_date()
RETURNS datetime2
AS
BEGIN
   RETURN CONVERT(datetime2, '9999-12-31 23:59:59.9999')
END
GO

-- =============================================
-- Author:			Terry Watts
-- Create date: 18-SEP-2018
-- Description:	Lists indexes (other than the Primary keys) 
-- for 1 specific user table or all user tables
-- =============================================
CREATE PROCEDURE sp_get_indexes 
  @table_name VARCHAR(50) null,
  @index_name VARCHAR(50) null,
  @is_primary bit null, 
  @is_unique bit null  
AS
BEGIN
  SET NOCOUNT ON;

SELECT 
    table_name = t.name,
    index_name = ind.name,
    is_primary_key,
    ind.is_unique,
    ind.object_id as ndx_obj,
    t.object_id as tbl_obj,
    t.type_desc
FROM  
    sys.indexes ind INNER JOIN sys.tables t ON ind.object_id = t.object_id 
WHERE 
        ((@is_primary   = ind.is_primary_key) OR (@is_primary IS NULL)) 
    AND ((@table_name   = t.name )            OR (@table_name IS NULL))
    AND ((ind.name      = @index_name)        OR (@index_name IS NULL))
    AND ((ind.is_unique = @is_unique)         OR (@is_unique  IS NULL))
ORDER BY
     t.name, ind.name, ind.index_id;
END

GO

CREATE   FUNCTION [dbo].[fn_is_express_version]()
RETURNS bit
AS
BEGIN
RETURN CAST( CHARINDEX('Express Edition', CONVERT( VARCHAR(255),SERVERPROPERTY('Edition'))) AS bit)
END

GO

-- =============================================
-- Author:		Terry Watts
-- Create date: 25-APR-2018
-- Description:	returns the version of the schema (from the dbo.version table)
-- =============================================
CREATE   FUNCTION [dbo].[fn_get_db_version]()
RETURNS  int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar int

	-- Add the T-SQL statements to compute the return value here
	SELECT @ResultVar = [version] from [dbo].[Version]

	-- Return the result of the function
	RETURN  @ResultVar;
END

GO

-- ===================================================================================
-- Author:		Terry Watts
-- Create date: 1-DEC-2017
-- Description:	Re turns the version information like:
--------------------------------------------------------------------------------------
-- MajorVersion	ProductLevel	Edition	                    ProductVersion	Is_Express
--------------------------------------------------------------------------------------
-- SQL2016	    SP1	            Express Edition (64-bit)	13.0.4206.0		1
-- ===================================================================================
CREATE   FUNCTION [dbo].[fn_get_db_version_info]()
RETURNS TABLE
AS
RETURN
(
SELECT
   CAST(SERVERPROPERTY('ProductLevel')   AS nvarchar(128))  AS product_level
  ,CAST(SERVERPROPERTY('Edition')        AS nvarchar(128))  AS edition
  ,CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(128))  AS product_version
  ,dbo.fn_is_express_version()           AS is_express
  ,DB_NAME()                             AS [db_name]
  ,CAST(SIZE/128.0 AS INT)               AS current_size_on_Disk_mb
  ,CAST(SERVERPROPERTY('MachineName')    AS nvarchar(128))  As machine_name
  ,(
    SELECT
      CASE
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%'    THEN 'SQL2000'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%'    THEN 'SQL2005'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 'SQL2008'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 'SQL2008 R2'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%'   THEN 'SQL2012'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%'   THEN 'SQL2014'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%'   THEN 'SQL2016'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '14%'   THEN 'SQL2017'
     ELSE 'unknown'
      END
  ) AS db_version,

  CASE WHEN dbo.fn_is_express_version() = 1 THEN
  (
    SELECT
      CASE
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%'    THEN '4 GB'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%'    THEN '4 GB'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN '4 GB'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN '10 GB'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%'   THEN '10 GB'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%'   THEN '10 GB'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%'   THEN '10 GB'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '14%'   THEN '10 GB'
      ELSE 'unknown'
    END
  )
  ELSE 'UNKNOWN'
  END  AS db_size_limit

  FROM sys.database_files
  WHERE FILE_ID = 1
)

GO
-- exec sp_get_indexes @table_name = 'Property', @is_unique=1,    @is_primary = 0  -- 1 row
-- exec sp_get_indexes @table_name = 'Property', @is_unique=NULL, @is_primary=NULL -- 4 rows
-- exec sp_get_indexes @table_name = 'Property', @is_unique=NULL, @is_primary=1    -- 1 rows
-- exec sp_get_indexes @table_name = 'Property', @is_unique=1   , @is_primary=1    -- 1 rows

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			Terry Watts
-- Create date: 18-SEP-2018
-- Description:	Lists Alternative unique indexes columns (other than thePrimary keys)
-- =============================================
CREATE PROCEDURE sp_get_index_columns
  @table_name varchar(50) NULL,
  @index_name VARCHAR(50) null,
  @is_primary bit null, 
  @is_unique bit null  
AS
BEGIN
	SET NOCOUNT ON;
SELECT
    table_name				= tbl.name,
    index_name				= ind.name,
    column_name				= col.name,
    column_type_name	= t.name,
    column_type_id		= t.user_type_id,
    column_id					= ic.index_column_id,
    is_unique,
    is_primary_key

FROM
           sys.indexes        ind 
INNER JOIN sys.index_columns  ic  ON ind.object_id    = ic.object_id  and ind.index_id  = ic.index_id 
INNER JOIN sys.columns        col ON ic.object_id     = col.object_id and ic.column_id  = col.column_id 
INNER JOIN sys.types          t   ON col.user_type_id = t.user_type_id
INNER JOIN sys.tables         tbl ON ind.object_id    = tbl.object_id 
WHERE
        ((@is_primary   = ind.is_primary_key) OR (@is_primary IS NULL)) 
    AND ((tbl.name      = @table_name)        OR (@table_name IS NULL))
    AND ((ind.name      = @index_name)        OR (@index_name IS NULL))
    AND ((ind.is_unique = @is_unique)         OR (@is_unique  IS NULL))
ORDER BY 
     tbl.name, ind.name, ic.index_column_id;

END

GO

-- EXEC sp_get_index_columns @table_name='Property', @is_unique=null, @is_primary = NULL	-- 3 keys 5 rows
-- EXEC sp_get_index_columns @table_name='Property', @is_unique=null, @is_primary = 1			-- 1 keys 1 rows
-- EXEC sp_get_index_columns @table_name='Property', @is_unique=0,    @is_primary = 1			-- 0 keys 0 rows
-- EXEC sp_get_index_columns @table_name='Property', @is_unique=1,    @is_primary = 0			-- 1 key 2 rows is unique: true
-- EXEC sp_get_index_columns @table_name=NULL,			 @is_unique=null,	@is_primary = NULL	-- all indexes:  mix of primary,    unique and non unique
-- EXEC sp_get_index_columns @table_name=NULL,			 @is_unique=null, @is_primary = 0			-- all indexes:  mix of no primary, unique and non unique
-- EXEC sp_get_index_columns @table_name=NULL,			 @is_unique=null, @is_primary = 1			-- All primary keys

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_pkeys_all
(
    @table_owner     sysname = null,
    @table_qualifier sysname = null
)
as
    declare @table_id           int

    if @table_qualifier is not null
    begin
        if db_name() <> @table_qualifier
        begin   -- If qualifier doesn't match current database
            raiserror (15250, -1,-1)
            return
        end
    end

    select
        TABLE_QUALIFIER = convert(sysname,db_name()),
        TABLE_OWNER = convert(sysname,schema_name(o.schema_id)),
        TABLE_NAME = convert(sysname,o.name),
        COLUMN_NAME = convert(sysname,c.name),
        PK_NAME = convert(sysname,k.name)
    from
        sys.indexes i,
        sys.all_columns c,
        sys.all_objects o,
        sys.key_constraints k
    where
        o.object_id = c.object_id and
        o.object_id = i.object_id and
        k.parent_object_id = o.object_id and 
        k.unique_index_id = i.index_id and 
        i.is_primary_key = 1 

    order by 1, 2, 3, 5
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


