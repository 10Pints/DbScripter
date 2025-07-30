SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================================
-- Author:       Terry Watts
-- Create date:  12-MAY-2020
-- Description:  returns the parameters string for the tested routine
-- Lookout for file permissions soft failure
-- ===================================================================
CREATE PROCEDURE [dbo].[sp_write_file]
         @text                      VARCHAR(8000),
         @file                      VARCHAR(500),
         @overwrite                 BIT = 1
AS
BEGIN
   DECLARE   @fn           NVARCHAR(100) = 'WRITE_FILE'
         ,@ex_msg       NVARCHAR(500)
         ,@hr           INT
   BEGIN TRY
   -- ACTIVATE XP_CMDSHELL
/*      EXEC @hr = sp_configure 'show advanced options', 1;
      EXEC dbo.sp_assert_equals 0, @hr, 50001, 'sp_configure show adv failed'
      RECONFIGURE;
      EXEC @hr = sp_configure 'Ole Automation Procedures', 1;
      EXEC dbo.sp_assert_equals 0, @hr, 50002, 'sp_configure OLE failed'
      RECONFIGURE;
   */
      SET NOCOUNT ON
      DECLARE @query        VARCHAR(8000)
      DECLARE @OLE INT
      DECLARE @FileID INT
      EXECUTE  @hr = sp_OACreate  'Scripting.FileSystemObject', @OLE OUT
         EXEC dbo.sp_assert_equal 0, @hr, 50003, 'Scripting.FileSystemObject failed'
      BEGIN TRY
         EXECUTE @hr = sp_OAMethod  @OLE, 50004,    'DeleteFile', @file
         END TRY
         BEGIN CATCH
            SET @ex_msg = dbo.fnGetErrorMsg()
            EXEC sp_log 'Caught exception deleting file:[', @file,'] ex: ',@ex_msg
         END CATCH
         --                           p2:  Verb       p3: f handl out, p4:mode: p5: 1 read, 2 : writing, 8: append  param 6: create 1 yes, 0 no
         -- p4: Format 0 = TristateFalse - Open the file as ASCII. This is default.
         --            1 = TristateTrue - Open the file as Unicode.
         --            2 = TristateUseDefault - Open the file using the system default.
         EXECUTE @hr = sp_OAMethod  @OLE, 'OpenTextFile', @FileID OUT, @file, 2, 1
         EXEC dbo.sp_assert_equal 0, @hr, 50005, 'sp_OAMethod  @OLE, OpenTextFile failed'
         EXECUTE @hr = sp_OAMethod  @FileID, 'WriteLine', Null, @text
         EXEC dbo.sp_assert_equal 0, @hr, 50006, 'sp_OAMethod  @FileID, WriteLine failed'
         EXECUTE @hr = sp_OADestroy @FileID
         EXEC dbo.sp_assert_equal 0, @hr, 50007, 'sp_OADestroy @FileID failed'
         EXECUTE @hr = sp_OADestroy @OLE
         EXEC dbo.sp_assert_equal 0, @hr, 50007, 'sp_OADestroy OLE failed'
         /*
         -- Step 3: Disable Ole Automation Procedures
         EXEC @hr = sp_configure 'show advanced options', 1;
         RECONFIGURE;
         EXEC dbo.sp_assert_equals 0, @hr, 50009, 'Ole Auto close show adv failed'
         EXEC @hr = sp_configure 'Ole Automation Procedures', 0;
         EXEC dbo.sp_assert_equals 0, @hr, 50010, 'Ole Auto close failed'
         RECONFIGURE;
         */
      END TRY
      BEGIN CATCH
         SET @ex_msg = dbo.fnGetErrorMsg()
         EXEC sp_log 'Caught exception writing to file:[', @file,'] ex: ',@ex_msg;
         THROW;
      END CATCH
END
GO

