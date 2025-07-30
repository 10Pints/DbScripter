SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Terry Watts
-- Create date: 16-OCT-2019
-- Description:	Creates a timestamp
-- =============================================
CREATE FUNCTION [dbo].[GetTimestamp]()
RETURNS VARCHAR(12)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @dt SMALLDATETIME
	DECLARE @timestamp VARCHAR(30)
	SET @dt = GetDate();
	SET @timestamp = CONCAT(CONVERT( VARCHAR, @dt, 12),'-', CONVERT(VARCHAR, @dt, 108), ':', '');
	SET @timestamp = CONCAT(LEFT(@timestamp, 7),SUBSTRING(@timestamp,8,2),SUBSTRING(@timestamp,11,2));
	RETURN @timestamp
END
/*
PRINT dbo.GetTimestamp();
*/
GO

