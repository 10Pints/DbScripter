SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      25-Nov-2023
-- Description:      main test rtn for the dbo.fnCaseSensistiveCompare rtn being tested
-- Tested rtn desc:
--  case sensitive compare helper function  
-- Returns:     1 if match false 0  
--
-- Tested rtn params: 
--    @expected  NVARCHAR(100),
--    @actual    NVARCHAR(100),
--
-- returns BIT
-- returns BIT
--========================================================================================
CREATE PROCEDURE [test].[test_077_fnCaseSensistiveCompare]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_077_fnCaseSensistiveCompare'
   EXEC ut.test.sp_tst_mn_st @fn;
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_077_fnCaseSensistiveCompare @tst_num='TG001', @expected='',@actual='', @exp_ex=0;
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   -- EXEC test.hlpr_077_fnCaseSensistiveCompare =0,@expected='',@actual='',@exp_ex=1, @subtest='TR001';
      EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_077_fnCaseSensistiveCompare';
EXEC tSQLt.RunAll;
*/
GO

