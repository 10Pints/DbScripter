SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 19-JUN-2023
--
-- Description: Imports the Ph Dep Ag Pesticide register
-- staging table temp
-- This imports each entire row into the stagingcolumn
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
--
-- POSTCONDITIONS:
--    CovidStaging1 staging column populated with the entire import row
--
-- Tests:
--    [test 012 sp_jh_imp_stg_1_bulk_insert]
-- ==============================================================================================================================================================================
CREATE PROCEDURE [dbo].[sp_bulk_insert_pesticide_register_230721]
    @imprt_csv_file    VARCHAR(360)
   ,@clr_first    BIT
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)   = N'BLK_INSRT PEST REG 230721'
      ,@RC        INT            = -1
      ,@import_nm VARCHAR(20)
   --SET @import_nm = dbo.fnGetSessionValueImportId();
   EXEC sp_log 2, @fn, '000: starting
imprt_csv_file:[',@imprt_csv_file, ']
clr_first     :[',@clr_first,      ']
';
   --EXEC sp_register_call @fn;
   EXEC @RC = sp_bulk_insert_LRAP @imprt_csv_file, 'RegisteredPesticideImport_230721_vw',@clr_first=@clr_first;
   EXEC sp_log 2, @fn, 'Bulk_insert of [', @imprt_csv_file, ' leaving, @RC: ', @RC;
   RETURN @RC;
END
/*
EXEC sp_bulk_insert_pesticide_register_230721 'D:\Dev\Repos\Farming\Data\LRAP-231025-231103.txt';
*/
GO

