SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 08-OCT-2023
-- Description: Handles the bulk import of the PathogenType.xlsx/txt file
-- NB this is the STATIC DATA: pathogen types not the dynamic data: pathogenTypeStaging
-- the list of pthogen types - Fungus, insec, mollusc
--
-- ALGORITHM:
--    Delete the log files if they exist
--    TRUNCATE the table
--    Bulk insert the file
--    Check the table is populated
--    Do any fixup
--
-- PRECONDITIONS:
--    PathogenTypeStaging table dependents have been creared
--
-- POSTCONDITIONS:
-- POST01: PathogenTypeStaging populated AND retur= 0 or RC = error code
--
-- CALLED BY:
--
-- TESTS:
--
-- CHANGES:
-- 231103: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 240223: import either tsv or xlsx
-- ==============================================================================
ALTER PROCEDURE [dbo].[sp_import_pathogenType]
    @import_file    VARCHAR(500)
   ,@display_tables BIT = 0
AS
BEGIN
   DECLARE
       @fn        VARCHAR(35)  = N'sp_import_pathogenType'
      ,@row_cnt   INT = 0
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, @import_file: [',@import_file,']';
      EXEC sp_import_file  @import_file, @table='PathogenTypeStaging', @row_cnt=@row_cnt;
      EXEC sp_log 1, @fn, '010: imported ', @row_cnt, ' rows';

      -- fixup?
      -- Drop fkeys, and referencing data?
      ALTER TABLE [dbo].[PathogenChemical] DROP CONSTRAINT [FK_PathogenChemical_type]
      ALTER TABLE [dbo].[Pathogen] DROP CONSTRAINT [FK_Pathogen_PathogenType]
      EXEC sp_log 1, @fn, '020:'

      -- Copy to PathogenType
      TRUNCATE TABLE PathogenType;
      INSERT INTO PathogenType( pathogenType_nm)
      SELECT pathogenType_nm
      FROM PathogenTypeStaging;
      EXEC sp_log 1, @fn, '030:'

      ALTER TABLE dbo.PathogenChemical WITH CHECK ADD CONSTRAINT FK_PathogenChemical_type FOREIGN KEY(pathogenType_id)
         REFERENCES dbo.PathogenType (pathogenType_id);
      ALTER TABLE dbo.PathogenChemical CHECK CONSTRAINT FK_PathogenChemical_type;

      ALTER TABLE dbo.Pathogen  WITH CHECK ADD  CONSTRAINT FK_Pathogen_PathogenType FOREIGN KEY(pathogenType_id)
         REFERENCES dbo.PathogenType (pathogenType_id);
      ALTER TABLE dbo.Pathogen CHECK CONSTRAINT FK_Pathogen_PathogenType;
      EXEC sp_log 1, @fn, '040:'

      IF @display_tables = 1
         SELECT * FROM PathogenType;
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500:'
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ', @row_cnt, ' rows';
END
/*
EXEC sp_import_pathogenType 'D:\Dev\Farming\Data\PathogenType.txt', 1;
*/

GO
