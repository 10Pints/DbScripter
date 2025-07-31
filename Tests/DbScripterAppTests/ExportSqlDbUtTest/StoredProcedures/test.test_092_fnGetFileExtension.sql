SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      19-Sep-2024
-- Description: main test routine for the dbo.fnGetFileExtension routine 
--
-- Tested rtn description:
-- Gets the file extension from the supplied file path
--
-- Tests:
--
-- CHANGES:
--=============================================================================================================
CREATE PROCEDURE [test].[test_092_fnGetFileExtension]
AS  -- AS-BGN-ST
BEGIN
DECLARE
   @fn NVARCHAR(35) = 'H901_FNGETFILEEXTENSION' -- fnCrtMnCodeCallHlpr
   EXEC test.sp_tst_mn_st 'test_092_fnGetFileExtension';
   EXEC test.hlpr_092_fnGetFileExtension
    @tst_num           ='T001'
   ,@inp_path          = NULL
   ,@exp_out_val       = NULL
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.hlpr_092_fnGetFileExtension
    @tst_num           ='T002'
   ,@inp_path          = ''
   ,@exp_out_val       = NULL
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.hlpr_092_fnGetFileExtension
    @tst_num           ='T003'
   ,@inp_path          = '.'
   ,@exp_out_val       = NULL
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.hlpr_092_fnGetFileExtension
    @tst_num           ='T004'
   ,@inp_path          = '.ext'
   ,@exp_out_val       = 'ext'
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.hlpr_092_fnGetFileExtension
    @tst_num           ='T005'
   ,@inp_path          = '.ext'
   ,@exp_out_val       = 'ext'
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.hlpr_092_fnGetFileExtension
    @tst_num           ='T006'
   ,@inp_path          = 'abc.defg'
   ,@exp_out_val       = 'defg'
   ,@exp_ex_num        = NULL
   ,@exp_ex_msg        = NULL
   EXEC test.sp_tst_mn_cls; -- sp_log 2, @fn, '99: All subtests PASSED' -- CLS-1
END
/*
EXEC tSQLt.Run 'test.test_092_fnGetFileExtension';
----------------------------------------------------------------------------
DECLARE @res NVARCHAR(50)
SET @res =dbo.fnGetFileExtension(NULL);
IF @res IS NULL PRINT 'IS NULL' ELSE PRINT CONCAT('|', @res, '|');
----------------------------------------------------------------------------
*/
GO

