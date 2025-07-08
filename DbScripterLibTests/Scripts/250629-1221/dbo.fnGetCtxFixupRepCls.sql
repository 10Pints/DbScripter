SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Author:      Terry Watts
-- ALTER date: 06-JAN-2025
-- Description: returns the current s2 fixup search clause
-- =========================================================
CREATE FUNCTION [dbo].[fnGetCtxFixupRepCls]()
RETURNS NVARCHAR(500)
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsString(dbo.fnGetCtxFixupRepClsKey());
END

GO
