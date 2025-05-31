SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ============================================================================
-- Author       Terry Watts
-- Create date: 07-FEB-2024
-- Description: registers the routine and sets the limit of the number of calls 
--              to the routine
--
-- CHECKED PRECONDITIONS: PRE 01: @rtn must not be registered already
-- ============================================================================
ALTER PROCEDURE [dbo].[sp_register_rtn]
    @rtn    NVARCHAR(128)
   ,@limit  INT               = 1
AS
BEGIN
   DECLARE
       @fn NVARCHAR(35) = 'REGISTER_RTN'
      ,@error_msg NVARCHAR(500)
      ,@key       NVARCHAR(128)
      ,@count     INT

   EXEC sp_log 1, @fn, 'routine: ', @rtn, ' limit: ', @limit;

   -- @rtn must NOT be registered yet
   IF EXISTS (SELECT 1 FROM SessionContext WHERE rtn = @rtn)
   BEGIN
      UPDATE SessionContext SET limit = @limit;
   END
   ELSE
   BEGIN
      -- PRE 01: @rtn must not already be registered
      SET @error_msg = CONCAT('The routine: ',@rtn, ' has already been registered');
      EXEC sp_log 4, @fn, @error_msg;
      THROW 53947, @error_msg, 1;
   END
END

GO
