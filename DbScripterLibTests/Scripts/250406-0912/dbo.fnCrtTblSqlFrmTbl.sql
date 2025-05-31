SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================
-- Author:      Terry Watts
-- Create date: 13-NOV-2024
-- Description: Creates the sql t create a table from an existing table
-- =====================================================================
ALTER FUNCTION [dbo].[fnCrtTblSqlFrmTbl]
(
   @qrn VARCHAR(80)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
   DECLARE
    @sql       VARCHAR(MAX)
   ,@sql2      VARCHAR(MAX)
   ,@tab       CHAR(1) = CHAR(9)
   ,@nl        CHAR(2) = CHAR(13)+CHAR(10)
   ,@nl_comma  CHAR(4) = CHAR(13)+CHAR(10)+CHAR(9)+','
   ,@max_len   INT
   ,@table     VARCHAR(80)
   ,@schema    VARCHAR(25)
   ;

   SELECT @max_len = MAX(dbo.fnlen(col_nm)) + 1 FROM dbo.fnGetCols4Tbl(@qrn)
   SELECT @sql2 = CONCAT(@tab, ' ',STRING_AGG(CONCAT(dbo.fnPadRight(col_nm, @max_len),  ' ', UPPER(data_ty)), @nl_comma)) FROM dbo.fnGetCols4Tbl(@qrn)

   SET @sql = CONCAT('CREATE TABLE ',@qrn, @nl, '(',@nl
,@sql2, @nl,')'
);

   RETURN @sql;
END
/*
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_gafgroup');

PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_gaflink');
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_gafname');
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_gaigroup');
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_gailink');
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_gainame');
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_ntxlink');
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_ntxname');
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_pflgroup');
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_pfllink');
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_pflname');
PRINT dbo.fnCrtTblSqlFrmTbl('EPPO_repco');

   SELECT
       @schema = schema_nm
      ,@table  = rtn_nm
   FROM fnSplitQualifiedName(@qrn);

   SELECT @max_len = MAX(dbo.fnLen(COLUMN_NAME)) + 18
   FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE TABLE_NAME = @table;

   SELECT @sql = string_agg(
   CONCAT
   (
      '   '
      ,iif(ordinal_position= 1, ' ',','), dbo.fnPadRight(CONCAT('MAX(dbo.fnLen([', COLUMN_NAME,']))'), @max_len), ' AS [', COLUMN_NAME, ']'
   ), @nl)
   FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @table AND TABLE_SCHEMA = @schema;

   SET @sql = CONCAT('SELECT', @nl,@sql, @nl,'FROM [',@table,'];')
*/

GO
