SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      24-APR-2024
-- Description:      main test rtn for the test.sp_crt_tst_mn_compile rtn
-- Tested rtn desc:  creates and compiles the main test rtn
--
-- Preconditions
--    Test.TestDef table pop'd
--
-- Postconditions:                     EX
-- POST 01: the main test procedure is compiled i the DB or EX 63200, 'failed to compile the main test script'
--
-- Test algorithm:
-- Check procedure not created
-- Create the procedure (run teh testyed rtn)
-- Check procedure created
--========================================================================================
----[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
----[@tSQLt:NoTransaction]('test.testCleanUp')
CREATE PROCEDURE [test].[test_013_sp_crt_tst_mn_compile]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_013_sp_crt_tst_mn_compile'
   EXEC test.sp_tst_mn_st @fn;
   -- SETUP
   -- <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_012_sp_crt_tst_mn_compile
       @tst_num  = 'T001'
      ,@qrn       = 'test].[sp__crt_tst_rtns'
      ,@trn       = 900
      ,@cora      = 'C'
      ,@inp_file  = 'D:\TstTmp\test_012_sp_crt_tst_mn_compile.sql'
      ,@run_detail_tst = 0
      ,@exp_ex_num= NULL
      ,@exp_ex_msg= NULL
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   -- EXEC test.hlpr_068_sp_crt_tst_rtns @q_tstd_rtn='',@test_rtn_num=0,@crt_or_alter='',@fn_ret_ty='',@exp_ex=1, @subtest='TR001';
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_012_sp_crt_tst_mn_compile';
EXEC tSQLt.RunAll;
*/
GO

