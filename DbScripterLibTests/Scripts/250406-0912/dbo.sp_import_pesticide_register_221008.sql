SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ========================================================
-- Author:      Terry Watts
-- Create date: 19-JUN-2023
-- Description: imports all the Pesticide Register files
-- 
-- PRECONDITIONS: none
--
-- POSTCONDITIONS:
--    Ready to call the fixup routne
--
-- ERROR HANDLING by exception handling
-- ========================================================
ALTER PROCEDURE [dbo].[sp_import_pesticide_register_221008]
AS
BEGIN
   DECLARE
        @fn          VARCHAR(35)  = N'BLK_IMPRT_PEST_REG_221008'
       ,@cnt         INT
       ,@rc          INT
       ,@result_msg  VARCHAR(500)
       ,@import_root VARCHAR(500)

   exec sp_log 2, @fn, '01 starting';
   --EXEC sp_register_call @fn;
   SET @result_msg = '';
   SET @import_root = CONCAT(dbo.fnGetImportRoot(), 'Exports Ph DepAg Registered Pesticides LRAP-221018.pdf\TSVs', NCHAR(92));

   TRUNCATE TABLE dbo.staging1;
   TRUNCATE TABLE dbo.staging2;

   -- Import all files
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 001-099.tsv',@clr_first=0; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 100-199.tsv',@clr_first=0; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 200-299.tsv',@clr_first=0; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 300-399.tsv',@clr_first=0; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 400-499.tsv',@clr_first=0; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 500-599.tsv',@clr_first=0; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 600-699.tsv',@clr_first=0; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 700-799.tsv',@clr_first=0; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;
   EXEC @rc = [dbo].sp_bulk_insert_pesticide_register_221018  'Ph DepAg Registered Pesticides LRAP-221018 800-819.tsv',@clr_first=0; IF @RC <> 0 THROW 60000, '[sp_bulk_insert_pesticide_register]: unhandled error', 1;

   SELECT @cnt = count(*) from dbo.staging1;
   PRINT CONCAT('Imported ', @cnt, ' including header rows'); -- 23524 rows currently 20-JUN-2023
   exec sp_log 2, @fn, '99 leaving, ret: ', @rc;
   RETURN @RC;
END

/*
EXEC dbo.[sp_import_Ph DepAg Registered Pesticides LRAP];
SELECT COUNT(*) FROM TEMP WHERE SHT <101
SELECT book, COUNT(*) FROM TEMP GROUP BY book order by book
*/

GO
