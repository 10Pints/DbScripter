SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      01-Dec-2023
-- Description:      test helper rtn for the fnChkEquals rtn being tested
-- Tested rtn desc:
--  function to compare values - includes an  
--              approx equal check for floating point types  
-- Returns 1 if equal, 0 otherwise  
--
-- Tested rtn params: 
--    @a        SQL_VARIANT,
--    @b        SQL_VARIANT,
--
-- returns BIT
-- returns BIT
--========================================================================================
CREATE PROCEDURE [test].[hlpr_026_fnChkEquals]
    @test_num     NVARCHAR(50)
   ,@a            SQL_VARIANT
   ,@b            SQL_VARIANT
   ,@exp_res      BIT = NULL
   ,@exp_ex_num   INT = NULL -- if -1: dont chk value - just the fact the exception was thrown
   ,@exp_ex_msg   NVARCHAR(500) = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(35)   = N'hlpr_081_fnChkEquals'
      ,@v            BIT
      ,@act_ex_num   INT
      ,@act_ex_msg   NVARCHAR(500)
      EXEC ut.test.sp_tst_hlpr_st @fn, @test_num
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn: SET @v = dbo.fnChkEquals( @a,@b);';
   IF @exp_ex_num IS NOT NULL
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 1, @fn, '05: Expect an exception here';
         SET @v = dbo.fnChkEquals( @a,@b);
         EXEC sp_log 4, @fn, '06: oops! Expected an exception but none were thrown';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 1, @fn, '07: caught expected exception';
         IF @exp_ex_num <> -1 -- check the ex num
         BEGIN
            SET @act_ex_num = ERROR_NUMBER();
            EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num;
         END
         IF @exp_ex_msg IS NOT NULL  -- check the ex msg
         BEGIN
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg;
         END
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
         EXEC sp_log 1, @fn, '08: Calling tested rtn: do not expect an exception now';
         SET @v = dbo.fnChkEquals( @a,@b);
         EXEC sp_log 1, @fn, '09: Returned from tested rtn: no exception thrown';
---- TEST:
      EXEC sp_log 1, @fn, '10: running tests...';
      IF @exp_res IS NOT NULL EXEC tSQLt.AssertEquals @exp_res, @v, 'fn return vlue does not match @exp_res'
   END -- ELSE -IF @exp_ex = 1
   -- <TBD>
      EXEC sp_log 1, @fn, '11: all tests ran OK';
---- CLEANUP:
   -- <TBD>
   EXEC sp_log 2, @fn, 'subtest ',@test_num, ': PASSED';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_026_fnChkEquals';
*/
GO

