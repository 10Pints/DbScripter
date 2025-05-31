SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: sets the log level
-- =============================================
ALTER PROCEDURE [dbo].[sp_set_log_level]
   @level INT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @log_level_key NVARCHAR(50) = dbo.fnGetLogLevelKey();
   EXEC sys.sp_set_session_context @key = @log_level_key, @value = @level;
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.sp_set_log_level', 79, 'C';
*/

GO
