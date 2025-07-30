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
    @file      VARCHAR(500)
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
   ,@ex_num    INT             = 53200
   ,@fn        VARCHAR(60)    = N'*'
   ,@log_level INT            = 0
AS
BEGIN
   DECLARE
       @fn_       VARCHAR(35)   = N'ASSERT_FILE_EXISTS'
      ,@msg       VARCHAR(MAX)
   EXEC sp_log @log_level, @fn_, '000: checking file [', @file, '] exists';
   IF dbo.fnFileExists( @file) = 1
   BEGIN
      ----------------------------------------------------
      -- ASSERTION OK
      ----------------------------------------------------
      EXEC sp_log @log_level, @fn, '010: OK,File [',@file,'] exists';
      RETURN 0;
   END
   ----------------------------------------------------
   -- ASSERTION ERROR
   ----------------------------------------------------
   SET @msg = CONCAT('File [',@file,'] does not exist');
   EXEC sp_log 3, @fn, '020:', @msg, ' raising exception';
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
      ,@fn     = @fn
   ;
END
/*
EXEC sp_assert_file_exists 'non existant file', ' second msg',@fn='test fn', @state=5  -- expect ex: 53200, 'the file [non existant file] does not exist', ' extra detail: none', @state=1, @fn='test fn';
EXEC sp_assert_file_exists 'C:\bin\grep.exe'   -- expect OK
*/
GO

