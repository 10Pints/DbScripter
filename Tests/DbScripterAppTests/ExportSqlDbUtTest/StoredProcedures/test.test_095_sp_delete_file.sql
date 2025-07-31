SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      20-Sep-2024
-- Description: main test routine for the dbo.sp_delete_file routine 
--
-- Tested rtn description:
-- Deletes the file on disk
--=============================================================================================================
--[@ tSQLt:NoTransaction]('test.testCleanUp')
CREATE PROCEDURE [test].[test_095_sp_delete_file]
AS  -- AS-BGN-ST
BEGIN
DECLARE
   @fn NVARCHAR(35) = 'H95_SP_DELETE_FILE' -- fnCrtMnCodeCallHlpr
   EXEC test.hlpr_095_sp_delete_file
    @tst_num           ='T001'
   ,@inp_file_path     = 'D:\Dev\Farming\Farming\Data\CallRegister.txt'
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.hlpr_095_sp_delete_file
    @tst_num           ='T001'
   ,@inp_file_path     = 'CallRegister.txt'
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC sp_log 2, @fn, '99: All subtests PASSED' -- CLS-1
END
/*
EXEC tSQLt.Run 'test.test_095_sp_delete_file';
*/
GO

