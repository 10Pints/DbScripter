SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=======================================================================================================================
-- Author:           Terry Watts
-- Create date:      15-APR-2023
-- Description:      creates the script for a test helper routine
--
-- Design: see EA ut/Use Case Model/Test Automation/Create Helper rotine Use case/Create the Helper routine
-- Algorithm:
-- Create the test helper script
--
-- Preconditions:
--    test.rtnDetails and test.ParamDetails populated
--=======================================================================================================================
CREATE PROCEDURE [test].[hlpr_086_sp_crt_tst_hlpr_script]
    @tst_num              NVARCHAR(100)
   ,@inp_qrn               NVARCHAR(100)
   ,@inp_trn               INT            = NULL
   ,@inp_cora              NCHAR(1)       = NULL
   ,@inp_ad_stp            BIT            = NULL -- flag to add the step comment sp we can find it and test it
   ,@tst_step_id           NVARCHAR(50)   = NULL -- search id for line NOTE step id not id as id can vary
   ,@inp_tst_mode          BIT            = NULL
   ,@inp_stop_stage        INT            = NULL
   ,@exp_ex_num            INT            = NULL
   ,@exp_ex_msg            NVARCHAR(500)  = NULL
   ,@display_script        BIT            = 0
-- Expected values all optional
   ,@exp_line              NVARCHAR(500)  = NULL -- necessary if we want to search for a line id by step_id
AS
BEGIN
   DECLARE
    @fn                    NVARCHAR(35)   = N'H086_sp_crt_tst_hlpr'
   ,@nl                    NVARCHAR(1)    = NCHAR(13)
   ,@n                     INT
   ,@params                NVARCHAR(MAX)
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
   BEGIN TRY
      SET @params = CONCAT
      (
'
@tst_num       :[',@tst_num      ,'[
@inp_qrn       :[',@inp_qrn       ,'[
@inp_trn       :[',@inp_trn       ,'[
@inp_cora      :[',@inp_cora      ,'[
@inp_ad_stp    :[',@inp_ad_stp    ,'[
@tst_step_id   :[',@tst_step_id   ,'[
@inp_tst_mode  :[',@inp_tst_mode  ,'[
@inp_stop_stage:[',@inp_stop_stage,'[
@exp_ex_num    :[',@exp_ex_num    ,'[
@exp_ex_msg    :[',@exp_ex_msg    ,'[
@display_script:[',@display_script,'[
@exp_line      :[',@exp_line      ,']'
      );
      EXEC test.sp_tst_hlpr_st @fn=@fn, @tst_num=@tst_num, @params=@params;
   ---- SETUP:
      EXEC test.sp_crt_tst_rtns_init
          @qrn          = @inp_qrn
         ,@trn          = @inp_trn
         ,@cora         = @inp_cora
         ,@ad_stp       = @inp_ad_stp
         ,@tst_mode     = @inp_tst_mode
         ,@stop_stage   = @inp_stop_stage
      SELECT * FROM test.RtnDetails;
      SELECT * FROM test.ParamDetails;
   ---- RUN tested rtn:
      EXEC sp_log 1, @fn, '005: running sp_crt_tst_hlpr_script';
      IF @exp_ex_num IS NOT NULL
      BEGIN -- Expect an exception here
         BEGIN TRY
            EXEC sp_log 1, @fn, '05: Calling sp_crt_tst_hlpr_script, expect exception';
            --EXEC sp_log_sub_tst @fn, 05, 'Expect an exception here'
            EXEC test.sp_crt_tst_hlpr_script;
            EXEC sp_log 4, @fn, '010: oops! Expected exception was not thrown';
            THROW 51000, ' Expected exception was not thrown', 1;
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
            EXEC sp_log 2, @fn, '030 test# ',@tst_num, ': exception test PASSED';
            RETURN;
         END CATCH
      END  -- end   Expect exception        bloc
      ELSE -- start Do not expect exception bloc
      BEGIN
         EXEC sp_log 1, @fn, '035: Calling sp_crt_tst_hlpr_script';
         EXEC test.sp_crt_tst_hlpr_script;
         EXEC sp_log 2, @fn, '040: Returned from tested rt';
         WHILE 1=1 -- Stage Test loop
         BEGIN
            ----------------------------------------------------------------------------------------------------------------------------
            -- TESTS:
            ----------------------------------------------------------------------------------------------------------------------------
            EXEC sp_log 1, @fn, '045: running tests...';
            ----------------------------------------------------------------------------------------------------------------------------
            -- Marker test
            ----------------------------------------------------------------------------------------------------------------------------
            IF @tst_step_id IS NOT NULL
            BEGIN
               EXEC sp_log 1, @fn, '050: checking @exp_line exists for step:', @tst_step_id;
               EXEC tSQLt.AssertNotEquals NULL, @exp_line, '@exp_line must be specified if @step_id is specified';
               SELECT @act_line = line FROM test.tstActDefHlpr where line LIKE CONCAT('%', @tst_step_id, '%');
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
             IF @inp_stop_stage = 12 BREAK;
            ---- CLEANUP:
            -- <TBD>
            IF @display_script = 1
            BEGIN
               --SELECT * FROM test.RtnDetails;
               --SELECT * FROM test.ParamDetails;
               SELECT id, line as [line                                                                                                                           .]
               FROM test.HlprDef;
            END
            EXEC sp_log 1, @fn, '990: all subtests PASSED';
            EXEC test.sp_tst_hlpr_hndl_success;
            BREAK;
         END
      END -- end of Stage Test loop
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      SELECT id, line as [line                                                                                                                           .]
      FROM test.HlprDef;
      SELECT * FROM test.RtnDetails;
      SELECT * FROM test.ParamDetails;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '99: leaving OK';
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
*/
GO

