SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      24-APR-2024
-- Description:      test helper rtn for the sp_crt_tst_mn_compile rtn
-- Tested rtn desc:  creates and compiles the main test rtn
--
-- Preconditions
--    Test.RtnDetails table pop'd
--    Test.TestDef    table pop'd
--
-- Postconditions:                     EX
-- POST 01: the main test procedure is compiled i the DB or EX 63200, 'failed to compile the main test script'
-- POST 02: the file exists'
--
-- Test algorithm:
-- Check procedure not created
-- Create the procedure (run teh testyed rtn)
-- Check procedure created
--
-- test algorithm:
-- check procedure not created
-- run routine
-- check procedure created
-- dtl chk: compare the lines
--========================================================================================
CREATE PROCEDURE [test].[hlpr_012_sp_crt_tst_mn_compile]
    @tst_num         NVARCHAR(100)
   ,@qrn             NVARCHAR(100)
   ,@trn             INT
   ,@cora            NCHAR(2)
   ,@inp_file        NVARCHAR(MAX)  -- including schema
   ,@run_detail_tst  BIT = 0
   ,@exp_ex_num      INT            = NULL
   ,@exp_ex_msg      NVARCHAR(500)  = NULL
   ,@display_tables  BIT            = 0
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = N'hlpr_012_sp_crt_tst_mn_compile'
   ,@act_ex_num      INT            = NULL
   ,@act_ex_msg      NVARCHAR(500)  = NULL
   ,@ad_stp          BIT            = 1 -- used in testing to identify a step with a unique name (not an incremental int id)
   ,@rtn_nm          NVARCHAR(60)
   ,@tst_mode        BIT            = 1 -- for testing - copy tmp tables to permananent tables for teting
   ,@schema_nm       NVARCHAR(32)
   ,@sql             NVARCHAR(3000)
   ,@stop_stage      INT            = 99 -- stage 12 for testing - display script
   ,@mn_tst_rtn_nm   NVARCHAR(60)
   ,@q_mn_tst_rtn_nm NVARCHAR(60)
   ,@hlpr_rtn_nm     NVARCHAR(60)
   ,@throw_if_err    BIT            = 1
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
   EXEC sp_log 2, @fn, '001: params:
tst_num        :[', @tst_num       ,']
qrn            :[', @qrn           ,']
trn            :[', @trn           ,']
cora           :[', @cora          ,']
inp_file       :[', @inp_file      ,']
run_detail_tst :[', @run_detail_tst,']
exp_ex_num     :[', @exp_ex_num    ,']
exp_ex_msg     :[', @exp_ex_msg    ,']
@display_tables:[', @display_tables ,']'
;
   -- SETUP:
   EXEC test.sp_get_rtn_details @qrn=@qrn, @trn=@trn, @cora=@cora;
   -- Create the script
   EXEC test.sp_crt_tst_mn_script;
   ----------------------------------------------------------------------------------
   -- Get the cached details
   ----------------------------------------------------------------------------------
   EXEC sp_log 2, @fn,'005: getting the cached details';
   SELECT
         @qrn          = qrn
      ,@schema_nm    = schema_nm
      ,@rtn_nm       = rtn_nm
      ,@trn          = trn
      ,@cora         = cora
      ,@ad_stp       = ad_stp
      ,@tst_mode     = tst_mode
      ,@stop_stage   = stop_stage
      ,@mn_tst_rtn_nm= tst_rtn_nm
      ,@hlpr_rtn_nm  = hlpr_rtn_nm
   FROM test.RtnDetails;
   SET @q_mn_tst_rtn_nm = CONCAT('test.', @mn_tst_rtn_nm);
   EXEC sp_log 2, @fn, '010: cached params:
@qrn          :[',@qrn         ,']
@trn          :[',@trn         ,']
@trn          :[',@trn         ,']
@schema_nm    :[',@schema_nm   ,']
@rtn_nm       :[',@rtn_nm      ,']
@cora         :[',@cora        ,']
@ad_stp       :[',@ad_stp      ,']
@tst_mode     :[',@tst_mode    ,']
@stop_stage   :[',@stop_stage  ,']
@throw_if_err :[',@throw_if_err,']
@mn_tst_rtn_nm:[',@mn_tst_rtn_nm,']
@hlpr_rtn_nm  :[',@hlpr_rtn_nm ,']'
;
   -- Display tyhe details tables
   IF @display_tables = 1
   BEGIN
      SELECT * FROM test.RtnDetails;
      SELECT * FROM test.ParamDetails;
      SELECT * FROM test.TstDef;
   END
   WHILE 1 = 1
   BEGIN
      BEGIN TRY
         -- test algorithm:
         -- Check procedure is not created - if so drop it
         IF EXISTS
         (
            SELECT 1 FROM dbo.sysRtns_vw s
            WHERE schema_nm = 'test' and rtn_nm = @mn_tst_rtn_nm
         )
         BEGIN -- rtn does exists so drop it for this test
           SET @sql = CONCAT('DROP PROCEDURE IF EXISTS [',@q_mn_tst_rtn_nm,']');
           EXEC sp_log 1, @fn,'015: test rtn [',@q_mn_tst_rtn_nm,']  exists so dropping it, sql:
           ', @sql;
           EXEC (@sql);
         END
         EXEC sp_log 1, @fn, '020: chking rtn ', @q_mn_tst_rtn_nm, ' does not exist';
         EXEC sp_assert_rtn_exists @q_mn_tst_rtn_nm, 0;
         -- Compile the routine
         EXEC sp_log 1, @fn, '020: running sp_crt_tst_mn_compile...';
         EXEC test.sp_crt_tst_mn_compile @inp_file;
         -- If test expects a exception - chk it now
         IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
         BEGIN
            EXEC sp_log 4, @fn, '025: oops! Expected an exception here';
            THROW 51000, ' Expected an exception but none were thrown', 1;
         END
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '030: caught exception';
         EXEC sp_log_exception @fn;
         SET @act_ex_num = ERROR_NUMBER();
         SET @act_ex_msg = ERROR_MESSAGE();
         IF @exp_ex_num IS NULL OR @exp_ex_msg IS NULL
         BEGIN
            EXEC sp_log 4, @fn, '035: oops! we did not expect an exception here';
            THROW 51000, ' caught unexpected exception', 1;
         END
         ----------------------------------------------------
         -- ASSERTION: if here then expected exception
         ----------------------------------------------------
         EXEC sp_log 1, @fn, '040: checking @act_ex_num, @act_ex_msg';
         IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num        ,'ex_num mismatch';
         IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg        ,'ex_msg mismatch';
         EXEC sp_log 1, @fn, '045: exception test passed';
         BREAK; -- passed exception test
      END CATCH
      -- TEST:
      EXEC sp_log 1, @fn, '050: running tests...';
      -- Test algorithm:
      -- Check procedure not created
      -- Create the procedure (run teh testyed rtn)
      -- Check procedure created
      EXEC sp_log 1, @fn, '055: checking main test procedure created';
      EXEC sp_assert_rtn_exists @q_mn_tst_rtn_nm, 1;
      EXEC sp_log 1, @fn, '060: ASSERTION: main test procedure created';
      -- dtl chk: compare the lines
      -- Get the lines into a table
      IF @run_detail_tst = 1
      BEGIN
         EXEC sp_log 1, @fn, '065: detailed tes';
         DROP TABLE IF EXISTS test.RtnDefAct;
         SELECT * INTO test.RtnDefAct
         FROM  dbo.fnGetRtnDef(@qrn);
         SELECT * FROM test.RtnDefAct;
         SELECT * FROM test.TstDef;
         EXEC tSQLt.AssertEqualsTable 'test.TstDef', 'test.RtnDefAct', 'OK msg', 'fail msg';
      END
      -- passed test
      BREAK;
   END --WHILE
   EXEC sp_log 2, @fn, '17: all tests ran OK';
   EXEC test.sp_tst_hlpr_hndl_success;
-- CLEANUP:
   -- <TBD>
   EXEC sp_log 2, @fn,'subtest 57: PASSED';
END
/*
EXEC tSQLt.Run 'test.test_012_sp_crt_tst_mn_compile';
EXEC tSQLt.RunAll;
EXEC sp_assert_rtn_exists 'test.test_900_sp__crt_tst_rtns', 1;
*/
GO

