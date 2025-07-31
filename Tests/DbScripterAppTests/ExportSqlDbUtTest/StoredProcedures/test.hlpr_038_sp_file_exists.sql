SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================================================
-- Author:           Terry Watts
-- Create date:      14-JAN-2023
-- Description:      tests dbo.sp_file_exists procedure
-- Tested rtn desc:  sp_file_exists procedure chks a file or folder exists
--                   params: @file_or_folder IN, @file_exists OUT, @folder_exists OUT
-- ========================================================================================
CREATE PROCEDURE [test].[hlpr_038_sp_file_exists]
    @tst_nm             NVARCHAR(100)
   ,@file_or_folder     NVARCHAR(500)
   ,@exp_file_exists    INT OUT
   ,@exp_folder_exists  INT OUT
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'hlpr_038_sp_file_exists'
      ,@actfile_exists     INT = -1
      ,@actfolder_exists   INT = -1
      
   EXEC sp_log 1, @fn,'01: starting';
------ SETUP
------ Call tested rtn:
   EXEC dbo.sp_file_exists @file_or_folder,@actfile_exists OUT, @actfolder_exists OUT
------ TEST
   EXEC tSQLt.AssertEquals @exp_file_exists,   @actfile_exists,   'file_exists error';
   EXEC sp_log 1, @fn,'01: file   exists test PASSED';
   EXEC tSQLt.AssertEquals @exp_folder_exists, @actfolder_exists, 'folder_exists error'
   EXEC sp_log 1, @fn,'01: folder exists test PASSED';
   EXEC sp_log 1, @fn,'99: leaving, ALL TESTS PASSED';
END
GO

