SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================
-- Author:      Terry watts
-- Create date: 24-DEC-2024
-- Description: copies file on disk
-- Rules:
-- R01: cannot copy to self Exception 70300 'Can't copy to self'
--
-- Preconditions:
-- PRE 01 R01: cannot copy to self Exception 70300 'Can't copy to self'
--
-- Postconditions:
-- POST 01: raise exception if failed to copy the file
-- POST 02: if there is an OS copy error then exception 70301, <dos error>
-- =========================================================================
CREATE PROCEDURE [dbo].[sp_copy_file]
    @src_file   VARCHAR(500)   = NULL
   ,@dst_file   VARCHAR(500)   = NULL
   ,@chk_exists BIT = 0 -- chk exists after copy
AS
BEGIN
   DECLARE
    @fn         VARCHAR(35)   = 'sp_copy_file'
   ,@cmd        NVARCHAR(MAX)
   ,@msg        VARCHAR(1000)
   ,@RC         INT
   ,@dstDir     VARCHAR(500)
   ;

   EXEC sp_log 1, @fn,'000: starting,
src file  :[', @src_file  ,']
dst file  :[', @dst_file  ,']
chk_exists:[', @chk_exists,']
';

   DROP TABLE IF EXISTS #tmp;
   CREATE table #tmp (id INT identity(1,1), [output] NVARCHAR(4000));

   ---------------------------------------------------------------------
   -- Validation
   ---------------------------------------------------------------------
   EXEC sp_log 1, @fn,'010: validating parameters';

   IF (dbo.fnFileExists(@src_file) = 0)
   BEGIN
      EXEC sp_raise_exception 58147, '020: source file [',@src_file,'] does not exist';
   END

   EXEC sp_assert_not_null_or_empty @dst_file, '030: destination file must be specified'
   SELECT @dstDir = folder FROM dbo.fnGetFileDetails(@dst_file);
   EXEC sp_assert_not_null_or_empty @dst_file, '035: destination file must be specified'
   -- PRE 01 R01: cannot copy to self Exception 70300 'Can't copy to self'
   EXEC sp_assert_not_equal @src_file, @dst_file, 'R01: cannot copy to self', @ex_num=70300;
   ------------------------------------------------------------
   -- ASSERTON: Validated preconditions
   ------------------------------------------------------------
   EXEC sp_log 1, @fn, '040: ASSERTON: Validated preconditions';

   ---------------------------------------------------------------------
   -- ASSERTION Validated params
   ---------------------------------------------------------------------
   EXEC sp_log 1, @fn,'040: ASSERTION: validated parameters';

   EXEC sp_log 1, @fn,'050: copying ',@src_file, ' to ', @dst_file;
   SET @cmd = CONCAT('INSERT INTO #tmp EXEC @RC = xp_cmdshell '' copy /Y "', @src_file, '","', @dst_file,'''');
   EXEC sp_log 1, @fn,'060: sql:[',@cmd,']';
   EXEC sp_executesql @cmd, N'@RC INT OUT', @RC OUT;

   IF @RC <> 0
   BEGIN
      EXEC sp_log 4, @fn,'065: OS copy cmd failed :[',@RC,']';
      --SELECT * FROM #tmp;
      SELECT @msg = [output] FROM #tmp where id = 1;
      EXEC sp_raise_exception 70301, '070: error copying ', @src_file, ' to ',@dst_file, ' ',@msg, @fn=@fn;
   END

   IF (@chk_exists = 1) AND (dbo.fnFileExists(@dst_file) = 0)  -- POST 01 raise exception if failed to copy the file
      EXEC sp_raise_exception 58147, ' 080: failed to copy [',@src_file,'] to  [@dst_file]', @fn=@fn;

   ---------------------------------------------------------------------
   -- ASSERTION successfully copied src file to dst file
   ---------------------------------------------------------------------

   EXEC sp_log 0, @fn,'999: leaving';
END
/*
EXEC sp_delete_file 'D:\Logs\a.txt';
EXEC sp_delete_file 'non exist file';
EXEC sp_delete_file 'D:\Logs\Farming.log';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_062_sp_copy_file';
*/

GO
