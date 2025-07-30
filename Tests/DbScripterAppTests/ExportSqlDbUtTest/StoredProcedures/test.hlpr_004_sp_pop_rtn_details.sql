SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 16-FEB-2021
-- Description: Helper for sp_get_rtn_parameters tests
-- =====================================================
CREATE PROCEDURE    [test].[hlpr_004_sp_pop_rtn_details]   
    @tst_num            NVARCHAR(50)
   ,@inp_qrn            NVARCHAR(150)
   ,@inp_trn            INT
   ,@inp_cora           NCHAR(1)
   ,@inp_ad_stp         BIT
   ,@inp_tst_mode       BIT
   ,@inp_stop_stage     INT
   ,@inp_throw_if_err   BIT
   ,@exp_schema_nm      NVARCHAR(60)   = NULL
   ,@exp_rtn_nm         NVARCHAR(60)   = NULL
   ,@exp_rtn_ty         NVARCHAR(1)    = NULL
   ,@exp_rtn_ty_code    NVARCHAR(2)    = NULL
   ,@exp_is_clr         BIT            = NULL
   ,@exp_trn            INT            = NULL
   ,@exp_qrn            NVARCHAR(90)   = NULL
   ,@exp_cora           NCHAR(1)       = NULL
   ,@exp_ad_stp         BIT            = NULL
   ,@exp_tst_mode       BIT            = NULL
   ,@exp_stop_stage     INT            = NULL
   ,@exp_tst_rtn_nm     NVARCHAR(50)   = NULL
   ,@exp_hlpr_rtn_nm    NVARCHAR(50)   = NULL
--   ,@exp_max_prm_len    INT            = NULL
   ,@exp_ex_num         INT            = NULL
   ,@exp_ex_msg         NVARCHAR(100)  = NULL
   ,@display_table      BIT            = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn                    NVARCHAR(35) = 'H004_sp_pop_rtn_details'
   ,@line                  NVARCHAR(120) = REPLICATE('-', 120)
   ,@act_cnt               INT
   ,@act_schema_nm         NVARCHAR(60)
   ,@act_rtn_nm            NVARCHAR(60)
   ,@act_rtn_ty            NVARCHAR(1) 
   ,@act_rtn_ty_code       NVARCHAR(2) 
   ,@act_is_clr            BIT         
   ,@act_trn               INT         
   ,@act_qrn               NVARCHAR(90)
   ,@act_cora              NCHAR(1)    
   ,@act_ad_stp            BIT         
   ,@act_tst_mode          BIT         
   ,@act_stop_stage        INT         
   ,@act_tst_rtn_nm        NVARCHAR(50)
   ,@act_hlpr_rtn_nm       NVARCHAR(50)
--   ,@act_max_prm_len       INT         
   ,@act_ex_num            INT
   ,@act_ex_msg            NVARCHAR(100)
   ,@ex_thrown             BIT
   ,@schema_nm             NVARCHAR(25)
   ,@msg                   NVARCHAR(500)
   ,@rtn_nm                NVARCHAR(50)
   PRINT ''
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
   EXEC sp_log 1, @fn, '001: params,
tst_num           :[',@tst_num         ,']
inp_qrn           :[',@inp_qrn         ,'] 
inp_trn           :[',@inp_trn         ,']
inp_cora          :[',@inp_cora        ,']
inp_ad_stp        :[',@inp_ad_stp      ,']
inp_tst_mode      :[',@inp_tst_mode    ,']
inp_stop_stage    :[',@inp_stop_stage  ,']
inp_throw_if_err  :[',@inp_throw_if_err,']
exp_schema_nm     :[',@exp_schema_nm   ,']
exp_rtn_nm        :[',@exp_rtn_nm      ,']
exp_rtn_ty        :[',@exp_rtn_ty      ,']
exp_rtn_ty_code   :[',@exp_rtn_ty_code ,']
exp_is_clr        :[',@exp_is_clr      ,']
exp_trn           :[',@exp_trn         ,']
exp_qrn           :[',@exp_qrn         ,']
exp_cora          :[',@exp_cora        ,']
exp_ad_stp        :[',@exp_ad_stp      ,']
exp_tst_mode      :[',@exp_tst_mode    ,']
exp_stop_stage    :[',@exp_stop_stage  ,']
exp_tst_rtn_nm    :[',@exp_tst_rtn_nm  ,']
exp_hlpr_rtn_nm   :[',@exp_hlpr_rtn_nm ,']
exp_ex_num        :[',@exp_ex_num      ,']
exp_ex_msg        :[',@exp_ex_msg      ,']
display_table     :[',@display_table   ,']'
;
-- exp_max_prm_len   :[',@exp_max_prm_len ,']
   -- SETUP
   EXEC sp_log 1, @fn, '002: setup: calling fnSplitQualifiedName...';
   SELECT
       @schema_nm = schema_nm
      ,@rtn_nm    = rtn_nm
   FROM test.fnSplitQualifiedName(@inp_qrn);
   EXEC sp_log 1, @fn, '004: running tested rtn...';
   WHILE 1 = 1
   BEGIN
      BEGIN TRY
         -- Partially populate the RtnDetails table (sp_pop_param_details precondition)
         EXEC test.sp_pop_rtn_details
             @qrn          = @inp_qrn
            ,@trn          = @inp_trn
            ,@cora         = @inp_cora
            ,@ad_stp       = @inp_ad_stp
            ,@tst_mode     = @inp_tst_mode
            ,@stop_stage   = @inp_stop_stage
            ,@throw_if_err = @inp_throw_if_err
         ;
         EXEC sp_log 1, @fn, '003: ret frm sp_get_rtn_details';
         IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
         BEGIN
            EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
            THROW 51000, ' Expected an exception but none were thrown', 1;
         END
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '07: caught exception';
         EXEC sp_log_exception @fn;
         SET @act_ex_num = ERROR_NUMBER();
         SET @act_ex_msg = ERROR_MESSAGE();
         IF @exp_ex_num IS NULL OR @exp_ex_msg IS NULL
         BEGIN
            EXEC sp_log 4, @fn, '08: oops! Unexpected an exception here';
            THROW 51000, ' caught unexpected exception but none', 1;
         END
         ----------------------------------------------------
         -- ASSERTION: if here then expected exception
         ----------------------------------------------------
         IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num        ,'ex_num mismatch';
         IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg, @act_ex_msg        ,'ex_msg mismatch';
         BREAK; -- passed exception test
      END CATCH
      -- TEST:
      EXEC sp_log 2, @fn, '10: running tests...';
      SELECT
          @act_schema_nm   = schema_nm
         ,@act_rtn_nm      = rtn_nm
         ,@act_rtn_ty      = rtn_ty
         ,@act_rtn_ty_code = rtn_ty_code
         ,@act_is_clr      = is_clr
         ,@act_trn         = trn
         ,@act_qrn         = qrn
         ,@act_cora        = cora
         ,@act_ad_stp      = ad_stp
         ,@act_tst_mode    = tst_mode
         ,@act_stop_stage  = stop_stage
         ,@act_tst_rtn_nm  = tst_rtn_nm
         ,@act_hlpr_rtn_nm = hlpr_rtn_nm
--       ,@act_max_prm_len = max_prm_len
      FROM test.RtnDetails;
      IF @display_table = 1
         SELECT * FROM test.RtnDetails;
      SELECT @act_cnt = COUNT(*) FROM test.RtnDetails;
      EXEC tSQLt.AssertEquals 1, @act_cnt, 'test.RtnDetails should have 1 row';
      IF @exp_schema_nm   IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm  , @act_schema_nm  ,'schema_nm';
      IF @exp_rtn_nm      IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm     , @act_rtn_nm     ,'rtn_nm';
      IF @exp_rtn_ty      IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_ty     , @act_rtn_ty     ,'rtn_ty';
      IF @exp_rtn_ty_code IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_ty_code, @act_rtn_ty_code,'rtn_ty_code';
      IF @exp_is_clr      IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_clr     , @act_is_clr     ,'is_clr';
      IF @exp_trn         IS NOT NULL EXEC tSQLt.AssertEquals @exp_trn        , @act_trn        ,'trn';
      IF @exp_qrn         IS NOT NULL EXEC tSQLt.AssertEquals @exp_qrn        , @act_qrn        ,'qrn';
      IF @exp_cora        IS NOT NULL EXEC tSQLt.AssertEquals @exp_cora       , @act_cora       ,'cora';
      IF @exp_ad_stp      IS NOT NULL EXEC tSQLt.AssertEquals @exp_ad_stp     , @act_ad_stp     ,'ad_stp';
      IF @exp_tst_mode    IS NOT NULL EXEC tSQLt.AssertEquals @exp_tst_mode   , @act_tst_mode   ,'tst_mode';
      IF @exp_stop_stage  IS NOT NULL EXEC tSQLt.AssertEquals @exp_stop_stage , @act_stop_stage ,'stop_stage';
      IF @exp_tst_rtn_nm  IS NOT NULL EXEC tSQLt.AssertEquals @exp_tst_rtn_nm , @act_tst_rtn_nm ,'tst_rtn_nm';
      IF @exp_hlpr_rtn_nm IS NOT NULL EXEC tSQLt.AssertEquals @exp_hlpr_rtn_nm, @act_hlpr_rtn_nm,'hlpr_rtn_nm';
--    IF @exp_max_prm_len IS NOT NULL EXEC tSQLt.AssertEquals @exp_max_prm_len, @act_max_prm_len,'max_prm_len';
      IF @exp_ex_num      IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_num     , @act_ex_num     ,'ex_num';
      IF @exp_ex_msg      IS NOT NULL EXEC tSQLt.AssertEquals @exp_ex_msg     , @act_ex_msg     ,'ex_msg';
      -- passed exception test
      BREAK;
   END --WHILE
   EXEC sp_log 2, @fn, '17: all tests ran OK';
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_pop_rtn_details';
*/
GO

