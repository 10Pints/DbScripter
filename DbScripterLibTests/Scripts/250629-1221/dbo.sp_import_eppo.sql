SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =====================================================================
-- Author:      Terry Watts
-- Create date: 13-Nov-2024
-- Description: Imports the group of eppo files
--
-- Algorithm
-- Import the eppo tables from the @folder folder. The list of eppo files is:
--    Eppo_Gafgroup, Eppo_Gaflink, Eppo_Gafname,
--    Eppo_Gaigroup, Eppo_Gailink, Eppo_Gainame,
--    Eppo_Ntxlink,  Eppo_Ntxname, Eppo_Pfllink,
--    Eppo_pflname,  Eppo_Repco
--
-- The associated file names are:
--    Eppo_Gafgroup.txt, Eppo_Gaflink.txt, Eppo_Gafname.txt,
--    Eppo_Gaigroup.txt, Eppo_Gailink.txt, Eppo_Gainame.txt,
--    Eppo_Ntxlink .txt, Eppo_Ntxname.txt, Eppo_Pfllink.txt,
--    Eppo_pflname .txt, Eppo_Repco.txt
--
-- STAGE 1: sp_import_eppo_files: these files are imported into their associated stagig files
-- STAGE 2: any fixup can be performed
-- STAGE 3: merge into the main EPPO tables convertig types as necessary
--
-- POSTCONDITIONS:
-- POST01: all eppo tables populated
-- =====================================================================
CREATE   PROCEDURE [dbo].[sp_import_eppo]
    @folder           VARCHAR(500) = NULL
   ,@field_terminator NCHAR(1)      = NULL
   ,@exp_cnts         VARCHAR(2000)= NULL
   ,@display_tables   BIT           = NULL

AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn           VARCHAR(35) = 'sp_import_eppo'
   ,@row_cnt      INT
   ,@exp_row_cnt  INT
   ,@table        VARCHAR(60)
   ,@eppo         Eppo
   ;

   -- Set defaults as necessary
   IF @folder           IS NULL SET @folder           = 'D:\Dev\Farming\Data\EPPO.bayer';
   IF @field_terminator IS NULL SET @field_terminator = ',';
   IF @display_tables   IS NULL SET @display_tables   = 0;

   EXEC sp_log 2, @fn,'000: starting:
folder:          [', @folder,   ']
field_terminator:[', @field_terminator, ']
exp_cnts        :[', @exp_cnts        , ']
display_tables  :[', @display_tables  , ']'
;

   BEGIN TRY
         -------------------------------------------------------------------------------------------
         -- 01: Validate parameters
         -------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn,'010: validating parameters';

         -------------------------------------------------------------------------------------------
         -- 02: Initialise
         -------------------------------------------------------------------------------------------
          EXEC sp_log 1, @fn,'020: validating parameters';

           -------------------------------------------------------------------------------------------
         -- 03: Process
         -------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn,'030: starting process';

         IF @exp_cnts IS NOT NULL
         BEGIN
            EXEC sp_log 2, @fn, '040: checking the expected row cnts   ';

            INSERT INTO @eppo(ordinal, [table], exp_row_cnt)
            SELECT ordinal, [table], exp_row_cnt
            FROM
            (
               SELECT ordinal, SUBSTRING(value, 1,CHARINDEX(':', value)-1) AS [table], SUBSTRING(value, CHARINDEX(':', value)+1, 900) AS [exp_row_cnt]
               FROM string_split(@exp_cnts, ',',1) as A
            ) X;

            SELECT * FROM @eppo;
         END

         -------------------------------------------------------------------------------------------
      -- STAGE 1: sp_import_eppo_files: these files are imported into their associated stagig files
         -------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn,'050: STAGE 1: calling sp_import_eppo_files';

         EXEC sp_import_eppo_files
             @folder
            ,@field_terminator
            ,@exp_cnts
            ,@display_tables
            ;

         -------------------------------------------------------------------------------------------
      -- STAGE 2: any fixup can be performed
         -------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn,'060: STAGE 2: any fixup can be performed';
         EXEC sp_import_eppo_fixup;

         -------------------------------------------------------------------------------------------
      -- STAGE 3: merge staging tables into the main EPPO tables converting types as necessary
         -------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn,'070: STAGE 3: calling sp_import_eppo_merge';
         EXEC sp_import_eppo_merge @display_table = @display_tables;

            -------------------------------------------------------------------------------------------
         -- 04: Check postconditions
         -------------------------------------------------------------------------------------------
            -- POST01: all eppo tables populated
--    Eppo_Gafgroup, Eppo_Gaflink, Eppo_Gafname,
--    Eppo_Gaigroup, Eppo_Gailink, Eppo_Gainame,
--    Eppo_Ntxlink,  Eppo_Ntxname, 
--    Eppo_Pfllink,  Eppo_pflname,  Eppo_Repco
         EXEC sp_log 1, @fn,'300 checking postconditions';
         EXEC sp_assert_tbl_populated 'EPPO_gafgroup';
         EXEC sp_assert_tbl_populated 'EPPO_gaflink';
         EXEC sp_assert_tbl_populated 'EPPO_gafname';
         EXEC sp_assert_tbl_populated 'EPPO_Gaigroup';
         EXEC sp_assert_tbl_populated 'Eppo_Gailink';
         EXEC sp_assert_tbl_populated 'Eppo_Gainame';
         EXEC sp_assert_tbl_populated 'EPPO_ntxlink';
         EXEC sp_assert_tbl_populated 'Eppo_Ntxname';
         EXEC sp_assert_tbl_populated 'EPPO_pflgroup';
         EXEC sp_assert_tbl_populated 'EPPO_pfllink';
         EXEC sp_assert_tbl_populated 'EPPO_pflname';
         EXEC sp_assert_tbl_populated 'EPPO_repco';

            -------------------------------------------------------------------------------------------
         -- 05: Process complete
         -------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn,'400: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, ' 550: ';
      THROW;
   END CATCH

   EXEC sp_log 2, @fn,'999: leaving:';
END
/*
EXEC tSQLt.Run 'test.test_021_sp_import_eppo';
SELECT * FROM gailinkStaging;
*/


GO
