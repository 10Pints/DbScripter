SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [test].[test_071_fnGetNthSubstring_2]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn         NVARCHAR(30)   = N'TEST FNGETNTHSBSTR'
     ,@error_msg  NVARCHAR(500) 
     ,@error_num  INT
     ,@error_flag BIT = 0
   EXEC sp_log 1, @fn, '01: starting';
   EXEC sp_set_session_context @fn   , 1;
   EXEC sp_set_session_context N'TST HLPR'                  , 1;
   EXEC sp_log 1, @fn, '02: running test 01: empty sep exp ex'
   -- expect a  EXEC [tSQLt].[ExpectException]
   BEGIN TRY
      EXEC test.hlpr_070_fnGetNthSubstring '', ''  ,1, '', 'test 01';
      SET @error_flag = 1 ; -- should not get here
   END TRY
   BEGIN CATCH
      SET @error_num = ERROR_NUMBER();
      SET @error_msg = ERROR_MESSAGE();
      EXEC sp_log 4, @fn, '50 caught expected exception: ', @error_num, ': ', @error_msg;
      EXEC tSQLt.AssertEquals 8134, @error_num, 'expected ex 8134'
      EXEC tSQLt.AssertEquals 'Divide by zero error encountered.', @error_msg, 'error msg not correct'
      EXEC sp_log 1, @fn, '59: leaving PASSED';
   END CATCH
   IF @error_flag = 1
      EXEC tSQLt.Fail 'Expected an exception here: Divide by zero error encountered.';
   SET @error_flag = 0
   EXEC test.hlpr_070_fnGetNthSubstring 'a'    , ','  ,1, 'a'  ,'test 02';
   EXEC test.hlpr_070_fnGetNthSubstring 'a'    , ','  ,2, ''   ,'test 03';
   EXEC test.hlpr_070_fnGetNthSubstring 'a,0b3', ','  ,2, '0b3','test 03';
   EXEC test.hlpr_070_fnGetNthSubstring 'x0b3' , 'x'  ,1, ''   ,'test 04';
   EXEC test.hlpr_070_fnGetNthSubstring 'abcx0b3def' , 'x0b3'  ,1, 'abc'   ,'test 05';
   EXEC test.hlpr_070_fnGetNthSubstring 'abcx0b3def' , 'x0b3'  ,2, 'def'   ,'test 05';
   EXEC sp_log 1, @fn, '99: leaving, all tests passed';
END
/*
EXEC tSQLt.RunAll
tSQLt.Run 'test.test_071_fnGetNthSubstring_2'
*/
GO

