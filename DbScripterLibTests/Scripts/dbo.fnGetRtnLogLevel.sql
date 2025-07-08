SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===========================================================================================
-- Author:      Terry Watts
-- Create date: 18-NOV-2024
-- Description: returns the rtn log level for the given UQ rtn name in the session context
--              or NULL if not exist in the ctx
-- ===========================================================================================
CREATE   FUNCTION [dbo].[fnGetRtnLogLevel]( @rtn_nm VARCHAR(64))
RETURNS INT
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsInt(dbo.fnGetRtnLogLevelKey( @rtn_nm));
END


GO
