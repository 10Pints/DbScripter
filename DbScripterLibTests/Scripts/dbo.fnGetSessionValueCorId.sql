SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 19-AUG-2023
-- Description: returns the cor_id value used in the Staging2 update trigger
--    to determine if need a new entry in the correction log
-- ==============================================================================
ALTER FUNCTION [dbo].[fnGetSessionValueCorId]()
RETURNS NVARCHAR(30)
AS
BEGIN
   RETURN ut.dbo.fnGetSessionContextAsString(dbo.fnGetSessionKeyCorId());
END

GO
