SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================
-- Author     : Terry Watts
-- Create date: 12-APR-2025
-- Description: removes double quotes an Line feeds from data
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:     EA
-- Tests:      test_018_fnCrtRemoveDoubleQuotesSql
--             test_037_sp_import_txt_file
-- ============================================================
CREATE FUNCTION [dbo].[fnCrtRemoveDoubleQuotesSql]
(
    @table              VARCHAR(60)
   ,@max_len_fld        INT
)
RETURNS VARCHAR(8000)
AS
BEGIN
   DECLARE
    @fn                 VARCHAR(35)       = N'sp_import_txt_file'
   ,@table_no_brkts     VARCHAR(60)
   ,@nl                 CHAR(2)           = CHAR(13)+CHAR(10)
   ,@sql                VARCHAR(8000)
   ,@empty_str          VARCHAR(2)=''''
   ,@double_quote       VARCHAR(5)='"'
   ;
   SET @table_no_brkts = REPLACE(REPLACE(@table, '[',''),  ']','');
   --    SELECT dbo.fnPadRight(CONCAT(''['', column_name, '']''), ', @max_len_fld+2, ') AS column_name
SET @sql = CONCAT
(
'DECLARE
    @nl             CHAR(2) = CHAR(13)+CHAR(10)
   ,@Lf             CHAR(1) = CHAR(10)
   ,@empty_str      VARCHAR(1)=''''
   ,@double_quote   VARCHAR(1)=''"''
   ,@sql            VARCHAR(8000)
;
WITH cte AS
(
   SELECT CONCAT(''['', column_name, '']'') AS column_name
      ,ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) AS row_num
      ,ordinal_position
      ,DATA_TYPE
      ,is_txt
   FROM list_table_columns_vw
   WHERE table_name = ''',@table_no_brkts, ''' AND is_txt = 1
)
,cte2 AS
(
   SELECT ''UPDATE ',@table,' SET '' AS sql
   UNION ALL
   SELECT
      CONCAT
      (  iif(row_num=1, '' '','','')
        ,column_name, '' = 
        TRIM(REPLACE(REPLACE('',column_name',','',CHAR(34),''',@empty_str,''''')
        ,CHAR(10),''',@empty_str,'''''
            )
         )''
      )
   FROM cte
   UNION ALL
   SELECT ''FROM ',@table,';''
)
SELECT @sql = 
string_agg(sql, ''', @NL, ''')
FROM cte2;'
);
   RETURN @sql;
END
/*
EXEC tSQLt.Run 'test.test_018_fnCrtRemoveDoubleQuotesSql';
EXEC tSQLt.Run 'test.test_037_sp_import_txt_file';
------------------------------------------------
DECLARE @sql VARCHAR(8000)
SELECT @sql = dbo.fnCrtRemoveDoubleQuotesSql('[User]', 12);
PRINT @sql
------------------------------------------------
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/
GO

