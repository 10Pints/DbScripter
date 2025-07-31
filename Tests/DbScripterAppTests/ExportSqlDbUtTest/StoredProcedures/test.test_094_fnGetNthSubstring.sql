SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================================================================================
-- Author:           Terry Watts
-- Create date:      11-May-2024
-- Description: main test routine for the dbo.fnGetNthSubstring routine 
--
-- Tested rtn description:
-- gets the n-th substring in str separated by sep
--              1 based numbering but [0] and [1] return
--                the first element in the sequence
-- if there are double quotes in the string then the seps in the double quotes section should be ignored
--
-- Preconditions: none
--
-- Postconditions
-- POST 00: @sub returns the @ndx substring from @input_str using sep to separate the items
--          or
--=============================================================================================================
CREATE PROCEDURE [test].[test_094_fnGetNthSubstring]
AS  -- AS-BGN-ST
BEGIN
DECLARE
   @fn NVARCHAR(35) = 'H94_FNGETNTHSUBSTRING' -- fnCrtMnCodeCallHlpr
   EXEC test.hlpr_094_fnGetNthSubstring
    @tst_num           ='T001'
   ,@inp_input_str     = ''
   ,@inp_sep           = ''
   ,@inp_ndx           = 0
   ,@exp_out_val       = NULL
   EXEC sp_log 2, @fn, '99: All subtests PASSED' -- CLS-1
END
/*
tSQLt.RunAll
EXEC tSQLt.Run 'test.test_094_fnGetNthSubstring';
*/
GO

