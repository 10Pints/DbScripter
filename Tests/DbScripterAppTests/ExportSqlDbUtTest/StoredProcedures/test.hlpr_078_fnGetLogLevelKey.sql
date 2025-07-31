SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      25-Nov-2023
-- Description:      test helper rtn for the fnGetLogLevelKey rtn being tested
-- Tested rtn desc:
--  returns the log level key
--
-- Tested rtn params:
--
--========================================================================================
CREATE PROCEDURE [test].[hlpr_078_fnGetLogLevelKey]
    @tst_num   NVARCHAR(50)
   ,@exp_key   NVARCHAR(50) = NULL
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'hlpr_078_fnGetLogLevelKey'
      ,@act_key   NVARCHAR(50)
   EXEC sp_log 2, @fn, '01: starting, @subtest: ', @tst_num;
   ------------------------------------------------------------------------------------------------------------------
---- SETUP:
   ------------------------------------------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------------------------------------
   -- RUN tested rtn:
   ------------------------------------------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '04: running tested rtn: SET @v = dbo.fnGetLogLevelKey( );';
   EXEC sp_log 2, @fn, '08: Calling tested rtn: do not expect an exception now';
   SET @act_key = dbo.fnGetLogLevelKey( );
   EXEC sp_log 2, @fn, '09: Returned from tested rtn: no exception thrown';
   ------------------------------------------------------------------------------------------------------------------
   -- TEST:
   ------------------------------------------------------------------------------------------------------------------
   EXEC sp_log 2, @fn, '10: running tests...';
   IF @exp_key IS NOT NULL EXEC tSQLt.AssertEquals @exp_key, @act_key, 'fn return value does not match @exp_key'
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
   EXEC tSQLt.Run 'test.test_078_fnGetLogLevelKey';
*/
GO

