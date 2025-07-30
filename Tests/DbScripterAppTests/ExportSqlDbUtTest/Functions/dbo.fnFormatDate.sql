SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 28-DEC-2019
-- Description:Returns a date formatted as dd-MMM-YYYY
-- =============================================
CREATE FUNCTION [dbo].[fnFormatDate]
(
   @date DATE
)
RETURNS NVARCHAR(12)
AS
BEGIN
   RETURN CONCAT( format (DAY(@date), '0#'), '-', UPPER(Convert(char(3), @date, 0)), '-', YEAR(@date))
END
GO

