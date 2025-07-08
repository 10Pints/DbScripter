SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if a is not <= b
-- ===============================================
CREATE PROCEDURE [dbo].[sp_assert_less_than_or_equal]
    @a      SQL_VARIANT
   ,@b      SQL_VARIANT
   ,@msg1   VARCHAR(200)  = NULL
   ,@msg2   VARCHAR(200)  = NULL
   ,@msg3   VARCHAR(200)  = NULL
   ,@msg4   VARCHAR(200)  = NULL
   ,@msg5   VARCHAR(200)  = NULL
   ,@msg6   VARCHAR(200)  = NULL
   ,@msg7   VARCHAR(200)  = NULL
   ,@msg8   VARCHAR(200)  = NULL
   ,@msg9   VARCHAR(200)  = NULL
   ,@msg10  VARCHAR(200)  = NULL
   ,@msg11  VARCHAR(200)  = NULL
   ,@msg12  VARCHAR(200)  = NULL
   ,@msg13  VARCHAR(200)  = NULL
   ,@msg14  VARCHAR(200)  = NULL
   ,@msg15  VARCHAR(200)  = NULL
   ,@msg16  VARCHAR(200)  = NULL
   ,@msg17  VARCHAR(200)  = NULL
   ,@msg18  VARCHAR(200)  = NULL
   ,@msg19  VARCHAR(200)  = NULL
   ,@msg20  VARCHAR(200)  = NULL
   ,@ex_num INT            = 50001
   ,@log_level INT            = 0
AS
BEGIN
   DECLARE
       @fn     VARCHAR(35)   = 'sp_assert_less_than_or_equal'
      ,@aTxt   VARCHAR(100)  = CONVERT(VARCHAR(20), @a)
      ,@bTxt   VARCHAR(100)  = CONVERT(VARCHAR(20), @b)

    EXEC sp_log @log_level, @fn, '000: starting @a:[',@aTxt, '] @b:[', @b, ']';

   --  a<= b means it is not the case that b < a
   IF dbo.fnIsLessThan(@b ,@a) = 0
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fn, '010: OK, @a:[',@aTxt, '] <= @b:[', @b, ']';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   EXEC sp_log 3, @fn, '020: @a:[',@aTxt, '] <= @b:[', @b, '] IS FALSE, raising exception';
   IF @ex_num IS NULL SET @ex_num = 50002;

   EXEC sp_raise_exception
       @msg0   = @msg1
      ,@msg1   = @msg2
      ,@msg2   = @msg3
      ,@msg3   = @msg4
      ,@msg4   = @msg5
      ,@msg5   = @msg6
      ,@msg6   = @msg7
      ,@msg7   = @msg8
      ,@msg8   = @msg9
      ,@msg9   = @msg10
      ,@msg10  = @msg11
      ,@msg11  = @msg12
      ,@msg12  = @msg13
      ,@msg13  = @msg14
      ,@msg14  = @msg15
      ,@msg15  = @msg16
      ,@msg16  = @msg17
      ,@msg17  = @msg18
      ,@msg18  = @msg19
      ,@msg19  = @msg20
      ,@ex_num = @ex_num
      ,@fn     = @fn -- -- function testing the assertion
   ;
END
/*
EXEC tSQLt.RunAll;
*/

GO
