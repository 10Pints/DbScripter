SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==================================================================================================================================================
-- Author:      Terry Watts
-- Create date: 20-JUNE-2023
-- Description: Main entry point for Importing all 9 100 page files Ph DepAg Registered Pesticides files
-- *** This cleans the staging tables first
-- import root = 'D:\Dev\Repos\<db name>\Data\'; use ut.dbo.fnGetImportRoot() to get it
-- in <import root>\Exports Ph DepAg Registered Pesticides LRAP-221018.pdf\tsvs\ - 9 tsv files
-- or <import root>\Exports Ph DepAg Registered Pesticides LRAP-230721.pdf\      - 1 tsv file
--
-- PARAMETERS:
-- @stage            : coarse granularity progress cursor
-- @start_row (n)    : if set then corrections loop will skip the first n rows
-- @stop_row         : if set then all processing is stoped after this row is procesed
-- @restore_s3_s2    : used to load s2 with a previous s3 cache of S2
-- @log_level        : multi switch parameter currently lonly LOG LEVEL:  is used
-- @LRAP_data_file   : LRAP import data file
-- @corrections_file : the tab separated s2 corrections file
-- @import_id        : int this is the version of the import file: 1 for LRAP-221018
-- @stop_stage       : set this top processing after the specified stage
--
-- Responsibilities:
-- 01. Perform main init
-- 02. Optionally restore S2 from S3 cache then go directly to import corrections
-- 03. Clear out clear out staging and main tables, S1 and S2, then import the static data
-- 04. Import the LRAP register file into S1 and perform basic fixup
-- 05: Fixup S1, copy Staging1 to Staging2
-- 06. Fixup Staging2 using the sp_fixup_s2 stored procedure and not the xls
-- 07: Import the import correction files
-- 08: Perform Spreadsheet based S2 fixup
-- 09: Populate the normalised staging tables
-- 10: Merge the normalised staging tables to the normalised tables
-- 11: Perform postcondition tests
--
-- Process
-- stage
-- 00: Clear the applog, Perform main init, 
-- 00: Optionally restore s2 from S3 cache then go directly to import corrections
-- 01: Clear out staging and main tables, S1 and S2, then import the static data
-- 02: import the LRAP register file into S1 and perform basic fixup
-- 03: fixup S1, copy S1->S2
-- 04: fixup S2 using the sp_fixup_s2 stored procedure and not the xls
-- 05: import the import correction files
-- 06: perform Spreadsheet based S2 fixup, using an importcorrections.xlsx file, cache S2->S3
-- 07: populate the staging tables
-- 08: Merge the staging tables to the normalised tables
-- 09: perform postcondition checks
--
-- CHANGES:
-- 230713: added LOG_LEVEL 0: DEBUG, 1:INFO, 2:WARNING, 3:ERROR
-- 230811: clean import then merge into the main tables, save the import_id as a session setting in import-init
-- 231005: added a check routine: sp_list_useful_table_rows to the comment area
-- 231007: added sp_merge_normalised_tables to update the main tables from this import
-- 231010: added call to sp_import_pathogenInfo to update the Pathogen table pathogen_type field
-- 231013: added a stop (after) stage parameter to facilitate interim testing of the db state
--         added while loop so we can break out easily
--         added temporary checks on existence of '%Cabagge moth%' and '%Golden apple Snails%' - theses should be removed
-- 231014  changed the import tab sep file name to exclude '.tsv' as MS Excel does not allow the use of .tsv or is 1 more step
--         renamed the fixupimport register sp for Staging to:  sp_fixup_s2_using_corrections_file
-- 231014: added a @stop_row parameter to stop the import from the main commandline, changed the order of the parameters
-- 231015: added @stop_stage parameter to stop after stage
-- 231016: changed parameter name: @skip_to -> @start_row for consistent naming
--       : changed call from sp_fixup_import_register to sp_fixup_s2_using_corrections_file as that sp name was changed
--       : added parameter: @stop_row to stop all processing after proccessing this row for testing db state
-- 231019: added Stage 0: truncate the main tables
-- 231029: BUG: Chlorthananil is not systemic -appears that the S2 Entry mode fixup has not run, even when run there are still some contact entries
-- 231031: BUG: Chlorthananil: research: can only import entry modes(actions) iff only 1 ingredient on the S2 row
-- 231031: added import use table
-- 231105: new feature: import multiple correction files
-- 231106: turned auto increment off so SET IDENTITY_INSERT ON/OFF not needed
-- 231108: multiple correction files, @correction_files is now a comma sep list of branches from @import_root
-- 240205: added a cache s2->s3 after the fixup from XL to debug stage 6+ post processing quicker (@restore_s3_s2 works with any stake >=5
-- 240309: moved the tuncate applog to main as we dont get any logging of main import right now
-- 240315: import 1 correction file at a time 
-- 240315: param name change: @import_file -> @LRAP_data_file, @corrections_file -> @cor_file
-- 240315: added optional parameter @cor_range to specifiy the range of the cor file
-- ==================================================================================================================================================
ALTER PROCEDURE [dbo].[sp__main_import]
    @LRAP_data_file     NVARCHAR(500)
   ,@LRAP_range         NVARCHAR(100)  = NULL-- LRAP-221018 230813
   ,@cor_file           NVARCHAR(MAX)  = NULL         -- cor file= correction file
   ,@cor_range          NVARCHAR(1000) = 'ImportCorrections$A:S'
   ,@start_stage        INT            = 0
   ,@stop_stage         INT            = 100
   ,@start_row          INT            = 1
   ,@stop_row           INT            = 100000
   ,@restore_s3_s2      BIT            = 0
   ,@log_level          INT            = 1
   ,@import_id          INT            = NULL
   ,@import_root        NVARCHAR(450)  = 'D:\Dev\Farming\Farming\Data'
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'MN_IMPRT'
      ,@cnt                INT            = 0
      ,@cor_file_path      NVARCHAR(MAX)  = NULL         -- cor file= correction file
      ,@error_msg          NVARCHAR(500)  = ''
      ,@fixup_cnt          INT            = 0
      ,@first_time         BIT            = 1
      ,@msg                NVARCHAR(500)  = ''
      ,@nl                 NVARCHAR(2)    = NCHAR(13)
      ,@options            INT
      ,@RC                 INT            = 0
      ,@result_msg         NVARCHAR(500)  = ''
      ,@sql                NVARCHAR(MAX)
      ,@stage_id           INT            = 0   -- current stage
      ,@status             INT
      ,@file_type          NCHAR(4)

   -----------------------------------------------------------------------------------
   -- 00: Clear the applog
   -----------------------------------------------------------------------------------
   TRUNCATE TABLE AppLog;

   EXEC sp_log 2, @fn,'00: starting:
LRAP_data_file:[', @LRAP_data_file,']
LRAP_range:    [', @LRAP_range,    ']
cor_file:      [', @cor_file,      ']
cor_range:     [', @cor_range,     ']
start_stage:   [', @start_stage,   ']
stop_stage:    [', @stop_stage,    ']
start_row:     [', @start_row,     ']
stop_row:      [', @stop_row,      ']
restore_s3_s2: [', @restore_s3_s2, ']
log_level:     [', @log_level,     ']
log_level:     [', @log_level,     ']
';

   SET NOCOUNT OFF;
   SET XACT_ABORT ON;

   BEGIN TRY
      SET NOCOUNT OFF;
      SET XACT_ABORT ON;

      WHILE 1=1
      BEGIN
         -------------------------------------------------------------------------------------------
         -- 01. Perform main init; responsibilities:
            -- 01: Determine the file type - xlsx or csv (txt)
            -- 02: Clear the applog 
            -- 03: Set the log level
            -- 04: Configure routine call control to avoid multiple calls of single call routines
            -- 05: Set session ctx vals: fixup count: 0, import_root
            -- 06: Get the import id from the file name
            -- 07: Override import_id with @import_id parameter if supplied
            -- 08: Delete bulk import log files
            -- 09: Postcondition checks
            -- 10: Completed processing
         -------------------------------------------------------------------------------------------
         EXEC sp_log 2, @fn,'Stage 00: Perform main init';

         EXEC sp_main_import_init @LRAP_data_file = @LRAP_data_file OUT
            ,@import_root  = @import_root
            ,@log_level    = @log_level
            ,@cor_file     = @cor_file
            ,@cor_file_path= @cor_file_path OUT
            ,@cor_range    = @cor_range
            ,@import_id    = @import_id     OUT
            ,@file_type    = @file_type     OUT -- 'txt' or 'xlsx'
            ;

         -- *** Register this call only after sp_main_import_init has configured the call register
         EXEC sp_register_call @fn;

         IF @stage_id >= @stop_stage BREAK;

         -------------------------------------------------------------------------------------------------------------------
         -- Stage 00. Optionally restore s2 from S3 cache then go directly to import corrections
         -------------------------------------------------------------------------------------------------------------------
         IF @restore_s3_s2 = 1
         BEGIN
            EXEC sp_log 2, @fn,'Stage 00. restore s2 from S3 cache then go directly to import corrections';
            EXEC sp_copy_s3_s2;
            SET @stage_id = 5; -- go directly to import corrections
         END

         ---------------------------------------------------------------------------------------
         -- Stage 01: clear out staging and main tables, S1 and S2, then import the static data
         ---------------------------------------------------------------------------------------
         --   {1. ActionStaging, 2. UseStaging, 3.Distributor, 4. PathogenTypeStaging, 5. PathogenPathogenTypeStaging, 6. TypeStaging}
         IF @start_stage <= 1
         BEGIN
            EXEC sp_log 2, @fn,'Stage 01: import static data';
            SET @stage_id = 1;
            EXEC sp_main_import_stage_01_imp_sta_dta;
            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 02: import the LRAP register file into S1 and perform basic fixup
         -----------------------------------------------------------------------------------
         IF @start_stage <= 2
         BEGIN
            EXEC sp_log 2, @fn,'Stage 02: import LRAP';
            SET @stage_id = 2;
            EXEC sp_main_import_stage_02_imp_LRAP @LRAP_data_file, @LRAP_range, @import_id;

            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 03: fixup S1, copy S1->S2
         -----------------------------------------------------------------------------------
         IF @start_stage <= 3
         BEGIN
            EXEC sp_log 2, @fn,'Stage 03: S1 fixup';
            SET @stage_id = 3;
            EXEC sp_main_import_stage_03_s1_fixup;

            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 04: fixup S2 using the sp_fixup_s2 stored procedure and not the xls
         -----------------------------------------------------------------------------------
         IF @start_stage <= 4
         BEGIN
            EXEC sp_log 2, @fn,'Stage 04: S2 fixup';
            SET @stage_id = 4;
            EXEC sp_main_import_stage_04_s2_fixup;

            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 05: import the import correction files
         -----------------------------------------------------------------------------------
         IF @start_stage <= 5
         BEGIN
            EXEC sp_log 2, @fn,'Stage 05: import cor';
            SET @stage_id = 5;
            DECLARE @correction_file_inc_rng NVARCHAR(500);
            SET @correction_file_inc_rng = CONCAT(@cor_file_path, '!', @cor_range);

            EXEC sp_main_import_stage_05_imp_cor
               @import_root            = @import_root
              ,@correction_file_inc_rng= @correction_file_inc_rng;

            IF @stage_id >= @stop_stage BREAK;
         END

         --------------------------------------------------------------------------------------
         -- Stage 06: perform Spreadsheet based S2 fixup, using an importcorrections.xlsx file, cache S2->S3
         --------------------------------------------------------------------------------------
         IF @start_stage <= 6
         BEGIN
            EXEC sp_log 2, @fn,'Stage 06: fixup cor using excel';
            SET @stage_id = 6;

            EXEC @rc = sp_main_import_stage_06_fixup_xl 
                @start_row    = @start_row
               ,@stop_row     = @stop_row
               ,@cor_file_path= @cor_file_path
               ,@cor_range    = @cor_range
               ,@fixup_cnt    = @fixup_cnt OUTPUT;

            IF (@stage_id >= @stop_stage) OR (@rc<> 0) BREAK; -- @rc= 0 means OK, 1 means stop and OK, -1 means error
         END

         -----------------------------------------------------------------------------------
         -- Stage 07: populate the staging tables
         -----------------------------------------------------------------------------------
         IF @start_stage <= 7
         BEGIN
            EXEC sp_log 2, @fn,'Stage 07: pop staging';
            SET @stage_id = 7;
            EXEC sp_main_import_stage_07_pop_stging;

            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 08: Merge the staging tables to the normalised tables
         -----------------------------------------------------------------------------------
         IF @start_stage <= 8
         BEGIN
            EXEC sp_log 2, @fn,'Stage 08: merge to main';
            SET @stage_id = 8;
            EXEC sp_main_import_stage_08_mrg_mn;

            IF @stage_id>= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Stage 09: perform postcondition checks
         -----------------------------------------------------------------------------------
         IF @start_stage <= 9
         BEGIN
            EXEC sp_log 2, @fn,'Stage 09: postcondition checks';
            SET @stage_id = 9;
            EXEC sp_main_import_stage_09_post_cks;

            IF @stage_id >= @stop_stage BREAK;
         END

         -----------------------------------------------------------------------------------
         -- Completed processing
         -----------------------------------------------------------------------------------
         EXEC sp_log 2, @fn,'90: completed processing OK';
         BREAK;
         END -- WHILE 1=1 main loop
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, '@stage_id: ', @stage_id;
      THROW;
   END CATCH

   SET @stage_id = 99; 
   SET @fixup_cnt = Ut.dbo.fnGetSessionContextAsInt(N'fixup count');
   EXEC sp_log 2, @fn, '99: leaving OK, stage: ', @stage_id, ' ret: ', @RC, @row_count=@fixup_cnt;
   RETURN @RC;
END
/*
EXEC sp__main_import
    @LRAP_data_file= 'D:\Dev\Farming\Farming\Data\LRAP-240910.txt'
   ,@cor_file      = NULL         -- cor file= correction file
   ,@cor_range     = 'ImportCorrections$A:S'
   ,@start_stage   = 0
   ,@stop_stage    = 100
   ,@start_row     = 1
   ,@stop_row      = 100000
   ,@restore_s3_s2 = 0
   ,@log_level     = 1
   ,@import_id     = NULL
   ,@import_root   = 'D:\Dev\Farming\Farming\Data'
*/

GO
