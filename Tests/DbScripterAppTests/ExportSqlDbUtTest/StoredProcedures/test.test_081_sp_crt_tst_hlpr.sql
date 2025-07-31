SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      02-Dec-2023
-- Description:      main test rtn for the test.sp_crt_tst_hlpr rtn being tested
-- Tested rtn desc:
--  creates a tSQLt test helper routine
-- SAME as the function test.fnCrtTstHlpr - but easier to debug
-- Preconditions:
--    PRE01: params table populated
--
-- Algoritm:
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
--========================================================================================
CREATE PROCEDURE [test].[test_081_sp_crt_tst_hlpr]
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'T081_sp_crt_tst_hlpr'
      ,@exp_mn_tst_nm      NVARCHAR(100)
      ,@exp_hlpr_tst_nm    NVARCHAR(100)
      ,@exp_nxt_tst_num    INT;
   EXEC sp_log 2, @fn,'01: starting';
   EXEC test.sp_tst_mn_st @fn
   WHILE 1=1    -- Run test loop
   BEGIN
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 01. validate and init default params if necessary
      -- including BUG 01: handle wonky [] if not fixed this will return an error
      ----------------------------------------------------------------------------------------------------------------------------
      SET @exp_mn_tst_nm   = CONCAT('test_', @exp_nxt_tst_num, '_fnGetRtnDef')
      SET @exp_hlpr_tst_nm = CONCAT('hlpr_', @exp_nxt_tst_num, '_fnGetRtnDef')
      EXEC sp_log 2, @fn,'010, Stage 01 tests, next test num: ', @exp_nxt_tst_num;
      --------------------------------------------------------
      SET @exp_nxt_tst_num = test.fnGetNxtTstRtnNum();
      EXEC test.hlpr_081_sp_crt_tst_hlpr
          @test_num              = 'TG001: S01'
         ,@inp_qrn               = 'dbo.[fnGetRtnDef'
         ,@inp_trn               = 99
         ,@inp_cora              = 'C'
         ,@inp_ad_stp            = 1
         ,@inp_step_id           = NULL -- search id for line note step id not id as id can vary with other modifications
         ,@inp_tst_mode          = NULL
         ,@inp_stop_stage        = NULL
         ,@exp_qrn               = 'dbo.fnGetRtnDef'
         ,@exp_ex_num            = NULL
         ,@exp_ex_msg            = NULL
         ,@tst_mode              = 1
         ,@exp_tst_rtn_num       = @exp_nxt_tst_num
         ,@exp_crt_or_alter      = 'C'
         ,@exp_crse_rtn_ty_code  = 'F'
         ,@exp_detld_rtn_ty_code = 'TF'
         ,@exp_rtn_ty_nm         = 'SQL_TABLE_VALUED_FUNCTION'
         ,@exp_schema_nm         = 'dbo'
         ,@exp_rtn_nm            = 'fnGetRtnDef'
         ,@exp_tst_proc_mn_nm    = 'test_100_fnGetRtnDef'
         ,@exp_tst_proc_hlpr_nm  = 'hlpr_100_fnGetRtnDef'
         ,@exp_error_num         = NULL
         ,@exp_error_msg         = NULL
         ,@display_tables        = 1
      --------------------------------------------------------
BREAK;
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 02 Get the tested rtn's parameters --> fnCrtHlprCodeTstdRtnPrms()
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'020, Stage 02 tests';
      DECLARE @obj_id INT
      SELECT @obj_id = rtn_id FROM  paramsVw WHERE rtn_nm = 'fnGetRtnDef';
/*
      EXEC test.hlpr_081_sp_crt_tst_hlpr 
          @test_num              = 'TG002: Stg 02'
         ,@inp_qrn               = '[dbo].[fnGetRtnDef]'
         ,@stop_stage            = 2
         ,@exp_schema_nm         = 'dbo'
         ,@exp_rtn_nm            = 'fnGetRtnDef'
         ,@exp_tst_rtn_num       = NULL
         ,@exp_param_nm          = '@rtn_name'
         ,@exp_param_ty_nm       = 'NVARCHAR'
         ,@exp_param_ty_nm_full  = 'NVARCHAR(120)'
         ,@exp_param_ty_id       = 231
         ,@exp_param_ty_len      = 120
         ,@exp_is_output         = 0
         ,@exp_has_default_value = 0
         ,@exp_default_value     = 0
         ,@exp_is_nullable       = 1
         ,@exp_rtn_ty_nm         = 'Table function'
         ,@exp_rtn_ty_code       = 'TF'
         ,@exp_rtn_id            = @obj_id
      EXEC sp_log 2, @fn, 'TG002 ret';
      SELECT * FROM test.ParamTable;
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 03 Add the test specific chk parms --> fnCrtHlprCodeTstSpecificPrms(@schema_nm, @rtn_nm, @n)
      ----------------------------------------------------------------------------------------------------------------------------
      -- chk: rtn_nm	rtn_id	schema_nm	param_nm	ordinal_position	param_ty_nm	param_ty_nm_full	param_ty_id	param_ty_len	is_output	has_default_value	default_value	is_nullable	rtn_ty_nm	rtn_ty_code	col2_st	col3_st	col4_st	error_num	error_msg
      EXEC sp_log 2, @fn,'030, Stage 03 tests';
      EXEC test.hlpr_081_sp_crt_tst_hlpr 
          @test_num              = 'TG002: TF-DECL-ACTRTNDEF-TV'
         ,@inp_qrn               = 'dbo.[fnGetRtnDef'
         ,@stop_stage            = 3
         ,@exp_schema_nm         = 'dbo'
         ,@exp_rtn_nm            = 'fnGetRtnDef'
         ,@exp_param_nm          = '@rtn_name'
         ,@exp_prm_count         = 5
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 04: Get the rtn return type if scalar fn and not specified  --> fnGetScalarFnReturnType
      -- already test fn: test.test_052_fnCrtTstdRtnCall so tst integratin here
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'010, Stage 04 tests';
      EXEC test.hlpr_081_sp_crt_tst_hlpr 
          @test_num              = 'TG002: TF-DECL-ACTRTNDEF-TV'
         ,@q_tstd_rtn            = 'dbo.fnGetLine'
         ,@stop_stage            = 4
         ,@exp_rtn_ty_nm         = 'NVARCHAR(100)'
      BREAK;
*/
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 05: Create tst rtn hdr: Auth, crt dt, desc, Tstd rtn prms   -->fnCrtHlprCodeTstHdr
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'010, Stage 05 tests';
      DECLARE @exp_desc NVARCHAR(4000)='-- Description: returns the substring in sql starting at pos until new line 
--              or 100 chars max, or the remaining string whichever is the 
--              the shortest'
      EXEC test.hlpr_081_sp_crt_tst_hlpr 
          @test_num              = 'TG002: TF-DECL-ACTRTNDEF-TV'
         ,@inp_qrn               = 'dbo.fnGetLine'
      BREAK;
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 06: Create the tested routine call                          -->fnCrtHlprCodeCallTstdRtn: including Create the helper signature <test.hlpr_num_><tst_rtn_num> params: 1 line each
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'010, Stage 06 tests';
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 07: Create the hlper proc begin bloc ->fnCrtHlprCodeBegin
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'010, Stage 07 tests';
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 08: Create the  run tested rtn bloc with exception handler  --> fnCrtHlprCodeRunTstdRtn() 
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'010, Stage 08 tests';
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 09: Create the run Tests bloc  --> fnCrtHlprCodeRunTsts
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'010, Stage 09 tests';
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 10: Create the cleanup bloc: --> fnCrtHlprCodeCleanup(): log leaving PASS status
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'010, Stage 10 tests';
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 11: Create the end bloc:   end, run test comment,  GO --> fnCrtHlprCodeEnd()
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'010, Stage 11 tests';
      ----------------------------------------------------------------------------------------------------------------------------
      -- Stage 12: pop the test.tstActDefHlpr table for testing and display the generated hlpr code --> test.sp_pop_display_ActDefHlp_tbl
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'010, Stage 12 tests';
      ----------------------------------------------------------------------------------------------------------------------------
      -- BUG 02: IF TF TF-POP-ACTRTNDEF-TV
      ----------------------------------------------------------------------------------------------------------------------------
      ----------------------------------------------------------------------------------------------------------------------------
      -- BUG 03: IF TF replace this dbo.fnGetRtnDef @rtn_name; with INSERT INTO @actRtnDef (line) SELECT line from dbo.fnGetRtnDef(@rtn_name); STEP id: TF-POP-ACTRTNDEF_TV
      ----------------------------------------------------------------------------------------------------------------------------
      ----------------------------------------------------------------------------------------------------------------------------
      -- BUG 04: @act_ex_num,@act_ex_msg,@error_msg not declared
      ----------------------------------------------------------------------------------------------------------------------------
      ----------------------------------------------------------------------------------------------------------------------------
      -- BUG 05: @error_msg L77 remove closing ' on first line, change was not found' -> was not found');
      ----------------------------------------------------------------------------------------------------------------------------
      ----------------------------------------------------------------------------------------------------------------------------
      -- BUG 06: Duplicate END at end of script
      ----------------------------------------------------------------------------------------------------------------------------
      BREAK; -- end of tests
   END -- WHILE Run test loop
   EXEC test.sp_tst_mn_cls;
   EXEC sp_log 2, @fn, '99: leaving, All subtests PASSED'
END
/*
EXEC tSQLt.Run 'test.test_081_sp_crt_tst_hlpr';
EXEC tSQLt.RunAll;
*/
GO

