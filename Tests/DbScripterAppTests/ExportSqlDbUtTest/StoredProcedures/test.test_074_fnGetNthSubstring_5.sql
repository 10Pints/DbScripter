SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:      Terry Watts
-- Create date: 22-JUN-2021
-- Description: tests the dbo.testfnGetNthSubstring function
-- ===========================================================
CREATE PROCEDURE [test].[test_074_fnGetNthSubstring_5]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
      @fn     NVARCHAR(30)   = N'TEST 075 fnGetNthSubstring_5'
   EXEC sp_log 1, @fn, '01: starting'
   EXEC sp_set_session_context @fn                 , 1;
   EXEC sp_set_session_context N'TST HLPR'         , 1;
   EXEC sp_set_session_context N'GETNTHSUBSTRING'  , 1;
   EXEC test.hlpr_070_fnGetNthSubstring '8,4,3,23-Apr-21,Dododong: interior hse initial INV,Construction HSE,50000,', ','  ,8, ''         , 2
   EXEC test.hlpr_070_fnGetNthSubstring '8,4,3,23-Apr-21,Dododong: interior hse initial INV,Construction HSE,50000,', ','  ,7, '50000'    , 1
   EXEC sp_log 1, @fn, '99: leaving'
END
/*
tSQLt.Run 'test.test_074_fnGetNthSubstring_5'
*/
GO

