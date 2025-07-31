SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2021
-- Description: tests the dbo.fnGetNthSubstring function
-- ===========================================================
CREATE PROCEDURE [test].[test_072_fnGetNthSubstring_3]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn     NVARCHAR(30)   = N'TEST FNGETNTHSUBSTR3'
   EXEC sp_log 1, @fn, '01: starting';
   EXEC sp_set_session_context @fn          , 1;
   EXEC sp_set_session_context N'TST HLPR'  , 1;
   EXEC sp_set_session_context @fn          , 1;
   EXEC [tSQLt].[ExpectException]
   EXEC test.hlpr_070_fnGetNthSubstring '', null  ,1, null
   EXEC sp_log 1, @fn, 'leaving'
END
/*
tSQLt.Run 'test.test_072_fnGetNthSubstring_3'
*/
GO

