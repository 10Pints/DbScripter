SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 09-JULY-2021
-- Description: opens the log file and saves the 
--              parameters
--
-- The process of writing log to the Log File
-- on start of the procedure or day:
-- 1: open the log at the desired start of the process or session:
--    1.1:create the File ID and @OLE
--    1.2: save the File ID and @OLE in a setting
--
-- 2: do the logging in the process
-- 3: when done processing close the log:
-- =============================================
CREATE PROCEDURE [dbo].[sp_open_log]
       @log_file  NVARCHAR(260)
      ,@mode      BIT = 1        -- 0: Overwrite, 1: Append
AS
BEGIN
   DECLARE   @OLE    INT
            ,@FileID INT
            ,@hr     INT
            ,@msg    NVARCHAR(2000)
            ,@_mode  INT
   SET @_mode = IIF(@mode = 0, 2, 8);
   -- Step 1: Enable Ole Automation Procedures
   EXECUTE sp_OACreate 'Scripting.FileSystemObject', @OLE OUT;
   -- sp_OAMethod has a variable number of parameters depending on the method call (Verb)
   -- parameter 1 is the object id to call
   -- the subesequent parameters are specific to the object called
   -- in this case its OpenTextFile which has 4 parameters in this order:
   -- FilePath -Required. The name of the file to open
   --
   -- Mode - Optional. How to open the file
   -- 1 = Read   - Open a file for reading. You cannot write to this file.
   -- 2 = Write  - Overwrite the file.
   -- 8 = Append - write to the end of the file.
   --
   -- Create - Optional. Sets whether a new file can be created if the filename does not exist. 
   --    True indicates that a new file can be created,
   --    False indicates that a new file will not be created. False is default.
   --
   -- Format - Optional. The format of the file
   --    0 = TristateFalse - Open the file as ASCII. This is default.
   --    1 = TristateTrue - Open the file as Unicode.
   --    2 = TristateUseDefault - Open the file using the system default.
   EXECUTE @hr = sp_OAMethod @OLE, 'OpenTextFile', @FileID OUT, /*FilePath*/@log_file, /*Mode: Write*/2, /*Create*/1, /*Format: ASCII*/0;  -- 1:  Open the file as ASCII. 2= overwrite the file
   if @hr = 0
   BEGIN
      EXEC sys.sp_set_session_context @key = N'log_file_id', @value = @FileID;
      EXEC sys.sp_set_session_context @key = N'log_ole_id',  @value = @OLE;
   END
   ELSE
   BEGIN
      SET @msg = CONCAT('There was an error opening the log file:[', @log_file, '] error code: ', @hr);
      PRINT @msg;
      throw 52002, @msg, 2;
   END
   -- 0 means ok
   RETURN @hr;
END
GO

