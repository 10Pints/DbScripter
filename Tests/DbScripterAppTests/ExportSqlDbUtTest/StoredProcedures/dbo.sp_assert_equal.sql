SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 21-JAN-2020
-- Description: 1 line check null or mismatch and throw message
--              ASSUMES data types are the same
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_equal] 
       @a         SQL_VARIANT
      ,@b         SQL_VARIANT
      ,@msg       NVARCHAR(200)   = NULL
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
   IF dbo.fnChkEquals(@a ,@b) = 0
      EXEC sp_raise_exception
          @msg1    = @msg
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
         ,@state  = @state
END
/*
   EXEC tSQLt.RunAll;
*/
GO

