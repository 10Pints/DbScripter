SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 09-DEC-2024
-- Description: use when problems with tSQLt txns 
-- and GetError message
-- =============================================
CREATE   PROC [dbo].[sp_get_errror]
    @err_num INT            OUT
   ,@err_msg VARCHAR(1000) OUT
AS
BEGIN
   DECLARE 
    @fn              VARCHAR(35) = 'sp_get_errror'
   SET NOCOUNT OFF;

   BEGIN TRY
      SET @err_num = ERROR_NUMBER();
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '*** ERROR_NUMBER() FAILED ***';
      EXEC sp_log 3, @fn, 'Trying @@error';
      BEGIN TRY
         SET @err_num = @@ERROR;
      END TRY
      BEGIN CATCH
         EXEC sp_log 4, @fn, '*** @@ERROR FAILED ***';
         EXEC sp_log 3, @fn, 'setting @err_num to 60000';
         SET @err_num = 60000
      END CATCH
   END CATCH
   BEGIN TRY
      SET @err_msg = ERROR_MESSAGE();
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '*** ERROR_MESSAGE() FAILED ***';
      EXEC sp_log 3, @fn, 'setting @err_msg to ''Failed to get Error Message''';
      SET @err_msg = 'Failed to get Error Message';
   END CATCH
END
/*
EXEC sp_delete '%NAME OF COMPANY%', 'company', 'staging2'
DELETE FROM [pathogens] WHERE [company] LIKE '%NAME OF COMPANY%'
*/


GO
