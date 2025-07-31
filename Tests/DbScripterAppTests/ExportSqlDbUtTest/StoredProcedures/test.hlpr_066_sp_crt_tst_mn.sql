SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      24-Nov-2023
-- Description:      test helper rtn for the sp_crt_tst_fn_mn rtn being tested
-- Tested rtn desc:
--  sp version of test.fnCrtTstRtnMn
--
-- Test Rtns:
--
-- Changes:
-- 231121: @q_tstd_rtn must exist or exception 56472, '<@q_tstd_rtn> does not exist'
-- 231121: added a try catch handler to log errors
-- 231130: moving subtest to first parameter and rename to test_num
--         adding better exception testing
--
-- Tested rtn params:
--    @q_tstd_rtn_nm  NVARCHAR(100),
--    @tst_rtn_num    INT,
--    @crt_or_alter   NCHAR(2)
--========================================================================================
CREATE PROCEDURE [test].[hlpr_066_sp_crt_tst_mn]
    @test_num        NVARCHAR(50)
   ,@q_tstd_rtn_nm   NVARCHAR(100)
   ,@tst_rtn_num     INT
   ,@crt_or_alter    NCHAR(2)       = 'C'
   ,@exp_ex_num      INT            = NULL
   ,@exp_ex_msg      NVARCHAR(500)  = NULL
   ,@exp_row_detail  NVARCHAR(4000) = NULL -- for rtns that return a table
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = N'hlpr_066_sp_crt_tst_mn'
   ,@act_line        NVARCHAR(4000)
   ,@act_ex_num      INT
   ,@act_ex_msg      NVARCHAR(500)
   ,@error_msg       NVARCHAR(500)
   EXEC sp_log 2, @fn, @test_num, ' 01: starting';
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, @test_num, ' 04:  running tested rtn...';
   IF @exp_ex_num IS NOT NULL
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 2, @fn, @test_num,  '05: Expect an exception here';
         EXEC test.sp_crt_tst_mn @q_tstd_rtn_nm, @tst_rtn_num,@crt_or_alter;
         EXEC sp_log 4, @fn, @test_num, ' 06: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, @test_num, ' 07: caught expected exception';
         IF @exp_ex_num <> -1
         BEGIN
            SET @act_ex_num = ERROR_NUMBER();
            EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num
         END
         IF @exp_ex_msg IS NOT NULL
         BEGIN
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg
         END
      END CATCH
   END -- IF @exp_ex IS NOT NULL
   ELSE
   BEGIN
      -- Do not expect an exception here
      EXEC sp_log 2, @fn, @test_num, ' 08: test Calling tested rtn: do not expect an exception now';
      EXEC test.sp_crt_tst_mn @q_tstd_rtn_nm,@tst_rtn_num,@crt_or_alter;
      EXEC sp_log 2, @fn, @test_num, ' 09: Returned from tested rtn: no exception thrown';
---- TEST:
      EXEC sp_log 2, @fn, @test_num, ' 10: running tests...';
      IF @exp_row_detail IS NOT NULL
      BEGIN
         EXEC sp_log 2, @fn, @test_num, '15: detailed row chk...';
         IF NOT EXISTS (SELECT 1 FROM test.tstActDefMn WHERE line LIKE @exp_row_detail)
         BEGIN
            SET @error_msg = CONCAT('Detail row check error: 
exp row:[',@exp_row_detail,'] 
was not found');
            EXEC tSQLt.Fail @error_msg;
         END
         EXEC sp_log 2, @fn, @test_num, ' 20: test detailed row chk PASSED';
      END -- IF @exp_row_detail IS NOT NULL
   END -- ELSE -IF @exp_ex IS NOT NULL
   EXEC sp_log 2, @fn, @test_num, ' 25: all tests ran OK';
---- CLEANUP:
   -- <TBD>
   EXEC sp_log 2, @fn, @test_num, ' 99: leaving, test PASSED';
END
/*
   EXEC tSQLt.RunAll;
   EXEC tSQLt.Run 'test.test_066_sp_crt_tst_mn';
   -- EXEC test.hlpr_150_sp_get_line_num @test_num='TR001',@txt='',@offset=0,@ln_num=0,@ln_start=0,@ln_end=0,@col=0, @exp_ex_num=-1, @exp_ex_msg=NULL';] 
   -- EXEC test.hlpr_150_sp_get_line_num @test_num='TR001',@txt='',@offset=0,@ln_num=0,@ln_start=0,@ln_end=0,@col=0, @exp_ex_num=-1, @exp_ex_msg=NULL;
EXP:   -- EXEC test.hlpr_150_sp_get_line_num @test_num='TR003',@txt='',@offset=0,@ln_num=0,@ln_start=0,@ln_end=0,@col=0, @exp_ex_num=51356 <todo: replace this with the expected exception number>, @exp_ex_msg='blah <todo: replace this with the expected exception msg>'';';
ACT:   -- EXEC test.hlpr_150_sp_get_line_num @test_num='TR003',@txt='',@offset=0,@ln_num=0,@ln_start=0,@ln_end=0,@col=0, @exp_ex_num=51356 <todo: replace this with the expected exception number>, @exp_ex_msg='blah <todo: replace this with the expected exception msg>;
*/
GO

