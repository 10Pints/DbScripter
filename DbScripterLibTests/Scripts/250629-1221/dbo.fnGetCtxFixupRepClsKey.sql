SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author:      Terry Watts
-- ALTER date: 06-JAN-2025
-- Description: returns the current s2 fixup search clause key
-- ============================================================
CREATE FUNCTION [dbo].[fnGetCtxFixupRepClsKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'REPLACE_CLAUSE';
END

GO
