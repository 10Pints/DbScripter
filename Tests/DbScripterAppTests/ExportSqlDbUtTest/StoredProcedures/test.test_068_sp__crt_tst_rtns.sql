SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      24-Nov-2023
-- Description:      main test rtn for the test.sp_crt_tst_rtns rtn being tested
-- Tested rtn desc:
--  Creates both the main and the helper test rtns
--   for the given tested rtn
--
-- Changes:
-- 231124: added remove [] brckets to make it easier to set up tests
--
-- Tested rtn params:
--    @q_tstd_rtn    NVARCHAR(100),
--    @test_rtn_num  INT,
--    @crt_or_alter  NCHAR(2),
--    @fn_ret_ty     NVARCHAR(50)
--========================================================================================
----[@tSQLt:NoTransaction]('test.testCleanUp')
CREATE PROCEDURE [test].[test_068_sp__crt_tst_rtns]
AS
BEGIN
   DECLARE
      @fn   NVARCHAR(35)   = N'test_068_sp__crt_tst_rtns'
   TRUNCATE TABLE AppLog
   EXEC test.sp_tst_mn_st @fn;
   WHILE 1=1
   BEGIN
      EXEC sp_log 1, @fn, '010: calling hlpr_068_sp__crt_tst_rtns T001 sp';
      EXEC test.hlpr_068_sp__crt_tst_rtns
          @tst_num   = 'T003 tf'
         ,@qrn       = 'dbo.fnDeltaStats'
         ,@trn       = 902
         ,@cora      = 'C'
         ,@ad_stp    = 1    -- used in testing to identify a step with a unique name (not an incremental int id)
         ,@tst_mode  = 1
         ,@folder    = 'D:\Dev\Repos\Ut\Tests\test_068_sp__crt_tst_rtns'
         ,@stop_stg  = 99
         ,@exp_ex_num= NULL
         ,@exp_ex_msg= NULL
      ;
      BREAK;
      -- Run the test Helper rtn to run the tested rtn and do some checks
      EXEC test.hlpr_068_sp__crt_tst_rtns
          @tst_num   = 'T001 sp'
         ,@qrn       = 'dbo.sp_app_log_display'
         ,@trn       = 900
         ,@cora      = 'C'
         ,@ad_stp    = 1    -- used in testing to identify a step with a unique name (not an incremental int id)
         ,@tst_mode  = 1
         ,@stop_stg  = 99
         ,@folder    = 'D:\Dev\Repos\Ut\Tests\test_068_sp__crt_tst_rtns'
         ,@exp_ex_num= NULL
         ,@exp_ex_msg= NULL
      ;
      EXEC sp_log 1, @fn, '015: ret frm hlpr_068_sp__crt_tst_rtns T001 sp';
      EXEC test.hlpr_068_sp__crt_tst_rtns
          @tst_num   = 'T002 fn'
         ,@qrn       = 'dbo.fnDeSquareBracket'
         ,@trn       = 901
         ,@cora      = 'C'
         ,@ad_stp    = 1    -- used in testing to identify a step with a unique name (not an incremental int id)
         ,@tst_mode  = 1
         ,@stop_stg  = 99
         ,@folder    = 'D:\Dev\Repos\Ut\Tests\test_068_sp__crt_tst_rtns'
         ,@exp_ex_num= NULL
         ,@exp_ex_msg= NULL
      ;
      BREAK;
   END
   EXEC test.sp_tst_mn_cls;
END
/*
---------------------------------------------------------------------
TRUNCATE TABLE AppLog
EXEC tSQLt.Run 'test.test_068_sp__crt_tst_rtns';
---------------------------------------------------------------------
EXEC tSQLt.RunAll;
EXEC sp_list_AppLog
EXEC sp_list_AppLog @fnFilter='hlpr_068_sp__crt_tst_rtns%'
SELECT * FROM AppLog
*/
GO

