SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--===========================================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine details
-- ===========================================================
ALTER VIEW [dbo].[SysRtns_vw]
AS
SELECT TOP 2000
    SCHEMA_NAME([schema_id])              AS schema_nm
   ,[name]                                AS rtn_nm
   ,IIF([type] IN ('P','PC'), 'P', 'F')   AS rtn_ty
   ,dbo.fnTrim([type])                    AS ty_code
   ,[type_desc]                           AS ty_nm
   ,IIF([type] IN ('FS','FT','PC'),1,0)   AS is_clr
   ,is_ms_shipped
   ,DATEFROMPARTS(YEAR(create_date), MONTH(create_date), Day(create_date)) AS created
   ,DATEFROMPARTS(YEAR(modify_date), MONTH(modify_date), Day(modify_date)) AS modified
FROM sys.objects
    WHERE
     [type] IN ('P', 'FN', 'TF', 'IF', 'AF', 'FT', 'IS', 'PC', 'FS')
ORDER BY [schema_nm], [type], [name]
/*
SELECT TOP 500 schema_nm, rtn_nm, ty_code FROM dbo.SysRtns_vw
WHERE ty_code in('FN', 'TF','P')
ORDER BY ty_code, schema_nm, rtn_nm;

SELECT TOP 500 * FROM dbo.SysRtns2_vw;
---------------------------------------------------------------------------------------------------------------------------------
SELECT TOP 500 
   name as rtn_nm
   ,SCHEMA_NAME(schema_id) as schema_nm
   ,[type] as rtn_ty
   ,type_desc
   ,create_date
   ,modify_date
   ,is_ms_shipped
FROM sys.objects
    WHERE
     [type] IN ('P', 'FN', 'TF', 'IF', 'AF', 'FT', 'IS', 'PC', 'FS')
ORDER BY [schema_nm], [type], [name]
---------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT ty_code, ty_nm,det_ty_nm FROM  SysRtns_vw;
ty_code	ty_nm
AF	AGGREGATE_FUNCTION
FN	SQL_SCALAR_FUNCTION
FS	CLR_SCALAR_FUNCTION
FT	CLR_TABLE_VALUED_FUNCTION
IF	SQL_INLINE_TABLE_VALUED_FUNCTION
P 	SQL_STORED_PROCEDURE
PC	CLR_STORED_PROCEDURE
TF	SQL_TABLE_VALUED_FUNCTION
PRINT Db_Name();
*/

GO
