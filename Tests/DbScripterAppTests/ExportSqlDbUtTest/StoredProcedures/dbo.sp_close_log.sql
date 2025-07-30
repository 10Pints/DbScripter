SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 09-JULY-2021
-- Description: closes the log file
-- =============================================
CREATE PROCEDURE [dbo].[sp_close_log] 
AS
BEGIN
   DECLARE   @Ole_id    INT
            ,@File_id   INT
   SET @File_id = CONVERT(INT, SESSION_CONTEXT(N'log_file_id'));
   SET @Ole_id  = CONVERT(INT, SESSION_CONTEXT(N'log_ole_id'));
   BEGIN TRY
      IF ((@Ole_id IS NOT NULL) AND (@File_id IS NOT NULL))
      BEGIN
         EXECUTE sp_OADestroy @File_id
         EXECUTE sp_OADestroy @Ole_id
      END
      EXEC sys.sp_set_session_context @key = N'log_file_id', @value = NULL;
      EXEC sys.sp_set_session_context @key = N'log_ole_id',  @value = NULL;
   END TRY
   BEGIN CATCH
      DECLARE @msg NVARCHAR(3000);
      SET @msg = '';
      PRINT CONCAT('sp_close_log caught exception: ', ut.dbo.fnGetErrorMsg());
      RETURN 1;
   END CATCH
   RETURN 0;
END
/*
EXEC ut.[dbo].[sp_close_log] 
*/
GO

