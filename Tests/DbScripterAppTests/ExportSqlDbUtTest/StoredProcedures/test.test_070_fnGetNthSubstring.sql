SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2021
-- Description: tests the dbo.testfnGetNthSubstring function
-- ===========================================================
CREATE PROCEDURE [test].[test_070_fnGetNthSubstring]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn     NVARCHAR(30)   = N'TEST FNGTNTHSBSTR'
   EXEC sp_log 1, @fn, '01: starting'
   EXEC sp_set_session_context @fn                 , 1;
   EXEC sp_set_session_context N'TST HLPR'         , 1;
   EXEC sp_set_session_context N'GETNTHSUBSTRING'  , 1;
   EXEC test.hlpr_070_fnGetNthSubstring null, ','  ,1, null, 1
   EXEC test.hlpr_070_fnGetNthSubstring '', ','  ,1, ''    , 2
   EXEC test.hlpr_070_fnGetNthSubstring '"capital items like machinery, land"'     , ','  ,1, '"capital items like machinery, land"'     ,3
   EXEC test.hlpr_070_fnGetNthSubstring '"capital items like machinery, land",'    , ','  ,1, '"capital items like machinery, land"'    , 4
   EXEC test.hlpr_070_fnGetNthSubstring '"capital items like machinery, land",fred', ','  ,1, '"capital items like machinery, land"'    , 5
   EXEC test.hlpr_070_fnGetNthSubstring '1234', ','  ,1, '1234'                                                                         , 6
   EXEC test.hlpr_070_fnGetNthSubstring '1234,', ','  ,1, '1234'                                                                        , 7
   EXEC test.hlpr_070_fnGetNthSubstring '2,"capital items like machnery, land"', ',',1, '2'                                             , 8
   EXEC test.hlpr_070_fnGetNthSubstring '2,"capital items like machnery, land"', ','  ,2, '"capital items like machnery, land"'         , 9
   EXEC test.hlpr_070_fnGetNthSubstring '2,Capital,"capital items like machnery, land"', ','  ,2, 'Capital'                             , 10
   EXEC test.hlpr_070_fnGetNthSubstring '2,Capital,"capital items like machnery, land",', ','  ,3, '"capital items like machnery, land"', 11
   EXEC test.hlpr_070_fnGetNthSubstring '2,Capital,"capital items like machnery, land"', ','  ,3, '"capital items like machnery, land"' , 12
   EXEC sp_log 1, @fn, '99: leaving'
END
/*
tSQLt.Run 'test.test_070_fnGetNthSubstring'
*/
GO

