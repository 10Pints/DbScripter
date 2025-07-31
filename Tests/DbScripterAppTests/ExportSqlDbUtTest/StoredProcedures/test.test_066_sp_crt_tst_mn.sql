SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      24-Nov-2023
-- Description:      main test rtn for the test.sp_crt_tst_fn_mn rtn being tested
-- Tested rtn desc:
--  sp version of test.fnCrtTstRtnMn  
--  
-- Test Rtns:  
--      
-- Changes:  
-- 231121: @q_tstd_rtn must exist or exception 56472, '<@q_tstd_rtn> does not exist'  
-- 231121: added a try catch handler to log errors  
--
-- Tested rtn params: 
--    @q_tstd_rtn_nm  NVARCHAR(100),
--    @tst_rtn_num    INT,
--    @crt_or_alter   NCHAR(2)
--========================================================================================
--[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
CREATE PROCEDURE [test].[test_066_sp_crt_tst_mn]
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = N'test_066_sp_crt_tst_fn_mn'
   EXEC sp_log 2, @fn,'01: starting';
---- SETUP
   -- <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG001'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@crt_or_alter    = 'C'
      ,@exp_row_detail  = 'CREATE PROCEDURE test.test_150_sp_get_line_num';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG002'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@crt_or_alter    = 'A'
      ,@exp_row_detail  = 'ALTER PROCEDURE test.test_150_sp_get_line_num';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG003: log start'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@crt_or_alter    = 'C'
      ,@exp_ex_num      = NULL
      ,@exp_ex_msg      = NULL
      ,@exp_row_detail  = '   EXEC sp_log 2, @fn,''01: starting''';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG004: log end'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '   EXEC sp_log 2, @fn, ''99: leaving, All subtests PASSED''';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG005: -- Tested rtn desc:'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '-- Tested rtn desc:';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG006: -- Tested rtn params: '
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '-- Tested rtn params:';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG007: test rtn parameter #1'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '--    @txt       NVARCHAR(4000),';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG008: test rtn parameter last'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '--    @col       INT';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG009: Green tests comment'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '   -- Green tests: ones that should work ok';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG010: Red tests comment'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '   -- Red tests: ones that should fail';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG011: Run the test Helper comment'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '   ---- Run the test Helper rtn to run the tested rtn and do some checks';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG012: call the helper line'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '   EXEC test.hlpr_150_sp_get_line_num @test_num=''TG001'',@txt='''',@offset=0,@ln_num=0,@ln_start=0,@ln_end=0,@col=0, @exp_ex_num=NULL, @exp_ex_msg=NULL;';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG013: commented exception handler line 1'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '   -- EXEC test.hlpr_150_sp_get_line_num @test_num=''TR001'',@txt='''',@offset=0,@ln_num=0,@ln_start=0,@ln_end=0,@col=0, @exp_ex_num=-1, @exp_ex_msg=NULL;';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG014: commented exception handler line 2'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '   -- EXEC test.hlpr_150_sp_get_line_num @test_num=''TR002'',@txt='''',@offset=0,@ln_num=0,@ln_start=0,@ln_end=0,@col=0, @exp_ex_num=51356 <todo: replace this with the expected exception number>, @exp_ex_msg=NULL;';
   EXEC test.hlpr_066_sp_crt_tst_mn 
       @test_num        = 'TG015: commented exception handler line 3'
      ,@q_tstd_rtn_nm   = 'dbo.sp_get_line_num'
      ,@tst_rtn_num     = 150
      ,@exp_row_detail  = '   -- EXEC test.hlpr_150_sp_get_line_num @test_num=''TR003'',@txt='''',@offset=0,@ln_num=0,@ln_start=0,@ln_end=0,@col=0, @exp_ex_num=51356 <todo: replace this with the expected exception number>, @exp_ex_msg=''blah <todo: replace this with the expected exception msg>;';
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   -- EXEC test.hlpr_066_sp_crt_tst_fn_mn @q_tstd_rtn_nm='',@tst_rtn_num=0,@crt_or_alter='',@exp_ex=1, @subtest='TR001';
   EXEC sp_log 2, @fn, '99: All subtests PASSED';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_066_sp_crt_tst_mn';
*/
GO

