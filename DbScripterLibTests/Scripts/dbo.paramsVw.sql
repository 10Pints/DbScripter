SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2023
-- Description: returns the parameters
-- e.g. sysobjects xtype code 
-- ======================================================
ALTER VIEW [dbo].[paramsVw]
AS 
SELECT
    OBJECT_NAME(sap.object_id)         AS rtn_nm
   ,sap.object_id                      AS rtn_id
   ,SCHEMA_NAME( schema_id)            AS schema_nm
   ,sap.name                           AS param_nm
   ,parameter_id                       AS ordinal_position
   ,TYPE_NAME(system_type_id)          AS ty_nm
   ,IIF( TYPE_NAME(system_type_id) IN ('VARCHAR', 'NVARCHAR', 'NTEXT')
      ,CONCAT( TYPE_NAME(system_type_id), '('
              ,iif
               ( system_type_id in (167, 231)
                ,iif(max_length= -1, 4000,max_length/2)
                , max_length
               )
              ,')'
             ) -- end concat
      ,TYPE_NAME(system_type_id)
      )          AS ty_nm_full
   ,system_type_id                     AS ty_id
   ,iif
    (
       system_type_id in (231)
      ,max_length/2, max_length
    ) AS ty_len
    , IIF(TYPE_NAME(system_type_id) IN ('VARCHAR', 'NVARCHAR', 'NCHAR','CHAR','NTEXT'), 1, 0) AS is_chr_ty
   ,is_output
   ,is_nullable
   ,has_default_value
   ,default_value
   ,dbo.fnGetTyNmFrmTyCode([type])     AS rtn_ty_nm
   ,[type]                             AS rtn_ty_code
FROM sys.all_parameters sap
     JOIN sys.all_objects so ON sap.object_id=so.object_id;

/*
SELECT * FROM paramsVw WHERE rtn_nm = 'fn_CamelCase';
SELECT * FROM paramsVw WHERE rtn_nm = 'sp_exprt_to_xl_val';
SELECT  * FROM paramsVw where param_nm ='' -- Scalar function, CLR scalar function return value
SELECT TOP 100 * FROM sys.all_parameters sap JOIN sys.all_objects so ON sap.object_id=so.object_id;
SELECT top 10 * FROM sys.sysobjects
*/

GO
