SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 12-SEP-2019
-- Description: returns the sql clause to open the rowset to the set of colmns provided
--              wraps the openrowset for excel to make it easier to use
--
-- RETURNS a sql substring that can be used to open a rowset to an Excel range
--
-- R01: If @ext is not supplied then is defaulted to 'HDR=YES;IMEX=1'
-- R02: Makes sure a $ exists in the range - appending one if not to the end
-- R03: If the columns are not specified use * to get all columns
-- =============================================
CREATE FUNCTION [dbo].[fnGetOpenRowSetXL_SQL]
(
       @wrkbk     NVARCHAR(260)
      ,@range     NVARCHAR(50)   = 'Sheet1$'
      ,@xl_cols   NVARCHAR(2000) = NULL --'*'        -- select XL column names: can be *
      ,@ext       NVARCHAR(50)   = NULL       -- default: 'HDR=NO;IMEX=1'
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE
       @sql       NVARCHAR(4000)
      ,@NL        NVARCHAR(2)    = NCHAR(13) + NCHAR(10)
      -- Defaults: 
      -- @xl_cols = '*'
      if @xl_cols IS NULL SET @xl_cols = '*';
   -- Checks the file exists, returns NULL if not
   --IF dbo.fnFileExists(@wrkbk) = 0
   --  return NULL
   -- If @ext is not supplied then is defaulted to 'HDR=YES;IMEX=1'
   IF @ext IS NULL
      SET @ext = 'HDR=YES;IMEX=1'
   -- Makes sure a $ exists in the range - appending one if not to the end
   IF CHARINDEX('$', @range, 1) = 0
      SET @range = CONCAT(@range, '$');
   SET @sql = CONCAT('OPENROWSET ( ''Microsoft.ACE.OLEDB.12.0'','     ,@NL   -- OPENROWSET ( 'Microsoft.ACE.OLEDB.12.0',
      ,'''Excel 12.0;', iif(@ext IS NULL, '', CONCAT(@ext, ';')),' Database=', @wrkbk, ''',' ,@NL   -- 'Database=C:\Public\R02.xlsx',
      ,'''SELECT ', @xl_cols                                          ,@NL   -- SELECT id,   Region, Province, City, bgy, pop_2015
      ,'FROM [',@range, ']'');' );
   RETURN @sql;
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_023_fnGetXLOpenRowsetSql';
PRINT dbo.fnGetOpenRowSetXL_SQL(
 'D:\Data\Family\Terry\Jobs\Archive\Met Office\Met Office Check List.xlsx'
,'Sheet1$A1:C8'
,'Item,Status,Notes'
, 'HDR=YES;IMEX=1');
SELECT * FROM 
OPENROWSET ( 'Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;IMEX=1; Database=D:\Data\Family\Terry\Jobs\Archive\Met Office\Met Office Check List.xlsx',
'SELECT Item,Status,Notes
FROM [Sheet1$A1:C8]' );
SELECT * FROM 
OPENROWSET ( 'Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;IMEX=1; Database=D:\Data\Family\Terry\Jobs\Archive\Met Office\Met Office Check List.xlsx',
'SELECT Item,Status,Notes
FROM [Sheet1$A1:C8]' )
WHERE Item NOT IN ('Continuation Sheet','Sig Tru cpy');
SELECT Item,Status FROM 
OPENROWSET ( 'Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;IMEX=1; Database=D:\Data\Family\Terry\Jobs\Archive\Met Office\Met Office Check List.xlsx',
'SELECT Item,Status,Notes
FROM [Sheet1$A1:C8]' )
WHERE Item NOT IN ('Continuation Sheet','Sig Tru cpy');
*/
GO

