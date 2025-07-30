SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author:      Terry Watts
-- Create date: 25-MAR-2020
-- Description: Raises an exception coallescing the error messages
-- with a space between the messages
--
-- Ensures @state is positive
-- if @ex_num < 50000 message and raise to 50K+ @ex_num
-- ================================================================
CREATE PROCEDURE [dbo].[sp_raise_exception]
       @ex_num    INT           = 53000
      ,@msg0      VARCHAR(MAX)  = NULL
      ,@msg1      VARCHAR(MAX)  = NULL
      ,@msg2      VARCHAR(MAX)  = NULL
      ,@msg3      VARCHAR(MAX)  = NULL
      ,@msg4      VARCHAR(MAX)  = NULL
      ,@msg5      VARCHAR(MAX)  = NULL
      ,@msg6      VARCHAR(MAX)  = NULL
      ,@msg7      VARCHAR(MAX)  = NULL
      ,@msg8      VARCHAR(MAX)  = NULL
      ,@msg9      VARCHAR(MAX)  = NULL
      ,@msg10     VARCHAR(MAX)  = NULL
      ,@msg11     VARCHAR(MAX)  = NULL
      ,@msg12     VARCHAR(MAX)  = NULL
      ,@msg13     VARCHAR(MAX)  = NULL
      ,@msg14     VARCHAR(MAX)  = NULL
      ,@msg15     VARCHAR(MAX)  = NULL
      ,@msg16     VARCHAR(MAX)  = NULL
      ,@msg17     VARCHAR(MAX)  = NULL
      ,@msg18     VARCHAR(MAX)  = NULL
      ,@msg19     VARCHAR(MAX)  = NULL
      ,@fn        VARCHAR(35)   = NULL
AS
BEGIN
   DECLARE
       @fnThis    VARCHAR(35) = 'sp_raise_exception'
      ,@msg       VARCHAR(max)
   ;
   DECLARE @msgs TABLE (txt VARCHAR(MAX));
   SELECT @msg =  dbo.fnAggregateMsgs
   (
       @msg0,  @msg1,  @msg2,  @msg3,  @msg4
      ,@msg5 , @msg6,  @msg7,  @msg8,  @msg9
      ,@msg10, @msg11, @msg12, @msg13, @msg14
      ,@msg15, @msg16, @msg17, @msg18, @msg19
   );
   IF @ex_num IS NULL SET @ex_num = 53000; -- default
      EXEC sp_log 4, @fnThis, '000: throwing exception ', @ex_num, ' ', @msg, ' st: 1';
   ------------------------------------------------------------------------------------------------
   -- Validate
   ------------------------------------------------------------------------------------------------
   -- check ex num >= 50000 if not add 50000 to it
   IF @ex_num < 50000
   BEGIN
      SET @ex_num = abs(@ex_num) + 50000;
      EXEC sp_log 3, @fnThis, '010: supplied exception number is too low changing to ', @ex_num;
   END
   ------------------------------------------------------------------------------------------------
   -- Throw the exception
   ------------------------------------------------------------------------------------------------
   ;THROW @ex_num, @msg, 1;
END
/*
EXEC tSQLt.Run 'test.test_076_sp_raise_exception';
*/
GO

