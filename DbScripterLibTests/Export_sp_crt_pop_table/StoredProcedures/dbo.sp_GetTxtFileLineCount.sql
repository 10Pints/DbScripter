SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Description: Gets a text file line count
-- Author:      Terry Watts
-- Create date: 11-JUL-2025
-- Design:      
-- Tests:       
-- ====================================================
CREATE PROCEDURE [dbo].[sp_GetTxtFileLineCount]
    @file_path          NVARCHAR(4000)
AS
BEGIN
   DECLARE
       @fn              VARCHAR(35) = 'sp_GetTxtFileLineCount'
      ,@cnt             INT
      ,@sql             NVARCHAR(4000)
      ,@sep             CHAR = '\0'
      ,@row_terminator  CHAR(2) = '\r\n'
   ;

   SET NOCOUNT ON;
   EXEC sp_log 1, @fn, '000: starting:
    @file_path:[', @file_path, ']';

   -- Step 1: Create a temporary table to hold the file content
   CREATE TABLE #TempFileLines (LineText NVARCHAR(MAX));

   -- Step 2: Use BULK INSERT to read the text file
   SET @sql = CONCAT('
   BULK INSERT #TempFileLines
   FROM ''', @file_path, '''
   WITH (
       ROWTERMINATOR   = ''',@row_terminator,''', 
       FIELDTERMINATOR = ''',@sep,''',
       CODEPAGE = ''65001''
   );'
   );

   EXEC (@sql);

         EXEC @cnt = sp_import_txt_file
          @table            = '#TempFileLines'
         ,@file             = @file_path
         ,@folder           = NULL
         ,@field_terminator = @sep
         ,@codepage         = 65001
         ,@first_row        = 2
 --        ,@format_file      = @format_file
 --        ,@display_table    = @display_tables
      ;

      EXEC sp_log 1, '050: raw cnt: ', @cnt;

   -- Step 3: Count the number of lines
SELECT COUNT(*) AS LineCount
FROM #TempFileLines
WHERE PATINDEX('%[A-Za-z0-9]%', REPLACE(REPLACE(LineText, CHAR(9), ''), CHAR(10), '')) > 0;

-- Debug: Inspect all rows
SELECT 
    LineText,
    LEN(LineText) AS LineLength,
    ASCII(LEFT(LineText, 1)) AS FirstCharASCII,
    ASCII(RIGHT(LineText, 1)) AS LastCharASCII
FROM #TempFileLines
WHERE PATINDEX('%[A-Za-z0-9]%', REPLACE(REPLACE(LineText, CHAR(9), ''), CHAR(10), '')) > 0
;

   -- Step 4: Clean up the temporary table
   DROP TABLE #TempFileLines;
   EXEC sp_log 1, @fn, '999: leaving @cnt: ',@cnt , ' rows';
   RETURN @cnt;
END
/*
EXEC sp_GetTxtFileLineCount 'D:\Dev\Property\Data\PropertySales.Resort.txt';
*/

GO
