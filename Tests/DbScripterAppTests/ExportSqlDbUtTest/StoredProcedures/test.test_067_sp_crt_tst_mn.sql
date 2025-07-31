SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      24-Nov-2023
-- Description:      main test rtn for the test.sp_crt_tst_fn_mn rtn being tested
-- Tested rtn desc:
--  sp version of test.fnCrtTstRtnMn  
--  
-- Test Rtns:  
--      
-- Changes:  
-- 231121: @q_tstd_rtn must exist or exception 56472, '<@q_tstd_rtn> does not exist'  
-- 231121: added a try catch handler to log errors  
--
-- Tested rtn params: 
--    @q_tstd_rtn_nm  NVARCHAR(100),
--    @tst_rtn_num    INT,
--    @crt_or_alter   NCHAR(2)
--========================================================================================
CREATE PROCEDURE [test].[test_067_sp_crt_tst_mn]
AS
BEGIN
   DECLARE
    @fn              NVARCHAR(35)   = N'T067_sp_crt_tst_mn'
   ,@exp_table       DescTableType
   EXEC ut.test.sp_tst_mn_st @fn;
---- SETUP
   -- <TBD>
   INSERT INTO @exp_table (id, line) VALUES (26, 'CREATE PROCEDURE test.test_150_sp_get_line_num');
   EXEC test.hlpr_067_sp_crt_tst_mn
       @test_num        = 'TG001'
      ,@qrn             = 'dbo.sp_chk_rtn_exists'
      ,@trn             = 100
      ,@cora            = 'C'
      ,@ad_stp          = 1
      ,@stop_stage      = 99
      ,@tst_mode        = 1
      ,@throw_if_err    = 1
      ,@row_id          = NULL
      ,@exp_table       = @exp_table
      ,@exp_ex_num      = NULL
      ,@exp_ex_msg      = NULL
      ,@display_script  = 1
   EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_067_sp_crt_tst_mn';
EXEC tSQLt.RunAll;
*/
GO

