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
CREATE PROCEDURE [test].[test_038_sp_file_exists]
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'test_038_sp_file_exists'
   EXEC sp_log 1, @fn,'01: starting';
   EXEC test.sp_tst_mn_st @fn;
   -- Green tests: test file folder:
   --                                 test#   @file_or_folder                 exp f_ex, exp d_ex
   EXEC test.hlpr_038_sp_file_exists 'TG001: ', 'D:\Dev\Repos\Farmingx\Datax\', 0,          0;               
   EXEC test.hlpr_038_sp_file_exists 'TG002: ', 'D:\Dev\Repos\Farming\Datax\',  0,          0;               
   EXEC test.hlpr_038_sp_file_exists 'TG003: ', 'D:\Dev\Repos\Farming\Data\',   0,          1;               
   -- Red tests
   EXEC test.hlpr_038_sp_file_exists 'TR004: empty file nm', '', 0,          0;               
   EXEC test.hlpr_038_sp_file_exists 'TR005: null  file nm', '', 0,          0;               
   EXEC sp_log 1, @fn,'99: leaving, ALL TESTS PASSED';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_038_sp_file_exists'
*/
GO

