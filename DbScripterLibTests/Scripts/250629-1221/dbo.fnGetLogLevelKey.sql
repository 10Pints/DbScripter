SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: returns the log level key
-- =============================================
CREATE   FUNCTION [dbo].[fnGetLogLevelKey] ()
RETURNS NVARCHAR(50)
AS
BEGIN
   RETURN N'LOG_LEVEL';
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.fnGetLogLevelKey', 
*/


GO
