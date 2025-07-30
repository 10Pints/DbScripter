SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2024
-- Description: Excel sheet importer into an existing table
-- =========================================================
CREATE PROCEDURE [dbo].[sp_import_XL_existing]
(
    @spreadsheet  NVARCHAR(400)  -- path to xls
   ,@range        NVARCHAR(100)  -- like 'Corrections_221008$A:P' OR 'Corrections_221008$'
   ,@fields       NVARCHAR(4000) -- comma separated list
   ,@table        NVARCHAR(60)   -- new table
   ,@clr_first    BIT        = 1 -- if 1 then delete the table contets first
)
AS
BEGIN
   DECLARE @cmd NVARCHAR(4000)
   IF @clr_first = 1
   BEGIN
   SET @cmd = CONCAT('DELETE FROM [', @table,']');
   PRINT @cmd;
   EXEC( @cmd)
   END
   SET @cmd = CONCAT('INSERT INTO ', @table,' (', @fields, ')
 SELECT ',@fields,' 
FROM OPENROWSET
(
    ''Microsoft.ACE.OLEDB.12.0''
   ,''Excel 12.0;HDR=YES;Database='
   ,@spreadsheet,';''
   ,''SELECT * FROM [',@range,']''
)'
   );
   PRINT @cmd;
   EXEC( @cmd)
END
/*
EXEC sp_import_XL_existing 'D:\Dev\Repos\Farming\Data\EntryModeFixup.xlsx', 'Sheet1$', 'id, routine,search_clause,clause_1,clause_2,clause_3', 'EntryModeFixup', @clr_first=1;
select * from EntryModeFixup
*/
GO

