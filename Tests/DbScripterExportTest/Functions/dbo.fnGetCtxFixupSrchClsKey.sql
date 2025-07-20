SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author:      Terry Watts
-- Create date: 06-JAN-2025
-- Description: returns the current s2 fixup search clause key
-- ============================================================
CREATE FUNCTION [dbo].[fnGetCtxFixupSrchClsKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'SEARCH_CLAUSE';
END

GO
