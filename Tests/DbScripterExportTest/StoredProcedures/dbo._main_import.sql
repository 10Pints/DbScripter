SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================================================================================================
-- Procedure:   dbo._main_import
-- Description: Main entry point for Importing 1 Ph DepAg LRAP (List of Registered Agructural Pesticides) file
-- Design     : EA: Model.Conceptual Model.LRAP Import
--            :     Model.Use Case Model.Import Lrap File (activity diagram)
--
-- Tests      : tSQLt.Run 'test.test_066__main_import'
-- Author:      Terry Watts
-- Create date: 20-JUNE-2023
-- Description: Main entry point for Importing all 9 100 page files Ph DepAg Registered Pesticides files
-- *** This cleans the staging tables first
-- import root = 'D:\Dev\Repos\<db name>\Data\'; use dbo.fnGetImportRoot() to get it
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
-- 01. Initialise
-- 02 Import primary static data from non LRAP sources (optional)
--
-- Preconditions: none
-- Postconditions:

-- Process for LRAP Import and scrub:
-------------------------------------------------------------------------------------------------------
-- Stage                                               Preconditions
-------------------------------------------------------------------------------------------------------
-- 01: Initialize (mandatory)                          none
-- 02: Import primary static data                      import_root specified
-- 03: Import the LRAP data                            import_root specified, LRAP file specified
-- 04: Do the S1 fixup                                 s1 pop
-- 05: Stage 5: Copy S1 to S2                          LRAP file imported
-- 06: Import the LRAP corrections files               import_root specified, LRAP file specified,cor files specified
-- 07: optionally restore s2 from S1 or S3 caches      none
-- 08: Scrub the imported LRAP fixup S2                Import corrections tbl pop
-- 09: Populate the dynamic data staging tables        fixup done
-- 10: Indentify the unmatched dynamic staging data    fixup done
-- 11: Copy S2 to the S3 cache                         LRAP file imported
-- 12: Merge Staging to Main                           fixup done
-- 13: Perform postcondition checks                    none
-------------------------------------------------------------------------------------------------------
--
-- CHANGES:
-- ==================================================================================================================================================
CREATE PROCEDURE [dbo].[_main_import]
    @import_root     VARCHAR(500)   = NULL
   ,@import_file     VARCHAR(500)   = NULL    -- exclude path, (and range if XL) assume in @import_root
   ,@cor_files       VARCHAR(500)   = NULL    -- coma sep list, file name only - assume in @import_root
   ,@start_stage     INT            = 0
   ,@stop_stage      INT            = 10
   ,@start_row       INT            = 1
   ,@stop_row        INT            = 100000
   ,@restore_s1_s2   BIT            = 0      -- Reset the state of Staging2 to the original LRAP import - useful when testing corrections
   ,@restore_s3_s2   BIT            = 0      -- Reset the state of Staging2 to the Fixed up version of S2 before the Corrections process
   ,@log_level       INT            = 1
   ,@import_eppo     BIT            = 0
   ,@display_tables  BIT            = 0
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)    = N'_main_import'
   ,@cnt             INT            = 0
   ,@error_msg       VARCHAR(500)   = ''
   ,@file_cnt        INT
   ,@fixup_cnt       INT            = 0
   ,@first_time      BIT            = 1
   ,@import_id       INT            = NULL
   ,@line2           VARCHAR(200)   = REPLICATE('*', 200)
   ,@msg             VARCHAR(500)   = ''
   ,@nl              VARCHAR(2)     = NCHAR(13)
   ,@options         INT
   ,@RC              INT            = 0
   ,@result_msg      VARCHAR(500)   = ''
   ,@row_cnt         INT            = 0
   ,@sql             VARCHAR(MAX)
   ,@stage_id        INT            = 1   -- current stage
   ,@status          INT
   ;

   -----------------------------------------------------------------------------------
   -- 00: Clear the applog
   -----------------------------------------------------------------------------------

   EXEC sp_log 2, @fn,'000: starting:
import_root:   [', @import_root,   ']
import_file:   [', @import_file,   ']
cor_files:     [', @cor_files,     ']
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
         -- Stage 01: Initialise (always performed)
         -------------------------------------------------------------------------------------------
         -- Preconditions: none
         EXEC sp_log 1, @fn,'010: initialising, calling sp_main_import_init';

         -- 241230: Notes to get the modified parameters query the state tables Importstate and Corfiles
         EXEC sp_mn_imprt_ini
          @import_root    = @import_root      -- have import root suffix when output
         ,@import_file    = @import_file -- LRAP import file
         ,@cor_files      = @cor_files       -- must be specified if stage < 5
         ,@start_stage    = @start_stage
         ,@stop_stage     = @stop_stage
         ,@start_row      = @start_row
         ,@stop_row       = @stop_row
         ,@restore_s1_s2  = @restore_s1_s2  -- Reset the state of Staging2 to the original LRAP import - useful when testing corrections
         ,@restore_s3_s2  = @restore_s3_s2  -- Reset the state of Staging2 to the Fixed up version of S2 before the Corrections process
         ,@log_level      = @log_level
         ,@import_eppo    = @import_eppo
         ;

         SELECT
             @import_root    = import_root     -- have import root suffix when output
            ,@import_file    = import_file      -- LRAP import file
            ,@cor_files      = cor_files       -- must be specified if stage < 5
            ,@start_stage    = start_stage
            ,@stop_stage     = stop_stage
            ,@start_row      = start_row
            ,@stop_row       = stop_row
            ,@restore_s1_s2  = restore_s1_s2  -- Reset the state of Staging2 to the original LRAP import - useful when testing corrections
            ,@restore_s3_s2  = restore_s3_s2  -- Reset the state of Staging2 to the Fixed up version of S2 before the Corrections process
            ,@log_level      = log_level
            ,@import_eppo    = import_eppo
            ,@import_id      = import_id
         FROM Importstate
         WHERE id = 1;

         -- Stage 1: Postconditions: (which become the prconditions for the next stage)
         -- all init done for the given stage
         -- Tables pop: CallRegister
         -- Tables clrd: AppLog,CallRegister,CorrectionLog,S2UpdateLog,S2UpdateSummary
         EXEC sp_log 1, @fn,'020: ret frm sp_main_import_init, @import_id: ', @import_id;

         -- *** Register this call only after sp_main_import_init has configured the call register
         --EXEC sp_register_call @fn;

         IF @stage_id >= @stop_stage BREAK;

         -------------------------------------------------------------------------------------------
         -- Stage 2: Import static data
         -------------------------------------------------------------------------------------------
         IF @start_stage <= 2
         BEGIN
            EXEC sp_log 2, @fn,'030: Stage 02: import static data';
            SET @stage_id = 2;
            --EXEC LRAP_Imprt_S02_ImprtStaticData @import_eppo = @import_eppo;
            EXEC sp_import_static_data @import_root, @display_tables, @import_eppo;
         END

         -- Stage 2: Postconditions:
         IF @stage_id >= @stop_stage BREAK;

         ----------------------------------------------------------------------------------------------------------
         -- Stage 03: Import the LRAP data
         ----------------------------------------------------------------------------------------------------------
         IF @start_stage <= 3
         BEGIN
            SET @stage_id = 3; -- go directly to import corrections

            IF @restore_s3_s2 = 0
            BEGIN
               -- Import the LRAP data and do the S1 fixup
               EXEC sp_log 2, @fn,'040: Stage 03: import LRAP data';
               EXEC sp_import_LRAP_file @import_file, @import_id;
            END
         END

         -- Stage 3: Postconditions: Staging1 pop'd
         IF @stage_id >= @stop_stage BREAK;

         -----------------------------------------------------------------------------------
         -- 04: Do the S1 fixup
         -----------------------------------------------------------------------------------
         IF @start_stage <= 4
         BEGIN
            EXEC sp_log 2, @fn,'050: Stage 04: fixup S1';
            SET @stage_id = 4;
            EXEC sp_fixup_s1 @fixup_cnt = @fixup_cnt OUT;
         END

         -- Stage 4: Postconditions:
         IF @stage_id >= @stop_stage BREAK;

         ---------------------------------------------------------------------------------------
         -- 05: Stage 5: Copy S1 to S2
         ---------------------------------------------------------------------------------------
         IF @start_stage <= 5
         BEGIN
            EXEC sp_log 2, @fn,'060: Stage 05: copy s1 -> s2';
            SET @stage_id = 5;
            EXEC sp_cpy_s1_s2;
         END

         -- Stage 5: Postconditions:
         IF @stage_id >= @stop_stage BREAK;

         ---------------------------------------------------------------------------------------
         -- 06: Import the LRAP corrections files
         ---------------------------------------------------------------------------------------
         IF @start_stage <= 6
         BEGIN
            EXEC sp_log 2, @fn,'050: Stage 06 Import the LRAP corrections file';
            SET @stage_id = 6;
            EXEC sp_import_cor_files @tot_cnt = @row_cnt OUT, @file_cnt=@file_cnt OUT;
            EXEC sp_log 2, @fn,'060: Stage 06 Imported ',@row_cnt,' rows from ',@file_cnt,' cor files';
         END

         -- Stage 6: Postconditions:
         IF @stage_id >= @stop_stage BREAK;

         ---------------------------------------------------------------------------------------
         -- 07: optionally restore s2 from either S1 or S3 cache cache
         ---------------------------------------------------------------------------------------
         IF @start_stage <= 7
         BEGIN
            SET @stage_id = 7;

            IF @restore_s1_s2 = 1
            BEGIN
               EXEC sp_log 2, @fn,'070. stage 07.1: optionally restore s2 from either S1 or S3 cache cache';
               EXEC sp_cpy_s1_s2;
            END
            ELSE IF @restore_s3_s2 = 1
            BEGIN
               EXEC sp_log 2, @fn,'080. stage 07.2:restore s2 from the S3 cache';
               EXEC sp_cpy_s3_s2;
            END
         END

         -- Stage 7: Postconditions:
         IF @stage_id >= @stop_stage BREAK;

         -----------------------------------------------------------------------------------
         -- 08: Scrub the imported LRAP source table data i.e. fixup S2
         -----------------------------------------------------------------------------------
         IF @start_stage <= 8
         BEGIN
            SET @stage_id = 8;
            EXEC sp_log 2, @fn,'090: Stage 08: S2 fixup';

            EXEC @rc = sp_fixup_S2
                @start_row = @start_row
               ,@stop_row  = @stop_row
               ,@row_count = @row_cnt   OUT
               ,@fixup_cnt = @fixup_cnt OUT
               ;
         END

         -- Stage 8: Postconditions:
         IF @stage_id >= @stop_stage BREAK;

         -----------------------------------------------------------------------------------
         -- 09: Populate the dynamic data staging tables (mandatory)
         -----------------------------------------------------------------------------------
         IF @start_stage <= 9
         BEGIN
            SET @stage_id = 9;
            EXEC sp_log 2, @fn,'100: Stage 09: Populate dynamic data staging tables';
            EXEC sp_pop_dynamic_data;
         END

         -- Stage 9: Postconditions:
         IF @stage_id >= @stop_stage BREAK;

         -----------------------------------------------------------------------------------
         -- 10: Indentify the unmatched dynamic staging data
         --     items not found in the primary static data
         --     Like Pathogens, Crops, Company, Ingredient, Entry mode (mandatory)
         -----------------------------------------------------------------------------------
         IF @start_stage <= 10
         BEGIN
            SET @stage_id = 10;
            EXEC sp_log 2, @fn,'110: Stage 10: indentify and display a list of the unmatched dynamic staging data items not found in the primary static data';
            EXEC @rc = sp_fnd_unregistered_dynamic_data;

            IF @rc<> 0
            BEGIN
               -------------------------------------------------------------------------------------------------------------------------------------
               -- Manual process: build XL correction sheets for these anomalies and repeat eimport rom Stage 04: Import the LRAP corrections files
               -------------------------------------------------------------------------------------------------------------------------------------
               EXEC sp_log 3, @fn,'120 There are ',@rc,' unmatched unmatched dynamic staging data items not found in the primary static data';
               EXEC sp_log 3, @fn,'130: Fix and re-import from Stage 04: Import the LRAP corrections files';

               -- 241218: continue for now so we can test what we have
               -- make a copy of S3 now for test prurposes
               -- EXEC sp_cpy_s2_s3;
               -- BREAK;
            END
         END

         -- Stage 10: Postconditions: no unmatched dynamic reference staging data
         IF @stage_id >= @stop_stage BREAK;

         ---------------------------------------------------------
         -- ASSERTION no unmatched dynamic reference staging data
         ---------------------------------------------------------

         -----------------------------------------------------------------------------------
         -- 11: Copy S2 to the S3 cache
         -----------------------------------------------------------------------------------
         IF @start_stage <= 11
         BEGIN
            ---------------------------------------------------------------------------
            -- 08: Copy S2 to S3 so that S3 holds the fixed up S2
            -- this can be used for re-entrant fixup when modifying the corrections files
            -- and to create the test data stored is test.s2_tst, and  test.s2_tst_bak
            -- that is used by sp_gen_tst_dta_S2_tst
            ----------------------------------------------------------------------------
            SET @stage_id = 11;
            EXEC sp_log 2, @fn,'140: Stage 11: copy s2->s3';
            EXEC sp_cpy_s2_s3;
         END

         -- Stage 11: Postconditions:
         IF @stage_id >= @stop_stage BREAK;

         --------------------------------------------------------------------------------------
         -- 12: Merge the dynamic data staging to their respective main tables 
         --------------------------------------------------------------------------------------
         IF @start_stage <= 12
         BEGIN
            SET @stage_id = 12;
            EXEC sp_log 2, @fn,'150: Stage 12: merge the main tables';
            EXEC LRAP_Imprt_S09_merge_mn; -- @correction_file_path_inc_rng= @cor_file;
         END

         -- Stage 12: Postconditions:
         IF @stage_id >= @stop_stage BREAK;

         -----------------------------------------------------------------------------------
         -- 13: Perform postcondition checks
         -----------------------------------------------------------------------------------
         IF @start_stage <= 13
         BEGIN
            SET @stage_id = 13;
            EXEC sp_log 2, @fn,'160: Stage 13: postcondition checks';
            EXEC sp_mn_imprt_stg_12_post_cks @import_eppo;
         END

         -----------------------------------------------------------------------------------
         -- Completed processing
         -----------------------------------------------------------------------------------
         EXEC sp_log 2, @fn,'800: completed processing OK';

         -- Stage 13: Postconditions:
         BREAK;
         END -- WHILE 1=1 main loop
   END TRY
   BEGIN CATCH
      PRINT CONCAT(@nl, @line2);
      EXEC sp_log_exception @fn, ' 550: @stage_id: ', @stage_id;
      PRINT CONCAT(@line2, @nl);
      THROW;
   END CATCH

   SET @stage_id = 99;
   EXEC sp_log 2, @fn, '999: leaving, stage: ', @stage_id, ' ret: ', @RC, @row_count=@fixup_cnt;
   RETURN @RC;
END
/*
-- 01: Full import from initialization to ImportCorrections_221018-Pathogens_A-C.txt
EXEC _main_import
    @start_stage=1
   ,@import_file='LRAP-221018.txt'
   ,@import_root='D:\Dev\Farming\Data'
   ,@cor_files = 'ImportCorrections_221018-Crops.txt';

--   ,@cor_files = 'ImportCorrections_221018-PreFixup.txt,ImportCorrections_221018-Company.txt,ImportCorrections_221018-Crops.txt,ImportCorrections_221018-Entry_mode.txt,ImportCorrections_221018-Product.txt,ImportCorrections_221018-Uses.txt,ImportCorrections_221018-Pathogens_A-C.txt';
;

--****************************************************************************************************************************
   -- uncache s1-> s2, and import the cor files up to and inc crops
   -- 06: Import the LRAP corrections files from crops fixup and on

EXEC _main_import @start_stage=6, @restore_s1_s2 = 1, @import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections_221018-Entry_mode.txt,ImportCorrections_221018-Product.txt,ImportCorrections_221018-Uses.txt,ImportCorrections_221018-Crops.txt' --,ImportCorrections_221018-Entry_mode.txt,ImportCorrections_221018-Product.txt,ImportCorrections_221018-Uses.txt,ImportCorrections_221018-Pathogens_A-C.txt,ImportCorrections_221018-Pathogens_D-M.txt,ImportCorrections_221018-Pathogens-N-Z.txt';
--****************************************************************************************************************************


-- 06: Import the LRAP corrections files from up not including pathogens
-- assumes previous fixup has been done
EXEC _main_import @start_stage=8, @restore_s1_s2 = 1,@import_root='D:\Dev\Farming\Data'
,@cor_files = 'ImportCorrections_221018-Crops.txt';--,ImportCorrections_221018-Entry_mode.txt,ImportCorrections_221018-Product.txt,ImportCorrections_221018-Uses.txt';

--******************************************************************************************************************************************************************
-- 06: Import the LRAP corrections files ImportCorrections_221018-crops
-- assumes previous fixup has been done
EXEC _main_import @start_stage=6, @import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections_221018-Entry_mode.txt,ImportCorrections_221018-Uses.txt';
--******************************************************************************************************************************************************************

EXEC _main_import @start_stage=6, @import_file='LRAP-221018.txt',@import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections_221018-Company.txt,ImportCorrections_221018-Pathogens_A-C.txt';

-- 06: Import the LRAP corrections files ImportCorrections_221018-Pathogens_A-C.txt only
-- assumes previous fixup has been done
EXEC _main_import @start_stage=6, @import_file='LRAP-221018.txt',@import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections_221018-Company.txt';
EXEC _main_import @start_stage=6, @import_file='LRAP-221018.txt',@import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections_221018-Company.txt,ImportCorrections_221018-Pathogens_A-C.txt';

-- 06: Import the LRAP corrections files ImportCorrections_221018-Pathogens_D-M.txt only
-- assumes previous fixup has been done includin ImportCorrections_221018-Pathogens_A-C.txt
EXEC _main_import @start_stage=6,@stop_row=20,@import_file='LRAP-221018-2.txt',@import_root='D:\Dev\Farming\Tests\test_066',@cor_files = 'ImportCorrections_221018-Pathogens_D-M.txt,ImportCorrections_221018-Pathogens-N-Z.txt';

EXEC _main_import @start_stage=6,@import_file='LRAP-221018.txt',@import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections.PreFixup 221018.txt,ImportCorrections_221018-Pathogens_A-C.txt,ImportCorrections_221018-Pathogens_D-M.txt,ImportCorrections_221018-Pathogens-N-Z.txt';
-- pre conditions: ImportCorrections.PreFixup 221018.tx,,ImportCorrections 221018.txt imported
EXEC _main_import @start_stage=6,@stop_row=20,@import_file='LRAP-221018-2.txt',@import_root='D:\Dev\Farming\Tests\test_066',@cor_files = 'ImportCorrections_221018-Pathogens_A-C.txt,ImportCorrections_221018-Pathogens_D-M.txt,ImportCorrections_221018-Pathogens-N-Z.txt';

-- 02: Import primary static data
EXEC _main_import @start_stage=2, @import_eppo = true, @import_file='LRAP-221018.txt',@import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections.PreFixup 221018.txt,ImportCorrections_221018-Pathogens_A-C.txt,ImportCorrections_221018-Pathogens_D-M.txt,ImportCorrections_221018-Pathogens-N-Z.txt';

-- 03: Import the LRAP data
EXEC _main_import @start_stage=3, @import_eppo= 0,@import_file='LRAP-221018.txt',@import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections.PreFixup 221018.txt,ImportCorrections_221018-Pathogens_A-C.txt,ImportCorrections_221018-Pathogens_D-M.txt,ImportCorrections_221018-Pathogens-N-Z.txt';

-- 04: Do the S1 fixup
EXEC _main_import @start_stage=4, @import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections.PreFixup 221018.txt,ImportCorrections_221018-Pathogens_A-C.txt,ImportCorrections_221018-Pathogens_D-M.txt,ImportCorrections_221018-Pathogens-N-Z.txt';

-- 05: Stage 5: Copy S1 to S2
EXEC _main_import @start_stage=5, @import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections.PreFixup 221018.txt,ImportCorrections_221018-Pathogens_A-C.txt,ImportCorrections_221018-Pathogens_D-M.txt,ImportCorrections_221018-Pathogens-N-Z.txt';

-- 06: Import the LRAP corrections files and restore S2 from S1
EXEC _main_import @start_stage=6,@restore_s1_s2=1;, @import_root='D:\Dev\Farming\Data',@cor_files = 'ImportCorrections.PreFixup 221018.txt,ImportCorrections_221018-Pathogens_A-C.txt,ImportCorrections_221018-Pathogens_D-M.txt,ImportCorrections_221018-Pathogens-N-Z.txt';

-- 07: optionally restore s2  from either S1 or S3 cache cache
EXEC _main_import @start_stage=7;

-- 08: fixup S2, using S1 and the exisitng import corrections
EXEC _main_import @start_stage=8,@restore_s1_s2=1;

-- 09: Populate the dynamic data staging tables
EXEC _main_import @start_stage=9;

-- 10: Indentify the unmatched dynamic staging data
EXEC _main_import @start_stage=10

-- 11: Copy S2 to the S3 cache
EXEC _main_import @start_stage=11;

-- 12: Merge Staging to Main
EXEC _main_import @start_stage=12;

-- 13: Perform postcondition checks
EXEC _main_import @start_stage=13;

EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns ' [dbo].[_main_import]', @trn=67, @ad_stp=1
*/

GO
