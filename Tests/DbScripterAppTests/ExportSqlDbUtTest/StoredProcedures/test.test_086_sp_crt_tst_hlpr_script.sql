SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      15-APR-2023
-- Description:      creates the script for a test helper routine
--
-- Design: see EA ut/Use Case Model/Test Automation/Create Helper rotine Use case/Create the Helper routine
-- Algorithm:
-- Create the test helper script 
-- Preconditions:
--    test.rtnDetails and test.ParamDetails populated
--========================================================================================
CREATE PROCEDURE [test].[test_086_sp_crt_tst_hlpr_script]
AS
BEGIN
   DECLARE
       @fn                 NVARCHAR(35)   = N'T086_sp_crt_tst_hlpr_scrpt'
   TRUNCATE TABLE AppLog;
   EXEC sp_log 2, @fn,'01: starting';
   WHILE 1=1    -- Run test loop
   BEGIN
      EXEC test.hlpr_086_sp_crt_tst_hlpr_script
          @tst_num         = 'TG001: SP sp_grep_rtns'
         ,@inp_qrn         = '[dbo].[sp_class_creator]'
         ,@inp_trn         = 93
         ,@inp_cora        = 'C'
         ,@inp_ad_stp      = 1
         ,@tst_step_id     = NULL -- search id for line note step id not id as id can vary with other modifications
         ,@inp_tst_mode    = NULL
         ,@inp_stop_stage  = NULL
         ,@exp_ex_num      = NULL
         ,@exp_ex_msg      = NULL
         ,@exp_line        = NULL
         ,@display_script  = 1
RETURN;
      EXEC test.hlpr_086_sp_crt_tst_hlpr_script
          @tst_num         = 'TG001: SP sp_grep_rtns'
         ,@inp_qrn         = '[dbo].[sp_grep_rtns]'
         ,@inp_trn         = 99
         ,@inp_cora        = 'C'
         ,@inp_ad_stp      = 1
         ,@tst_step_id     = NULL -- search id for line note step id not id as id can vary with other modifications
         ,@inp_tst_mode    = NULL
         ,@inp_stop_stage  = NULL
         ,@exp_ex_num      = NULL
         ,@exp_ex_msg      = NULL
         ,@exp_line        = NULL
         ,@display_script  = 1
      EXEC test.hlpr_086_sp_crt_tst_hlpr_script
          @tst_num               = 'TG002: TF'
         ,@inp_qrn               = 'dbo.fnGetRtnDef'
         ,@inp_trn               = 99
         ,@inp_cora              = 'C'
         ,@inp_ad_stp            = 1
         ,@tst_step_id           = NULL -- search id for line note step id not id as id can vary with other modifications
         ,@inp_tst_mode          = NULL
         ,@inp_stop_stage        = NULL
         ,@exp_ex_num            = NULL
         ,@exp_ex_msg            = NULL
         ,@exp_line              = NULL
         ,@display_script        = 1
      --EXEC sp_list_applog;
      --EXEC sp_list_applog @fnFilter='CRT_TST_HLPR_SCRPT';
      BREAK; -- end of tests
   END -- WHILE Run test loop
   EXEC sp_log 2, @fn, '99: leaving, All tests PASSED'
END
/*
   EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script'
*/
GO

