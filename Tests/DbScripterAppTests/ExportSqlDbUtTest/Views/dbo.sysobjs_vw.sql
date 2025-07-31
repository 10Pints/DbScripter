SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[sysobjs_vw]
AS
-- https://social.msdn.microsoft.com/Forums/sqlserver/en-US/9d0b5f32-e413-403f-9a40-b876663132b9/how-to-tell-system-stored-procedures-from-user-stored-procedures-in-sysprocedures?forum=transactsql
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver15
-- ET = External Table
-- FN = SQL scalar function
-- FS = Assembly (CLR) scalar-function
-- FT = Assembly (CLR) table-valued function
-- IF = SQL inline table-valued function
-- P  = SQL Stored Procedure
-- PC = Assembly (CLR) stored-procedure
-- PK = PRIMARY KEY constraint
-- RF = Replication-filter-procedure
-- TF = SQL table-valued-function
-- TT = Table type
-- U  = table
-- UQ = Unique Key
-- PK = primary key
-- P  = procedure
-- V: = View
-- X  = Extended procedure
SELECT * FROM
(
SELECT
    smsp.object_id as obj_id
   ,sp.name
   ,sp.type AS ty_code
   ,dbo.fnGetTyNmFrmTyCode(sp.type) AS ty_nm
   ,CAST
    (
      CASE
         WHEN sp.is_ms_shipped = 1 THEN 1
         WHEN (
            SELECT major_id
            FROM sys.extended_properties
            WHERE
                major_id = sp.object_id
            AND minor_id = 0
            AND class    = 1
            AND [name]   = N'microsoft_database_tools_support'
           ) IS NOT NULL THEN 1
         ELSE 0
         END AS BIT
    ) AS is_sys_obj
   ,SCHEMA_NAME(sp.schema_id) AS [schema_id]
FROM
sys.all_objects                           AS sp
LEFT OUTER JOIN sys.sql_modules           AS smsp  ON smsp.object_id   = sp.object_id
LEFT OUTER JOIN sys.system_sql_modules    AS ssmsp ON ssmsp.object_id  = sp.object_id
) X
WHERE is_sys_obj=0
/*
SELECT TOP 500 * FROM sysobjs_vw -- object_id	name	ty	type	is_system_object	schema
*/
GO

