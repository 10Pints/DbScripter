SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =====================================================================================
-- AUTHOR       Terry Watts
-- CREATE DATE: 30-NOV-2024
-- DESCRIPTION: clean imports the Pathogen data
-- NOTE:        imports into the staging table then does the fixup
--              and copy to the Pathogen table
--
-- CALLED BY:   use when updating pathogen data during the import corrections process
--
-- CHECKED PRECONDITIONS: PRE 01: @rtn must be registered
-- =====================================================================================
ALTER PROCEDURE [dbo].[sp_import_Pathogens]
    @import_file     VARCHAR(500)
   ,@display_tables  BIT = 0
AS
BEGIN
   DECLARE
        @fn       VARCHAR(35) = 'sp_import_Pathogens'
       ,@is_XLS   BIT
   EXEC sp_log 2, @fn,'000: starting: 
import_file   : [',@import_file   ,']
display_tables: [',@display_tables,']
;'

   BEGIN TRY

      ------------------------------------------
      -- Import
      ------------------------------------------
      EXEC sp_log 1, @fn,'010: import the PathogenStaging table';
      EXEC dbo.sp_import_txt_file
          @table        = 'PathogenStaging'
         ,@file         = @import_file
         ,@first_row=3
         ,@non_null_flds= 'pathogen_nm,pathogenType_nm'
         ,@display_table= @display_tables
         ;

      ------------------------------------------
      -- Do fixup: done by sp_import_txt_file
      ------------------------------------------
      EXEC sp_log 1, @fn,'020: fixup done by sp_import_txt_file';

      if @display_tables = 1
         SELECT * FROM PathogenStaging;

      ------------------------------------------
      -- Populate the PathogenType Table
      ------------------------------------------
      EXEC sp_log 1, @fn,'030: merging the PathogenType Table';
      EXEC sp_assert_tbl_pop 'PathogenType';

      -----------------------------------------------------------------------------------
      --  06: Pop Pathogen table
      -----------------------------------------------------------------------------------
      -- Drop Pathogen constraints
      EXEC sp_log 1, @fn, '040: dropping constraints';
      ALTER TABLE Pathogen         DROP CONSTRAINT IF EXISTS FK_Pathogen_PathogenType;
      ALTER TABLE PathogenChemical DROP CONSTRAINT IF EXISTS FK_PathogenChemical_Pathogen;
      ALTER TABLE CropPathogen     DROP CONSTRAINT IF EXISTS FK_CropPathogen_Pathogen;

      EXEC sp_log 1, @fn,'050: TRUNCATE TABLE CropPathogen';
      TRUNCATE TABLE CropPathogen;
      EXEC sp_log 1, @fn,'052: TRUNCATE TABLE CropPathogen';
      TRUNCATE TABLE CropPathogen;
      EXEC sp_log 1, @fn,'054: TRUNCATE TABLE PathogenChemical';
      TRUNCATE TABLE Pathogen;

      EXEC sp_log 1, @fn,'070: creating constraints';

      -- Recreate Pathogen constraints
      ALTER TABLE dbo.CropPathogen     WITH CHECK ADD CONSTRAINT FK_CropPathogen_Pathogen FOREIGN KEY(pathogen_id) REFERENCES dbo.Pathogen (pathogen_id)
      ALTER TABLE dbo.CropPathogen     CHECK CONSTRAINT FK_CropPathogen_Pathogen

      ALTER TABLE dbo.PathogenChemical WITH CHECK ADD CONSTRAINT FK_PathogenChemical_Pathogen FOREIGN KEY(pathogen_nm) REFERENCES dbo.Pathogen (pathogen_nm)
      ALTER TABLE dbo.PathogenChemical CHECK CONSTRAINT FK_PathogenChemical_Chemical

      ALTER TABLE dbo.Pathogen         WITH CHECK ADD  CONSTRAINT FK_Pathogen_PathogenType FOREIGN KEY(pathogenType_id) REFERENCES dbo.PathogenType (pathogenType_id)
      ALTER TABLE dbo.Pathogen         NOCHECK CONSTRAINT FK_Pathogen_PathogenType

      EXEC sp_log 1, @fn,'080: clean pop Pathogen table from statging';
      INSERT INTO Pathogen
      (
            [pathogen_nm]
           ,[pathogenType_nm]
           ,[pathogenType_id]
           ,[subtype]
           ,[latin_nm]
           ,[alt_latin_nms]
           ,[alt_common_nms]
           ,[ph_common_nms]
           ,[crops]
           ,[taxonomy]
           ,[notes]
           ,[urls]
           ,[biological_cure]
      )
      SELECT
            [pathogen_nm]
           ,pt.pathogenType_nm
           ,pt.pathogenType_id
           ,[subtype]
           ,[latin_nm]
           ,[alt_latin_nms]
           ,[alt_common_nms]
           ,[ph_common_nms]
           ,[crops]
           ,[taxonomy]
           ,[notes]
           ,[urls]
           ,[biological_cure]
      FROM PathogenStaging ps LEFT JOIN PathogenType pt ON ps.pathogenType_nm=pt.pathogenType_nm;

      if @display_tables = 1
         SELECT * FROM Pathogen;

      EXEC sp_assert_tbl_pop 'Pathogen';
      return;

      -----------------------------------------------------------------------------------
      -- Populate the CropPathogen Table
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'100: merging CropPathogen Table';
      EXEC sp_assert_tbl_pop 'CropStaging';
      --EXEC sp_assert_tbl_pop 'Crop';

      MERGE CropPathogen          AS target
      USING
      (
         SELECT p.pathogen_nm, c.crop_id, c.crop_nm, p.pathogen_id
         FROM
            CropPathogenStaging cps
            LEFT JOIN CropStaging   cs ON cs.crop_nm = cps.crop_nm
            LEFT JOIN Crop          c  ON c. crop_nm = cs .crop_nm
            LEFT JOIN Pathogen      p  ON p .pathogen_nm = cps.pathogen_nm
         WHERE 
                cs.crop_nm IS NOT NULL
            AND cs.crop_nm <>''
            AND p.pathogen_nm IS NOT NULL
            AND p.pathogen_nm <>''
      )       AS s
      ON target.crop_nm = s.crop_nm AND target.pathogen_nm = s.pathogen_nm
      WHEN NOT MATCHED BY target THEN
         INSERT (  crop_id,   pathogen_id,  crop_nm,   pathogen_nm)
         VALUES (s.crop_id, s.pathogen_id,s.crop_nm, s.pathogen_nm)
         ;

      if @display_tables = 1
         SELECT * FROM CropPathogen;

      EXEC sp_assert_tbl_pop 'CropPathogen';

      -----------------------------------------------------------------------------------
      --Merge PathogenChemical table
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'070: populating PathogenChemical Table';
      EXEC sp_assert_tbl_pop 'Chemical';

      MERGE PathogenChemical AS target
      USING
      (
         SELECT p.pathogen_id, p.pathogen_nm, c.chemical_id, c.chemical_nm, pt.pathogenType_id 
         FROM 
            PathogenChemicalStaging pcs
            LEFT JOIN Pathogen p ON p.pathogen_nm = pcs.pathogen_nm
            LEFT JOIN Chemical c ON c.chemical_nm = pcs.chemical_nm
            LEFT JOIN PathogenType pt ON pt.pathogenType_id=p.pathogenType_id
      ) AS s
      ON target.pathogen_nm = s.pathogen_nm AND target.chemical_nm = s.chemical_nm
      WHEN NOT MATCHED BY target THEN
         INSERT ( pathogen_id, chemical_id, pathogen_nm, chemical_nm, pathogenType_id)
         VALUES ( pathogen_id, chemical_id, pathogen_nm, chemical_nm, pathogenType_id)
         ;

      EXEC sp_assert_tbl_pop 'PathogenChemical';

      if @display_tables = 1
         SELECT * FROM PathogenChemical;

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
EXEC sp_import_Pathogens 'D:\Dev\Farming\Data\Pathogen.txt', 1;

ALTER TABLE [dbo].[CropPathogen]  WITH CHECK ADD  CONSTRAINT [FK_CropPathogen_Crop] FOREIGN KEY([crop_id])
REFERENCES [dbo].[Crop] ([crop_id])

ALTER TABLE [dbo].[CropPathogen] CHECK CONSTRAINT [FK_CropPathogen_Crop]
SELECT * FROM CropPathogenStaging;
SELECT * FROM CropStaging;
SELECT * FROM Crop;
SELECT * FROM Pathogen
SELECT * FROM Pathogen where Crops is null;
SELECT * FROM PathogenStaging;
pathogen_id	pathogen_nm	pathogenType_nm	pathogenType_id	subtype	latin_name	alt_latin_names	alt_common_names	ph_common_names	crops	taxonomy	notes	urls	biological_cure
SELECT *
FROM
   CropPathogenStaging cps
   LEFT JOIN CropStaging   cs ON cs.crop_nm = cps.crop_nm
   LEFT JOIN Crop          c  ON c. crop_nm = cs .crop_nm
   LEFT JOIN Pathogen      p  ON p .pathogen_nm = cps.pathogen_nm
*/

GO
