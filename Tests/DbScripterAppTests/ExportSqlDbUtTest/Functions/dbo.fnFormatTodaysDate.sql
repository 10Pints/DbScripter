SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 17-MAR-2020
-- Description: Returns today's date formatted as dd-MMM-YYYY
-- =============================================
CREATE FUNCTION [dbo].[fnFormatTodaysDate]()
RETURNS NVARCHAR(12)
AS
BEGIN
   RETURN [dbo].[fnFormatDate]( CONVERT(DATE, GETDATE(), 0));
END
GO

