SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 15-FEB-2021
-- Description: Tests the fnPadRight function
-- =====================================================
CREATE PROCEDURE [test].[test_033_fnPadRight]
AS
BEGIN
   SET NOCOUNT ON
   DECLARE 
      @v  NVARCHAR(1000)
      ,@exp INT
      ,@act INT
   EXEC test.hlpr_033_fnPadRight '001', '', 25, 25;
   EXEC test.hlpr_033_fnPadRight '001', '123', 25, 25;
   EXEC test.hlpr_033_fnPadRight '001', '123456789', 25, 25;
   EXEC test.hlpr_033_fnPadRight '001', '1234567891111111111111112', 25, 25;
   EXEC test.hlpr_033_fnPadRight '001', '12345678911111111111111123', 25, 25;
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_033_fnPadRight'
*/
GO

