SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Author:      Terry Watts
-- Create date: 14-JAN-2023
-- Description: helper procedure for spTableExists tests
-- ==========================================================
CREATE PROCEDURE [test].[hlpr_036_sp_assert_table_exists]
    @tst_num      NVARCHAR(50)
   ,@table_spec   NVARCHAR(60)
   ,@inp_ex_num   INT            = NULL
   ,@inp_ex_msg   NVARCHAR(500)  = NULL
   ,@exp_ex_num   INT            = NULL
   ,@exp_ex_msg   NVARCHAR(500)  = NULL
AS
BEGIN
DECLARE
    @fn           NVARCHAR(35)   = N'hlpr_036_sp_assert_table_exists'
   ,@msg          NVARCHAR(200)
   ,@act_ex_num   INT            = NULL
   ,@act_ex_msg   NVARCHAR(500)  = NULL
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
   IF @exp_ex_num IS NOT NULL
   BEGIN -- Expect an exception here
      BEGIN TRY
         EXEC sp_log 1, @fn, '05: Calling tested rtn, expect an exception';
         EXEC dbo.sp_assert_table_exists
             @table_spec = @table_spec
            ,@ex_num     = @inp_ex_num
            ,@ex_msg     = @inp_ex_msg
         EXEC sp_log 4, @fn, '010: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         SET @act_ex_num = ERROR_NUMBER();
         SET @act_ex_msg = ERROR_MESSAGE();
         EXEC sp_log 1, @fn, '015: caught expected exception
@act_ex_num:[',@act_ex_num,']
@act_ex_msg:[',@act_ex_msg,']';
         IF @exp_ex_num IS NOT NULL -- check the ex num
         BEGIN
            EXEC sp_log 1, @fn, '020 check ex num , exp: ', @exp_ex_num, ' act: ', @act_ex_num;
            EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num, '020 check ex num';
         END -- IF @exp_ex_num <> -1
         IF @exp_ex_msg IS NOT NULL  -- check the ex msg
         BEGIN
            EXEC sp_log 1, @fn, '025 check ex msg, exp: ', @exp_ex_msg, ' act: ', @act_ex_msg;
            EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg, '025 check ex msg';
         END -- IF @exp_ex_msg IS NOT NULL
      END CATCH
   END  -- expect exception
   ELSE -- do not expect exception
   BEGIN
      EXEC sp_log 1, @fn, '035: Calling tested rtn...';
      SELECT
         @act_ex_num  = @exp_ex_num
        ,@act_ex_msg  = @exp_ex_msg
      EXEC dbo.sp_assert_table_exists
          @table_spec = @table_spec
         ,@ex_num     = @act_ex_num OUT
         ,@ex_msg     = @act_ex_msg OUT
   -- Perform tests: chk exception num and msg have correct defaulted
      IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num, '040 check ex num';
      IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg, '045 check ex msg';
   END
   EXEC sp_log 1, @fn, '990: test ',@tst_num, ' PASSED';
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.Run 'test.test_036_sp_assert_table_exists'
*/
GO

