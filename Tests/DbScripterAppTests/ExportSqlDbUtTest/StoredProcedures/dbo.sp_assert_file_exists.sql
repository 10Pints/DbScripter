SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 30-MAR-2020
-- Description: assert the given file exists or throws exception @ex_num* 'the file[<@file>] does not exist', @state
-- * if @ex_num default: 53200, state=1
-- =============================================
CREATE PROCEDURE [dbo].[sp_assert_file_exists]
       @file      NVARCHAR(500)
      ,@msg1      NVARCHAR(200)   = NULL
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
      ,@ex_num    INT             = 53200
      ,@state     INT             = 1
      ,@fn        NVARCHAR(60)    = N'xxx*'  -- function testing the assertion
AS
BEGIN
   IF dbo.fnFileExists(@file) = 0
   DECLARE
       @fn_       NVARCHAR(35)   = N'ASSERT_FILE_EXISTS'
      ,@msg       NVARCHAR(MAX)
   EXEC sp_log 1, @fn_, '000: checking file [', @file, '] exists';
   IF dbo.fnFileExists( @file) = 0
   BEGIN
      SET @msg = CONCAT('File [',@file,'] does not exist');
      EXEC sp_raise_exception
          @ex_num = @ex_num
         ,@msg1   = @msg
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
         ,@msg20  = @msg19
         ,@state  = @state
      END
END
/*
EXEC sp_assert_file_exists 'non existant file', ' second msg',@fn='test fn', @state=5  -- expect ex: 53200, 'the file [non existant file] does not exist', ' extra detail: none', @state=1, @fn='test fn';
EXEC sp_assert_file_exists 'C:\bin\grep.exe'   -- expect OK
*/
GO

