SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      20-Sep-2024
-- Description: main test routine for the dbo.GetFileDetails routine 
--
-- Tested rtn description:
-- Gets the file details from the supplied file path:
--    [Folder, File name woyhout ext, extension]
--
-- Tests:
--
-- CHANGES:
--=============================================================================================================
CREATE PROCEDURE [test].[test_096_fnGetFileDetails]
AS  -- AS-BGN-ST
BEGIN
DECLARE
   @fn NVARCHAR(35) = 'H96_fnGetFileDetails' -- fnCrtMnCodeCallHlpr
   EXEC sp_log 2, @fn,'01: starting';
   EXEC test.sp_tst_mn_st @fn
   EXEC test.hlpr_096_fnGetFileDetails
    @tst_num           = 'T001 no folder' -- expect nulls
   ,@inp_file_path     = 'CallRegister.txt'
   ,@exp_folder        = NULL
   ,@exp_file_name     = NULL
   ,@exp_ext           = NULL
   ,@exp_fn_pos        = NULL
   ,@exp_dot_pos       = NULL
   ,@exp_len           = 16
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.hlpr_096_fnGetFileDetails
    @tst_num           = 'T002 green'
   ,@inp_file_path     = 'D:\Dev\Ut\Tests\test_096_GetFileDetails\CallRegister.abc.txt'
   ,@exp_folder        = 'D:\Dev\Ut\Tests\test_096_GetFileDetails'
   ,@exp_file_name     = 'CallRegister.abc'
   ,@exp_ext           = 'txt'
   ,@exp_fn_pos        = 39
   ,@exp_dot_pos       = 56
   ,@exp_len           = 60
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.hlpr_096_fnGetFileDetails
    @tst_num           = 'T003 null'
   ,@inp_file_path     = NULL
   ,@exp_folder        = NULL
   ,@exp_file_name     = NULL
   ,@exp_ext           = NULL
   ,@exp_fn_pos        = NULL
   ,@exp_dot_pos       = NULL
   ,@exp_len           = NULL
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.hlpr_096_fnGetFileDetails
    @tst_num           = 'T004 MT'
   ,@inp_file_path     = ''
   ,@exp_folder        = NULL
   ,@exp_file_name     = NULL
   ,@exp_ext           = NULL
   ,@exp_fn_pos        = NULL
   ,@exp_dot_pos       = NULL
   ,@exp_len           = 0
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_096_fnGetFileDetails';
*/
GO

