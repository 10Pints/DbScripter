SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--===========================================================
-- Author:      Terry watts
-- Create date: 18-MAY-2020
-- Description: lists routine details
-- ===========================================================
CREATE VIEW [dbo].[SysRtns_vw]
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
;
/*
SELECT * FROM SysRtns_vw WHERE ty_code = 'P' AND schema_nm IN ('dbo','test')
SELECt top 500 * from sys.objects WHERE name like 'sp_%'
*/


GO
