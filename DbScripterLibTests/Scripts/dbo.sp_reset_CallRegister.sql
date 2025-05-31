SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================
-- Author       Terry Watts
-- Create date: 07-FEB-2024
-- Description: resets the count field to  zero in the call register table
--              but leaves the limit field intact
--
-- PRECONDITIONS: none
-- ============================================================================
ALTER PROCEDURE [dbo].[sp_reset_CallRegister]
   @rtn_nm NVARCHAR(50) = NULL
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35) = 'RESET_CALL__REGISTER'
      ,@error_msg NVARCHAR(500)
      ,@key       NVARCHAR(128)
      ,@count     INT

   EXEC sp_log 1, @fn, '00: starting @rtn_nm:[',@rtn_nm,']';
   EXEC sp_log 1, @fn, '10: clearing rows';
   UPDATE CallRegister SET [count] = 0 WHERE @rtn_nm IS NULL OR rtn=@rtn_nm;
   EXEC sp_log 1, @fn, '99: leaving OK';
END
/*
EXEC sp_reset_CallRegister;
EXEC sp_reset_CallRegister 'SP_MAIN_IMPORT_STAGE_8';
SELECT * FROM CallRegister;
*/

GO
