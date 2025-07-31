SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=======================================================================================================================
-- Author:           Terry Watts
-- Create date:      02-Dec-2023
-- Description:      test helper rtn for the sp_crt_tst_hlpr rtn being tested
-- Tested rtn desc:
--  creates a tSQLt test helper routine
-- SAME as the function test.fnCrtTstHlpr - but easier to debug
-- Preconditions:
--    PRE01: params table populated
--
-- Algorithm:
-- Header:
--    Au, crt dt,desc
--    Tested trn params
-- Test helper Signature
--    <test.hlpr_num_><tst_rtn_num>
--    params - 1 line each
-- Initial bloc
--    As, begin
--    Declare bloc
--    log starting params bloc
--    Setup bloc
-- Run tst rtn bloc
--    2 parts: Log, if not expect exception / else exception handler
-- Run Tests bloc
-- End bloc
--    Cleanup, log leaving status
--    end
--    run test comment
--    GO
--
-- Changes:
-- 231115: helper should have same defaults as the tstd rtn
-- 231121: @q_tstd_rtn must exist or exception 56472, '<@q_tstd_rtn> does not exist'
-- 231121: added a try catch handler to log errors
--
-- Tested rtn params:
--    @q_tstd_rtn    NVARCHAR(100),
--    @tst_rtn_num   INT,
--    @crt_or_alter  NCHAR(2),
--    @fn_ret_ty     NVARCHAR(50),
--    @add_step      BIT
--=======================================================================================================================
CREATE PROCEDURE [test].[hlpr_081_sp_crt_tst_hlpr]
    @test_num              NVARCHAR(100)
   ,@inp_qrn               NVARCHAR(100)
   ,@inp_trn               INT            = NULL
   ,@inp_cora              NCHAR(1)       = NULL
   ,@inp_ad_stp            BIT            = NULL -- necessary if we want to search for a line id by step_id
   ,@inp_step_id           NVARCHAR(50)   = NULL -- search id for line note step id not id as id can vary with other modifications
   ,@inp_tst_mode          BIT            = NULL
   ,@inp_stop_stage        INT            = NULL
-- Expected values all optional
   ,@exp_line              NVARCHAR(500)  = NULL -- necessary if we want to search for a line id by step_id
   ,@exp_qrn               NVARCHAR(120)  = NULL
   ,@exp_prm_count         INT            = NULL
   ,@exp_ex_num            INT            = NULL
   ,@exp_ex_msg            NVARCHAR(500)  = NULL
   ,@tst_mode              BIT            = 1    -- for testing - copy tmp tables to permananent tables for teting
-- Stage 01
   ,@exp_rtn_nm            NVARCHAR(100)  = NULL
   ,@exp_schema_nm         NVARCHAR(100)  = NULL
   ,@exp_tst_rtn_num       INT            = NULL
   ,@exp_crt_or_alter      NCHAR(1)       = NULL
   ,@exp_crse_rtn_ty_code  NVARCHAR(1)    = NULL
   ,@exp_detld_rtn_ty_code NCHAR(2)       = NULL
   ,@exp_rtn_ty_nm         NVARCHAR(25)   = NULL
   ,@exp_tst_proc_mn_nm    NVARCHAR(120)  = NULL
   ,@exp_tst_proc_hlpr_nm  NVARCHAR(120)  = NULL
   ,@exp_error_num         INT            = NULL-- if error this will not be NULL
   ,@exp_error_msg         NVARCHAR(500)  = NULL-- if error this will not be NULL
-- stage 02 extra exps
   ,@exp_param_nm          NVARCHAR(60)   = NULL
   ,@exp_type_nm           NVARCHAR(50)   = NULL
   ,@exp_ordinal           INT            = NULL
   ,@exp_parameter_mode    NVARCHAR(60)   = NULL
   ,@exp_param_ty_len      NVARCHAR(60)   = NULL
   ,@exp_is_output         NVARCHAR(60)   = NULL
   ,@exp_is_chr_ty         BIT            = NULL
   ,@exp_is_result         BIT            = NULL
   ,@exp_is_nullable       NVARCHAR(60)   = NULL
   ,@exp_rtn_ty_code       NVARCHAR(60)   = NULL
   ,@exp_rtn_id            INT            = NULL
-- Stage 03 extra exps
-- Stage 04 extra exps
   ,@exp_fn_ret_ty         NVARCHAR(60)   = NULL
   ,@display_tables        BIT            = 0
AS
BEGIN
   DECLARE
    @fn                    NVARCHAR(35)   = N'hlpr_081_sp_crt_tst_hlpr'
   ,@nl                    NVARCHAR(1)    = NCHAR(13)
   ,@n                     INT
   -- stage 1 acts
   ,@act_schema_nm         NVARCHAR(50)
   ,@act_qrn               NVARCHAR(120)
   ,@act_tst_rtn_num       INT
   ,@act_crt_or_alter      NCHAR(1)
   ,@act_ex_num            INT
   ,@act_ex_msg            NVARCHAR(500)
   ,@act_line              NVARCHAR(500)
   ,@act_crse_rtn_ty_code  NVARCHAR(1)
   ,@act_detld_rtn_ty_code NCHAR(2)
   ,@act_rtn_ty_nm         NVARCHAR(25)
   ,@act_rtn_nm            NVARCHAR(100)
   ,@act_tst_proc_mn_nm    NVARCHAR(120)
   ,@act_tst_proc_hlpr_nm  NVARCHAR(120)
   ,@act_count             INT
   ,@act_error_num         INT            -- if error this will not be NULL
   ,@act_error_msg         NVARCHAR(500)  -- if error this will not be NULL
   -- stage 2 acts
   ,@act_param_nm           NVARCHAR(120)
   ,@act_ordinal            NVARCHAR(120)
   ,@act_param_ty_nm        NVARCHAR(120)
   ,@act_param_ty_nm_full   NVARCHAR(120)
   ,@act_param_ty_id        NVARCHAR(120)
   ,@act_param_ty_len       NVARCHAR(120)
   ,@act_is_output          BIT
   ,@act_has_default_value  BIT
   ,@act_default_value      SQL_VARIANT
   ,@act_is_chr_ty          BIT
   ,@act_is_nullable        BIT
   ,@act_is_result          BIT
   ,@act_parameter_mode     NVARCHAR(30)
   ,@act_rtn_ty_code        NVARCHAR(120)
   ,@act_rtn_id             NVARCHAR(120)
   ,@act_type_nm            NVARCHAR(50)
   -- Stage 04 acts
   ,@act_fn_ret_ty          NVARCHAR(60)   = NULL
   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @fn, @test_num;
---   - SETUP:
      -- <TBD>
---   - RUN tested rtn:
      EXEC sp_log 1, @fn, '005: running tested rtn: EXEC test.sp_crt_tst_hlpr @q_tstd_rtn,@tst_rtn_num,@crt_or_alter,@fn_ret_ty,@add_step;';
      IF @exp_ex_num IS NOT NULL
      BEGIN -- Expect an exception here
         BEGIN TRY
            EXEC sp_log 1, @fn, '05: Expect an exception here';
            EXEC sp_log_sub_tst @fn, 05, 'Expect an exception here'
            EXEC test.sp_crt_tst_rtns_init
                @qrn          = @inp_qrn
               ,@trn          = @inp_trn
               ,@cora         = @inp_cora
               ,@ad_stp       = @inp_ad_stp
               ,@tst_mode     = @inp_tst_mode
               ,@stop_stage   = @inp_stop_stage
            EXEC test.sp_crt_tst_hlpr
               ;
            EXEC sp_log 4, @fn, '010: oops! Expected an exception here';
            THROW 51000, ' Expected an exception but none were thrown', 1;
         END TRY
         BEGIN CATCH
            EXEC sp_log 1, @fn, '015: caught expected exception';
            IF @exp_ex_num <> -1 -- check the ex num
            BEGIN
               SET @act_ex_num = ERROR_NUMBER();
               EXEC sp_log 1, @fn, '020 check ex num , exp: ', @exp_ex_num, ' act: ', @act_ex_num;
               EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num;
            END -- IF @exp_ex_num <> -1
            IF @exp_ex_msg IS NOT NULL  -- check the ex msg
            BEGIN
               SET @act_ex_msg = ERROR_MESSAGE();
               EXEC sp_log 1, @fn, '025 check ex msg, exp: ', @exp_ex_msg, ' act: ', @act_ex_msg;
               EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg;
            END -- IF @exp_ex_msg IS NOT NULL
            EXEC sp_log 2, @fn, '030 test# ',@test_num, ': exception test PASSED';
            RETURN;
         END CATCH
      END -- Expect exception
      EXEC sp_log 1, @fn, '035: Calling tested rtn: do not expect an exception now';
      EXEC test.sp_crt_tst_rtns_init
          @qrn          = @inp_qrn
         ,@trn          = @inp_trn
         ,@cora         = @inp_cora
         ,@ad_stp       = @inp_ad_stp
         ,@tst_mode     = @inp_tst_mode
         ,@stop_stage   = @inp_stop_stage;
      EXEC test.sp_crt_tst_hlpr
         ;
      EXEC sp_log 2, @fn, '040: Returned from tested rtn: no exception thrown';
      WHILE 1=1 -- Stage Test loop
      BEGIN
         ----------------------------------------------------------------------------------------------------------------------------
         -- TESTS:
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '045: running tests...';
         ----------------------------------------------------------------------------------------------------------------------------
         -- Marker test
         ----------------------------------------------------------------------------------------------------------------------------
         IF @inp_step_id IS NOT NULL
         BEGIN
            EXEC sp_log 1, @fn, '050: checking @exp_line exists for step:', @inp_step_id;
            EXEC tSQLt.AssertNotEquals NULL, @exp_line, '@exp_line must be specified if @step_id is specified';
            SELECT @act_line = line FROM test.tstActDefHlpr where line LIKE CONCAT('%', @inp_step_id, '%');
            EXEC sp_log 1, @fn, '060: checking if the actual line matches the expected line..',@nl
            , 'exp:[', @exp_line,']',@nl
            , 'act:[', @act_line,']',@nl
            ;
            IF ((@act_line IS NULL) OR (@act_line NOT LIKE @exp_line))
            BEGIN
               SET @act_error_msg = CONCAT('actual line does not match expected line',@nl
               ,'exp: [',@exp_line, ']',@nl
               ,'act: [',@act_line, ']');
               EXEC sp_log 4, @fn, '065: ', @act_error_msg;
               EXEC tSQLt.Fail @act_error_msg;
            END
         END -- end of marker test
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 01 tests: validate and init default params if necessary --> fnCrtTstHlprInit
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '070: Stage 01 tests';
         --IF @inp_stop_stage = 1 -- Refactor this to a separate test later when the tst harness works
         --BEGIN
            --EXEC sp_log 1, @fn, '090: hlpr_prms_tbl checks ...';
/*            EXEC sp_chk_tbl_populated 'test.hlpr_prms_tbl';
            -- chk parameters are entered in the test.hlpr_prms_tbl table correctly.
            IF @exp_qrn               IS NOT NULL EXEC tSQLt.AssertEquals @exp_qrn              , @act_qrn              ,'qrn              ','12';
            IF @exp_tst_rtn_num       IS NOT NULL EXEC tSQLt.AssertEquals @exp_tst_rtn_num      , @act_tst_rtn_num      ,'tst_rtn_num      ','13';
            IF @exp_crt_or_alter      IS NOT NULL EXEC tSQLt.AssertEquals @exp_crt_or_alter     , @act_crt_or_alter     ,'crt_or_alter     ','14';
            IF @exp_crse_rtn_ty_code  IS NOT NULL EXEC tSQLt.AssertEquals @exp_crse_rtn_ty_code , @act_crse_rtn_ty_code ,'crse_rtn_ty_code ','15';
            IF @exp_detld_rtn_ty_code IS NOT NULL EXEC tSQLt.AssertEquals @exp_detld_rtn_ty_code, @act_detld_rtn_ty_code,'detld_rtn_ty_code','16';
            IF @exp_rtn_ty_nm         IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_ty_nm        , @act_rtn_ty_nm        ,'rtn_ty_nm        ','17';
            IF @exp_schema_nm         IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm        , @act_schema_nm        ,'schema_nm        ','18';
            IF @exp_rtn_nm            IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm           , @act_rtn_nm           ,'rtn_nm           ','19';
            IF @exp_tst_proc_mn_nm    IS NOT NULL EXEC tSQLt.AssertEquals @exp_tst_proc_mn_nm   , @act_tst_proc_mn_nm   ,'tst_proc_mn_nm   ','20';
            IF @exp_tst_proc_hlpr_nm  IS NOT NULL EXEC tSQLt.AssertEquals @exp_tst_proc_hlpr_nm , @act_tst_proc_hlpr_nm ,'tst_proc_hlpr_nm ','21';
            IF @exp_error_num         IS NOT NULL EXEC tSQLt.AssertEquals @exp_error_num        , @act_error_num        ,'error_num        ','22';
            IF @exp_error_msg         IS NOT NULL EXEC tSQLt.AssertEquals @exp_error_msg        , @act_error_msg        ,'error_msg        ','23';
            EXEC sp_log 1, @fn, '095: hlpr_prms_tbl column stage 1 field checks passed';
         --END
         IF @inp_stop_stage = 1 BREAK;
*/
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 02 tests: Get the tested rtn's parameters
         -- sp_crt_tst_hlpr Stage 0 populates the test.ParamTable with the tested rtn's parameters, fields are:
         --        rtn_nm,schema_nm,param_nm,ordinal,param_ty_nm,param_ty_nm_full,param_ty_id,param_ty_len,is_output,has_default_value
         --       ,default_value,is_nullable,rtn_ty_nm,rtn_ty_code,rtn_id,error_num,error_msg
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '100: Stage 02 tests';
         --EXEC sp_chk_tbl_populated 'test.ParamTable', 1
         SELECT
             @act_param_nm       = param_nm
            ,@act_type_nm        = type_nm
            ,@act_ordinal        = ordinal
            ,@act_parameter_mode = parameter_mode
            ,@act_is_chr_ty      = is_chr_ty
            ,@act_is_result      = is_result
            ,@act_is_output      = is_output
            ,@act_is_nullable    = is_nullable
         FROM test.ParamDetails
         EXEC sp_log 1, @fn, '105: chk prm param_nm';
--         IF @exp_rtn_nm           IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm          ,@act_rtn_nm          ,'rtn_nm          ','24';
--         IF @exp_schema_nm        IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm       ,@act_schema_nm       ,'schema_nm       ','25';
         IF @exp_param_nm         IS NOT NULL EXEC tSQLt.AssertEquals @exp_param_nm        ,@act_param_nm        ,'param_nm        ','26';
         IF @exp_type_nm          IS NOT NULL EXEC tSQLt.AssertEquals @exp_type_nm         ,@act_type_nm         ,'type_nm         ','27';
         IF @exp_ordinal IS NOT NULL EXEC tSQLt.AssertEquals @exp_ordinal,@act_ordinal,'ordinal','28';
         IF @exp_parameter_mode   IS NOT NULL EXEC tSQLt.AssertEquals @exp_parameter_mode  ,@act_parameter_mode  ,'parameter_mode  ','29';
         IF @exp_is_chr_ty        IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_chr_ty       ,@act_is_chr_ty       ,'is_chr_ty       ','30';
         IF @exp_is_result        IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_result       ,@act_is_result       ,'is_result       ','31';
         IF @exp_is_output        IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_output       ,@act_is_output       ,'is_output       ','32';
         IF @exp_is_nullable      IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_nullable     ,@act_is_nullable     ,'is_nullable     ','33';
--         EXEC sp_log 1, @fn, '20: chk prm param_ty_nm';
--         EXEC sp_log 1, @fn, '20: chk prm param_ty_nm_full ';
--         EXEC sp_log 1, @fn, '20: chk prm param_ty_id';
--         EXEC sp_log 1, @fn, '20: chk prm param_ty_len';
--         EXEC sp_log 1, @fn, '20: chk prm is_output';
--         EXEC sp_log 1, @fn, '20: chk prm has_default_value';
--         EXEC sp_log 1, @fn, '20: chk prm default_value';
--         EXEC sp_log 1, @fn, '20: chk prm is_nullable';
--         EXEC sp_log 1, @fn, '20: chk prm rtn_ty_code';
--         EXEC sp_log 1, @fn, '20: chk prm rtn_id';
         IF @inp_stop_stage = 2 BREAK;
         EXEC sp_log 1, @fn, '110: Stage 03 tests: Add the test specific chk parms';
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 03 tests: Add the test specific chk parms --> fnCrtHlprCodeTstSpecificPrms(@schema_nm, @rtn_nm, @n)
         ----------------------------------------------------------------------------------------------------------------------------
         --EXEC sp_log 1, @fn, '30: Stage 03 tests';
         -- count
         IF @exp_prm_count IS NOT NULL
         BEGIN
             EXEC sp_log 1, @fn, '115: Stage 04 tests';
            SELECT @act_count = COUNT(*) FROM test.ParamDetails
            EXEC tSQLt.AssertEquals @exp_prm_count, @act_count, 'param table count', '35'
         END
         --IF @inp_stop_stage = 3
         --BEGIN
         --   SELECT * FROM test.ParamDetails
         --   BREAK;
         --END
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 04 tests: Get the rtn return type if scalar fn and not specified
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '120: Stage 04 tests';
         IF @exp_fn_ret_ty         IS NOT NULL EXEC tSQLt.AssertEquals @exp_fn_ret_ty, @act_fn_ret_ty, 'fn_ret_ty ', '36';
         IF @inp_stop_stage = 4 BREAK;
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 05 tests: Create the test rtn Header:  ->fnCrtHlprCodeTstHdr
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '125: Stage 05 tests';
         IF @inp_stop_stage = 5 BREAK;
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 06 tests: Create the tested routine call ->fnCrtHlprCodeCallTstdRtn
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '130: Stage 06 tests';
         IF @inp_stop_stage = 6 BREAK;
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 07 tests: Create the hlper proc begin bloc ->fnCrtHlprCodeBegin
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '135: Stage 07 tests';
         IF @inp_stop_stage = 7 BREAK;
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 08 tests: Create the  run tested rtn bloc with exception handler  --> fnCrtHlprCodeRunTstdRtn()
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '140: Stage 08 tests';
         IF @inp_stop_stage = 8 BREAK;
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 09 tests: Create the run Tests bloc  --> fnCrtHlprCodeRunTsts
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '145: Stage 09 tests';
         IF @inp_stop_stage = 9 BREAK;
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 10 tests: Create the cleanup bloc: --> fnCrtHlprCodeCleanup(): log leaving PASS status
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '150: Stage 10 tests';
         IF @inp_stop_stage = 10 BREAK;
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 11 tests: Create the end bloc:   end, run test comment,  GO --> fnCrtHlprCodeEnd()
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '155: Stage 11 tests';
         IF @inp_stop_stage = 11 BREAK;
         ----------------------------------------------------------------------------------------------------------------------------
         -- Stage 12 tests: pop the test.tstActDefHlpr table for testing and display the generated hlpr code --> test.sp_pop_display_ActDefHlp_tbl
         ----------------------------------------------------------------------------------------------------------------------------
         EXEC sp_log 1, @fn, '160: Stage 12 tests';
         IF @inp_stop_stage = 12 BREAK;
      ---- CLEANUP:
         -- <TBD>
         IF @display_tables = 1
         BEGIN
            SELECT * FROM test.RtnDetails;
            SELECT * FROM test.ParamDetails;
            SELECT * FROM test.HlprDef;
         END
         EXEC sp_log 1, @fn, '990: all subtests PASSED';
         EXEC test.sp_tst_hlpr_hndl_success;
         BREAK;
      END -- end of Stage Test loop
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      SELECT * FROM test.RtnDetails;
      SELECT * FROM test.ParamDetails;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '99: leaving OK';
END
/*
EXEC tSQLt.Run 'test.test_081_sp_crt_tst_hlpr';
EXEC tSQLt.RunAll;
SELECT * FROM test.hlpr_prms_tbl;
*/
GO

