SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      25-Nov-2023
-- Description:      main test rtn for the dbo.sp_set_log_level rtn being tested
-- Tested rtn desc:
--  sets the log level  
--
-- Tested rtn params: 
--    @level  INT
--========================================================================================
CREATE PROCEDURE [test].[test_079_sp_set_log_level]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_079_sp_set_log_level'
   EXEC sp_log 2, @fn,'01: starting'
---- SETUP
   -- <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_079_sp_set_log_level @inp_level=1,@exp_ex=0, @subtest='TG001', @exp_level = 1;
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   -- EXEC test.hlpr_079_sp_set_log_level @level=0,@exp_ex=1, @subtest='TR001';
   EXEC sp_log 2, @fn, '99: All subtests PASSED'
END
/*
EXEC tSQLt.Run 'test.test_079_sp_set_log_level';
*/
GO

