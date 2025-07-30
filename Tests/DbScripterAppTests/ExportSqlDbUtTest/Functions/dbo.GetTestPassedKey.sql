SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 03-JUN-2020
-- Description: returns the session data key 
--    for the test passed count for this fn
-- =============================================
CREATE FUNCTION [dbo].[GetTestPassedKey]( @fn NVARCHAR(30))
RETURNS NVARCHAR(50)
AS
BEGIN
   RETURN CONCAT(@fn, N' tests passed')
END
GO

