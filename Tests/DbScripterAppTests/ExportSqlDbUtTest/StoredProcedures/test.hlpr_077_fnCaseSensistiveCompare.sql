SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      25-Nov-2023
-- Description:      test helper rtn for the fnCaseSensistiveCompare rtn being tested
-- Tested rtn desc:
--  case sensitive compare helper function  
-- Returns:     1 if match false 0  
--
-- Tested rtn params: 
--    @expected  NVARCHAR(100),
--    @actual    NVARCHAR(100),
--
-- returns BIT
-- returns BIT
--========================================================================================
CREATE PROCEDURE [test].[hlpr_077_fnCaseSensistiveCompare]
    @tst_num              NVARCHAR(50)
   ,@expected  NVARCHAR(100)
   ,@actual    NVARCHAR(100)
   ,@exp_res   BIT = NULL
   ,@exp_ex    BIT = 0
AS
BEGIN
   DECLARE
       @fn                NVARCHAR(35)   = N'hlpr_077_fnCaseSensistiveCompare'
      ,@v                 bit
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
   -- SETUP:
   -- <TBD>
   -- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn: SET @v = dbo.fnCaseSensistiveCompare( @expected,@actual);';
   IF @exp_ex = 1
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 2, @fn, '05: Expect an exception here';
         SET @v = dbo.fnCaseSensistiveCompare( @expected,@actual);
         EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '07: caught expected exception';
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
         EXEC sp_log 2, @fn, '08: Calling tested rtn: do not expect an exception now';
         SET @v = dbo.fnCaseSensistiveCompare( @expected,@actual);
         EXEC sp_log 2, @fn, '09: Returned from tested rtn: no exception thrown';
   END -- ELSE -IF @exp_ex = 1
---- TEST:
      EXEC sp_log 2, @fn, '10: running tests...';
   IF @exp_res IS NOT NULL EXEC tSQLt.AssertEquals @exp_res, @v, 'fn return vlue does not match @exp_res'
   -- <TBD>
      EXEC sp_log 2, @fn, '11: all tests ran OK';
   -- CLEANUP:
   -- <TBD>
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
   EXEC tSQLt.Run 'test.test_077_fnCaseSensistiveCompare';
*/
GO

