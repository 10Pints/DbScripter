SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 17-JAN-2020
-- Description: Tests the fnGetReplacePhrase routine
-- =============================================
CREATE PROCEDURE [test].[test_020_fnGetReplacePhrase]
AS
BEGIN
   DECLARE
       @fn  NVARCHAR(60) = N'test 020 fnGetReplacePhrase'
   EXEC ut.test.sp_tst_mn_st @fn
   EXEC test.hlpr_020_fnGetReplacePhrase
       @test_num    = 'TR 001'
      ,@table       = NULL
      ,@folder      = NULL
      ,@wrkbk_nm    = NULL
      ,@sheet_nm    = NULL
      ,@view_nm     = NULL
      ,@tmstmp      = NULL
      ,@exp_rc      = 0
      ,@exp_wrkbk_nm= NULL
      ,@exp_sht_nm  = NULL
      ,@exp_view_nm = NULL
      ,@exp_tmstmp  = NULL
      ,@exp_err_msg = NULL
      ,@exp_ex_num  = 50102
      ,@exp_ex_msg  = 'table must be specified'
   EXEC test.hlpr_020_fnGetReplacePhrase
       @test_num    = 'TR 002'
      ,@table       = 'a table'
      ,@folder      = NULL
      ,@wrkbk_nm    = NULL
      ,@sheet_nm    = NULL
      ,@view_nm     = NULL
      ,@tmstmp      = NULL
      ,@exp_rc      = 0
      ,@exp_wrkbk_nm= NULL
      ,@exp_sht_nm  = NULL
      ,@exp_view_nm = NULL
      ,@exp_tmstmp  = NULL
      ,@exp_err_msg = NULL
      ,@exp_ex_num  = 50102
      ,@exp_ex_msg  = 'unknown table'
   EXEC test.hlpr_020_fnGetReplacePhrase
       @test_num    = 'TR 003'
      ,@table       = 'AppLog'
      ,@folder      = NULL
      ,@wrkbk_nm    = NULL
      ,@sheet_nm    = NULL
      ,@view_nm     = NULL
      ,@tmstmp      = NULL
      ,@exp_rc      = 0
      ,@exp_wrkbk_nm= NULL
      ,@exp_sht_nm  = NULL
      ,@exp_view_nm = NULL
      ,@exp_tmstmp  = NULL
      ,@exp_err_msg = NULL
      ,@exp_ex_num  = 50102
      ,@exp_ex_msg  = 'folder must be specified'
   EXEC test.hlpr_020_fnGetReplacePhrase
       @test_num    = 'TR 004'
      ,@table       = 'AppLog'
      ,@folder      = 'non existent folder'
      ,@wrkbk_nm    = NULL
      ,@sheet_nm    = NULL
      ,@view_nm     = NULL
      ,@tmstmp      = NULL
      ,@exp_rc      = 0
      ,@exp_wrkbk_nm= NULL
      ,@exp_sht_nm  = NULL
      ,@exp_view_nm = NULL
      ,@exp_tmstmp  = NULL
      ,@exp_err_msg = NULL
      ,@exp_ex_num  = 50102
      ,@exp_ex_msg  = 'folder does not exist'
   EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_020_fnGetReplacePhrase'
*/
GO

