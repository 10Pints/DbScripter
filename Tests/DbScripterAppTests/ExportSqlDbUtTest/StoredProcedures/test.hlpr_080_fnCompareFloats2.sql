SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      27-Nov-2023
-- Description:      test helper rtn for the fnCompareFloats2 rtn being tested
-- Tested rtn desc:
--  determines if 2 floats are approximately equal  
-- Returns    : 1 if a significantly gtr than b  
--              0 if a = b with the signifcance of epsilon   
--             -1 if a significantly less than b within +/- Epsilon, 0 otherwise  
-- DROP FUNCTION [dbo].[fnCompareFloats2]  
--
-- Tested rtn params: 
--    @a        FLOAT,
--    @b        FLOAT,
--    @epsilon  FLOAT,
--
-- returns INT
-- returns INT
-- returns INT
--========================================================================================
CREATE PROCEDURE [test].[hlpr_080_fnCompareFloats2]
   @a        FLOAT,
   @b        FLOAT,
   @epsilon  FLOAT,
   @exp_res  INT = NULL,
   @exp_ex   BIT = 0,
   @subtest  NVARCHAR(100)
AS
BEGIN
   DECLARE
       @fn                NVARCHAR(35)   = N'hlpr_080_fnCompareFloats2'
      ,@v                 int
   EXEC sp_log 1, @fn, '01: starting, @subtest: ', @subtest;
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn: SET @v = dbo.fnCompareFloats2( @a,@b,@epsilon);';
   IF @exp_ex = 1
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 1, @fn, '05: Expect an exception here';
         SET @v = dbo.fnCompareFloats2( @a,@b,@epsilon);
         EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 1, @fn, '07: caught expected exception';
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
         EXEC sp_log 1, @fn, '08: Calling tested rtn: do not expect an exception now';
         SET @v = dbo.fnCompareFloats2( @a,@b,@epsilon);
         EXEC sp_log 1, @fn, '09: Returned from tested rtn: no exception thrown';
---- TEST:
      EXEC sp_log 1, @fn, '10: running tests...';
      IF @exp_res IS NOT NULL EXEC tSQLt.AssertEquals @exp_res, @v, 'fn return vlue does not match @exp_res'
   END -- ELSE -IF @exp_ex = 1
   -- <TBD>
      EXEC sp_log 1, @fn, '11: all tests ran OK';
---- CLEANUP:
   -- <TBD>
   EXEC sp_log 2, @fn, 'subtest ',@subtest, ': PASSED';
END
/*
   EXEC tSQLt.Run 'test.test_080_fnCompareFloats2';
*/
GO

