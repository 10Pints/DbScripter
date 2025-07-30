SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================================
-- Author       Terry Watts
-- Create date: 07-FEB-2024
-- Description: Registers a routine call and checks the call count against the limit
--
-- CHECKED PRECONDITIONS: PRE 01: @rtn must be registered
--
-- Changes:
-- 240414: faciltate multiple calls for example as in testing tSQLt.Runall
-- =====================================================================================
CREATE   PROCEDURE [dbo].[sp_register_call]
   @rtn VARCHAR(128)
AS
BEGIN
   DECLARE
       @fn VARCHAR(35) = 'REGISTER_CALL'
      ,@error_msg VARCHAR(500)
      ,@key       VARCHAR(128)
      ,@count     INT
      ,@limit     INT
      ,@enforce_single_call_flg BIT = COALESCE(dbo.fnGetSessionContextAsInt(N'ENFORCE_SINGLE_CALL'), 1);
   SET NOCOUNT ON;
   -- If testing ignore the single call system
   IF @enforce_single_call_flg = 0
      RETURN;
   SELECT
       @count = [count]
      ,@limit = limit
   FROM CallRegister
   WHERE rtn = @rtn;
   IF @count IS NOT NULL
   BEGIN
      SET @limit = (SELECT limit FROM CallRegister WHERE rtn = @rtn);
      -- Increment the call count
      UPDATE CallRegister 
      SET
         [count] = @count + 1
         ,updated = GetDate()
      WHERE rtn = @rtn;
      if(@count >= @limit)
      BEGIN
         SET @error_msg = CONCAT(@rtn, ' has already been called ',@limit,' times - this is the call limit for this routine');
         EXEC sp_log 4, @fn, @error_msg;
         THROW 56214, @error_msg, 1;
      END
   END
   ELSE
   BEGIN
      -- CHECKED PRECONDITIONS: PRE 01: @rtn must be registered
      SET @error_msg = CONCAT('The routine: ',@rtn, ' has not been registered');
      EXEC sp_log 4, @fn, @error_msg;
      THROW 53948, @error_msg, 1;
   END
   SET NOCOUNT OFF;
END
GO

