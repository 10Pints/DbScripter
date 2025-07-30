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
CREATE FUNCTION [dbo].[fnGetTyNmFrmTyCode]
(
   @ty_code NVARCHAR(2)
)
RETURNS NVARCHAR(30)
AS
BEGIN
   RETURN
   (
      CASE 
         WHEN @ty_code = 'AF' THEN 'CLR aggregate function'
         WHEN @ty_code = 'C'  THEN 'CHECK constraint'
         WHEN @ty_code = 'D'  THEN 'DEFAULT'
         WHEN @ty_code = 'EC' THEN 'Edge constraint'
         WHEN @ty_code = 'ET' THEN 'External tbl'
         WHEN @ty_code = 'F'  THEN 'Foreign key'
         WHEN @ty_code = 'FN' THEN 'Scalar function'
         WHEN @ty_code = 'FS' THEN 'CLR scalar function'
         WHEN @ty_code = 'FT' THEN 'CLR table function'
         WHEN @ty_code = 'IF' THEN 'Inline table function'
         WHEN @ty_code = 'IT' THEN 'Intrnl table'
         WHEN @ty_code = 'P'  THEN 'Procedure'
         WHEN @ty_code = 'PC' THEN 'CLR procedure'
         WHEN @ty_code = 'PG' THEN 'Plan guide'
         WHEN @ty_code = 'P'  THEN 'Procedure'
         WHEN @ty_code = 'PK' THEN 'Primary key'
         WHEN @ty_code = 'R'  THEN 'Rule'
         WHEN @ty_code = 'RF' THEN 'Repl fltr proc'
         WHEN @ty_code = 'S'  THEN 'Sys base table'
         WHEN @ty_code = 'SN' THEN 'Synonym'
         WHEN @ty_code = 'SO' THEN 'Sequence object'
         WHEN @ty_code = 'SQ' THEN 'Service queue'
         WHEN @ty_code = 'TA' THEN 'CLR DML trigger'
         WHEN @ty_code = 'TF' THEN 'Table function'
         WHEN @ty_code = 'TR' THEN 'SQL DML trigger'
         WHEN @ty_code = 'TT' THEN 'Table type'
         WHEN @ty_code = 'U'  THEN 'Table'
         WHEN @ty_code = 'UQ' THEN 'Unique Key'
         WHEN @ty_code = 'V'  THEN 'View'
         WHEN @ty_code = 'X'  THEN 'Extended procedure'
         ELSE '???'
      END
   );
END
/*
PRINT dbo.fnGetTyNmFrmTyCode('TF')
*/
GO

