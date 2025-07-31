SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================
-- Author:      Terry Watts
-- Create date: 16-FEB-2021
-- Description: Tests the sp_get_rtn_parameters rtn
-- Trtn Desc  : Creates a table of arguments and their attributes
--
-- Responsibilities;
-- R01: fully populate the ParamDetails table
-- R02: update the RtnDetails table max_prm_len field with the length of the longest parameter name including the @xxx_ prefix
--
--ALGORITHM:
-- Clear the test.Param TabIe
-- Add the tst_num parameter setting type = SYS
-- Get the rtn parameters
-- Add the rtn parameters as inp if a Scalar FN ignore the is_result parameter
-- Add an exp row cnt INT setting type = TST
--
-- If Table fn:
--    Add a search key to identify the row to be checked etting type = TST
--    Get the tn ouput table cols
--    Add an exp row cnt INT setting type = TST
--    Add a search key to identify the row to be checked setting type = TST
--    For each Col: add the param as exp_x setting type = EXP
--
-- If Scalar fn:
--    Add the is result parameter as exp_result ty: EXP
--
-- PRECONDITIONS:
--    test.RtnDetails pop'd
--
-- POST CONDITIONS:
-- POST 01: fully populates the ParamDetails table or exception <TBA> <TBA>
-- POST 02: updates the RtnDetails table max_prm_len field or exception <TBA> <TBA>
-- POST 03: if routine not found then exception 70003, 'Routine [[<@schema_nm>].[<@rtn_nm>]] not found'
-- =============================================================================================================================
CREATE PROCEDURE [test].[test_034_sp_pop_param_details]
AS
BEGIN
   SET NOCOUNT ON
   DECLARE 
       @fn  NVARCHAR(35) = 'T034_sp_pop_param_details'
      ,@exp INT
      ,@act INT
   EXEC sp_set_log_level 1;
   EXEC ut.test.sp_tst_mn_st @fn;
   EXEC test.hlpr_034_sp_pop_param_details
    @tst_num              = 'T001: first row'
   ,@inp_qrn               = 'dbo.sp_exprt_to_xl'
   ,@tst_ordinal           = 1
   ,@exp_param_nm          = 'tst_num'
   ,@exp_type_nm           = 'nvarchar(50)'
   ,@exp_parameter_mode    = 'IN'
   ,@exp_is_chr_ty         = 1
   ,@exp_is_result         = 0
   ,@exp_is_output         = 0
   ,@exp_tst_ty            = 'TST'
   ,@display_table         = 0
   ;
   EXEC test.hlpr_034_sp_pop_param_details
    @tst_num              = 'T002: last row'
   ,@inp_qrn               = 'dbo.sp_exprt_to_xl'
   ,@tst_ordinal           = 10
   ,@exp_param_nm          = 'max_rows'
   ,@exp_type_nm           = 'INT'
   ,@exp_parameter_mode    = 'IN'
   ,@exp_is_chr_ty         = 0
   ,@exp_is_result         = 0
   ,@exp_is_output         = 0
   ;
   EXEC test.hlpr_034_sp_pop_param_details
    @tst_num              = 'T003: non existant param'
   ,@inp_qrn               = 'dbo.sp_exprt_to_xl'
   ,@tst_ordinal           = 16
   ,@exp_param_found       = 0
   ;
-- POST 01: Validated params or exception  '@qrn not specified', @ex_num = 53681
-- POST 03: if routine not found then exception 70003, 'Routine [<@schema_nm.@rtn_nm>] not found'
   EXEC test.hlpr_034_sp_pop_param_details
    @tst_num              = 'T004: null @qrn     '
   ,@inp_qrn               = NULL
   ,@exp_ex_num            = 70003
   ,@exp_ex_msg            = 'routine <.> was not found'
   ;
   EXEC test.hlpr_034_sp_pop_param_details
    @tst_num              = 'T005: empty @qrn     '
   ,@inp_qrn                   = ''
   ,@exp_ex_num            = 70003
   ,@exp_ex_msg            = 'routine <.> was not found'
   ;
   -- POST 05: if qrn not found and @throw_if_err is false: pop rtnDetails with qrn, schema and rtn name
   EXEC test.hlpr_034_sp_pop_param_details
    @tst_num              = 'T006: no schema'
   ,@inp_qrn               = '.b'
   ,@exp_ex_num            = 70003
   ,@exp_ex_msg            = 'routine <>.<b> was not found'
   ;
   -- POST 02: if routine not found then exception 70003, 'Routine not found'
   EXEC test.hlpr_034_sp_pop_param_details
    @tst_num              = 'T007:  non exist rtn'
   ,@inp_qrn               = 'dbo.nonexistant_rtn'
   ,@exp_ex_num            = 70003
   ,@exp_ex_msg            = 'routine <dbo>.<nonexistant_rtn> was not found'
   ;
   EXEC ut.test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_034_sp_pop_param_details';
EXEC tSQLt.RunAll;
*/
GO

