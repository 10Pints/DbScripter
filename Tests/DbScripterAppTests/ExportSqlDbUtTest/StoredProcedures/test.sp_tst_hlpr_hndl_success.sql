SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================
-- Author:      Terry Watts
-- Create date: 13-FEB-2021
-- Description: handles test success 
--                increments the test passed counter, logs (force) msg
--
-- CALLED BY:   sp_tst_gen_chk
-- TESTS:       hlpr_015_fnGetErrorMsg
-- =========================================================================
CREATE PROCEDURE [test].[sp_tst_hlpr_hndl_success]
AS
BEGIN
   -- INCREMENT the TESTs PASSED count
   DECLARE
       @test_pass_cnt INT
      ,@log_msg       VARCHAR(4000)
   -- Passed so increment the test count
   EXEC @test_pass_cnt = test.sp_tst_incr_pass_cnt;
   -- log success
   SET @log_msg = ut.test.fnGetTestNum(test.fnGetCrntTstNum(), test.fnGetCrntTstSubNum());
   EXEC sp_log 1, 'sp_tst_hlpr_hndl_success', @log_msg, '  ', @test_pass_cnt,' tests_passed';
END
GO

