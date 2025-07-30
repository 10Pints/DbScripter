SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: Get session context as bit
-- RETURNS      if    key/value present returns value as BIT
--              if no key/value present returns NULL
--
-- See Also: fnGetSessionContextAsString, sp_set_session_context
-- ===============================================================
CREATE FUNCTION [dbo].[fnGetSessionContextAsBit](@key NVARCHAR(100))
RETURNS INT
BEGIN
   RETURN CONVERT(BIT,  SESSION_CONTEXT(@key));
END
GO

