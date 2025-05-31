SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===========================================================
-- Author:      Terry watts
-- Create date: 20-SEP-2024
-- Description: Deletes the file on disk
--
-- Postconditions:
-- POST 01 raise exception if failed to delete the file
-- ===========================================================
ALTER PROCEDURE [dbo].[sp_delete_file]
    @file_path    VARCHAR(500)   = NULL
   ,@chk_exists   BIT = 0 -- chk exists in the first place
   ,@fn           VARCHAR(35)    = N'*'
AS
BEGIN
   DECLARE
    @fnThis       VARCHAR(35)   = N'SP DELETE_FILE'
   ,@cmd          VARCHAR(MAX)
   ,@msg          VARCHAR(1000)
   ;

   EXEC sp_log 1, @fnThis,'000: starting, deleting file:[',@file_path,']';
   DROP TABLE IF EXISTS #tmp;
   CREATE table #tmp (id INT identity(1,1), [output] NVARCHAR(4000))

   IF (dbo.fnFileExists(@file_path) <> 0)
   BEGIN
      --SET @cmd = CONCAT('INSERT INTO #tmp  EXEC xp_cmdshell ''del "', @file_path, '"'' ,NO_OUTPUT');
      SET @cmd = CONCAT('INSERT INTO #tmp  EXEC xp_cmdshell '' del "', @file_path, '"''');
      --PRINT @cmd;
      EXEC sp_log 1, @fnThis,'010: sql:[',@cmd,']';
      EXEC (@cmd);

      --IF EXISTS (SELECT TOP 2 1 FROM #tmp) SELECT * FROM #tmp;
   END
   ELSE -- file does not exist
      IF (@chk_exists = 1) -- POST 01 raise exception if failed to delete the file
         EXEC sp_raise_exception 58147, ' 020: file [',@file_path,'] does not exist but chk_exists specified', @fn=@fnThis;

   IF dbo.fnFileExists(@file_path) <> 0
   BEGIN
      IF EXISTS (SELECT TOP 2 1 FROM #tmp)
         SELECT @msg = [output] FROM #tmp where id = 1;

      EXEC sp_raise_exception 63500, '030: failed to delete file [', @file_path, '], reason: ',@msg, @fn=@fnThis;
   END

   EXEC sp_log 0, @fnThis,'999: leaving';
END
/*
EXEC sp_delete_file 'D:\Logs\a.txt';
EXEC sp_delete_file 'non exist file';
EXEC sp_delete_file 'D:\Logs\Farming.log';

EXEC xp_cmdshell 'del "D:\Logs\Farming.log"'


*/

GO
