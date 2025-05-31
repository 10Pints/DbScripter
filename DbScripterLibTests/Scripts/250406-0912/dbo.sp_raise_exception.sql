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
ALTER   PROCEDURE [dbo].[sp_raise_exception]
       @ex_num    INT            = 53000
      ,@msg0      VARCHAR(max)  = NULL
      ,@msg1      VARCHAR(max)  = NULL
      ,@msg2      VARCHAR(max)  = NULL
      ,@msg3      VARCHAR(max)  = NULL
      ,@msg4      VARCHAR(max)  = NULL
      ,@msg5      VARCHAR(max)  = NULL
      ,@msg6      VARCHAR(max)  = NULL
      ,@msg7      VARCHAR(max)  = NULL
      ,@msg8      VARCHAR(max)  = NULL
      ,@msg9      VARCHAR(max)  = NULL
      ,@msg10     VARCHAR(max)  = NULL
      ,@msg11     VARCHAR(max)  = NULL
      ,@msg12     VARCHAR(max)  = NULL
      ,@msg13     VARCHAR(max)  = NULL
      ,@msg14     VARCHAR(max)  = NULL
      ,@msg15     VARCHAR(max)  = NULL
      ,@msg16     VARCHAR(max)  = NULL
      ,@msg17     VARCHAR(max)  = NULL
      ,@msg18     VARCHAR(max)  = NULL
      ,@msg19     VARCHAR(max)  = NULL
      ,@msg20     VARCHAR(max)  = NULL
      ,@fn        VARCHAR(35)   = NULL
AS
BEGIN
   DECLARE
       @fnThis    VARCHAR(35) = 'sp_raise_exception'
      ,@msg       VARCHAR(max)

      IF @ex_num IS NULL SET @ex_num = 53000; -- default
      EXEC sp_log 4, @fnThis, '000: starting, @fn:[', @fn, '] @ex_num:[', @ex_num,'] @msg1:[', @msg1,']';

   ------------------------------------------------------------------------------------------------
   -- Validate
   ------------------------------------------------------------------------------------------------
   -- check ex num >= 50000 if not add 50000 to it
   IF @ex_num < 50000
   BEGIN
      SET @ex_num = abs(@ex_num) + 50000;
      EXEC sp_log 3, @fnThis, '010: supplied exception number is too low changing to ', @ex_num;
   END

   SET @msg =
      CONCAT
      (
          @msg0
         ,@msg1
         ,@msg2
         ,@msg3
         ,@msg4
         ,@msg5
         ,@msg6
         ,@msg7
         ,@msg8
         ,@msg9
         ,@msg10
         ,@msg11
         ,@msg12
         ,@msg13
         ,@msg14
         ,@msg15
         ,@msg16
         ,@msg17
         ,@msg18
         ,@msg19
         ,@msg20
      );

   ------------------------------------------------------------------------------------------------
   -- Throw the exception
   ------------------------------------------------------------------------------------------------
    EXEC sp_log 4, @fn, '020: throwing exception ', @ex_num, ' ',@msg, ' st: 1';
   ;THROW @ex_num, @msg, 1;
END
/*
EXEC sp_raise_exception 53000, 'test exception msg 1',' msg 2', @state=2, @fn='test_fn'
*/


GO
