SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ======================================================================================================
-- Procedudure: NM:dbo].[sp_mn_imprt_ini
-- Description: main import routine init, set the import state tables
-- Design EA:   Model.Requirements.LRAP import Requirements.Import Initialisation
-- Tests:       EXEC tSQLt.Run 'test.test_099_sp_mn_imprt_ini'
-- AUTHOR:      Terry Watts
-- CREATE DATE: 02-AUG-2023
--
-- Notes: to get the modified parameters query the state tables Importstate and Corfiles
--
-- CALLED BY:   sp_main__import_pesticide_register
--
-- RESPONSIBILITIES:
-- R01: Display the prms
-- R03: Clear tables
--   R03.1: Clear AppLog table
--   R03.2: Clear CorrectionLog table
--   R03.3: Clear S2UpdateLog table
--   R03.4: Clear S2UpdateSummary table
-- R04: Set the log level
-- R05: prefix the root to the import file
--------------------------------------------------------------------------------------------------------------------------------
-- 06: Validation:
--------------------------------------------------------------------------------------------------------------------------------
--       the inputs according to stage
-- R06.1: import root: must be specified/exist if stage < 4 if not raise exception 60001 'R05.1: import root must be specified if stage < 5'
-- R06.3: cor files:   1 or more files must be specified if stage < 5 if not raise exception 60003 'R05.3: 1: or more correction files must be specified if stage < 5'
-- R06.4: start stage: between 0 and 10                     if not raise exception 60004 'R05.4: start_stage must be between 0 and 10'
-- R06.5: stop stage:  between 0 and 10, >= st stg          if not raise exception 60005 'R05.5: stop stage must be between 0 and 10 and be >= start stage'
-- R06.6: start row:   between 0 and 100000                 if not raise exception 60006 'R05.6: start row must be between 0 and 100000'
-- R06.7: stop row:    between 0 and 100000 , >= st row     if not raise exception 60007 'R05.7: stop row must be between 0 and 100000 and be >= start row'
-- R06.8: log level:   between 0 and 4                      if not raise exception 60008 'R05.8: log level must be between 0 and 4'
-- R06.9: import id:   is a numeric LRAP file format identifier. This varies with LRAP release. RANGE: 0 < import_id < 10
--                     if stage < 7                         if not raise exception 60009 'R05.9: import id should be between 1 and 10'
-- R07: imports the CallRegister ASAP
-- R09: Configure routine call control to avoid multiple calls of single call routines
-- R11: Configure routine call control to avoid multiple calls of single call routines
-- R13: Get the import id from the file name
--
-- Preconditions: NONE
--
-- Postconditions:
-- POST 02: R02
-- POST 03: R03
-- POST 06: R06
-- POST 07: Parameter defaults:
--    @start_row      1
--    @stop_row       100000
--
-- Process for LRAP Import and scrub:
-------------------------------------------------------------------------------------------------------
-- Stage                                               Preconditions
-------------------------------------------------------------------------------------------------------
-- 01: Initialize (mandatory)                          none
-- 02: Import primary static data                      import_root specified
-- 03: Import the LRAP data                            import_root specified, LRAP file specified
-- 04: Do the S1 fixup                                 s1 pop
-- 05: Stage 5: Copy S1 to S2                          LRAP file imported
-- 06: Import the LRAP corrections files               cor files specified
-- 07: optionally restore s2 from S1 or S3 caches      none
-- 08: Scrub the imported LRAP fixup S2                Import corrections tbl pop
-- 09: Populate the dynamic data staging tables        fixup done
-- 10: Indentify the unmatched dynamic staging data    fixup done
-- 11: Copy S2 to the S3 cache                         LRAP file imported
-- 12: Merge Staging to Main                           fixup done
-- 13: Perform postcondition checks                    none
-------------------------------------------------------------------------------------------------------
-- CHANGES:
-- 230811: Clean import then merge into the main tables, save the import_id as a session setting in import-init
-- 231013: Override @import_id if supplied
-- 231014: ADDED POST Condition CHKS: import_id NOT NULL AND > 0
--         Added support of table logging: clear the table before the main procedure starts
-- 231108: removed params: @import_root which is now supplied to the main fn with a default
-- 240207: added call to sp_clear_call_register to clear the routine call register table
-- 240309: moved the tuncate applog to main as we dont get any logging of main import right now
-- 240323: added sp_write_results_to_cor_file validation now so as to waste time processing if bad p
-- ======================================================================================================
ALTER PROCEDURE [dbo].[sp_mn_imprt_ini]
    @import_root     VARCHAR(450)
   ,@import_file     VARCHAR(150)    -- LRAP import file
   ,@cor_files       VARCHAR(500)   = NULL -- must be specified if stage < 5
   ,@start_stage     INT            --= 0
   ,@stop_stage      INT            --= 100
   ,@start_row       INT            --= 1
   ,@stop_row        INT            --= 100000
   ,@restore_s1_s2   BIT            = 0      -- Reset the state of Staging2 to the original LRAP import - useful when testing corrections
   ,@restore_s3_s2   BIT            = 0      -- Reset the state of Staging2 to the Fixed up version of S2 before the Corrections process
   ,@log_level       INT            = 1
   ,@import_eppo     BIT            = 0
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)   = N'sp_mn_imprt_ini'
   ,@msg             VARCHAR(500)  = ''
   ,@ndx             INT
   ,@import_id_cpy   INT
   ,@imp_file        VARCHAR(500)
   ,@import_id       INT
   ,@file_type       VARCHAR(10)

      SET NOCOUNT OFF
      SET XACT_ABORT ON;

-- R01: display the prms
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
';


   BEGIN TRY
      --********************************************************************************
      -- Set defaults:
      --********************************************************************************
      EXEC sp_log 1, @fn, '010: setting defaults';

      IF @import_root IS NULL SET @import_root = 'D:\Dev\Farming\Data';
      IF @start_row   IS NULL SET @start_row   = 1;
      IF @stop_row    IS NULL SET @stop_row    = 100000

      --********************************************************************************
      -- Validation
      --********************************************************************************
      EXEC sp_log 1, @fn, '020: validating preconditions';

      IF @start_stage NOT BETWEEN 0 AND 13      EXEC sp_raise_exception 50005, 'start_stage must be between 0 and 13';
      IF @stop_stage  NOT BETWEEN 0 AND 13      EXEC sp_raise_exception 50006, 'stop_stage must be between 0 and 13';
      IF @start_row   NOT BETWEEN 0 AND 1000000 EXEC sp_raise_exception 50005, 'start_row must be between 1 and 1000000';
      IF @stop_row    NOT BETWEEN 0 AND 1000000 EXEC sp_raise_exception 50005, '@stop_row must be between 1 and 1000000';

      If @start_stage < 7
      BEGIN
         -- R06.3: if stage < 7 then 1 or more cor files must be specified  if not raise exception 60003 'R05.3: 1: or more correction files must be specified if stage < 5'
         EXEC sp_assert_not_null_or_empty @cor_files, '030: 1 or more cor files must be specified if stage <5', @ex_num=60003, @fn=@fn;
         EXEC sp_log 1, @fn, '040: chk @import_root specified';

         -- POST 07: @file_type set = 'txt' or 'xlsx'  and not null
         EXEC sp_assert_not_null_or_empty @import_root, '101:  @import_root',@fn=@fn;


         -----------------------------------------------------------------------------------
         --R04: prefix the root to the import file
         -----------------------------------------------------------------------------------
         SET @import_file = CONCAT(@import_root, CHAR(92), @import_file);

         -- R05.1 @import_root: must be specified if stage < 5 -- if not raise exception 60001 'R05.1: import root must be specified if stage < 5'
         IF (@import_root IS NULL OR dbo.fnLen(@import_root)=0) AND @start_stage < 5
            EXEC sp_raise_exception 60001, '050: R05.1: import root must be specified if stage < 5', @fn=@fn;

         -- R05.3 @cor_files:   must be specified if stage < 5 -- if not raise exception 60003 @cor_files: must be specified if stage < 5
         IF (@cor_files   IS NULL OR dbo.fnLen(@cor_files)=0) AND @start_stage < 5
            EXEC sp_raise_exception 60003, '060: R05.3: 1 or more correction files must be specified if stage < 5', @fn=@fn;
      END

      -- R06.1: import root: must be specified/exist if stage < 4 if not raise exception 60001 'R05.1: import root must be specified if stage < 5'
      --        if stage < 7                         if not raise exception 60009 'R05.9: import id should be between 1 and 10'
      -- R02: Determine the file type - xlsx or txt if stage < 4
      If @start_stage < 4
      BEGIN
         EXEC sp_assert_not_null_or_empty @import_root, '070: Import root must be specified if stage <4', @fn=@fn;
         EXEC sp_log 1, @fn,'080 getting the LRAP import file type([',@import_file,'])';
         SELECT @file_type = ext
         FROM dbo.fnGetFileDetails(@import_file);

         EXEC sp_log 1, @fn,'090 chk @file_type [',ext,']';
         EXEC sp_assert_not_null_or_empty @file_type, ' 131: @file_type', @fn= @fn;

         -- R03.1: Clear AppLog table - by the end of the ini process AppLog will have about 35 rows - so chk this post condidion now - its the only time it should be true
         -- POST 02: R02
         -----------------------------------------------------------------------------------
         -- Get the import id from the data header
         -- R11: Get the import id from the file name
         -----------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '100: calling sp_get_LRAP_import_type @import_file:[', @import_file,']';
         EXEC sp_get_LRAP_import_type @import_file, @import_id OUT;
         EXEC sp_log 1, @fn, '110: @import_id: ',@import_id;
         EXEC dbo.sp_assert_not_null @import_id,    '120: @import_id must not be NULL', @ex_num = 58100; 
         EXEC sp_assert_not_equal -1, @import_id, '130: Unrecognised LRAP import file format (',@import_file,')';
         --------------------------------------------------------------------------------------------------------------------------------
         -- R05.9: @import_id: is a numeric LRAP file format identifier. This varies with LRAP release. RANGE: 0 < import_id < 10 
         -- if not raise exception 60009 'R05.9: import id should be between 1 and 10'
         IF (@import_id < 1) OR (@import_id>10) EXEC sp_raise_exception 60009,'140: R05.9: import id should be between 1 and 10', @fn=@fn;
      END
      EXEC sp_log 1, @fn,'150';

      IF @start_stage < 9
      BEGIN
         -- R05.4: start_stage must be between 0 and 10         -- if not raise exception 60004 'R05.4: start_stage must be between 0 and 10'
         IF (@start_stage <0) OR (@start_stage>10) EXEC sp_raise_exception 60004,'170: R05.4: start_stage must be between 0 and 10', @fn=@fn;

         -- R05.5: @stop_stage:  between 0 and 10, >= st stg    -- if not raise exception 60005 'R05.5: stop stage: must be between 0 and 10 and be >= start stage'
         IF (@stop_stage <0) OR (@stop_stage>10) OR (@start_stage > @stop_stage) EXEC sp_raise_exception 60005,'180: R05.5: stop stage: must be between 0 and 10 and be >= start stage', @fn=@fn;

         -- R05.6: start row must be between 0 and 100000 and be >= start row -- if not raise exception 60006 'R05.6: start row must be between 0 and 10000'
         IF (@start_row <0) OR (@start_row>100000) EXEC sp_raise_exception 60006,'190: R05.6: start row must be between 0 and 100000 and be >= start row', @fn=@fn;

         -- R05.7: 'R05.7: stop row must be between 0 and 100000 and be >= start row' - if not raise exception 60006 'R05.7: stop row must be between 0 and 100000 and be >= start row'
         IF (@stop_row < 0) OR (@stop_row > 100000) EXEC sp_raise_exception 60007,'200: R05.7: stop row must be between 0 and 100000 and be >= start row', @fn=@fn;
      END

      -- R05.8 @log_level:   between 0 and 4                -- if not raise exception 60008 'R05.8: @log_level: must be between 0 and 4'
      IF (@log_level <0 ) OR (@log_level >4 )  EXEC sp_raise_exception 60008,'210: R05.8: @log_level: must be between 0 and 4', @fn=@fn;

     -----------------------------------------------------------------------------------
      -- R03: Set the log level
      -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '220: setting minimum logging level to: ', @log_level, ' mode txt:[',@msg,']';
     --------------------------------------------------------------------------------------------------------------------------------
      -- ASSERTION: Validated parameters
      --------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '230: ASSERTION: Validated parameters';
      EXEC sp_set_log_level @log_level;-- POST 4: set the min log level

      SET @import_id_cpy = @import_id;

      --------------------------------------------------------------------------------------------
      -- ASSERTION: Validation succeeded
      --------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '240: ASSERTION: Validation succeeded';


      --********************************************************************************
      -- Process
      --********************************************************************************
     -----------------------------------------------------------------------------------
      -- R02: Clear the following tables Clear the results tables
     -----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '250: Clear the results tables: CorrectionLog, S2UpdateLog, S2UpdateSummary';
      -- Disable the staging2 on update trigger
      DISABLE TRIGGER staging2.sp_Staging2_update_trigger ON staging2;
      TRUNCATE TABLE CorFiles;
      TRUNCATE TABLE S2UpdateLog;
      TRUNCATE TABLE S2UpdateSummary;
      TRUNCATE TABLE CorrectionLog;
      -- R03.1: Clear AppLog table
     TRUNCATE TABLE Applog;
     TRUNCATE TABLE ImportState;

      -- ASSERTION: @import_id id known and > 0
      EXEC sp_set_ctx_imp_id @import_id;              -- POST 3: set import id

      -- R03: Clear tables
      EXEC sp_log 1, @fn, '260: chk postcondion R03: Cleared tables';
      --   R03.2: Clear CorrectionLog table
      EXEC sp_assert_tbl_not_pop 'CorrectionLog';
      --   R03.3: Clear S2UpdateLog table
      EXEC sp_assert_tbl_not_pop 'S2UpdateLog';
      --   R03.4: Clear S2UpdateSummary table
      EXEC sp_assert_tbl_not_pop 'S2UpdateSummary';

      ----------------------------------------------------------------
   -- R15: Set the session context values:
         -------------------------------------------------------------
   -- R15.1 set ctx: import_root
   EXEC sp_set_session_context_import_root @import_root

   -- file type: txt or xlsx
   -- Cor files
   EXEC sp_log 1, @fn, '270: pop ImportState, Corfiles';

   -- Save parameters in state
   INSERT INTO ImportState
          ( import_root, import_file, cor_files, start_stage, stop_stage, start_row, stop_row, restore_s1_s2, restore_s3_s2
          , log_level, import_eppo, import_id, file_type)
   VALUES (@import_root,@import_file,@cor_files,@start_stage,@stop_stage,@start_row,@stop_row,@restore_s1_s2,@restore_s3_s2
          ,@log_level,@import_eppo,@import_id,@file_type)
   ;

   EXEC sp_init_cor_files @cor_files = @cor_files, @import_root = @import_root;

         -------------------------------------------------------------
         -- 10: Completed processing
         -------------------------------------------------------------
      EXEC sp_log 2, @fn, '400: Completed processing ok';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC dbo.sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '999: leaving, @import_id: [',@import_id,']';
END
/*
EXEC tSQLt.Run 'test.test_099_sp_mn_imprt_ini';
EXEC test.test_099_sp_mn_imprt_ini;
EXEC sp_AppLog_display 'sp_mn_imprt_ini'
*/

GO
