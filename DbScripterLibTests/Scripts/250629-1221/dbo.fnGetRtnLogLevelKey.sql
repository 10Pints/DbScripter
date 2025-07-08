SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===========================================================================================
-- Author:      Terry Watts
-- Create date: 18-NOV-2024
-- Description: returns the rtn log level key for the given UQ rtn name in the session context
-- ===========================================================================================
CREATE   FUNCTION [dbo].[fnGetRtnLogLevelKey]( @rtn_nm NVARCHAR(64))
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN CONCAT(N'RtnLogLevel_', @rtn_nm);
END


GO
