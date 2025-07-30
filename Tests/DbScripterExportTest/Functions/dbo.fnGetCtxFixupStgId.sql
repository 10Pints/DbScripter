SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:      Terry Watts
-- Create date: 06-JAN-2025
-- Description: returns the file row id for the current s2 fixup
-- ==============================================================
CREATE FUNCTION [dbo].[fnGetCtxFixupStgId]()
RETURNS INT
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsInt(dbo.fnGetCtxFixupStgIdKey());
END
GO

