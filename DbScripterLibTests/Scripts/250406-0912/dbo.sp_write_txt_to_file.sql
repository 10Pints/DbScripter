SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

ALTER PROCEDURE [dbo].[sp_write_txt_to_file]
(
    @string  VARCHAR(8000)
   ,@file    VARCHAR(500)
   ,@append  BIT        = 0
)
AS
BEGIN
DECLARE
    @objFileSystem   INT
   ,@objTextStream   INT
   ,@objErrorObject  INT
   ,@err_msg         VARCHAR(1000)
   ,@Command         VARCHAR(1000)
   ,@hr              INT
   ,@Source          VARCHAR(255)
   ,@Description     VARCHAR(255)
   ,@Helpfile        VARCHAR(255)
   ,@HelpID          INT
   ,@mode            INT = iif(@append=1, 8,2)
;

   SET NOCOUNT ON

   WHILE 1=1
   BEGIN
      SET @err_msg = 'opening the File System Object';
      EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT;

      IF @HR <> 0
         BREAK;

      SET @objErrorObject=@objFileSystem
      SET @err_msg='Creating file "' + @file+'"';

      EXECUTE @hr = sp_OAMethod @objFileSystem, 'CreateTextFile', @objTextStream OUT, @file,@mode,True; -- true here means create if does not exist

      IF @HR <> 0
         BREAK;

      SET  @objErrorObject  = @objTextStream;
      SET  @err_msg = 'writing to the file "'+@file+'"';

      EXECUTE @hr = sp_OAMethod  @objTextStream, 'Write', Null, @String;

      IF @HR <> 0
         BREAK;

      SET  @objErrorObject  = @objTextStream
      SET  @err_msg = 'closing the file "' + @file + '"';

      EXECUTE @hr = sp_OAMethod @objTextStream, 'Close';

      IF @HR <> 0
      BEGIN
         EXECUTE sp_OAGetErrorInfo  @objErrorObject, @source OUTPUT,@description OUTPUT,@Helpfile OUTPUT, @HelpID OUTPUT;
         PRINT CONCAT('Error hr: ', @HR, 'occurred closing the file: [', @file,'] source: ', @source, ' description:', @description, ' @Helpfile:[', @Helpfile,'] @HelpID: ',@HelpID);
         SET @HR = 0; -- Log and ignore this error for now.
      END

      BREAK;
   END -- while 1=1

   EXECUTE sp_OADestroy @objTextStream;
   EXECUTE sp_OADestroy @objFileSystem;

   IF @hr<>0
   BEGIN
      EXECUTE sp_OAGetErrorInfo  @objErrorObject, @source OUTPUT,@Description OUTPUT,@Helpfile OUTPUT, @HelpID OUTPUT;

      SET @err_msg = CONCAT('Error HR: ',@HR, ' ', @err_msg,' ', COALESCE(@err_msg,'doing something'), ', ', COALESCE(@Description, ''));
      EXECUTE sp_OADestroy @objTextStream;
      EXECUTE sp_OADestroy @objFileSystem;
      THROW 65555, @err_msg,1;
   END
END
/*
EXEC dbo.sp_write_txt_to_file 'The quick brown fox jumped over the lazy dog', 'D:\data\b.txt';
*/

GO
