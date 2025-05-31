SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: Raises exception if @a is NULL
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_not_null]
    @val       SQL_VARIANT
   ,@prm_nm    VARCHAR(200)   = NULL -- this should be the parameter name
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
   ,@msg19     VARCHAR(200)   = NULL
   ,@msg20     VARCHAR(200)   = NULL
   ,@ex_num    INT             = NULL
   ,@fn        VARCHAR(60)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
DECLARE
    @fnThis     VARCHAR(60) = N'sp_assert_not_null'
   ,@valTxt VARCHAR(100)= CONVERT(VARCHAR(20), @val)
   ,@msg0   VARCHAR(200)

   EXEC sp_log @log_level, @fnThis, '000 starting @val:[',@valTxt,']';

   IF (@val IS NOT NULL)
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fnThis, '010: OK, ASSERTION: [',@prm_nm, '] IS NOT NULL';
      RETURN 0;
   END

   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   SET @msg0 = CONCAT('ERROR: [', @prm_nm, '] is NULL')
   EXEC sp_log 4, @fnThis, 'ASSERTION: val:[',@prm_nm, '] is NULL - raising exception ', @ex_num;
   IF @ex_num IS NULL SET @ex_num = 50004;

   EXEC sp_raise_exception
       @msg0   = @msg0
      ,@msg1   = @msg1
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
EXEC tSQLt.Run 'test.test_049_sp_assert_not_null_or_empty';
EXEC tSQLt.RunAll;
*/

GO
