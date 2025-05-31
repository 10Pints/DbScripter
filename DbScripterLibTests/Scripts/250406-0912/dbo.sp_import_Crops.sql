SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================================
-- AUTHOR       Terry Watts
-- CREATE DATE: 28-JAN-2025
-- DESCRIPTION: clean imports the Crop data
-- NOTE:        imports into the staging table then does the fixup
--              and copy to the Crop table
--
-- CALLED BY:   use when updating pathogen data during the import corrections process
--
-- CHECKED PRECONDITIONS: PRE 01: @rtn must be registered
-- =====================================================================================
ALTER PROCEDURE [dbo].[sp_import_Crops]
    @import_file     VARCHAR(500)
   ,@display_tables  BIT = 0
AS
BEGIN
   DECLARE
        @fn       VARCHAR(35) = 'sp_import_Crops'
       ,@is_XLS   BIT
   EXEC sp_log 2, @fn,'000: starting: 
import_file   : [',@import_file   ,']
display_tables: [',@display_tables,']
;'

   BEGIN TRY

      ------------------------------------------
      -- Import
      ------------------------------------------
      EXEC sp_log 1, @fn,'010: import the CropStaging table';
      EXEC dbo.sp_import_txt_file
          @table        = 'CropStaging'
         ,@file         = @import_file
         ,@first_row=2
         ,@non_null_flds= 'crop_nm'
         ,@display_table= @display_tables
         ;

      ------------------------------------------
      -- Do fixup: done by sp_import_txt_file
      ------------------------------------------
      EXEC sp_log 1, @fn,'020: fixup done by sp_import_txt_file';

      -----------------------------------------------------------------------------------
      --  06: Pop Pathogen table
      -----------------------------------------------------------------------------------
      -- Drop Pathogen constraints
      EXEC sp_log 1, @fn, '040: dropping constraints';
      ALTER TABLE CropPathogen     DROP CONSTRAINT IF EXISTS FK_CropPathogen_Crop;

      EXEC sp_log 1, @fn,'050: TRUNCATE TABLE CropPathogen';
      TRUNCATE TABLE CropPathogen;
      EXEC sp_log 1, @fn,'054: TRUNCATE TABLE Crop';
      TRUNCATE TABLE Crop;

      EXEC sp_log 1, @fn,'070: creating constraints';

      -- Recreate Pathogen constraints
      ALTER TABLE dbo.CropPathogen     WITH CHECK ADD CONSTRAINT FK_CropPathogen_Crop FOREIGN KEY(crop_id) REFERENCES dbo.Crop (crop_id)
      ALTER TABLE dbo.CropPathogen     CHECK CONSTRAINT FK_CropPathogen_Crop

      EXEC sp_log 1, @fn,'080: clean pop Crop table from staging';
      INSERT INTO Crop
      (
            crop_nm
           ,latin_nm
           ,alt_latin_nms
           ,alt_common_nms
           ,taxonomy
           ,notes
      )
      SELECT
            crop_nm
           ,latin_nm
           ,alt_latin_nms
           ,alt_common_nms
           ,taxonomy
           ,notes
      FROM CropStaging; -- ps LEFT JOIN PathogenType pt ON ps.pathogenType_nm=pt.pathogenType_nm;

      if @display_tables = 1
         SELECT * FROM Crop;

      EXEC sp_assert_tbl_populated 'Crop';

      ------------------------------------------
      -- Process complete
      ------------------------------------------
      EXEC sp_log 1, @fn,'400: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 2, @fn,'500: caught exception';
      EXEC sp_log_exception @fn;
      throw;
   END CATCH

   EXEC sp_log 2, @fn,'999: leaving OK';
END
/*
EXEC sp_import_crops 'D:\Dev\Farming\Data\crops.txt', 1;
*/

GO
