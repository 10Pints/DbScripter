SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================
-- Author:           Terry Watts
-- Create date:      14-JAN-2023
-- Description:      tests dbo.spTableExists()
-- Tested rtn desc:  spTableExists() checks if a table exists 
--                   params: table, schema, db all in @table_spexc param
-- ====================================================================
CREATE PROCEDURE [test].[test_036_sp_assert_table_exists]
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(35)   = N'sp_chk_table_exists'
   EXEC test.sp_tst_mn_st @fn;
   -- Green tests:  should exist 
   EXEC test.hlpr_036_sp_assert_table_exists
    @tst_num    = 'T001: fq tbl shld exst'
   ,@table_spec = 'test].[RtnDetails'
   ,@inp_ex_num = NULL
   ,@inp_ex_msg = NULL
   ,@exp_ex_num = NULL
   ,@exp_ex_msg = NULL
   EXEC test.hlpr_036_sp_assert_table_exists
    @tst_num    = 'T002: tbl only shld exst'
   ,@table_spec = 'AppLog'
   ,@inp_ex_num = NULL
   ,@inp_ex_msg = NULL
   ,@exp_ex_num = NULL
   ,@exp_ex_msg = NULL
   -- Green tests:  should not exist 
   EXEC test.hlpr_036_sp_assert_table_exists
    @tst_num    = 'T003: shld not exst no ex spec'
   ,@table_spec = 'CountryData'
   ,@inp_ex_num = NULL
   ,@inp_ex_msg = NULL
   ,@exp_ex_num = 62250
   ,@exp_ex_msg = '[CountryData] does not exist.'
   EXEC test.hlpr_036_sp_assert_table_exists
    @tst_num    = 'T004: shld not exst spec''d ex spec'
   ,@table_spec = 'test.CountryData'
   ,@inp_ex_num = 70000
   ,@inp_ex_msg = 'test ex msg'
   ,@exp_ex_num = 70000
   ,@exp_ex_msg = 'test ex msg'
   -- Edge cases:
   -- NULL table tests
   EXEC test.hlpr_036_sp_assert_table_exists
    @tst_num    = 'T005: null table spec shld not exst'
   ,@table_spec = null
   ,@inp_ex_num = null
   ,@inp_ex_msg = null
   ,@exp_ex_num = 62250
   ,@exp_ex_msg = '[] does not exist.'
   -- Empty table tests
   EXEC test.hlpr_036_sp_assert_table_exists
    @tst_num    = 'T006: shld not exst with ex spec'
   ,@table_spec = ''
   ,@inp_ex_num = null
   ,@inp_ex_msg = null
   ,@exp_ex_num = 62250
   ,@exp_ex_msg = '[] does not exist.'
   EXEC test.hlpr_036_sp_assert_table_exists
    @tst_num    = 'T006: shld not exst with ex spec'
   ,@table_spec = '.'
   ,@inp_ex_num = null
   ,@inp_ex_msg = null
   ,@exp_ex_num = 62250
   ,@exp_ex_msg = '[.] does not exist.'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_036_sp_assert_table_exists'
*/
GO

