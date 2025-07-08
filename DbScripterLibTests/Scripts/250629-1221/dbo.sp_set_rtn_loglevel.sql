SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =====================================================================================
-- Author:      Terry Watts
-- Create date: 18-NOV-2024
-- Description: sets the rtn log level for the given UQ rtn name in the session context
--              and returns the old level or NULL if not exist in ctx
--
-- POST CONDITIONS:
-- POST01: RETURNS old log level or null if not exist in ctx
-- CHANGES:
-- =====================================================================================
CREATE   PROCEDURE [dbo].[sp_set_rtn_loglevel]
    @rtn_nm    VARCHAR(64)
   ,@log_level INT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn           VARCHAR(35) = N'sp_set_rtn_loglevel'
      ,@key          NVARCHAR(64)
      ,@old_loglevel INT
   ;

   EXEC sp_log 1, @fn, '000: starting
@rtn_nm   :[',@rtn_nm   , ']
@log_level:[', log_level, ']'
;

   BEGIN TRY
      SET @key          = dbo.fnGetRtnLogLevelKey(@rtn_nm);
      SET @old_loglevel = dbo.fnGetRtnLogLevel( @rtn_nm);

      EXEC sp_set_session_context @key, @log_level;
      EXEC sp_log 1, @fn, '999: leaving';
   END TRY
   BEGIN CATCH
      DECLARE
          @ex_msg VARCHAR(500)
         ,@ex_num INT
      ;

      SET @ex_num = ERROR_NUMBER()
      SET @ex_msg = ERROR_MESSAGE();

      EXEC sp_log 4, @fn, '030: caught exception',  ex_num, ': ',ex_msg;
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   -- Cannot return NULL so set NULL to -1
   if @old_loglevel IS NULL 
   BEGIN
      EXEC sp_log 1, @fn, '040: sp cannot return NULL so returning -1 to indicate old value was NULL.';
      SET @old_loglevel = -1
   END

   RETURN @old_loglevel;
END
/*
   EXEC tSQLt.Run 'test.test_033_sp_set_rtn_loglevel';
   EXEC tSQLt.RunAll;
   PRINT dbo.fnGetRtnLogLevelKey('sp_bulk_insert_LRAP');
   PRINT dbo.fnGetRtnLogLevel( 'sp_bulk_insert_LRAP')
*/


GO
