SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2021
-- Description: tests the dbo.testfnGetNthSubstring function
-- ===========================================================
CREATE PROCEDURE [test].[test_063_spGetNthSubstring_3]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn     NVARCHAR(30)   = N'TEST 063 GetNthSubstr_3'
   EXEC ut.test.sp_tst_mn_st @fn;
   EXEC sp_set_session_context @fn                          , 1;
   EXEC sp_set_session_context N'TST HLPR'                  , 1;
   EXEC sp_set_session_context N'GETNTHSUBSTRING2'          , 1;
--   EXEC [tSQLt].[ExpectException] @ExpectedMessagePattern = '%input must be specified'
   EXEC test.hlpr_061_spGetNthSubstring 
       @tst_num= 'T001'
      ,@inp = NULL
      ,@sep =  ','
      ,@n   = 1
      ,@exp = NULL
   EXEC ut.test.sp_tst_mn_cls;
END
/*
tSQLt.RunAll;
tSQLt.Run 'test.test_063_spGetNthSubstring_3';
*/
GO

