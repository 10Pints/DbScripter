SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      07-MAR-2024
-- Description: Tests the fnCrtTstRtnValPrm rtn
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
CREATE PROCEDURE [test].[hlpr_087_fnCrtTstRtnValPrms]
    @test_num              NVARCHAR(100)
   --------------------------------------------------------------
    -- Tested rtn input parameters
   --------------------------------------------------------------
   ,@inp_q_tstd_rtn        NVARCHAR(100)  -- in may be <tn_nm> only if unique - out will be schema.rtn_nm
   ,@inp_tst_rtn_num       INT            -- default = next test number
   ,@inp_crt_or_alter      NCHAR(1)       -- default = 'C'
   ,@inp_sc_fn_ret_ty      NVARCHAR(50)   -- only applies to scalar functionms
   ,@inp_add_step          BIT            -- 
   ,@inp_rtn_ty_nm         NVARCHAR(25)   -- 
   ,@inp_crse_rtn_ty_code  NVARCHAR(1)    -- coarse grained type one of {'F','P'}
   ,@inp_detld_rtn_ty_code NCHAR(2)       -- detailed type code: can be 1 of {'P', 'FN', 'IF','TF'}like TF for a table function
   --------------------------------------------------------------
   -- Expected results
   --------------------------------------------------------------
   ,@exp_schema_nm         NVARCHAR(50)  = NULL
   ,@exp_rtn_nm            NVARCHAR(100) = NULL
   ,@exp_rtn_ty_nm         NVARCHAR(25)  = NULL
   ,@exp_error_num         INT           = NULL
   ,@exp_error_msg         NVARCHAR(500) = NULL
AS
BEGIN
   DECLARE
    @fn                    NVARCHAR(35)   = N'hlpr_fnCrtTstRtnValPrms'
   ,@act_q_tstd_rtn        NVARCHAR(100)  -- in may be <tn_nm> only if unique - out will be schema.rtn_nm
   ,@act_tst_rtn_num       INT            -- default = next test number
   ,@act_crt_or_alter      NCHAR(1)       -- default = 'C'
   ,@act_sc_fn_ret_ty      NVARCHAR(50)   -- 
   ,@act_add_step          BIT            -- 
   ,@act_schema_nm         NVARCHAR(50)   -- 
   ,@act_rtn_nm            NVARCHAR(100)  -- 
   ,@act_rtn_ty_nm         NVARCHAR(25)   -- 
   ,@act_crse_rtn_ty_code  NVARCHAR(1)    -- coarse grained type one of {'F','P'}
   ,@act_detld_rtn_ty_code NCHAR(2)       -- detailed type code: can be 1 of {'P', 'FN', 'IF','TF'}like TF for a table function
   ,@act_error_num         INT            -- if error this will not be NULL
   ,@act_error_msg         NVARCHAR(500)  -- if error this will not be NULL
   ,@line                  NVARCHAR(60) = '----------------------------------'
   PRINT ' ';
   PRINT CONCAT(@line, ' test ', @test_num, ' ', @line);
   EXEC sp_log 1, @fn, '00: starting, calling fnCrtTstRtnValPrms 
';
   --------------------------------------------------------------
   -- Setup
   --------------------------------------------------------------
   --------------------------------------------------------------
   -- Call tested rtn
   --------------------------------------------------------------
      SELECT
          @act_q_tstd_rtn        = q_tstd_rtn
         ,@act_tst_rtn_num       = tst_rtn_num
         ,@act_crt_or_alter      = crt_or_alter
         ,@act_sc_fn_ret_ty      = sc_fn_ret_ty
         ,@act_add_step          = add_step
         ,@act_schema_nm         = schema_nm
         ,@act_rtn_nm            = rtn_nm
         ,@act_rtn_ty_nm         = rtn_ty_nm
         ,@act_crse_rtn_ty_code  = crse_rtn_ty_code
         ,@act_detld_rtn_ty_code = detld_rtn_ty_code
         ,@act_error_num         = error_num
         ,@act_error_msg         = error_msg
      FROM test.fnCrtTstRtnValPrms
      (
          @inp_q_tstd_rtn
         ,@inp_tst_rtn_num
         ,@inp_crt_or_alter
         ,@inp_sc_fn_ret_ty
         ,@inp_add_step
         ,@inp_rtn_ty_nm
         ,@inp_crse_rtn_ty_code
         ,@inp_detld_rtn_ty_code
      );
   EXEC sp_log 1, @fn, '10: ret frm fnCrtTstRtnValPrms, params and results:
inp_q_tstd_rtn        [',@inp_q_tstd_rtn        ,']
inp_tst_rtn_num       [',@inp_tst_rtn_num       ,']
act_tst_rtn_num       [',@act_tst_rtn_num       ,']
inp_crt_or_alter      [',@inp_crt_or_alter      ,']
act_crt_or_alter      [',@act_crt_or_alter      ,']
inp_sc_fn_ret_ty      [',@inp_sc_fn_ret_ty      ,']
act_sc_fn_ret_ty      [',@act_sc_fn_ret_ty      ,']
inp_add_step          [',@inp_add_step          ,']
inp_rtn_ty_nm         [',@inp_rtn_ty_nm         ,']
inp_crse_rtn_ty_code  [',@inp_crse_rtn_ty_code  ,']
act_crse_rtn_ty_code  [',@act_crse_rtn_ty_code  ,']
inp_detld_rtn_ty_code [',@inp_detld_rtn_ty_code ,']
act_detld_rtn_ty_code [',@act_detld_rtn_ty_code ,']
act_add_step          [',@act_add_step          ,']
exp_schema_nm         [',@exp_schema_nm         ,']
act_schema_nm         [',@act_schema_nm         ,']
exp_rtn_nm            [',@exp_rtn_nm            ,']
act_rtn_nm            [',@act_rtn_nm            ,']
exp_rtn_ty_nm         [',@exp_rtn_ty_nm         ,']
act_rtn_ty_nm         [',@act_rtn_ty_nm         ,']
exp_error_num         [',@exp_error_num         ,']
act_error_num         [',@act_error_num         ,']
exp_error_msg         [',@exp_error_msg         ,']
act_error_msg         [',@act_error_msg         ,']';
   --------------------------------------------------------------
   -- Test
   -- 1. always test the inputs that are just passed thro to the output table
   --------------------------------------------------------------
   EXEC tSQLt.AssertEquals @inp_q_tstd_rtn       , @act_q_tstd_rtn        ,'@add_step';
   EXEC tSQLt.AssertEquals @inp_tst_rtn_num      , @act_tst_rtn_num       ,'@tst_rtn_num';
   EXEC tSQLt.AssertEquals @inp_crt_or_alter     , @act_crt_or_alter      ,'@crt_or_alter';
   EXEC tSQLt.AssertEquals @inp_sc_fn_ret_ty     , @act_sc_fn_ret_ty      ,'@sc_fn_ret_ty';
   EXEC tSQLt.AssertEquals @inp_add_step         , @act_add_step          ,'@add_step';
   EXEC tSQLt.AssertEquals @inp_rtn_ty_nm        , @act_rtn_ty_nm         ,'@rtn_ty_nm';
   EXEC tSQLt.AssertEquals @inp_crse_rtn_ty_code , @act_crse_rtn_ty_code  ,'@crse_rtn_ty_code ';
   EXEC tSQLt.AssertEquals @inp_detld_rtn_ty_code, @act_detld_rtn_ty_code ,'@detld_rtn_ty_code';
   EXEC tSQLt.AssertEquals @inp_crse_rtn_ty_code , @act_crse_rtn_ty_code  ,'@crse_rtn_ty_code';
   EXEC tSQLt.AssertEquals @inp_detld_rtn_ty_code, @act_detld_rtn_ty_code ,'@detld_rtn_ty_code';
    --------------------------------------------------------------
   -- 2. conditionally test the outputs as needed for the specific test
   --------------------------------------------------------------
   IF @exp_schema_nm         IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm        , @act_schema_nm        ,'@schema_nm';
   IF @exp_rtn_nm            IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm           , @act_rtn_nm           ,'@rtn_nm';
   IF @exp_rtn_ty_nm         IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_ty_nm        , @act_rtn_ty_nm        ,'@rtn_ty_nm';
   IF @exp_error_num         IS NOT NULL EXEC tSQLt.AssertEquals @exp_error_num        , @act_error_num        ,'@error_num';
   IF @exp_error_msg         IS NOT NULL EXEC tSQLt.AssertEquals @exp_error_msg        , @act_error_msg        ,'@error_msg';
   ---------------------------------------------------------------------------
   -- TESTING COMPLETE
   ---------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '900: testing complete';
   EXEC sp_log 1, @fn, '999: leaving, OK';
END
/*
*/
GO

