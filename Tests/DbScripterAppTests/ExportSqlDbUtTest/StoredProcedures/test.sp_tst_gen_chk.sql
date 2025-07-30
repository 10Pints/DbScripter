SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 15-JAN-2020
-- Description: renamed from sp_tst_helper_generic
--    handles the exp/act assertion and logs message etc.
--
-- Resps:
--
-- IF PASSED:
--    increment the test count
--
-- IF FAILED
--    log msg
--    if the continue on error flag is not set then 
--       raise exception
--
-- CALLED BY: ALL TESTS
-- ===============================================================
CREATE PROCEDURE [test].[sp_tst_gen_chk] 
       @test_sub_num    NVARCHAR(15)   = '*'
      ,@exp             SQL_VARIANT
      ,@act             SQL_VARIANT
      ,@fail_msg        NVARCHAR(500)
      ,@cmp_mode        NVARCHAR(1)    = N'=' -- can be =, <, >
AS
BEGIN
   DECLARE
       @NL              NVARCHAR(2)    = NCHAR(13)+NCHAR(10)
      ,@str_exp         VARCHAR(4000)
      ,@str_act         VARCHAR(4000)
      ,@col             INT
      ,@thisFn          NVARCHAR(50)   = N'sp_tst_gen_chk'
      ,@err_msg         NVARCHAR(500)
      ,@len_act         INT
      ,@len_exp         INT
      ,@Line            NVARCHAR(102)  = CONCAT(REPLICATE('-', 100), NCHAR(13), NCHAR(10))
      ,@test_num        NVARCHAR(100)
      ,@ln_num          INT
      ,@ln_start        INT
      ,@ln_end          INT
      ,@msg2            VARCHAR(MAX)   = NULL
      ,@tmp             VARCHAR(MAX)   = NULL
      ,@pos             INT
      ,@res             BIT
   -- ut.test.sp_tst_gen_chk
   -- handle defaults
   IF @cmp_mode IS NULL SET @cmp_mode = N'=';
   -- Get the current test num
   SET @test_num     = test.fnGetCrntTstNum()
   -- Set the tst_sub_num
   EXEC test.sp_tst_set_crnt_tst_sub_num @test_sub_num;
   IF @exp IS NULL AND @act IS NULL
   BEGIN
      EXEC sp_log 1, @thisFn, ' PASS: both @exp AND @act ARE NULL: so match', @NL;
      PRINT @tmp;
      EXEC test.sp_tst_hlpr_hndl_success;
      RETURN;
   END
   -- Convert the exp, act to strings
   SET @str_exp = CAST(@exp AS VARCHAR(4000));
   SET @str_act = CAST(@act AS VARCHAR(4000));
   SET @len_exp = dbo.fnLen(@str_exp)
   SET @len_act = dbo.fnLen(@str_act)
   if @len_exp IS NULL SET @len_exp = 0;
   if @len_act IS NULL SET @len_act = 0;
   SET @res = iif(@cmp_mode = N'=', [dbo].[fnIsEqual]   ( @exp, @act)
             ,iif(@cmp_mode = N'<', [dbo].[fnIsLessThan]( @exp, @act)
             ,iif(@cmp_mode = N'>', [dbo].[fnIsLessThan]( @exp, @act), 1/0))); -- error if none of these comparisons
   IF @res = 1
   BEGIN
      -- ASSERTION: PASSED TEST
      -- INCREMENT the all TESTs PASSED count and log success msg
      EXEC test.sp_tst_hlpr_hndl_success
   END
   ELSE
   BEGIN
      -- ASSERTION: FAILED TEST
      -- Log and stop
      DECLARE
          @msg                NVARCHAR(200)
         ,@continue_on_error  BIT            = CONVERT(BIT,  SESSION_CONTEXT(N'TST_CONTINUE_ON_ERROR'))
         ,@timestamp          NVARCHAR(13)   = FORMAT(GETDATE(), 'yyMMdd')
         ,@fn                 NVARCHAR(20)   
      BEGIN TRY
         SET @fn = test.fnGetCrntTstdFn();
         SET @msg = CONCAT(@test_num, '.', @test_sub_num, ' failed ', @fail_msg, ' exp: ', @str_exp, ' act: ',@str_act)
         EXEC sp_log 1, '', @msg, @NL, @msg;
         IF @len_exp <> @len_act
            EXEC sp_log 1, @fn, '** length mismatch', @NL, 'exp len: ', @len_exp, @NL, ' act len: ', @len_act;
         SET @msg2 = CONCAT(@NL, 'EXPECTED:', @NL, IIF(@str_exp IS NULL, '<NULL>', @str_exp), ']');
         EXEC sp_log 1, '', @msg2;
         SET @msg2 = CONCAT(@NL, 'ACTUAL:'  , @NL, IIF(@str_act IS NULL, '<NULL>', @str_act), ']');
         EXEC sp_log 1, '', @msg2, @NL, @NL;
   --      SET @file_path = 'C:\temp\expected_1509.txt'
         EXEC sp_write_file @str_exp, 'C:\temp\exp.txt'
         EXEC sp_write_file @str_act, 'C:\temp\act.txt'
         PRINT @Line;
         PRINT '';
      END TRY
      BEGIN CATCH
         SET @msg = CONCAT('caught exception: ', dbo.fnGetErrorMsg());
         EXEC sp_log 1, thisFn, @msg;
         THROW;
      END CATCH
      -- Save the details
      --  sp_set_session_context N'TST_EXP',     @str_exp;
      -- EXEC sp_set_session_context N'TST_ACT',     @str_act;
      -- EXEC sp_set_session_context N'TST_MSG',     @msg
      IF (@continue_on_error IS NULL) OR (@continue_on_error = 0)
         EXEC sp_raise_exception 50000, @msg, @fn=@fn;
   END
END
/*
EXEC test.[test 032 sp_tst_hlp_chk]
EXEC tSQLt.Run 'test.test 032 sp_tst_hlp_chk'
EXEC tSQLt.RunAll
*/
GO

