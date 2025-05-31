SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 25-MAY-2020
-- Description: Get session context as int - default = -1
-- RETURNS      if    key/value present returns value as INT
--              if no key/value present returns NULL
--
-- See Also: fnGetSessionContextAsString, sp_set_session_context
--
-- CHANGES:
-- 14-JUL-2023: default = -1 (not found) was 0 before
-- 06-FEB-2024: simply returns value if key found else NULL
-- ===============================================================
ALTER   FUNCTION [dbo].[fnGetSessionContextAsInt](@key NVARCHAR(100))
RETURNS INT
BEGIN
   RETURN CONVERT(INT, SESSION_CONTEXT(@key));
END
/*
PRINT CONCAT('[',dbo.fnGetSessionContextAsInt(N'cor_id'),']')
*/


GO
