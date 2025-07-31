SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      20-Nov-2023
-- Description:      test helper rtn for the sp_crt_tst_hlpr rtn being tested
-- Tested rtn desc:
--  creates a tSQLt test helper routine
-- SAME as the function test.fnCrtTstHlpr - but easier to debug
-- Preconditions:
--    PRE01: params table populated
--
-- Algorihtm:
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
--
-- Tested rtn params:
--    @q_tstd_rtn    NVARCHAR(100),
--    @tst_rtn_num   INT,
--    @crt_or_alter  NCHAR(2),
--    @fn_ret_ty     NVARCHAR(50)
--========================================================================================
CREATE PROCEDURE [test].[hlpr_057_sp_crt_tst_hlpr]
    @tst_num      NVARCHAR(50)
   ,@qrn          NVARCHAR(100)
   ,@trn          INT
   ,@cora         NCHAR(2)
   ,@exp_ex_num   INT            = NULL
   ,@exp_ex_msg   NVARCHAR(500)  = NULL
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = N'hlpr_057_sp_crt_tst_fn_hlpr'
   ,@msg             NVARCHAR(500)
   ,@exp_schema_nm   NVARCHAR(50)
   ,@exp_rtn_nm      NVARCHAR(50)
   ,@exp_trn         NVARCHAR(50)
   ,@act_qrn         NVARCHAR(100)
   ,@act_trn         INT
   ,@act_cora        NCHAR(2)
   ,@act_ex_num      INT            = NULL
   ,@act_ex_msg      NVARCHAR(500)  = NULL
--   ,@act_fn_ret_ty     NVARCHAR(50)
   EXEC sp_log 2, @fn, '01: starting,
tst_num     :[', @tst_num,']
qrn         :[', @qrn,']
tst_rtn_num: [', @trn,']
crt_or_alter:[', @cora,']
exp_ex_num  :[', @exp_ex_num,']
exp_ex_msg  :[', @exp_ex_msg,']'
;
SELECT * FROM test.ParamDetails;
---- SETUP:
   SELECT
       @exp_schema_nm  = schema_nm
      ,@exp_rtn_nm    = rtn_nm
   FROM test.fnSplitQualifiedName(@qrn);
   EXEC test.sp_get_rtn_details @qrn
   -- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn: EXEC test.sp_crt_tst_fn_hlpr @q_tstd_rtn,@tst_rtn_num,@crt_or_alter,@fn_ret_ty;';
   WHILE 1 = 1
   BEGIN
      BEGIN TRY
         EXEC test.sp_crt_tst_hlpr --  @q_tstd_rtn,@tst_rtn_num,@crt_or_alter,@fn_ret_ty;
         IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
         BEGIN
            EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
            THROW 51000, ' Expected an exception but none were thrown', 1;
         END
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '07: caught exception';
         EXEC sp_log_exception @fn;
         SET @act_ex_num = ERROR_NUMBER();
         SET @act_ex_msg = ERROR_MESSAGE();
         IF @exp_ex_num IS NULL OR @exp_ex_msg IS NULL
         BEGIN
            EXEC sp_log 4, @fn, '08: oops! Unexpected an exception here';
            THROW 51000, ' caught unexpected exception but none', 1;
         END
         ----------------------------------------------------
         -- ASSERTION: if here then expected exception
         ----------------------------------------------------
         IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num        ,'ex_num mismatch';
         IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg        ,'ex_msg mismatch';
         BREAK; -- passed exception test
      END CATCH
      -- TEST:
      EXEC sp_log 2, @fn, '10: running tests...';
      -- passed exception test
      BREAK;
   END --WHILE
   EXEC sp_log 2, @fn, '17: all tests ran OK';
   EXEC test.sp_tst_hlpr_hndl_success;
-- CLEANUP:
   -- <TBD>
   EXEC sp_log 2, @fn,'subtest 57: PASSED';
END
/*
   EXEC tSQLt.Run 'test.test_057_sp_crt_tst_hlpr';
   SELECT * FROM test.ParamDetails
*/
GO

