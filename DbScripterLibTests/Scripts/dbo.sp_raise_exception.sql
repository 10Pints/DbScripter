SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =========================================================
-- Author:      Terry Watts
-- Create date: 25-MAR-2020
-- Description: Raises an exception
--    Ensures @state is positive
--    if @ex_num < 50000 message and raise to 50K+ @ex_num
-- =========================================================
ALTER PROCEDURE [dbo].[sp_raise_exception]
       @ex_num    INT            = 53000
      ,@msg1      NVARCHAR(200)  = NULL
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
      ,@state     INT            = 1
AS
BEGIN
   DECLARE
       @fn    NVARCHAR(35) = 'sp_raise_exception'
      ,@msg   NVARCHAR(4000)

      IF @ex_num IS NULL SET @ex_num = 53000; -- default

      EXEC sp_log 1, @fn, 'starting
@ex_num:[', @ex_num,']
@msg1  :[', @msg1,']
@state :[', state,']'
;

   ------------------------------------------------------------------------------------------------
   -- Validate
   ------------------------------------------------------------------------------------------------
   -- check ex num >= 50000 if not add 50000 to it
   IF @ex_num < 50000
   BEGIN
      SET @ex_num = abs(@ex_num) + 50000;
      EXEC sp_log 3, @fn, 'supplied exception number is too low changing to ', @ex_num;
   END

   -- Cannot send negative state so invert
   IF @state < 0
   BEGIN
      EXEC sp_log 3, @fn, 'supplied state number is negative ', @state, ' so making state postive';
      SET @state = 0 - @state;
   END

   SET @msg = 
      CONCAT 
      ( @msg1 ,@msg2 ,@msg3 ,@msg4 ,@msg5 ,@msg6 ,@msg7 ,@msg8 ,@msg9 ,@msg10
       ,@msg11,@msg12,@msg13,@msg14,@msg15,@msg16,@msg17,@msg18,@msg19,@msg20
      );

   ------------------------------------------------------------------------------------------------
   -- Throw the exception
   ------------------------------------------------------------------------------------------------
    EXEC sp_log 4, @fn, 'throwing exception ', @ex_num, ' ',@msg, ' st: ',@state;
   ;THROW @ex_num, @msg, @state;
END
/*
EXEC sp_raise_exception 53000, 'test exception msg 1',' msg 2', @state=2, @fn='test_fn'
*/

GO
