SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================================================================
-- Author:      Terry Watts
-- Create date: 06-JAN-2025
-- Description: returns the rtn log level key for the given UQ rtn name in the session context
-- ===========================================================================================
CREATE FUNCTION [dbo].[fnGetCtxFixupRowId]()
RETURNS INT
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsInt(dbo.fnGetCtxFixupRowIdKey());
END

GO
