SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Author:      Terry Watts
-- Create date: 14-JAN-2023
-- Description: helper procedure for [test_fnCountOccurrences
-- ==========================================================
CREATE PROCEDURE [test].[hlpr_035_fnCountOccurrences]
    @tst_num NVARCHAR(50)
	,@string  NVARCHAR(MAX)
   ,@token   NVARCHAR(MAX)
   ,@exp     INT           = NULL
AS
BEGIN
DECLARE
        @fn    NVARCHAR(30)   = N'hlpr_fnCountOccurrences'
       ,@msg   NVARCHAR(200)
       ,@act   INT
   EXEC sp_log 1, @fn, '01: starting';
   -- Call tested routine
   SET @act = dbo.fnCountOccurrences(@string, @token);
   -- Perform tests
   IF @exp IS NOT NULL EXEC tSQLt.AssertEquals @exp, @act, @tst_num
   EXEC sp_log 1, @fn, '99: leaving, test: ', @tst_num, ' PASSED';
END
GO

