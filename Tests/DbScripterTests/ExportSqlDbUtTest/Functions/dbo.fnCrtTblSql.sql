SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================
-- Author:      Terry Watts
-- Create date: 13-JUN-2025
--
-- Description: 
-- creates the SQL to create a table
-- based on the input string.
-- All fields are VARCHAR(MAX)
-- Delimits the qualified @tbl_nm if necessary
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    returns creat table SQL
--
-- Tests:
-- =============================================
CREATE FUNCTION [dbo].[fnCrtTblSql]
(
    @tbl_nm VARCHAR(60)
   ,@fields VARCHAR(8000))
RETURNS VARCHAR(8000)
AS
BEGIN
   DECLARE
       @sql      VARCHAR(8000)
      ,@joiner   VARCHAR(40)=' VARCHAR(8000)
   ,'
      ,@snippet  VARCHAR(400)
      ,@NL       CHAR(2)     = CHAR(13) + CHAR(10)
      ,@tab      CHAR        = CHAR(9)
      ,@sep      CHAR        = CHAR(9)
;
   SET @sep = IIF(CHARINDEX( @tab,@fields)>0, @tab, ',');
   -- split the fields and add them as VARCHAR(8000)
SELECT @snippet =string_agg(TRIM(value), @joiner)
FROM   STRING_SPLIT(@fields, @sep);
   SET @sql =
   CONCAT
   ('CREATE TABLE ', dbo.fnDelimitIdentifier(@tbl_nm),'
(
    '
, @snippet
, ' VARCHAR(8000)', @NL
,');'
);
   RETURN @sql;
END
/*
EXEC test.test_069_fnCrtTblSql;
PRINT dbo.fnCrtTblSql('TestTable','id, name,description, location');
EXEC tSQLt.Run 'test.test_069_fnCrtTblSql';
*/
GO

