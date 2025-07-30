SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:      Terry Watts
-- Create date: 25-FEB-2024
-- Description: Creates the SQL to buk import a tsv file
-- ================================================================
CREATE FUNCTION [dbo].[fnCrtBulkImportSqlForTsv]
(
    @table     NVARCHAR(60)
   ,@tsv_file  NVARCHAR(60)
   ,@view      NVARCHAR(120)
)
RETURNS INT
AS
BEGIN
   -- Declare the return variable here
   DECLARE
    @cmd        NVARCHAR(MAX)
   SET @cmd = CONCAT(
      'BULK INSERT [',@view,'] FROM ''', @tsv_file, '''
      WITH
      (
         FIRSTROW        = 2
        ,ERRORFILE       = ''D:\Logs',NCHAR(92),@table,'Import.log''
        ,FIELDTERMINATOR = ''\t''
        ,ROWTERMINATOR   = ''\n''   
      );
   ');
   RETURN @cmd;
END
GO

