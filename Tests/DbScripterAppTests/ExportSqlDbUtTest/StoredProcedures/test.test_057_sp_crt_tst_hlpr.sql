SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      20-Nov-2023
-- Description:      main test rtn for the test.sp_crt_tst_fn_hlpr rtn being tested
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
--
-- Tested rtn params:
--    @q_tstd_rtn    NVARCHAR(100),
--    @tst_rtn_num   INT,
--    @crt_or_alter  NCHAR(2),
--    @fn_ret_ty     NVARCHAR(50)
--========================================================================================
CREATE PROCEDURE [test].[test_057_sp_crt_tst_hlpr]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_057_sp_crt_tst_fn_hlpr'
   EXEC sp_log 2, @fn,'01: starting';
   EXEC test.sp_tst_mn_st @fn
---- SETUP
   -- <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
      -- TG002: 'dbo.fnEatWhitespace', 53, 'C'  -> @txt   NVARCHAR(MAX) --> NVARCHAR(0),
   EXEC sp_log 2, @fn,'10: running test: TG002';
   EXEC test.hlpr_057_sp_crt_tst_hlpr
    @tst_num      = 'T001'
   ,@qrn          = 'dbo.fnEatWhitespace'
   ,@trn          = 958
   ,@cora         = 'C'
   ,@exp_ex_num   = NULL
   ,@exp_ex_msg   = NULL
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_057_sp_crt_tst_hlpr';
EXEC tSQLt.RunAll;
*/
GO

