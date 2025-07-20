SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================================
-- Author:      Terry Watts
-- Create date: 06-JAN-2025
-- Description: returns the file row id key for the current s2 fixup
-- ==================================================================
CREATE FUNCTION [dbo].[fnGetCtxFixupFileKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'FIXUP_FILE_NM';
END

GO
