SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2024
-- Description: Excel sheet importer into a new table
-- ====================================================
CREATE PROCEDURE [dbo].[sp_import_XL_new]
(
    @spreadsheet_file   NVARCHAR(400)  -- path to xls
   ,@range              NVARCHAR(100)  -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@fields             NVARCHAR(4000) -- comma separated list
   ,@table              NVARCHAR(60)   -- new table
)
AS
BEGIN
   DECLARE @cmd NVARCHAR(4000)
   SET @cmd = CONCAT('DROP table if exists [', @table, ']');
   EXEC( @cmd)
   SET @cmd = dbo.fnCrtOpenRowsetSqlForXlsx(@table, @fields, @spreadsheet_file, @range, 1);
   EXEC( @cmd)
END
/*
EXEC dbo.sp_import_XL_new 'D:\Dev\Repos\Farming\Data\ForeignKeys.xlsx', 'Sheet1$', '*', 'ForeignKeys';
select * from ForeignKeys
EXEC sp_import_XL_existing 'D:\Dev\Repos\Farming\Data\ForeignKeys.xlsx', 'Sheet1$', '*', 'ForeignKeys';
/*   SET @cmd = CONCAT('SELECT ', @fields
,' INTO ',@table,'
FROM OPENROWSET
(
    ''Microsoft.ACE.OLEDB.12.0''
   ,''Excel 12.0;HDR=YES;Database='
   ,@spreadsheet_file,';''
   ,''SELECT * FROM [',@range,']''
)'
   );
   PRINT @cmd;
   */
*/
GO

