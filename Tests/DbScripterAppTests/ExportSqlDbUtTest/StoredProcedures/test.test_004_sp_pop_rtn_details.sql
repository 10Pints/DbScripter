SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================
-- Author:      Terry Watts
-- Create date: 22-APR-2024
-- Description: Tests the sp_pop_rtn_ rtn
-- Trtn Desc  : Gets the routine details for the routine @q_rtn_nm
--    Populates
--       Test.RtnDetails   with the rtn level details onlt
--       Does not populate the param details table
--
-- Responsibilities:
-- Sole populator of the 2 rtn metadata tables: {Test.RtnDetails, Test.RtnParamDetails}
-- Parameters:
-- @q_tstd_rtn the qualified tested routine name <schema>.<routine> optionally wrapped in []
--
-- Preconditions: none
--
-- Postconditions:
-- Populates
--       Test.RtnDetails   with the rtn level details
------------------------------------------------------------------------------------------------------
-- RULES     Rule                       Ex num  ex msg
------------------------------------------------------------------------------------------------------
-- POST 01: if routine not found and @throw_if_err is true then throw exception 70003, 'Routine [[<@schema_nm>].[<@rtn_nm>]] not found'
-- POST 02: Test.RtnDetails      pop OR 70101,  Could not find the routine   details for <@q_tstd_rtn>
-- POST 03: Test.RtnParamDetails pop OR 70102,  Could not find the parameter details for <@q_tstd_rtn>
-- POST 04: qrn returned fully qualified with schema
-- POST 05: if routine not found and @throw_if_err is false then pop rtnDetails with the rtn name details only
--
-- Algorithm:
-- 1. Removes square brackets
-- 2. Validate parameters
-- 2. Pop Test.RtnDetails   with the rtn level details
--
-- Tests: test.hlpr_034_get_rtn_parameters
-- =============================================================================================================================
----[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
CREATE PROCEDURE [test].[test_004_sp_pop_rtn_details]
AS
BEGIN
   SET NOCOUNT ON
   DECLARE 
       @fn  NVARCHAR(35) = 'T004_sp_pop_rtn_details'
      ,@exp INT
      ,@act INT
   EXEC sp_set_log_level 1;
   EXEC test.sp_tst_mn_st @fn;
   EXEC test.hlpr_004_sp_pop_rtn_details
    @tst_num            = 'T001'
   ,@inp_qrn            = 'sp_exprt_to_xl'
   ,@inp_trn            = 200
   ,@inp_cora           = NULL
   ,@inp_ad_stp         = 1
   ,@inp_tst_mode       = 0
   ,@inp_stop_stage     = NULL
   ,@inp_throw_if_err   = 1
   ,@exp_schema_nm      = 'dbo'
   ,@exp_rtn_nm         = 'sp_exprt_to_xl'
   ,@exp_rtn_ty         = 'P'
   ,@exp_rtn_ty_code    = 'P'
   ,@exp_is_clr         = 0
   ,@exp_trn            = 200
   ,@exp_qrn            = 'dbo.sp_exprt_to_xl'
   ,@exp_cora           = 'C'
   ,@exp_ad_stp         = '1'
   ,@exp_tst_mode       = '0'
   ,@exp_stop_stage     = '12'
   ,@exp_tst_rtn_nm     = 'test_200_sp_exprt_to_xl'
   ,@exp_hlpr_rtn_nm    = 'hlpr_200_sp_exprt_to_xl'
-- ,@exp_max_prm_len    = 18
   ,@exp_ex_num         = NULL
   ,@exp_ex_msg         = NULL
   ,@display_table      = 1
   ;
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_pop_rtn_details';
EXEC tSQLt.RunAll;
*/
GO

