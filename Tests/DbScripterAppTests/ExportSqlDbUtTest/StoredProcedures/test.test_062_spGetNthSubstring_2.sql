SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [test].[test_062_spGetNthSubstring_2]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn     NVARCHAR(30)   = N'TEST 061 GetNthSubstr_2'
   EXEC sp_log 1, @fn, '01: starting'
   EXEC sp_set_session_context @fn   , 1;
   EXEC sp_set_session_context N'TST HLPR'                  , 1;
   EXEC sp_set_session_context N'GETNTHSUBSTRING2'          , 1;
   EXEC [tSQLt].[ExpectException] @ExpectedMessagePattern = '%separator must be specified'
   --EXEC test.hlpr_061_spGetNthSubstring '', ''  ,1, ''
   EXEC test.hlpr_061_spGetNthSubstring
       @tst_num= 'T001'
      ,@inp    = 'input str'
      ,@sep    = ''
      ,@n      = 1
      ,@exp    = NULL
   EXEC test.hlpr_061_spGetNthSubstring
       @tst_num= 'T001'
      ,@inp    = 'input str'
      ,@sep    = NULL
      ,@n      = 1
      ,@exp    = NULL
   EXEC sp_log 1, @fn, '99: leaving'
END
/*
tSQLt.Run 'test.test_062_spGetNthSubstring_2'
tSQLt.RunAll
*/
GO

