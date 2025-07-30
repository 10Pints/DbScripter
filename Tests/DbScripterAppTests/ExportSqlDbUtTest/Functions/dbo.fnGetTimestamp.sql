SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================
-- Author:      Terry Watts
-- Create date: 16-OCT-2019
-- Description: Creates a timestamp like 191229-2245
-- Format:      <yyMMdd-HHmm'>
-- Notes:       If the supplied date time is NULL then
--              uses the current date and time
--
-- Tests:       test.test_022_fnGetTimestamp
-- ====================================================
CREATE FUNCTION [dbo].[fnGetTimestamp](@dt DATETIME2)
RETURNS NVARCHAR(12)
AS
BEGIN
   -- Declare the return variable here
   DECLARE @timestamp  NVARCHAR(30)
   IF @dt IS NULL
      SET @dt = GetDate();
   SET @timestamp = FORMAT(@dt, 'yyMMdd-HHmm');
   RETURN @timestamp
END
/*
PRINT dbo.fnGetTimestamp(GetDate())
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_022_fnGetTimestamp';
*/
GO

