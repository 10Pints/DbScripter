SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 05-OCT-2024
--
-- Description: Imports the Ph Dep Ag Pesticide register version 240502, 240910
-- to the staging table
--
-- CALLEd BY: sp__main_import_pesticide_register
--
-- PROCESS:
-- 1. download the Ph DepAg Registered Pesticides LRAP-221018 001-099.pdf from
-- 2. split it down into 100 page pdfs as is too large for conversion 
-- 2.1: by using the pro pdf editor / edit/ Organise pages/select first 100 pages/ right click /Extract  {delete after extract} and OK to R U sure U want to delete pages 1-99
-- 2.2: save: choose a different location like: Ph DepAg Registered Pesticides LRAP-221018 001-099.pdf
-- 2.3: repeat the above steps till no pages left
-- 2.2: then extracted file like Ph DepAg Registered Pesticides LRAP-221018 001-099.tsv
-- 3. export each 100 page section pdf to Excel
-- 4. use Excel to:
-- 4.1 add 2 columns at the start sht, row and populate the sheet no (int) and the row number - 1-30 for each row on the sheet
-- 4.2 export as a tsv
-- 5: replace the singly LF line endings using notepad++:
-- 5.1:  replace ([^\r])\n  with \1
-- 5.2: save (and close) the file to the exports\tsv folder: D:\Data\Biz\Banana Farming\LRAP EXPORTS-221018\TSVs
-- 6: SQL Server
-- 6.1 run EXEC [dbo].[sp_bulk_insert_Ph DepAg Registered Pesticides LRAP] 'D:\Data\Biz\Banana Farming\LRAP EXPORTS-221018\TSVs\Ph DepAg Registered Pesticides LRAP-221018 001-099.tsv'
-- 7. run [dbo].[sp_process Ph DepAg Registered Pesticides LRAP]
--
-- PRECONDITIONS:
--    rows with this version already deleted
--    the import file has an added row id column and all column single LF EOL have been removed
--
-- POSTCONDITIONS:
--    CovidStaging1 staging column populated with the entire import row
--
-- Tests:
--    
-- ==============================================================================================================================================================================
CREATE   PROCEDURE [dbo].[sp_bulk_insert_pesticide_register_240502]
     @imprt_csv_file    VARCHAR(360)
   ,@clr_first    BIT
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)   = N'BLK_INSRT PEST REG 240502'
      ,@RC        INT            = -1
      ,@import_nm VARCHAR(20)
   --SET @import_nm = dbo.fnGetSessionValueImportId();
   EXEC sp_log 2, @fn, '000: starting
imprt_csv_file:[',@imprt_csv_file, ']
clr_first     :[',@clr_first,      ']
]';
   EXEC @RC = sp_bulk_insert_LRAP @imprt_csv_file, 'RegisteredPesticideImport_230721_vw',@clr_first=@clr_first;--, @import_nm;
   EXEC sp_log 2, @fn, 'Bulk_insert of [', @imprt_csv_file, ' leaving, @RC: ', @RC;
   RETURN @RC;
END
/*-------------------------------------------------------------------------------------------
EXEC sp_reset_callRegister;
TRUNCATE TABLE staging1;
EXEC sp_bulk_insert_pesticide_register_240502 'D:\Dev\Farming\Data\LRAP-240910.txt';
SELECT * FROM staging1;
   DECLARE
       @fn              VARCHAR(35)   = N'BLK INSRT LRAP'
      ,@cmd             VARCHAR(4000)
      ,@notepad_path    VARCHAR(500) = '"C:\program Files\notepad++\notepad++.exe" '
   SET @cmd = CONCAT('''', '"C:\bin\SQL_Notepad.bat" ', ' D:\Logs\LRAPImportErrors.log.Error.Txt''');
   PRINT @cmd;
   EXEC xp_cmdshell @cmd;
EXEC xp_cmdshell '"C:\bin\SQL_Notepad.bat"  D:\Logs\LRAPImportErrors.log.Error.Txt'
-------------------------------------------------------------------------------------------
*/
GO

