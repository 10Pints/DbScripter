SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 05-NOV-2024
-- RETURNS      the ImportRoot context
--
-- See Also: fnGetSessionContextAsString, sp_set_session_context
--
-- CHANGES:
-- ===============================================================
ALTER   FUNCTION [dbo].[fnGetSessionContextImportRoot]()
RETURNS VARCHAR(450)
BEGIN
   RETURN CONVERT(VARCHAR(450),  SESSION_CONTEXT(dbo.fnGetKeyImportRoot()));
END


GO
