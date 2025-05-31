SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: asserts that a is greater than b
--              raises an exception if not
-- =============================================
ALTER   PROCEDURE [dbo].[sp_assert_gtr_than]
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       VARCHAR(200)  = NULL
      ,@msg2      VARCHAR(200)  = NULL
      ,@msg3      VARCHAR(200)  = NULL
      ,@msg4      VARCHAR(200)  = NULL
      ,@msg5      VARCHAR(200)  = NULL
      ,@msg6      VARCHAR(200)  = NULL
      ,@msg7      VARCHAR(200)  = NULL
      ,@msg8      VARCHAR(200)  = NULL
      ,@msg9      VARCHAR(200)  = NULL
      ,@msg10     VARCHAR(200)  = NULL
      ,@msg11     VARCHAR(200)  = NULL
      ,@msg12     VARCHAR(200)  = NULL
      ,@msg13     VARCHAR(200)  = NULL
      ,@msg14     VARCHAR(200)  = NULL
      ,@msg15     VARCHAR(200)  = NULL
      ,@msg16     VARCHAR(200)  = NULL
      ,@msg17     VARCHAR(200)  = NULL
      ,@msg18     VARCHAR(200)  = NULL
      ,@msg19     VARCHAR(200)  = NULL
      ,@msg20     VARCHAR(200)  = NULL
      ,@ex_num    INT            = 53502
      ,@fn        VARCHAR(60)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
   DECLARE
       @fnThis VARCHAR(35) = 'sp_assert_gtr_than'
      ,@aTxt   VARCHAR(100)= CONVERT(VARCHAR(100), @a)
      ,@bTxt   VARCHAR(100)= CONVERT(VARCHAR(100), @b)

   EXEC sp_log @log_level, @fnThis, '000: starting @a:[',@aTxt, '] @b:[', @bTxt, ']';

   -- a>b -> b<a 
   IF dbo.fnIsLessThan(@b ,@a) = 1
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fnThis, '010: OK, @a:[',@aTxt, '] IS GTR THN @b:[', @bTxt, ']';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   EXEC sp_log 3, @fnThis, '020: [',@aTxt, '] IS GTR THN [', @bTxt, '] IS FALSE, raising exception';

   EXEC sp_raise_exception
          @msg1   = @msg
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
         ,@ex_num = @ex_num
         ,@fn     = @fn
   ;
END
/*
EXEC sp_assert_gtr_than 4, 5;
EXEC sp_assert_gtr_than 5, 4;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_055_sp_assert_gtr_than';
*/


GO
