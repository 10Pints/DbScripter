SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 20-OCT-2024
-- Description:
--
-- PRECONDITIONS:
-- PRE01: none
--
-- POSTCONDITIONS:
-- POST01: MosaicVirus table must have rows
-- POST02: no double quotes exists in any column
-- POST03: no leaading/trailing wsp exists in any column
--
-- BCP create (DOS_:
-- bcp Farming_dev.dbo.cropstaging format nul -c -T -f CropStaging.fmt
--
-- TESTS:
--
-- CHANGES:
-- ==========================================================================================================
CREATE PROCEDURE [dbo].[sp_import_MosaicVirus]
    @file     VARCHAR(500)
   ,@folder         VARCHAR(600) = NULL
   ,@display_tables BIT          = 0
AS
BEGIN
   DECLARE
       @fn                 VARCHAR(35)   = N'IMPRT_MosaicVirus'
      ,@bkslsh             CHAR(1)       = CHAR(92)
      ,@sql                VARCHAR(MAX)
      ,@cmd                VARCHAR(MAX)
      ,@error_file         VARCHAR(400)  = NULL
      ,@error_msg          VARCHAR(MAX)  = NULL
      ,@table_nm           VARCHAR(35)   = 'Distributor'
      ,@rc                 INT            = -1
      ,@import_root        VARCHAR(MAX)
      ,@pathogen_row_cnt   INT            = -1
      ,@update_row_cnt     INT            = -1
      ,@null_type_row_cnt  INT            = -1
      ;

   SET NOCOUNT OFF
   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting:
file          :[', @file  ,']
folder        :[', @folder,']
display_tables:[', @display_tables,']
';

      ---------------------------------------
      -- Validate inputs
      ---------------------------------------
      IF @folder IS NOT NULL
         SET @file = CONCAT(@folder, @bkslsh, @file);

      ---------------------------------------                          
      -- Process
      ---------------------------------------                          
      EXEC sp_log 1, @fn, '010: clearing Distributor table';

      EXEC sp_log 1, @fn, '020: calling sp_bulk_import_tsv2';
      EXEC sp_import_txt_file
          @table         = 'MosaicVirusStaging'
         ,@view          = NULL
         ,@file          = @file
         ,@format_file   = NULL
         ,@expect_rows   = NULL
         ,@non_null_flds = 'species,crops,Genus,Family,Order,Class,Kingdom,Realm,Genome'
        ;

      ---------------------------------------                          
      -- Do any extra fixup not performed by sp_import_txt_file
      ---------------------------------------                          
      EXEC sp_log 1, @fn, '030: Do any extra fixup not performed by sp_import_txt_file';

      ----------------------------------------------------------------------------------
      -- Clean copy staging -> Main
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '040: clean copy to MosaicVirus';
      DELETE FROM MosaicVirus;

      INSERT INTO MosaicVirus
      (
          [Species]
         ,[Crops]
         ,[Genus]
         ,[Subfamily]
         ,[Family]
         ,[Order]
         ,[Class]
         ,[Subphylum]
         ,[Phylum]
         ,[Kingdom]
         ,[Realm]
         ,[Genome]
         ,[Vector]
         ,[OPPO_code]
      )
      SELECT Species, Crops, Genus, Subfamily, Family, [Order], Class, Subphylum, Phylum, Kingdom, Realm, Genome, Vector, OPPO_code
      FROM MosaicVirusStaging
      ;

      ----------------------------------------------------------------------------------
      -- Postcondition checks
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '050:performing postcondition checks'
      EXEC sp_assert_tbl_pop MosaicVirus;

      ----------------------------------------------------------------------------------
      -- Completed processing OK
      ----------------------------------------------------------------------------------

      IF @display_tables = 1 SELECT * FROM MosaicVirus;
      SET @rc = 0; -- OK
      EXEC sp_log 1, @fn, '95:completed import and fixup OK'
   END TRY
   BEGIN CATCH
      SET @error_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn, '50: Caught exception: ', @error_msg;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '99: leaving, RC: ', @rc
   RETURN @RC;
END
/*
EXEC sp_import_MosaicVirus 'D:\Dev\Farming\Data\MosaicViruses.txt', 1;
*/

GO
