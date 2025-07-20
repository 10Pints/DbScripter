SET ANSI_NULLS ON

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
   DECLARE
       @fn            VARCHAR(35)   = N'sp_tst_hlpr_hndl_success'
      ,@test_pass_cnt INT
      ,@msg           VARCHAR(500)
   ;

 -- Passed so increment the test count
   EXEC @test_pass_cnt = test.sp_tst_incr_pass_cnt;
   SET @msg = CONCAT(test.fnGetCrntTstFn(), '.', test.fnGetCrntTstNum2());

   PRINT test.fnGetTstHdrFooterLine(0, 0, @msg, 'passed');
END
/*
*/



GO
