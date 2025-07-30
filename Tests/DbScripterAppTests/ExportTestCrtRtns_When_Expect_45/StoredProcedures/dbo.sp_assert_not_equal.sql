SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if exp = act
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_equal]
    @a         SQL_VARIANT
   ,@b         SQL_VARIANT
   ,@msg       VARCHAR(200)   = NULL
   ,@msg2      VARCHAR(200)   = NULL
   ,@msg3      VARCHAR(200)   = NULL
   ,@msg4      VARCHAR(200)   = NULL
   ,@msg5      VARCHAR(200)   = NULL
   ,@msg6      VARCHAR(200)   = NULL
   ,@msg7      VARCHAR(200)   = NULL
   ,@msg8      VARCHAR(200)   = NULL
   ,@msg9      VARCHAR(200)   = NULL
   ,@msg10     VARCHAR(200)   = NULL
   ,@msg11     VARCHAR(200)   = NULL
   ,@msg12     VARCHAR(200)   = NULL
   ,@msg13     VARCHAR(200)   = NULL
   ,@msg14     VARCHAR(200)   = NULL
   ,@msg15     VARCHAR(200)   = NULL
   ,@msg16     VARCHAR(200)   = NULL
   ,@msg17     VARCHAR(200)   = NULL
   ,@msg18     VARCHAR(200)   = NULL
   ,@msg19     VARCHAR(200)   = NULL
   ,@ex_num    INT             = NULL
   ,@fn        VARCHAR(60)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
DECLARE
    @fnThis    VARCHAR(35) = 'sp_assert_not_equal'
   ,@aTxt      VARCHAR(100)= CONVERT(VARCHAR(20), @a)
   ,@bTxt      VARCHAR(100)= CONVERT(VARCHAR(20), @b)
   ,@std_msg   VARCHAR(200)
    EXEC sp_log @log_level, @fnThis, '000: starting @a:[',@aTxt, '] @b:[', @bTxt, ']';
   -- a<>b MEANS a<b OR b<a -> !(!a<b AND !(b<a))
   IF ((dbo.fnIsLessThan(@a ,@b) = 1) OR (dbo.fnIsLessThan(@b ,@a) = 1))
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fnThis, '010: OK, [',@aTxt, '] <> [', @bTxt, ']';
      RETURN 0;
   END
   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   --EXEC sp_log 3, @fnThis, '020: [', @aTxt , '] equals [',@bTxt,'], raising exception';
   IF @ex_num IS NULL SET @ex_num = 50003;
   SET @std_msg = CONCAT(@fnThis, ' [', @aTxt , '] equals [',@bTxt,'] ');
   EXEC sp_raise_exception
       @msg1   = @std_msg
      ,@msg2   = @msg
      ,@msg3   = @msg2
      ,@msg4   = @msg3
      ,@msg5   = @msg4
      ,@msg6   = @msg5
      ,@msg7   = @msg6
      ,@msg8   = @msg7
      ,@msg9   = @msg8
      ,@msg10  = @msg9
      ,@msg11  = @msg10
      ,@msg12  = @msg11
      ,@msg13  = @msg12
      ,@msg14  = @msg13
      ,@msg15  = @msg14
      ,@msg16  = @msg15
      ,@msg17  = @msg16
      ,@msg18  = @msg17
      ,@msg19  = @msg18
      ,@ex_num = @ex_num
      ,@fn     = @fn
   ;
END
/*
-- Smoke test 
EXEC sp_assert_not_equal 0, 1, 'Failed: tested routine not qualified'
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_047_sp_assert_not_equal';
EXEC test.sp__crt_tst_rtns '[dbo].[sp_assert_not_equal]'
*/
GO

