SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 20-SEP-2024
-- Description: Deletes the file on disk
-- =============================================
CREATE PROCEDURE [dbo].[sp_delete_file] 
       @file_path       NVARCHAR(500)   = NULL
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(35)   = N'MAIN_IMPORT_INIT'
      ,@cmd NVARCHAR(MAX);
   EXEC sp_log 2, @fn,'000: deleting file:[',@file_path,']'
   ;
   SET @cmd = CONCAT('xp_cmdshell ''del "', @file_path, '"''');
   EXEC (@cmd);
   IF dbo.fnFileExists(@file_path) <> 0
      EXEC sp_raise_exception 63500, '500: failed to delete file [', @file_path, ']';
   EXEC sp_log 2, @fn,'999: successfully deleted file [', @file_path,']';
END
/*
*/
GO

