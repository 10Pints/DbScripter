SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      05-Jan-2024
-- Description:      main test rtn for test.fnCrtTstRtnValPrms()
--
-- Tested rtn desc: returns the parameters and derived parameters in a table:
-- (
--   tst_rtn_num -> next test fn (Max test num used so far) +1
--   crt_or_alter-> default = 'C'
--   schema name and rtn name split out from @q_tstd_rtn
--   routine type name
--   routine type code
--   sc_fn_ret_ty
--   add_step
--   schema_nm
--   rtn_nm
--   rtn_ty_nm
--   crse_rtn_ty_code  coarse grained type one of {'F','P'}
--   detld_rtn_ty_code detailed type code: can be 1 of {'P', 'FN', 'IF','TF'}like TF for a table function
--   error_num         if error this will not be NULL
--   error_msg         if error this will not be NULL
-- )
--
-- Postconditions:
-- Throws exception and sets session ctx error message 
-- postcondition violations as per the rules below:
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RULES     Rule                               Ex num  ex msg
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- POST 00: if completes OK then error_msg and error_num ARE NULL, ELSE contains the detailed errr msg and error_num the associated exception code
-- POST 01: @q_tstd_rtn                         53681, 'if @q_tstd_rtn is rtn_nm only then it must be unique accross all schemas, else it must be of the form <schema>.<rtn>'
-- POST 02: @q_tstd_rtn   must exist            53682, 'tested routine must exist'
-- POST 03: @tst_rtn_num  > 0                   53683, 'test routine num parameter must be > 0'
-- POST 04: @tst_rtn_num  NULL                          Default: next test num
-- POST 05: @tst_rtn_num already used           53684, 'test num already used'
-- POST 06: @crt_or_alter not null              53685   '@crt_or_alter must be Either 'C','A' or NULL, in which case default: 'C''
-- POST 07: @sc_fn_ret_ty if is Null or empty           Default: fnGetFnRetType
-- POST 08: @add_step     if is null                    Default: '0'
--========================================================================================
--[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
CREATE PROCEDURE [test].[test_087_fnCrtTstRtnValPrms]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_086_AsFloat'
   EXEC sp_log 2, @fn,'01: starting'
---- SETUP <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   EXEC test.hlpr_087_fnCrtTstRtnValPrms
    @test_num              = 'T002: SP'
   ,@inp_q_tstd_rtn        = 'dbo.sp_main_import_init'
   ,@inp_tst_rtn_num       = '900'
   ,@inp_crt_or_alter      = 'A'
   ,@inp_sc_fn_ret_ty      = 'INT'
   ,@inp_add_step          = 1
   ,@inp_rtn_ty_nm         = 'SQL_TABLE_VALUED_FUNCTION'
   ,@inp_crse_rtn_ty_code  = 'F'
   ,@inp_detld_rtn_ty_code = 'TF'
   ,@exp_schema_nm         = 'dbo'
   ,@exp_rtn_nm            = 'sp_main_import_init'
   ,@exp_rtn_ty_nm         = 'SQL_TABLE_VALUED_FUNCTION'
   ,@exp_error_num         = '0'
   ,@exp_error_msg         = ''
   EXEC test.hlpr_087_fnCrtTstRtnValPrms
    @test_num              = 'T001: TF'
   ,@inp_q_tstd_rtn        = 'test.fnCrtTstRtnValPrms'
   ,@inp_tst_rtn_num       = '900'
   ,@inp_crt_or_alter      = 'C'
   ,@inp_sc_fn_ret_ty      = 'INT'
   ,@inp_add_step          = 1
   ,@inp_rtn_ty_nm         = 'SQL_TABLE_VALUED_FUNCTION'
   ,@inp_crse_rtn_ty_code  = 'F'
   ,@inp_detld_rtn_ty_code = 'TF'
   ,@exp_schema_nm         = 'test'
   ,@exp_rtn_nm            = 'fnCrtTstRtnValPrms'
   ,@exp_rtn_ty_nm         = 'SQL_TABLE_VALUED_FUNCTION'
   ,@exp_error_num         = '0'
   ,@exp_error_msg         = ''
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
      EXEC sp_log 2, @fn, '99: leaving, All subtests PASSED'
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_087_fnCrtTstRtnValPrms';
*/
GO

