SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      25-Nov-2023
-- Description:      main test rtn for the dbo.fnGetLogLevelKey rtn being tested
-- Tested rtn desc:
--  returns the log level key  
--
-- Tested rtn params: 
--
--========================================================================================
CREATE PROCEDURE [test].[test_078_fnGetLogLevelKey]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_078_fnGetLogLevelKey'
   EXEC ut.test.sp_tst_mn_st @fn;
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_078_fnGetLogLevelKey @tst_num='TG001', @exp_key='Log_Level';
   EXEC test.hlpr_078_fnGetLogLevelKey @tst_num='TG001', @exp_key='LOG_LEVEL';
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   -- EXEC test.hlpr_078_fnGetLogLevelKey ='',@exp_ex=1, @subtest='TR001';
   EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_078_fnGetLogLevelKey';
EXEC tSQLt.RunAll;
*/
GO

