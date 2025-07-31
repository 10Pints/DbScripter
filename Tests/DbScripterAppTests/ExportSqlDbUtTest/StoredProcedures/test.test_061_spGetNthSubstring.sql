SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2021
-- Description: tests the dbo.spGetNthSubstring sp
-- ===========================================================
----[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
CREATE PROCEDURE [test].[test_061_spGetNthSubstring]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn     NVARCHAR(30)   = N'TEST 061 GetNthSubstr'
   EXEC ut.test.sp_tst_mn_st @fn;
   EXEC sp_set_session_context N'TST HLPR'         , 1;
   EXEC sp_set_session_context N'GETNTHSUBSTRING'  , 1;
   EXEC test.hlpr_061_spGetNthSubstring
       @tst_num= 'T001'
      ,@inp = null
      ,@sep =  ','
      ,@n   = 1
      ,@exp = null
   EXEC test.hlpr_061_spGetNthSubstring
       @tst_num= 'T002'
      ,@inp = ''
      ,@sep =  ','
      ,@n   = 1
      ,@exp = ''
--   , ','  ,1, ''    , 2
   EXEC test.hlpr_061_spGetNthSubstring
       @tst_num= 'T003'
      ,@inp = '"capital items like machinery, land"'
      ,@sep =  ','
      ,@n   = 1
      ,@exp = null
   EXEC test.hlpr_061_spGetNthSubstring 
       @tst_num= 'T004'
      ,@inp = '"capital items like machinery, land"'
      ,@sep =  ','
      ,@n   = 1
      ,@exp = '"capital items like machinery, land"'
   EXEC test.hlpr_061_spGetNthSubstring 
       @tst_num= 'T005'
      ,@inp = '"capital items like machinery, land",fred'
      ,@sep =  ','
      ,@n   = 1
      ,@exp = "capital items like machinery, land"
   EXEC test.hlpr_061_spGetNthSubstring
   @tst_num= 'T006'
      ,@inp = '1234'
      ,@sep =  ','
      ,@n   = 1
      ,@exp = '1234'
   EXEC test.hlpr_061_spGetNthSubstring
       @tst_num= 'T007'
      ,@inp = '2,"capital items like machnery, land"'
      ,@sep =  ','
      ,@n   = 1
      ,@exp = '2'
--   , ','  ,2, '"capital items like machnery, land"'         , 9
   EXEC test.hlpr_061_spGetNthSubstring
       @tst_num= 'T008'
      ,@inp = '2,"capital items like machnery, land"'
      ,@sep =  ','
      ,@n   = 2
      ,@exp = ''
      /*
--   '2,Capital,"capital items like machnery, land"', ','  ,2, 'Capital'                             , 10
   EXEC test.hlpr_061_spGetNthSubstring
   @tst_num= 'T009'
      ,@inp = null
      ,@sep =  ','
      ,@n   = 1
      ,@exp = null
*/
--   '2,Capital,"capital items like machnery, land",', ','  ,3, '"capital items like machnery, land"', 11
   EXEC test.hlpr_061_spGetNthSubstring
   @tst_num= 'T009'
      ,@inp = '2,Capital,"capital items like machnery, land"'
      ,@sep =  ','
      ,@n   = 3
      ,@exp = ''
   ;
   EXEC ut.test.sp_tst_mn_cls;
END
/*
tSQLt.RunAll
tSQLt.Run 'test.test_061_spGetNthSubstring'
*/
GO

