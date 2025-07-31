SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:      Terry Watts
-- Create date: 02-FEB-2021
-- Description: tests the dbo.GetWeekStartDate() routine
-- =======================================================
CREATE PROCEDURE [test].[test_027_fnGetWeekStartDate]
AS
BEGIN
EXEC test.hlpr_027_fnGetWeekStartDate 'T01', '24-JAN-2021', '2021-01-24'
EXEC test.hlpr_027_fnGetWeekStartDate 'T02', '30-JAN-2021', '2021-01-24'
EXEC test.hlpr_027_fnGetWeekStartDate 'T03', '31-JAN-2021', '2021-01-31'
EXEC test.hlpr_027_fnGetWeekStartDate 'T04', '06-FEB-2021', '2021-01-31'
EXEC test.hlpr_027_fnGetWeekStartDate 'T05', '07-FEB-2021', '2021-02-07'
END
/*
EXEC tSQLt.RunAll
EXEC tSQLt.Run 'test.test_027_fnGetWeekStartDate'
EXEC test.[test 027 fnGetWeekStartDate]
*/
GO

