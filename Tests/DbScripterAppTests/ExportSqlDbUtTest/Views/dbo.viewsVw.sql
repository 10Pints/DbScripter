SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewsVw]
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
SELECT TOP 2000 TABLE_NAME as [name], TABLE_SCHEMA as [schema] 
FROM INFORMATION_SCHEMA.VIEWS
ORDER BY TABLE_NAME;
GO

