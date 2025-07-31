SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2021
-- Description: tests the dbo.testfnGetNthSubstring function
-- ===========================================================
CREATE PROCEDURE [test].[test_073_fnGetNthSubstring_4]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn     NVARCHAR(30)   = N'TEST 073 FnGetNthSubstr_4'
   EXEC sp_log 1, @fn, '01: starting'
   EXEC sp_set_session_context @fn                 , 1;
   EXEC sp_set_session_context N'TST HLPR'         , 1;
   EXEC sp_set_session_context N'GETNTHSUBSTRING2' , 1;
   -- Invalid length parameter passed to the LEFT or SUBSTRING function.[16,3]{test.hlpr_070_fnGetNthSubstring2,13}
   EXEC test.hlpr_070_fnGetNthSubstring '"capital items like machinery__ land"', '__'  ,2, ''
   EXEC test.hlpr_070_fnGetNthSubstring '"capital items like machinery__ land"', '__'  ,1, '"capital items like machinery__ land"'
   EXEC test.hlpr_070_fnGetNthSubstring '"capital items like machinery__ land"__', '__'  ,2, ''
   EXEC test.hlpr_070_fnGetNthSubstring '"capital items like machinery___land"___fred', '___'  ,1, '"capital items like machinery___land"'
   EXEC sp_log 1, @fn, '99: leaving'
END
/*
tSQLt.Run 'test.test_073_fnGetNthSubstring_4'
*/
GO

