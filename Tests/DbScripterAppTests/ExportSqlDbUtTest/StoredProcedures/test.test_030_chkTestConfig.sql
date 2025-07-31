SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================
-- Author:      Terry Watts
-- Create date: 27-MAY-2020
-- Description: Tests the following:
--    1: settings configuration getters,
--    2: setters
--    3: test.sp_tst_main_start
--
--   SELECT * FROM  [dbo].[fnGetProcedureDetails]('%current%' ,'' ,'test')
-- ==============================================================================
CREATE PROCEDURE [test].[test_030_chkTestConfig]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(60) = N'test 030 chkTestConfig'-- @fn: the test function nm
      ,@test_fn   NVARCHAR(60)
      ,@tested_fn NVARCHAR(30) -- tested   fn nm
      ,@fn_num    NVARCHAR(3)  -- test number
      ,@hlpr_fn   NVARCHAR(60) -- helper fn nm
      ,@tsu_fn    NVARCHAR(60) -- tsu    fn nm
      ,@tsu1_fn   NVARCHAR(60) -- tsu1   fn nm
      ,@tcls_fn   NVARCHAR(60) -- close  fn nm
      ,@len       INT
      ,@NL        NVARCHAR(3) = dbo.fnGetNL()
      ,@v         NVARCHAR(60)
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         SET NOCOUNT ON
         EXEC test.sp_tst_mn_st @fn;
         EXEC sp_log 1, @fn, '005: setup';
         EXEC test.sp_tst_set_crnt_tst_err_msg             N'Error msg 1'
         EXEC test.sp_tst_set_crnt_tst_err_st              1
         -- First check the keys:
         EXEC sp_log 1, @fn, '010: check the keys';
         EXEC test.hlpr_030_chkTestConfig N'T001', N'test.fnGetCrntTst1OffSetupFnKey' , N'TSU1 fn';
         EXEC test.hlpr_030_chkTestConfig N'T002', N'test.fnGetCrntTstClsFnKey'       , N'TCLS fn';
         EXEC test.hlpr_030_chkTestConfig N'T003', N'test.fnGetCrntTstdFnKey'         , N'Tested fn';
         EXEC test.hlpr_030_chkTestConfig N'T004', N'test.fnGetCrntTstErrMsgKey'      , N'Error msg';
         EXEC test.hlpr_030_chkTestConfig N'T005', N'test.fnGetCrntTstErrStKey'       , N'Error state';
         EXEC test.hlpr_030_chkTestConfig N'T006', N'test.fnGetCrntTstFnKey'          , N'Test fn';
         EXEC test.hlpr_030_chkTestConfig N'T007', N'test.fnGetCrntTstHlprFnKey'      , N'Hlpr fn';
         EXEC test.hlpr_030_chkTestConfig N'T008', N'test.fnGetCrntTstNumKey'         , N'Test num';
         EXEC test.hlpr_030_chkTestConfig N'T009', N'test.fnGetCrntTstSubNumKey'      , N'Test sub num'
         EXEC test.hlpr_030_chkTestConfig N'T010', N'test.fnGetCrntTstSetupFnKey'     , N'TSU fn';
         EXEC test.hlpr_030_chkTestConfig N'T011', N'test.fnGetCrntFailedTstNumKey'   , N'Failed test num'
         EXEC test.hlpr_030_chkTestConfig N'T012', N'test.fnGetCrntFailedTstSubNumKey', N'Failed test sub num'
         -- Test the setter and the getter together
         -- Step 1: Setup: Test 1: data setup by directly using setters
         EXEC sp_log 1, @fn, '100: Test the setter and the getter together';
         EXEC sp_log 1, @fn, '105: Set all the contexts first';
         EXEC test.sp_tst_set_crnt_tst_1_off_setup_fn N'1 off 1';
         EXEC test.sp_tst_set_crnt_tst_clse_fn        N'close_fn_name 1';
         EXEC test.sp_tst_set_crnt_tst_setup_fn       N'per_test_setup 1';
         EXEC test.sp_tst_set_crnt_tst_fn             N'test_fn_name 1';
         EXEC test.sp_tst_set_crnt_tstd_fn            N'tested_fn_name 1';
         EXEC test.sp_tst_set_crnt_tst_hlpr_fn        N'test helper 1';
         EXEC test.sp_tst_set_crnt_tst_num            N'T999';
         EXEC test.sp_tst_set_crnt_tst_sub_num        N'T33.1';
         EXEC test.sp_tst_set_crnt_failed_tst_num     N'T428'
         EXEC test.sp_tst_set_crnt_failed_tst_sub_num N'04.18'
         EXEC test.sp_tst_set_crnt_tst_err_st         0;
         -- Step 2: get the context
         EXEC sp_log 1, @fn, '200: Step 2: get the settings from the context';
         EXEC test.hlpr_030_chkTestConfig N'T013', N'test.fnGetCrntTst1OffSetupFn', N'1 off 1'
         EXEC test.hlpr_030_chkTestConfig N'T014', N'test.fnGetCrntTstSetupFn', N'per_test_setup 1';
         --EXEC test.sp_tst_set_crnt_tst_fn             N'test_fn_name 1';
         EXEC test.hlpr_030_chkTestConfig N'T015', N'test.fnGetCrntTstSetupFn', N'per_test_setup 1';
         -- EXEC test.sp_tst_set_crnt_tstd_fn            N'tested_fn_name 1';
         EXEC test.hlpr_030_chkTestConfig N'T016', N'test.fnGetCrntTstdFn', N'tested_fn_name 1';
         EXEC test.hlpr_030_chkTestConfig N'T017', N'test.fnGetCrntTstErrMsg'        , N'Error msg 1';
         EXEC test.hlpr_030_chkTestConfig N'T019', N'test.fnGetCrntTstFn'            , N'test_fn_name 1';
         EXEC test.hlpr_030_chkTestConfig N'T019', N'test.fnGetCrntTstErrSt'         , N'0';
         EXEC test.hlpr_030_chkTestConfig N'T020', N'test.fnGetCrntTstFn'            , N'test_fn_name 1';
         EXEC test.hlpr_030_chkTestConfig N'T021', N'test.fnGetCrntTstHlprFn'        , N'test helper 1';
         EXEC test.hlpr_030_chkTestConfig N'T022', N'test.fnGetCrntTstNum'           , N'T022';
         EXEC test.hlpr_030_chkTestConfig N'T023', N'test.fnGetCrntTstSubNum'        , N'T33.1';
--         EXEC test.hlpr_030_chkTestConfig N'T024', N'test.fnGetCrntTstSetupFn'       , N'per_test_setup 1';
         EXEC sp_log 1, @fn, '300: setting current_failed_tst_num: T428 ';
         EXEC test.sp_tst_set_crnt_failed_tst_num N'T428';
         SET @v = test.fnGetCrntFailedTstNum();
         EXEC sp_log 1, @fn, '305: getter: ', @v;
         EXEC tSQLt.assertEquals N'T428', @v, 'CrntFailedTstNum';
         --EXEC test.sp_tst_set_crnt_failed_tst_sub_num N'04.18'
         EXEC test.sp_tst_set_crnt_failed_tst_sub_num N'04.18';
         SET @v = test.fnGetCrntFailedTstSubNum();
         EXEC sp_log 1, @fn, '310: fnGetCrntFailedTstSubNum: set: [04.18]  Got:[', @v, ']';
         EXEC tSQLt.assertEquals N'04.18', @v, 'CrntFailedTstNum';
         --EXEC test.hlpr_030_chkTestConfig N'T026', N'test.fnGetCrntFailedTstSubNum'  , N'04.18'
         EXEC test.hlpr_030_chkTestConfig N'T027', N'test.fnGetCrntTstClsFn'         , N'close_fn_name 1'
         --------------------------------------------------------------------------------------------------
         -- Setup: Test 2: data setup by sp_tst_main_start routine
         -- @test_fn   NVARCHAR(60) = N'test 030 chkTestConfig'-- @fn: the test function nm
         --------------------------------------------------------------------------------------------------
         EXEC test.sp_tst_mn_st @fn
         -- Get the initial state for test 030 chkTestConfig
         SET @test_fn   = test.fnGetCrntTstFn();
         SET @tested_fn = test.fnGetCrntTstdFn();
         SET @fn_num    = test.fnGetCrntTstNum();
         SET @hlpr_fn   = test.fnGetCrntTstHlprFn();
         SET @tsu_fn    = test.fnGetCrntTstSetupFn();
         SET @tsu1_fn   = test.fnGetCrntTst1OffSetupFn();
         SET @tcls_fn   = test.fnGetCrntTstClsFn();
         EXEC sp_log 1, @test_fn, 'parms: ', @NL
            ,'@test_fn   = [', @test_fn   ,']', @NL
            ,'@tested_fn = [', @tested_fn ,']', @NL
            ,'@fn_num    = [', @fn_num    ,']', @NL
            ,'@hlpr_fn   = [', @hlpr_fn   ,']', @NL
            ,'@tsu_fn    = [', @tsu_fn    ,']', @NL
            ,'@tsu1_fn   = [', @tsu1_fn   ,']', @NL
            ,'@tcls_fn   = [', @tcls_fn   ,']', @NL
            ;
         PRINT CONCAT('fnGetCrntTst1OffSetupFn: [', test.fnGetCrntTst1OffSetupFn(), ']')
         EXEC test.hlpr_030_chkTestConfig N'T026', N'test.fnGetCrntTst1OffSetupFn'     , N'TSU1 030 chkTestConfig';
         EXEC test.hlpr_030_chkTestConfig N'T027', N'test.fnGetCrntTstSetupFn'         , N'TSU 030 chkTestConfig';
         EXEC test.hlpr_030_chkTestConfig N'T028', N'test.fnGetCrntTstClsFn'           , N'TCLS 030 chkTestConfig';
         EXEC test.hlpr_030_chkTestConfig N'T029', N'test.fnGetCrntTstdFn'             , N'chkTestConfig';
         EXEC test.hlpr_030_chkTestConfig N'T030', N'test.fnGetCrntTstFn'              , N'test 030 chkTestConfig';
         EXEC test.hlpr_030_chkTestConfig N'T031', N'test.fnGetCrntTstHlprFn'          , N'h 030 chkTestConfig';
         EXEC test.hlpr_030_chkTestConfig N'T032', N'test.fnGetCrntTstErrMsg'          , N'Error msg 1';
         BREAK;  -- Do once loop
      END -- WHILE
      EXEC test.sp_tst_mn_cls
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC tSQLt.Run 'test.test_030_chkTestConfig';
PRINT test.fnGetCrntFailedTstNum()
EXEC tSQLt.RunAll
EXEC test.test_030_chkTestConfig;
EXEC test.sp_tst_set_crnt_failed_tst_sub_num N'04.18';
PRINT test.fnGetCrntFailedTstSubNum();
*/
GO

