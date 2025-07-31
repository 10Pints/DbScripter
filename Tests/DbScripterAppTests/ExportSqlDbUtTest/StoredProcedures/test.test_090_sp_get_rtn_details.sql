SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      14-Apr-2024
-- Description:      test rtn for the sp_get_rtn_details rtn
-- Tested rtn desc:
-- Tested rtn params:
--========================================================================================
--[@tSQLt:NoTransaction]('test.testCleanUp')
CREATE PROCEDURE [test].[test_090_sp_get_rtn_details]
AS
BEGIN
   DECLARE
    @fn               NVARCHAR(35)   = N'test_090_sp_get_rtn_dets'
   EXEC sp_log 1, @fn, '01: starting'
---- RUN tests
   EXEC test.hlpr_090_sp_get_rtn_details
    @tst_num               = 'T001'
   ,@inp_qrn               = '[dbo].[sp_exprt_to_xl_val]'
   ,@inp_trn               = 102
   ,@inp_cora              = NULL
   ,@inp_ad_stp            = NULL
   ,@inp_tst_mode          = NULL
   ,@inp_stop_stage        = NULL
   ,@inp_throw_if_err      = NULL
   ,@display_tables        = 1
   -- rtn details
   EXEC test.hlpr_090_sp_get_rtn_details
    @tst_num               = 'T002'
   ,@inp_qrn               = '[dbo].[sp_exprt_to_xl_val]'
   ,@inp_trn               = 102
   ,@inp_cora              = NULL
   ,@inp_ad_stp            = NULL
   ,@inp_tst_mode          = NULL
   ,@inp_stop_stage        = NULL
   ,@inp_throw_if_err      = NULL
   ,@exp_qrn               = 'dbo.sp_exprt_to_xl_val'
   ,@exp_trn               = 102
   ,@exp_schema_nm         = 'dbo'
   ,@exp_rtn_nm            = 'sp_exprt_to_xl_val'
   ,@exp_rtn_ty            = 'P'
   ,@exp_rtn_ty_code       = 'P'
   ,@exp_cora              = 'C'
   ,@exp_ad_stp            = 1
   ,@exp_tst_mode          = 1
   ,@exp_stop_stage        = 12
   ,@exp_is_clr            = 0
   ,@display_tables        = 0
   ;
   -- param details
   EXEC test.hlpr_090_sp_get_rtn_details
    @tst_num               = 'T003'
   ,@inp_qrn               = '[dbo].[sp_exprt_to_xl_val]'
   ,@inp_trn               = 102
   ,@inp_cora              = 'A'
   ,@inp_ad_stp            = 1
   ,@inp_tst_mode          = 0
   ,@inp_stop_stage        = NULL
   ,@inp_throw_if_err      = NULL
   ,@exp_param_nm          = 'tbl_spec'
   ,@exp_param_ty_nm       = 'NVARCHAR(50)'
   ,@exp_cora              = 'A'
   ,@exp_ordinal           = 3
   ,@exp_parameter_mode    = 'IN'
   ,@exp_is_chr_ty         = 1
   ,@exp_is_result         = 0
   ,@exp_is_output         = 0
   ,@exp_is_out_col        = 0
   ,@exp_is_nullable       = 1
   ,@exp_has_rows          = NULL
   ,@exp_has_ex_cols       = NULL
   ,@display_tables        = 0
   EXEC sp_log 2, @fn, 'all tests PASSED';
END
/*-- 48
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_090_sp_get_rtn_details';
*/
GO

