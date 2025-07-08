SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: sets the log level
--
-- CHANGES:
-- 241118: return old loglevel in the sp rtn status or 1 if not set
-- =================================================================
CREATE   PROCEDURE [dbo].[sp_set_log_level]
   @level INT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn            VARCHAR(50) = 'sp_set_log_level'
      ,@old_log_level INT          = dbo.fnGetLogLevel()
      ,@log_level_key NVARCHAR(50) = dbo.fnGetLogLevelKey()
      ,@msg           VARCHAR(200)
   ;

   EXEC sys.sp_set_session_context @key = @log_level_key, @value = @level;
   SET @msg = CONCAT('sp_set_log_level: 000: Setting logging level from [', @old_log_level,'] TO [',@level,']');
   EXEC sp_log 2, @fn, @msg;
   RETURN COALESCE (@old_log_level, 1);
END
/*
EXEC sp_set_log_level 1;
*/


GO
