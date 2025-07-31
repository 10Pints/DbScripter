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
CREATE PROCEDURE [test].[test_064_spGetNthSubstring_4]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn     NVARCHAR(30)   = N'TEST 064 GetNthSubstr_4';
   EXEC sp_log 1, @fn, '01: starting';
   EXEC sp_set_session_context @fn                 , 1;
   EXEC sp_set_session_context N'TST HLPR'         , 1;
   EXEC sp_set_session_context N'GETNTHSUBSTRING2' , 1;
   EXEC test.hlpr_spGetNthSubstring '"capital items like machinery__ land"__', '__'  ,2, '', 2;
   EXEC test.hlpr_spGetNthSubstring '"capital items like machinery__ land"', '__'  ,1, '"capital items like machinery__ land"', 1;
   EXEC test.hlpr_spGetNthSubstring '"capital items like machinery__ land"___fred', '___'  ,1, '"capital items like machinery__ land"', 3;
   EXEC test.hlpr_spGetNthSubstring '"capital items like machinery__ land"', '__'  ,2, '', 4;
   EXEC sp_log 1, @fn, '99: leaving';
END
/*
tSQLt.Run 'test.testspGetNthSubstring_4';
*/
GO

