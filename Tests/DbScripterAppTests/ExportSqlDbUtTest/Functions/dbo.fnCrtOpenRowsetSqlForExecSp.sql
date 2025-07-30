SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================
-- Author:      Terry Watts
-- Create date: 24-APR-2024
-- Description: Creates the SQL to populate a table from a stored procedure
-- example output:
/*
DROP TABLE IF EXISTS test.results;
SELECT * INTO test.results
FROM
OPENROWSET(
'SQLNCLI11',
'Server=(local)\SQLExpress;database=ut;Trusted_Connection=yes;',
'EXEC dbo.sp_grep_rtns ''dbo'', ''USER_TABLE'' '
)
SELECT * FROM test.results
*/
-- Changes:
-- =============================================================================================================
CREATE FUNCTION [dbo].[fnCrtOpenRowsetSqlForExecSp]
(
    @qtable             NVARCHAR(60)
   ,@qsp                NVARCHAR(120)
   ,@params             NVARCHAR(MAX) -- param string like ' ''A'', ''B'' ' or ' @a=''A'', @b=''B'' '
   ,@database           NVARCHAR(60)
   ,@new                BIT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
   DECLARE
    @cmd                NVARCHAR(MAX)
   ,@nl                 NCHAR(2)=NCHAR(13)+NCHar(10);
   -- New table: select fields into table..., existing table: insert into table (fields)...
--   IF @new = 1 SET @cmd = CONCAT('SELECT ', @fields, ' INTO [', @table, ']')
--   ELSE        SET @cmd = CONCAT('INSERT INTO [', @table,'] (', @fields, ')', @nl,'SELECT ', @fields);
   -- Fixup the range ensure [] and $
--   SET @range = ut.dbo.fnFixupXlRange(@range);
   IF @new = 1
   BEGIN
   SET @cmd = CONCAT
(
'DROP TABLE IF EXISTS test.results;
SELECT * INTO ', @qtable,'
FROM OPENROWSET(
''SQLNCLI11''
,''Server=(local)\SQLExpress;database=', @database, ';Trusted_Connection=yes;''
,''EXEC ', @qsp, ' ', @params, '''
);'
);
   END
   ELSE
   BEGIN
   SET @cmd = CONCAT
(
'DELETE FROM test.results;
INSERT INTO ', @qtable,'
SELECT * FROM OPENROWSET
(
''SQLNCLI11''
,''Server=(local)\SQLExpress;database=', @database, ';Trusted_Connection=yes;''
,''EXEC ', @qsp, ' ', @params, '''
);'
);
   END
   SET @cmd = CONCAT
   (
      @cmd, @nl
    ,'SELECT * FROM test.results;'
   )
   RETURN @cmd;
END
/*
DECLARE @cmd NVARCHAR(MAX)
SET @cmd = dbo.fnCrtOpenRowsetSqlForExecSp
('test.results'
, 'dbo.sp_grep_rtns'
, '@schema_filter=''''dbo'''' '
, 'ut'
, 1 -- new table
);
PRINT @cmd;
EXEC(@cmd);
SET @cmd = dbo.fnCrtOpenRowsetSqlForExecSp
('test.results'
, 'dbo.sp_grep_rtns'
, '@schema_filter=''''dbo'''' '
, 'ut'
, 0 -- existing table
);
PRINT @cmd;
EXEC(@cmd);
GO
*/
GO

