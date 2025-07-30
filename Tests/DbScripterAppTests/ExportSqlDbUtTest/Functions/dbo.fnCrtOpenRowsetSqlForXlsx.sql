SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: Creates the SQL to read data from an Excel file
--
-- Changes:
-- 08-MAR-2024: increased @spreadsheet_file parameter len from 60 to 500 as the file path was being truncated
-- =============================================================================================================
CREATE FUNCTION [dbo].[fnCrtOpenRowsetSqlForXlsx]
(
    @table              NVARCHAR(60)
   ,@fields             NVARCHAR(MAX)  -- comma sep field string
   ,@spreadsheet_file   NVARCHAR(500)
   ,@range              NVARCHAR(120)  -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@new                BIT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
   DECLARE
    @cmd                NVARCHAR(MAX)
   ,@nl                 NCHAR(2)=NCHAR(13)+NCHar(10);
   -- New table: select fields into table..., existing table: insert into table (fields)...
   IF @new = 1 SET @cmd = CONCAT('SELECT ', @fields, ' INTO [', @table, ']')
   ELSE        SET @cmd = CONCAT('INSERT INTO [', @table,'] (', @fields, ')', @nl,'SELECT ', @fields);
   -- Fixup the range ensure [] and $
   SET @range = ut.dbo.fnFixupXlRange(@range);
   SET @cmd = CONCAT(@cmd, '
FROM OPENROWSET
(
    ''Microsoft.ACE.OLEDB.12.0''
   ,''Excel 12.0;HDR=YES;Database='
   ,@spreadsheet_file,';''
   ,''SELECT * FROM ',@range,'''
)'
   );
   RETURN @cmd;
END
/*
PRINT dbo.fnCrtOpenRowsetSqlForXlsx(
 'ImportCorrectionsStaging'
,'id,command,search_clause,search_clause_cont,not_clause,replace_clause, case_sensitive, Latin_name, common_name, local_name, alt_names, note_clause, crops, doit, must_update, comments'
,'D:\Dev\Repos\Farming\Data\ImportCorrections 221018 230816-2000.xlsx'
,'Sheet1$:A:S'
,0
);
*/
GO

