SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if @a is null or empty
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_not_null_or_empty]
    @val       VARCHAR(3999)
   ,@msg1      VARCHAR(200)   = NULL
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
   ,@ex_num    INT            = NULL
   ,@fn        VARCHAR(35)    = '*'
   ,@log_level INT            = 0
AS
BEGIN
   DECLARE 
       @fnThis    VARCHAR(35) = N'sp_assert_not_null_or_empty'
      ,@valTxt    VARCHAR(20)= @val
   ;
   EXEC sp_log @log_level, @fnThis, '000: starting,' ,@msg1,': @val:[',@val,']';
   IF dbo.fnLen(@val) > 0
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
       IF dbo.fnLen(@valTxt) < 20 SET @valTxt= CONCAT(@valTxt, '   ');
      EXEC sp_log @log_level, @fnThis, '010: OK, ASSERTION: val: [',@valTxt, '] IS NOT NULL';
      RETURN 0;
   END
   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   EXEC sp_log 3, @fn, '020: @val IS NULL OR EMPTY, raising exception';
   IF @ex_num IS NULL SET @ex_num = 50005;
   DECLARE @msg0 VARCHAR(20)= 'val is NULL or empty'
   EXEC sp_raise_exception
       @ex_num = @ex_num
      ,@msg0   = 'sp_assert_not_null_or_empty'
      ,@msg1   = @msg0
      ,@msg2   = @msg1
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
      ,@fn     = @fn
      ;
END
/*
EXEC tSQLt.Run 'test.test_049_sp_assert_not_null_or_empty';
EXEC tSQLt.RunAll;
EXEC sp_assert_not_null_or_empty NULL
EXEC sp_assert_not_null_or_empty ''
EXEC sp_assert_not_null_or_empty 'Fred'
*/
GO

