SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 01-AUG-2023
--
-- Description: Imports the Ph Dep Ag Pesticide register FMT: 230721 into S1
-- This imports each entire row into the staging1 table
--
-- PROCESS:
-- 1. download the Ph DepAg Registered Pesticides LRAP-221018.pdf from the Ph GovT Pha site
-- 2. exportentire pdf to Excel
-- 3. export as a tsv
-- 4.replace the singly LF line endings using notepad++:
-- 4.1:  replace ([^\r])\n  with \1
-- 4.2: save (and close) the file to the exports\tsv folder: D:\Data\Biz\Banana Farming\LRAP EXPORTS-221018\TSVs
--
-- 5: SQL Server:
-- 5.1 run EXEC [dbo].[sp_bulk_insert_Ph DepAg Registered Pesticides LRAP] 'D:\Data\Biz\Banana Farming\LRAP EXPORTS-221018\TSVs\Ph DepAg Registered Pesticides LRAP-221018 001-099.tsv'
-- 6. run [dbo].[sp_process Ph DepAg Registered Pesticides LRAP]
--
-- PRECONDITIONS:
--    rows with this version already deleted
--
-- POSTCONDITIONS:
--    CovidStaging1 staging column populated with the entire import row
--
-- Tests:
--    [test 012 sp_jh_imp_stg_1_bulk_insert]
-- ========================================================
CREATE PROCEDURE [dbo].[sp_bulk_insert_pesticide_register_221018]
    @import_file VARCHAR(360)
   ,@clr_first       BIT
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)   = N'_BLK_INSRT PEST REG 221018'
   ,@RC              INT            = -1
   EXEC sp_log 2, @fn, '000: starting
import_file:[',@import_file,']
clr_first  :[',@clr_first  ,']
';
   EXEC @RC = sp_bulk_insert_LRAP @import_tsv_file = @import_file, @view='RegisteredPesticideImport_221018_vw', @clr_first=@clr_first;--, @import_nm='221018';
   EXEC sp_log 2, @fn, '99; return OK, bulk_insert of @import_file';
   RETURN @RC;
END
/*
TRUNCATE TABLE Staging1;
EXEC sp_bulk_insert_pesticide_register_221018 'D:\Dev\Repos\Farming\Data\Ph DepAg Registered Pesticides LRAP-221018 Export\LRAP-221018 230809-0815.tsv';
*/
GO

