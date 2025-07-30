SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-MAR-2020
-- Description: asserts that a is greater than b
--              raises an exception if not
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_gtr_than]
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
      ,@ex_num    INT            = 53502
      ,@state     INT            = 1
AS
BEGIN
   DECLARE
       @aTxt   NVARCHAR(100)= CONVERT(NVARCHAR(20), @a)
      ,@bTxt   NVARCHAR(100)= CONVERT(NVARCHAR(20), @b)
      ,@msg0   NVARCHAR(1000)
   WHILE(1=1)
   BEGIN
      IF dbo.fnChkEquals(@a ,@b) = 1
         BREAK;    -- mismatch
      IF dbo.fnIsLessThan(@b, @a) = 1
         RETURN 1; -- match
      -- ASSERTION: if here then mismatch
      BREAK;
   END
   -- ASSERTION: if here then mismatch
   SET @msg0 = CONCAT('ASSERTION [',CONVERT( NVARCHAR(40), @a), '] > [', CONVERT( NVARCHAR(40), @b), '] failed. ');
   EXEC sp_raise_exception
          @msg1   = @msg0
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
         ,@msg20  = @msg19
         ,@ex_num = @ex_num
         ,@state  = @state
   ;
END
/*
   EXEC tSQLt.RunAll;
   EXEC tSQLt.Run 'test.test_042_sp_assert_gtr_than';
*/
GO

