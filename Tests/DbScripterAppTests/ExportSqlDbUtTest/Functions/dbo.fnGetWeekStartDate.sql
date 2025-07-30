SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================
-- Author:      Terry Watts
-- Create date: 31-JAN-2021
-- Description: returns the week start date (Sunday)
-- ===================================================
CREATE FUNCTION [dbo].[fnGetWeekStartDate](@d Date)
RETURNS DATE
AS
BEGIN
   if @d IS NULL SET @d = GetDate();
   RETURN Cast(DATEADD(dd, -(DATEPART(WEEKDAY, @d)-1), DATEADD(dd, DATEDIFF(dd, 0, @d), 0)) AS DATE);
END
GO

