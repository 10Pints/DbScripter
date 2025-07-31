SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2021
-- Description: tests the dbo.testfnGetNthSubstring function
-- ===========================================================
--[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
CREATE PROCEDURE [test].[test_065_spGetNthSubstring_5]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn     NVARCHAR(30)   = N'TEST 065 GetNthSubstr_5'
   EXEC sp_log 1, @fn, '01: starting'
   EXEC sp_set_session_context @fn                 , 1;
   EXEC sp_set_session_context N'TST HLPR'         , 1;
   EXEC sp_set_session_context N'GETNTHSUBSTRING'  , 1;
   EXEC test.hlpr_spGetNthSubstring '8,2,', ','  ,3, ''         , 3
   EXEC test.hlpr_spGetNthSubstring '8,2' , ','  ,3, ''         , 4
   EXEC test.hlpr_spGetNthSubstring '8,2,', ','  ,2, '2'         , 1
   EXEC test.hlpr_spGetNthSubstring '8,2' , ','  ,2, '2'         , 2
   EXEC test.hlpr_spGetNthSubstring '8,4,3,23,Construction HSE,500,' , ',' ,7, ''   , 5
   EXEC test.hlpr_spGetNthSubstring '8,4,3,23,Construction HSE,500'  , ',' ,7, ''   , 6
   EXEC test.hlpr_spGetNthSubstring '8,4,3,23,Construction HSE,500,' , ',' ,6, '500', 7
   EXEC test.hlpr_spGetNthSubstring '8,4,3,23,Construction HSE,500'  , ',' ,6, '500', 8
   EXEC test.hlpr_spGetNthSubstring '8,4,3,23,Construction HSE,500,,', ',' ,7, ''   , 9
   EXEC test.hlpr_spGetNthSubstring '8,', ','  ,1, '8'         , 10
   EXEC test.hlpr_spGetNthSubstring '8', ','  ,1, '8'          , 11
   EXEC test.hlpr_spGetNthSubstring '', ','  ,1, ''            , 12
--   EXEC test.hlpr_spGetNthSubstring '8,4,3,23-Apr-21,Dododong: interior hse initial INV,Construction HSE,50000,', ','  ,7, '50000'    , 13
   EXEC sp_log 1, @fn, '99: leaving'
END
/*
EXEC test.hlpr_spGetNthSubstring '8,2,', ','  ,3, ''         , 3;
EXEC test.hlpr_spGetNthSubstring '8,2' , ','  ,3, ''         , 4;
EXEC test.testspGetNthSubstring_5
tSQLt.Run 'test.test_065_spGetNthSubstring_5';
*/
GO

