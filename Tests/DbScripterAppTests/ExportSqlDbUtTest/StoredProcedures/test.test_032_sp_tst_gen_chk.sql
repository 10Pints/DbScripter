SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 15-FEB-2021
-- Description: Tests the sp_tst_hlp_chk function
-- =====================================================
CREATE PROCEDURE [test].[test_032_sp_tst_gen_chk]
AS
BEGIN
   SET NOCOUNT ON
   DECLARE @fn NVARCHAR(35)='test_032_sp_tst_gen_chk';
   EXEC test.sp_tst_mn_st @fn  -- tst fn
   BEGIN TRY
      WHILE 1 = 1
      BEGIN
         EXEC sp_log 1, '001: running test T01G';
         -- GREEN: null not null fails
         EXEC test.hlpr_032_sp_tst_gen_chk
             @test_num     = N'T001 null/null matches ok'
            ,@test_sub_num = '01: GRN: when match exp ok'
            ,@inp_exp      = NULL
            ,@inp_act      = NULL
            ,@fail_msg     = NULL
            ,@cmp_mode     = NULL -- =
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
            ,@exp_ex_st    = NULL
         EXEC sp_log 1, '001: ret frm test T01G';
         -- GREEN: null null matches
         EXEC test.hlpr_032_sp_tst_gen_chk
             @test_num     = N'T002 null/'''' matches ok'
            ,@test_sub_num = '01: GRN: when match exp ok'
            ,@inp_exp      = NULL
            ,@inp_act      = ''
            ,@fail_msg     = NULL
            ,@cmp_mode     = NULL -- =
            ,@exp_ex_num   = NULL
            ,@exp_ex_msg   = NULL
            ,@exp_ex_st    = NULL
         BREAK;  -- Do once loop
      END -- WHILE
      EXEC test.sp_tst_mn_cls
   END TRY
   BEGIN CATCH
      EXEC ut.test.sp_tst_mn_hndl_ex;
   END CATCH
END
/*
EXEC tSQLt.Run 'test.test_032_sp_tst_gen_chk'
EXEC tSQLt.RunAll
*/
GO

