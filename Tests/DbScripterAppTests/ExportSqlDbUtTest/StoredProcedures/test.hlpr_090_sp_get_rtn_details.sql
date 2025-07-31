SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      05-Apr-2024
-- Description: Tests test.sp_get_rtn_details
--
-- Tested rtn description:
--  Gets the routine details for the routine @q_rtn_nm
--  Populates
--       Test.RtnDetails   with the rtn level details
--       Test.ParamDetails with the parameter level details
--
-- Responsibilities:
-- Sole populator of the 2 rtn metadata tables: {Test.RtnDetails, Test.RtnParamDetails}
-- Parameters:
--
-- Preconditions: none
--
-- Postconditions:
------------------------------------------------------------------------------------------------------
-- RULES     Rule                       Ex num  ex msg
------------------------------------------------------------------------------------------------------
-- POST 01: find the routine         OR 70100,  Could not find the routine <@q_tstd_rtn>
-- POST 02: Test.RtnDetails      pop OR 70101,  Could not find the routine   details for <@q_tstd_rtn>
-- POST 03: Test.RtnParamDetails pop OR 70102,  Could not find the parameter details for <@q_tstd_rtn>
-- POST 04: qrn returned fully qualified with schema--
-- Parameters:
--    @qrn     the schema qualified routine name
--    @ordinal the ordinal position to start the ordinal numbering of the returned rows
--
-- Algorithm:
-- add in the following 
--   ,@exp_add_step       BIT            = NULL
--   ,@chk_step_id        NVARCHAR(50)   = NULL -- line to check
--   ,@exp_line           NVARCHAR(25)   = NULL -- expected line
--   ,@exp_ex_num         INT            = NULL
--   ,@exp_ex_msg         NVARCHAR(100)  = NULL
--========================================================================================
CREATE PROCEDURE [test].[hlpr_090_sp_get_rtn_details]
    @tst_num               NVARCHAR(50)
   ,@inp_qrn               NVARCHAR(120)
   ,@inp_trn               INT
   ,@inp_cora              NCHAR(1)
   ,@inp_ad_stp            BIT
   ,@inp_tst_mode          BIT
   ,@inp_stop_stage        INT
   ,@inp_throw_if_err      BIT
   ,@exp_qrn               NVARCHAR(120)  = NULL
   ,@exp_trn               INT            = NULL
   ,@exp_schema_nm         NVARCHAR(50)   = NULL
   ,@exp_rtn_nm            NVARCHAR(50)   = NULL
   ,@exp_rtn_ty            NVARCHAR(20)   = NULL
   ,@exp_rtn_ty_code       NVARCHAR(2)    = NULL
   ,@exp_cora              NCHAR(1)       = NULL
   ,@exp_ad_stp            BIT            = NULL
   ,@exp_tst_mode          BIT            = NULL
   ,@exp_stop_stage        INT            = NULL
   ,@exp_is_clr            BIT            = NULL
   ,@exp_param_nm          NVARCHAR(50)   = NULL
   ,@exp_param_ty_nm       NVARCHAR(50)   = NULL
   ,@exp_ordinal           INT            = NULL
   ,@exp_parameter_mode    NVARCHAR(10)   = NULL
   ,@exp_is_chr_ty         BIT            = NULL
   ,@exp_is_result         BIT            = NULL
   ,@exp_is_output         BIT            = NULL
   ,@exp_is_out_col        BIT            = NULL
   ,@exp_is_nullable       BIT            = NULL
   ,@exp_has_rows          BIT            = NULL
   ,@exp_has_ex_cols       BIT            = NULL
   ,@display_tables        BIT            = 0
AS
BEGIN
   DECLARE
    @fn                    NVARCHAR(35)   = N'H_089_sp_get_rtn_dets'
   ,@line                  NVARCHAR(120)  =REPLICATE('-', 120)
   ,@act_qrn               NVARCHAR(120)  = NULL
   ,@act_trn               INT            = NULL
   ,@act_schema_nm         NVARCHAR(50)   = NULL
   ,@act_rtn_nm            NVARCHAR(50)   = NULL
   ,@act_rtn_ty            NVARCHAR(20)   = NULL
   ,@act_rtn_ty_code       NVARCHAR(2)    = NULL
   ,@act_cora              NCHAR(1)       = NULL
   ,@act_ad_stp            BIT            = NULL
   ,@act_tst_mode          BIT            = NULL
   ,@act_stop_stage        INT            = NULL
   ,@act_is_clr            BIT            = NULL
   ,@act_param_nm          NVARCHAR(50)   = NULL
   ,@act_param_ty_nm       NVARCHAR(50)   = NULL
   ,@act_ordinal           INT            = NULL
   ,@act_parameter_mode    NVARCHAR(10)   = NULL
   ,@act_is_chr_ty         BIT            = NULL
   ,@act_is_result         BIT            = NULL
   ,@act_is_output         BIT            = NULL
   ,@act_is_out_col        BIT            = NULL
   ,@act_is_nullable       BIT            = NULL
   ,@act_has_rows          BIT            = NULL
   ,@act_has_ex_cols       BIT            = NULL
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
   EXEC sp_log 1, @fn, '005: params, 
 tst_num           :[',@tst_num           ,']
,inp_qrn           :[',@inp_qrn           ,']
,inp_trn           :[',@inp_trn           ,']
,inp_cora          :[',@inp_cora          ,']
,inp_ad_stp        :[',@inp_ad_stp        ,']
,inp_tst_mode      :[',@inp_tst_mode      ,']
,inp_stop_stage    :[',@inp_stop_stage    ,']
,inp_throw_if_err  :[',@inp_throw_if_err  ,']
,exp_qrn           :[',@exp_qrn           ,']
,exp_trn           :[',@exp_trn           ,']
,exp_schema_nm     :[',@exp_schema_nm     ,']
,exp_rtn_nm        :[',@exp_rtn_nm        ,']
,exp_rtn_ty        :[',@exp_rtn_ty        ,']
,exp_rtn_ty_code   :[',@exp_rtn_ty_code   ,']
,exp_cora          :[',@exp_cora          ,']
,exp_ad_stp        :[',@exp_ad_stp        ,']
,exp_tst_mode      :[',@exp_tst_mode      ,']
,exp_stop_stage    :[',@exp_stop_stage    ,']
,exp_is_clr        :[',@exp_is_clr        ,']
,exp_param_nm      :[',@exp_param_nm      ,']
,exp_param_ty_nm   :[',@exp_param_ty_nm   ,']
,exp_ordinal       :[',@exp_ordinal       ,']
,exp_parameter_mode:[',@exp_parameter_mode,']
,exp_is_chr_ty     :[',@exp_is_chr_ty     ,']
,exp_is_result     :[',@exp_is_result     ,']
,exp_is_output     :[',@exp_is_output     ,']
,exp_is_out_col    :[',@exp_is_out_col    ,']
,exp_is_nullable   :[',@exp_is_nullable   ,']
,exp_has_rows      :[',@exp_has_rows      ,']
,exp_has_ex_cols   :[',@exp_has_ex_cols   ,']'
;
   ----------------------------------------------------------------
   -- Setup
   ----------------------------------------------------------------
   DELETE FROM Test.RtnDetails;
   DELETE FROM Test.ParamDetails;
   BEGIN TRY
      ----------------------------------------------------------------
      -- Execute
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: calling sp_get_rtn_details...';
      ;
      EXEC test.sp_get_rtn_details 
          @inp_qrn
         ,@inp_trn
         ,@inp_cora
         ,@inp_ad_stp
         ,@inp_tst_mode
         ,@inp_stop_stage
         ,@inp_throw_if_err;
      EXEC sp_log 1, @fn, '015: ret from sp_get_rtn_details';
      ----------------------------------------------------------------
      -- Test
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: testing';
   ----------------------------------------------------------------
      -- Test RtnDetails
   ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '025: testing RtnDetails';
      IF NOT EXISTS (SELECT 1 FROM Test.RtnDetails  )
         THROW 63120, '030: RtnDetails table is empty',1;
      EXEC sp_log 1, @fn, '035: getting act vals from RtnDetails';
      SELECT
          @act_qrn         = qrn
         ,@act_trn         = trn
         ,@act_cora        = cora
         ,@act_ad_stp      = ad_stp
         ,@act_tst_mode    = tst_mode
         ,@act_stop_stage  = stop_stage
         ,@act_rtn_nm      = rtn_nm
         ,@act_schema_nm   = schema_nm
         ,@act_is_clr      = is_clr
         ,@act_rtn_ty      = rtn_ty
         ,@act_rtn_ty_code = rtn_ty_code
      FROM Test.RtnDetails
      EXEC sp_log 1, @fn, '040: act vals:
   @act_qrn         :[', @act_qrn         ,']
   @act_trn         :[', @act_trn         ,']
   @act_cora        :[', @act_cora        ,']
   @act_ad_stp      :[', @act_ad_stp      ,']
   @act_tst_mode    :[', @act_tst_mode    ,']
   @act_stop_stage  :[', @act_stop_stage  ,']
   @act_rtn_nm      :[', @act_rtn_nm      ,']
   @act_schema_nm   :[', @act_schema_nm   ,']
   @act_is_clr      :[', @act_is_clr      ,']
   @act_rtn_ty      :[', @act_rtn_ty      ,']
   @act_rtn_ty_code :[', @act_rtn_ty_code ,']'
   ;
      IF @exp_qrn         IS NOT NULL EXEC tSQLt.AssertEquals @exp_qrn       , @act_qrn       , '045: qrn';
      IF @exp_trn         IS NOT NULL EXEC tSQLt.AssertEquals @exp_trn       , @act_trn       , '050: trn';
      IF @exp_rtn_nm      IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm    , @act_rtn_nm    , '055: rtn_nm';
      IF @exp_schema_nm   IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm , @act_schema_nm , '060: schema_nm';
      IF @exp_cora        IS NOT NULL EXEC tSQLt.AssertEquals @exp_cora      , @act_cora      , '065: cora';
      IF @exp_ad_stp      IS NOT NULL EXEC tSQLt.AssertEquals @exp_ad_stp    , @act_ad_stp    , '070: ad_stp';
      IF @exp_tst_mode    IS NOT NULL EXEC tSQLt.AssertEquals @exp_tst_mode  , @act_tst_mode  , '075: tst_mode';
      IF @exp_stop_stage  IS NOT NULL EXEC tSQLt.AssertEquals @exp_stop_stage, @act_stop_stage, '080: stop_stage';
      IF @exp_is_clr      IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_clr    , @act_is_clr    , '085: is_clr';
      IF @exp_rtn_ty      IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_ty    , @act_rtn_ty    , '090: rtn_ty';
      IF @exp_rtn_ty_code IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_ty_code  , @act_rtn_ty_code  , '095: rtn_ty_code';
      EXEC sp_log 1, @fn, '095: RtnDetails subtests passed';
      IF @exp_param_nm IS NOT NULL
      BEGIN
      ----------------------------------------------------------------
         -- Test ParamDetails
      ----------------------------------------------------------------
         IF NOT EXISTS (SELECT 1 FROM Test.ParamDetails) THROW 63121, 'ParamDetails table is empty',1;
         EXEC sp_log 1, @fn, '100: getting act vals from ParamDetails';
         SELECT
          @act_param_nm          = param_nm
         ,@act_param_ty_nm       = type_nm
         ,@act_ordinal           = ordinal
         ,@act_parameter_mode    = parameter_mode
         ,@act_is_chr_ty         = is_chr_ty
         ,@act_is_result         = is_result
         ,@act_is_output         = is_output
         ,@act_is_nullable       = is_nullable
         FROM test.ParamDetails
         WHERE param_nm = @exp_param_nm;
         EXEC sp_log 1, @fn, '105: testing ParamDetails';
         IF @exp_param_nm         IS NOT NULL EXEC tSQLt.AssertEquals @exp_param_nm        , @act_param_nm        , '105: param_nm';
         IF @exp_schema_nm        IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm       , @act_schema_nm       , '110: schema_nm';
         IF @exp_param_ty_nm      IS NOT NULL EXEC tSQLt.AssertEquals @exp_param_nm        , @act_param_nm        , '115: param_nm';
         IF @exp_ordinal          IS NOT NULL EXEC tSQLt.AssertEquals @exp_ordinal         , @act_ordinal         , '120: ordinal';
         IF @exp_parameter_mode   IS NOT NULL EXEC tSQLt.AssertEquals @exp_parameter_mode  , @act_parameter_mode  , '125: parameter_mode';
         IF @exp_is_chr_ty        IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_chr_ty       , @act_is_chr_ty       , '130: is_chr_ty';
         IF @exp_is_result        IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_result       , @act_is_result       , '135: is_result';
         IF @exp_is_output        IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_output       , @act_is_output       , '140: is_output';
         IF @exp_is_nullable      IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_nullable     , @act_is_nullable     , '145: is_nullable';
         EXEC sp_log 1, @fn, '095: ParamDetails subtests passed';
      END
      ----------------------------------------------------------------
         -- Tests passed
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '900: all sub tests passed';
      IF @display_tables = 1
      BEGIN
         EXEC sp_log 1, @fn, '030: display rtn details and param details tables';
         SELECT * FROM test.RtnDetails;
         SELECT * FROM test.ParamDetails;
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, 'caught exception:';
      SELECT * FROM test.RtnDetails;
      SELECT * FROM test.ParamDetails;
      THROW;
   END CATCH
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.Run 'test.test_090_sp_get_rtn_details';
EXEC tSQLt.RunAll;
*/
GO

