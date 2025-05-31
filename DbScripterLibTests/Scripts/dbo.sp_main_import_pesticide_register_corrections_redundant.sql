SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================
-- Author:      Terry Watts
-- Create date: 19-JUN-2023
-- Description: The main import corrections routine 
--    for the Ph Dep Ag Pesticide register import process
--
-- PROCESS
-- 1. Clean tables and bulk insert to staging table
-- 2: do the fixup the Import_corrections_staging table
-- 3: copy this data to ImportCorrections table
-- 4: display both tables for inspection
--
-- CALLED BY: sp__main_import_Ph DepAg Registered Pesticides LRAP_All_files
-- 
-- FULL Get data and import PROCESS:
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
-- ERROR HANDLING by exception handling
--
-- PRECONDITIONS:
--    none
--
-- POSTCONDITIONS:
--    Ready to process the pesticide register import
--    Clean bulk insert to tble from file
--
-- Tests:
--
--
-- Changes:
--  231105:removed the truncate tables so we can append
--         really this needs splitting up so we can do multiple imports
-- ======================================================================
ALTER PROCEDURE [dbo].[sp_main_import_pesticide_register_corrections_redundant]
    @imprt_tsv_file   NVARCHAR(360)
AS
BEGIN
   DECLARE
       @fn NVARCHAR(35)          = N'IMPRT CORRECTNS FILE'
      ,@rc INT                   = 0 
      ,@error_msg NVARCHAR(500)  = ''

   EXEC sp_log 1, @fn, 'starting';
   EXEC sp_register_call @fn;

   EXEC sp_log 0, @fn, '2: do the fixup the Import_corrections_staging table';

   -- if error throw exception
   EXEC sp_log 1, @fn,  '3: fixing up crctns staging...';
   EXEC @rc = sp_fixup_import_corrections_staging;
   EXEC sp_log 0, @fn, 'sp_fixup_Import_corrections_staging returned ', @rc;

   -- 3: copy this data to ImportCorrections table
   EXEC sp_log 1, @fn, '4: copying staging to corections table...';
   EXEC @rc = sp_copy_corrections_staging_to_mn;
   EXEC sp_log 0, '5: sp_copy_corrections_staging_to_mn returned: ', @rc;

   EXEC sp_log 1, @fn, '99 leaving, @rc: ', @RC;
   RETURN @RC;
END
/*
EXEC sp_main_import_pesticide_register_corrections 'D:\Dev\Repos\Farming\Data\LRAP-221008 Import\ImportCorrections 221018 230816-2000.tsv.txt';
SELECT * FROM ImportCorrectionsStaging;
SELECT * FROM ImportCorrections;
SELECT id, count(id)  from staging1 group by id having count(id)> 1;
*/

GO
