SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================
-- Author:      Terry Watts
-- Create date: 12-NOV-2023
-- Description: returns the type name from the type code
--e.g. sysobjects xtype code 
-- ======================================================
CREATE FUNCTION [dbo].[fnGetTyCodeFrmTyNm]
(
   @ty_name NVARCHAR(30)
)
RETURNS NVARCHAR(2)
AS
BEGIN
   RETURN
   (
      CASE 
         WHEN @ty_name = 'CLR aggregate function' THEN 'AF' 
         WHEN @ty_name = 'CHECK constraint'       THEN 'C'  
         WHEN @ty_name = 'DEFAULT'                THEN 'D'  
         WHEN @ty_name = 'Edge constraint'        THEN 'EC' 
         WHEN @ty_name = 'External table'         THEN 'ET' 
         WHEN @ty_name = 'Foreign key'            THEN 'F'  
         WHEN @ty_name = 'Scalar function'        THEN 'FN' 
         WHEN @ty_name = 'CLR scalar function'    THEN 'FS' 
         WHEN @ty_name = 'CLR table function'     THEN 'FT' 
         WHEN @ty_name = 'Inline table function'  THEN 'IF' 
         WHEN @ty_name = 'Intrnal table'          THEN 'IT' 
         WHEN @ty_name = 'Procedure'              THEN 'P'  
         WHEN @ty_name = 'CLR procedure'          THEN 'PC' 
         WHEN @ty_name = 'Plan guide'             THEN 'PG' 
         WHEN @ty_name = 'Procedure'              THEN 'P'  
         WHEN @ty_name = 'Primary key'            THEN 'PK' 
         WHEN @ty_name = 'Rule'                   THEN 'R'  
         WHEN @ty_name = 'Repl fltr proc'         THEN 'RF' 
         WHEN @ty_name = 'Sys base table'         THEN 'S'  
         WHEN @ty_name = 'Synonym'                THEN 'SN' 
         WHEN @ty_name = 'Sequence object'        THEN 'SO' 
         WHEN @ty_name = 'Service queue'          THEN 'SQ' 
         WHEN @ty_name = 'CLR DML trigger'        THEN 'TA' 
         WHEN @ty_name = 'Table function'         THEN 'TF' 
         WHEN @ty_name = 'SQL DML trigger'        THEN 'TR' 
         WHEN @ty_name = 'Table type'             THEN 'TT' 
         WHEN @ty_name = 'Table'                  THEN 'U'  
         WHEN @ty_name = 'Unique Key'             THEN 'UQ' 
         WHEN @ty_name = 'View'                   THEN 'V'  
         WHEN @ty_name = 'Extended procedure'     THEN 'X'  
         ELSE '???'
      END
   );
END
/*
PRINT dbo.fnGetTyNmFrmTyCode('TF')
EXEC test.sp_crt_tst_rtns 'dbo.fnGetTyCodeFrmTyNm', 59, 'C'
*/
GO

