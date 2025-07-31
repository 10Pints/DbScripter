SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      25-Nov-2023
-- Description:      test helper rtn for the sp_set_log_level rtn being tested
-- Tested rtn desc:
--  sets the log level  
--
-- Tested rtn params: 
--    @level    INT
--========================================================================================
CREATE PROCEDURE [test].[hlpr_079_sp_set_log_level]
   @inp_level  INT,
   @exp_ex     BIT = 0,
   @subtest    NVARCHAR(100),
   @exp_level  INT = NULL
 AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'hlpr_079_sp_set_log_level'
      ,@act_level INT
   EXEC sp_log 1, @fn, '01: starting, @subtest: ', @subtest;
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn: EXEC dbo.sp_set_log_level @level;';
   IF @exp_ex = 1
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 1, @fn, '05: Expect an exception here';
         EXEC dbo.sp_set_log_level @inp_level;
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
         EXEC dbo.sp_set_log_level @inp_level;
         EXEC sp_log 1, @fn, '09: Returned from tested rtn: no exception thrown';
---- TEST:
      EXEC sp_log 1, @fn, '10: running tests...';
      IF @exp_level IS NOT NULL 
      BEGIN
         -- doing from first principles
         SET @act_level = dbo.fnGetSessionContextAsInt(dbo.fnGetLogLevelKey());
         EXEC tSQLt.AssertNotEquals @act_level, NULL;
         EXEC tSQLt.AssertEquals @exp_level, @act_level;
      END
   END -- ELSE -IF @exp_ex = 1
   -- <TBD>
      EXEC sp_log 1, @fn, '11: all tests ran OK';
---- CLEANUP:
   -- <TBD>
   EXEC sp_log 2, @fn, 'subtest ',@subtest, ': PASSED';
END
/*
   EXEC tSQLt.Run 'test.test_079_sp_set_log_level';
*/
GO

