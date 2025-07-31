SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      05-Apr-2024
-- Description:      main test rtn for dbo.fnCrtHlprCodeTstSpecificPrms()
-- Tested rtn desc:
-- Tested rtn description:
-- Description: adds the routine output parameters if a table function
-- and
-- test specific parameters:
-- expected values  @exp_<>      optional
-- check step id:  @chk_step_id  optional
-- expected line: @exp_line      optional
-- expected exception info       optional (@exp_ex_num and @exp_ex_msg)
--
-- Tested rtn params:
--   @q_rtn             NVARCHAR(120)
--  ,@ordinal_position  INT
--========================================================================================
--[@ tSQLt:NoTransaction]('test.testCleanUp')
CREATE PROCEDURE [test].[test_085_fnCrtHlprCodeTstSpecificPrms]
AS
BEGIN
   DECLARE
      @fn NVARCHAR(35)   = N'test_085_fnCrtHlprCodeTstSpecificPrms'
   EXEC ut.test.sp_tst_mn_st @fn;
   EXEC test.hlpr_085_fnCrtHlprCodeTstSpecificPrms 
       @tst_num     ='TG001'
      ,@inp_qrn      ='dbo.fnGetRtnDef'
      ,@inp_ordinal  =4
   EXEC test.hlpr_085_fnCrtHlprCodeTstSpecificPrms 
       @tst_num               = 'TG001 basic chk'
      ,@inp_qrn               = 'dbo.fnGetRtnDef'
      ,@inp_ordinal           = 4
      ,@tst_ordinal           = 4
      ,@exp_rtn_nm            = 'fnGetRtnDef'
      ,@exp_schema_nm         = 'dbo'
      ,@exp_param_nm          = '@exp_add_step'
      ,@exp_param_ty_nm       = 'BIT'
      ,@exp_is_output         = 0
      ,@exp_has_default_value = 0
      ,@exp_is_nullable       = 1
      ,@exp_has_ex_cols       = 0
   EXEC test.hlpr_085_fnCrtHlprCodeTstSpecificPrms 
       @tst_num               = 'TG002 chk details'
      ,@inp_qrn               = 'dbo.fnGetRtnDef'
      ,@inp_ordinal           = 4
      ,@tst_ordinal           = 10
      ,@exp_rtn_nm            = 'fnGetRtnDef'
      ,@exp_schema_nm         = 'dbo'
      ,@exp_param_nm          = '@exp_line'
      ,@exp_param_ty_nm       = 'NVARCHAR(255)'
      ,@exp_is_output         = 0
      ,@exp_has_default_value = 0
      ,@exp_is_nullable       = 1
      ,@exp_has_ex_cols       = 0
   EXEC test.hlpr_085_fnCrtHlprCodeTstSpecificPrms 
       @tst_num               = 'TG003 chk hndl bad data: unknown rtn'
      ,@inp_qrn               = 'unknown'
      ,@inp_ordinal           = 4
      ,@exp_has_rows          = 0
--      ,@exp_ex_num            = 70003
--      ,@exp_ex_msg            = 'routine dbo.unknown was not found'
   EXEC test.hlpr_085_fnCrtHlprCodeTstSpecificPrms 
       @tst_num               = 'TG004 procedure has ex rows'
      ,@inp_qrn               = 'dbo.sp_grep_rtns_with_def'
      ,@inp_ordinal           = 4
      ,@tst_ordinal           = 8
      ,@exp_rtn_nm            = 'sp_grep_rtns_with_def'
      ,@exp_schema_nm         = 'dbo'
      ,@exp_param_nm          = '@exp_ex_msg'
      ,@exp_param_ty_nm       = 'NVARCHAR(500)'
      ,@exp_is_output         = 0
      ,@exp_has_default_value = 0
      ,@exp_is_nullable       = 1
      EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_085_fnCrtHlprCodeTstSpecificPrms';
SELECT * from test.Results;
EXEC tSQLt.RunAll;
*/
GO

