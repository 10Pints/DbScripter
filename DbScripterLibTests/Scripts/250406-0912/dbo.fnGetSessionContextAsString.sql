SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2021
-- Description: Get session context as a string 
-- RETURNS      value for the key if pressent in 
--              the session map or NULL if not exists
--
-- See Also: fnGetSessionContextAsInt, sp_set_session_context
-- ============================================================
ALTER   FUNCTION [dbo].[fnGetSessionContextAsString](@key NVARCHAR(100))
RETURNS VARCHAR(MAX)
BEGIN
   RETURN CONVERT(VARCHAR(MAX), SESSION_CONTEXT(@key));
END
/*
EXEC sp_set_session_context N'Debug', '1';
PRINT dbo.fnGetSessionContextAsString(N'Debug');
PRINT dbo.fnGetSessionContextAsInt(N'Debug');
*/


GO
