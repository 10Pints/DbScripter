SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      26-Nov-2023
-- Description:      test helper rtn for the fnSplit rtn being tested
-- Tested rtn desc:
--  splits a string of items separated  
-- by a character into a list (table)  
-- the lines include a NL if one existed in source code  
-- if max(st)=Len(txt) -> there was a trailing NL  
-- (on the last row)  
--
-- Tested rtn params: 
--    @string     NVARCHAR(4000),
--    @delimiter  NVARCHAR(2)
--========================================================================================
CREATE PROCEDURE [test].[hlpr_006_fnSplit]
    @test_num     NVARCHAR(100)
   ,@inp          NVARCHAR(4000)
   ,@sep          NVARCHAR(2)
   ,@exp_cnt      INT            = NULL
   ,@id           INT            = NULL
   ,@exp_line     NVARCHAR(500)  = NULL
   ,@exp_ex_num   INT            = 0
   ,@exp_ex_msg   NVARCHAR(500)  = NULL
AS
BEGIN
   DECLARE
       @fn                NVARCHAR(35)   = N'hlpr_006_fnSplit'
   EXEC test.sp_tst_hlpr_st @fn, @test_num;
---- SETUP: <TBD>
---- RUN tested rtn:
      EXEC test.sp_tst_hlpr_st @test_num, @fn;
   IF @exp_ex_num <> 0
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 1, @fn, '05: Expect an exception here';
         SELECT * FROM dbo.fnSplit (@inp, @sep);
         EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         DECLARE
             @act_ex_num   INT            = ERROR_NUMBER()
            ,@act_ex_msg   NVARCHAR(500)  = ERROR_MESSAGE()
         EXEC sp_log 1, @fn, '07: caught expected exception';
         IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg;
         IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num;
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
      EXEC sp_log 1, @fn, '08: Calling tested rtn: do not expect an exception now';
      SELECT * FROM dbo.fnSplit (@inp, @sep);
      EXEC sp_log 1, @fn, '09: Returned from tested rtn: no exception thrown';
---- TEST:
      EXEC sp_log 1, @fn, '10: running tests...';
   END -- ELSE -IF @exp_ex = 1
      EXEC sp_log 1, @fn, '11: all tests ran OK';
---- CLEANUP: <TBD>
   EXEC sp_log 2, @fn, 'subtest ',@test_num, ': PASSED';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_006_fnSplit';
*/
GO

