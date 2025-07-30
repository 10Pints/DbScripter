SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--===========================================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine details
--
---------------------------------------------
-- ty_code key:
---------------------------------------------
-- AF Aggregate function (CLR)
-- C  Check constraint
-- D  Default (constraint or stand-alone)
-- EC Edge constraint
-- ET External table
-- F  Foreign key constraint
-- FN SQL_SCALAR_FUNCTION
-- FS CLR_SCALAR_FUNCTION
-- FT CLR_TABLE_VALUED_FUNCTION
-- IF SQL_INLINE_TABLE_VALUED_FUNCTION
-- IT Internal table
-- P  SQL_STORED_PROCEDURE
-- PC CLR_STORED_PROCEDURE
-- PG Plan guide
-- PK Primary key constraint
-- R  Rule (old-style, stand-alone)
-- RF Replication-filter-procedure
-- S  System base table
-- SN Synonym
-- SO Sequence object
-- SQ Service queue
-- ST Statistics tree
-- TA Assembly (CLR) DML trigger
-- TF SQL table-valued-function (TVF)
-- TR SQL DML trigger
-- TT Table type
-- U  Table (user-defined)-- TF SQL_TABLE_VALUED_FUNCTION
-- UQ unique constraint
-- V  VIEW
-- X  Extended stored procedure
-- ===========================================================
CREATE VIEW [dbo].[list_recent_rtns_vw]
AS
SELECT 
    SCHEMA_NAME([schema_id])                       AS schema_nm
   ,[name]                                         AS rtn_nm
   ,IIF(dbo.fnTrim([type]) IN ('P','PC'), 'P'
     ,IIF(dbo.fnTrim([type]) IN ('FN', 'FS', 'IF','TF'), 'F'
     , IIF(dbo.fnTrim([type]) = 'V', 'V', 'X')))   AS rtn_ty   -- X means other type not F,P,V
   ,dbo.fnTrim([type])                             AS ty_code
   ,[type_desc]                                    AS ty_nm
   ,IIF(dbo.fnTrim([type]) IN ('FS','FT','PC'),1,0)            AS is_clr
   ,is_ms_shipped
   ,DATEFROMPARTS(YEAR(create_date), MONTH(create_date), Day(create_date)) AS created
   ,DATEFROMPARTS(YEAR(modify_date), MONTH(modify_date), Day(modify_date)) AS modified
FROM sys.objects
    WHERE
     [type] IN ('P', 'FN', 'TF', 'IF', 'AF', 'FT', 'IS', 'PC', 'FS', 'V')
   AND SCHEMA_NAME([schema_id]) IN ('dbo', 'test', 'FT', 'IS', 'PC', 'FS')
/*
SELECT TOP 1000 * 
FROM dbo.list_recent_rtns_vw
WHERE rtn_ty = 'X'
order by ty_code;
WHERE ty_code IN ('AF', 'IF',  'FT', 'IS', 'PC', 'FS');
*/
GO

