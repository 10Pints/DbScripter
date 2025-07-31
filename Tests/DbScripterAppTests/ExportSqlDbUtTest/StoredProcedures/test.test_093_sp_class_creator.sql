SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      03-May-2024
-- Description: main test routine for the dbo.sp_class_creator routine 
--
-- Tested rtn description:
-- C# Class Creator
--=============================================================================================================
CREATE PROCEDURE [test].[test_093_sp_class_creator]
AS  -- AS-BGN-ST
BEGIN
DECLARE
   @fn NVARCHAR(35) = 'H93_SP_CLASS_CREATOR' -- fnCrtMnCodeCallHlpr
   EXEC test.hlpr_093_sp_class_creator
    @tst_num           = NULL
   ,@tst_key           = NULL
   ,@inp_table_name    = NULL
   ,@exp_row_cnt       = NULL
   ,@exp_line          = NULL
   ,@exp_column_name   = NULL
   ,@exp_data_type     = NULL
   ,@exp_is_nullable   = NULL
   ,@exp_newtype       = NULL
   ,@exp_defn          = NULL
   EXEC sp_log 2, @fn, '99: All subtests PASSED' -- CLS-1
END
/*
EXEC tSQLt.Run 'test.test_093_sp_class_creator';
*/
GO

