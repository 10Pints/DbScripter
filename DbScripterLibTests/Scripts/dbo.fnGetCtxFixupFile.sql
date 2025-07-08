SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================
-- Author:      Terry Watts
-- Create date: 06-JAN-2025
-- Description: returns the file row id for the current s2 fixup
-- ==============================================================
CREATE FUNCTION [dbo].[fnGetCtxFixupFile]()
RETURNS NVARCHAR(500)
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsString(dbo.fnGetCtxFixupFileKey());
END

GO
