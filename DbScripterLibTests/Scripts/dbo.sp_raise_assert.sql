SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================================
-- Author:      Terry Watts
-- Create date: 31-MAY-2020
-- Description: creates the message and raises the assertion
--    assuming in a fail state (i.e. check already done and failed)
-- =================================================================
ALTER PROCEDURE [dbo].[sp_raise_assert]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       NVARCHAR(200)  = NULL
      ,@msg2      NVARCHAR(200)  = NULL
      ,@msg3      NVARCHAR(200)  = NULL
      ,@msg4      NVARCHAR(200)  = NULL
      ,@msg5      NVARCHAR(200)  = NULL
      ,@msg6      NVARCHAR(200)  = NULL
      ,@msg7      NVARCHAR(200)  = NULL
      ,@msg8      NVARCHAR(200)  = NULL
      ,@msg9      NVARCHAR(200)  = NULL
      ,@msg10     NVARCHAR(200)  = NULL
      ,@msg11     NVARCHAR(200)  = NULL
      ,@msg12     NVARCHAR(200)  = NULL
      ,@msg13     NVARCHAR(200)  = NULL
      ,@msg14     NVARCHAR(200)  = NULL
      ,@msg15     NVARCHAR(200)  = NULL
      ,@msg16     NVARCHAR(200)  = NULL
      ,@msg17     NVARCHAR(200)  = NULL
      ,@msg18     NVARCHAR(200)  = NULL
      ,@msg19     NVARCHAR(200)  = NULL
      ,@msg20     NVARCHAR(200)  = NULL
      ,@ex_num    INT
      ,@state     INT            = 1
      ,@fn_       NVARCHAR(60)   = '*'  -- assertion rtn calling the raise excption
      ,@fn        NVARCHAR(60)   = NULL -- function testing the assertion
      ,@sf        INT            = 1
AS
BEGIN
   DECLARE
       @fnThis    NVARCHAR(60)    = N'sp_raise_assert'

/*   EXEC sp_log 1, @fnThis,'01: starting
msg :[',@msg,']
msg2:[',@msg2,']
msg3:[',@msg3,']';*/
   IF dbo.fnChkEquals(@a ,@b) = 0
      EXEC sp_raise_exception
          @ex_num
         ,@msg1   = @msg
         ,@msg2   = @msg2
         ,@msg3   = @msg3
         ,@msg4   = @msg4
         ,@msg5   = @msg5
         ,@msg6   = @msg6
         ,@msg7   = @msg7
         ,@msg8   = @msg8
         ,@msg9   = @msg9
         ,@msg10  = @msg10
         ,@msg11  = @msg11
         ,@msg12  = @msg12
         ,@msg13  = @msg13
         ,@msg14  = @msg14
         ,@msg15  = @msg15
         ,@msg16  = @msg16
         ,@msg17  = @msg17
         ,@msg18  = @msg18
         ,@msg19  = @msg19
         ,@msg20  = @msg20
         ,@state  = @state
         ,@fn_    = @fn_     -- assertion rtn calling the raise excption
         ,@fn     = @fn      -- function testing the assertion
         ,@sf     = @sf
END
/*
EXEC test.sp_crt_tst_rtns 'dbo].[sp_raise_assert'
*/

GO
