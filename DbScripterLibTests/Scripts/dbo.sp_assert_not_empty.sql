SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 09-JUN-2020
-- Description: Raises exception if @a is empty
-- =============================================
ALTER PROCEDURE [dbo].[sp_assert_not_empty]
    @val       NVARCHAR(3999)
   ,@msg1      NVARCHAR(2000)  = NULL
   ,@msg2      NVARCHAR(200)   = NULL
   ,@msg3      NVARCHAR(200)   = NULL
   ,@msg4      NVARCHAR(200)   = NULL
   ,@msg5      NVARCHAR(200)   = NULL
   ,@msg6      NVARCHAR(200)   = NULL
   ,@msg7      NVARCHAR(200)   = NULL
   ,@msg8      NVARCHAR(200)   = NULL
   ,@msg9      NVARCHAR(200)   = NULL
   ,@msg10     NVARCHAR(200)   = NULL
   ,@msg11     NVARCHAR(200)   = NULL
   ,@msg12     NVARCHAR(200)   = NULL
   ,@msg13     NVARCHAR(200)   = NULL
   ,@msg14     NVARCHAR(200)   = NULL
   ,@msg15     NVARCHAR(200)   = NULL
   ,@msg16     NVARCHAR(200)   = NULL
   ,@msg17     NVARCHAR(200)   = NULL
   ,@msg18     NVARCHAR(200)   = NULL
   ,@msg19     NVARCHAR(200)   = NULL
   ,@msg20     NVARCHAR(200)   = NULL
   ,@ex_num    INT             = 50001
   ,@state     INT             = 1
AS
BEGIN
   DECLARE
    @fn        NVARCHAR(35)   = N'sp_assert_not_empty'
   ,@msg       NVARCHAR(MAX)
   EXEC sp_log 0, @fn, '000 starting @val: [',@val,']';

   IF dbo.fnLen(@val) <= 0 --AND @a IS NOT NULL
   BEGIN
   -- ASSERTION: if here then either '' or NULL
      EXEC sp_log 4, @fn, '002: raising assert'
      SET @msg = CONCAT('ASSERTION FAILED: value should not be empty ', @msg1);

      IF @ex_num IS NULL SET @ex_num = 50001;

      EXEC sp_raise_exception
             @ex_num = @ex_num
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
   END

   EXEC sp_log 0, @fn, '999: OK';
END;
/*
EXEC tSQLt.Run 'test.test_046_sp_assert_not_empty';

EXEC tSQLt.RunAll;
*/

GO
