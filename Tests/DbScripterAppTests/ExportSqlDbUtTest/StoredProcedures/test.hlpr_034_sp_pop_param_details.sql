SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author:      Terry Watts
-- Create date: 16-FEB-2021
-- Description: Helper for sp_pop_rtn_details tests
-- =====================================================
CREATE PROCEDURE [test].[hlpr_034_sp_pop_param_details]
    @tst_num            NVARCHAR(50)
   ,@inp_qrn            NVARCHAR(150)
   ,@tst_ordinal        INT            = NULL
   ,@exp_param_nm       NVARCHAR(50)   = NULL
   ,@exp_type_nm        NVARCHAR(50)   = NULL
   ,@exp_parameter_mode NVARCHAR(50)   = NULL
   ,@exp_is_chr_ty      BIT            = NULL
   ,@exp_is_result      BIT            = NULL
   ,@exp_is_output      BIT            = NULL
   ,@exp_tst_ty         NVARCHAR(3)    = NULL
   ,@exp_param_found    BIT            = NULL
   ,@exp_ex_num         INT            = NULL
   ,@exp_ex_msg         NVARCHAR(100)  = NULL
   ,@display_table      BIT            = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn                    NVARCHAR(35) = 'H034_sp_pop_param_details'
   ,@line                  NVARCHAR(120) = REPLICATE('-', 120)
   ,@act_param_nm          NVARCHAR(50)
   ,@act_type_nm           NVARCHAR(50)
   ,@act_parameter_mode    NVARCHAR(50)
   ,@act_is_chr_ty         BIT
   ,@act_is_result         BIT
   ,@act_is_output         BIT
   ,@act_tst_ty            NVARCHAR(3)
   ,@act_ex_num            INT
   ,@act_ex_msg            NVARCHAR(100)
   ,@ex_thrown             BIT
   ,@schema_nm             NVARCHAR(25)
   ,@msg                   NVARCHAR(500)
   ,@rtn_nm                NVARCHAR(50)
   PRINT '';
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
   EXEC sp_log 1, @fn, '000: params, 
test_num          :[',@tst_num               ,']
inp_qrn           :[',@inp_qrn               ,']
tst_ordinal       :[',@tst_ordinal           ,']
exp_param_nm      :[',@exp_param_nm          ,']
exp_type_nm       :[',@exp_type_nm           ,']
exp_parameter_mode:[',@exp_parameter_mode    ,']
exp_is_chr_ty     :[',@exp_is_chr_ty         ,']
exp_is_result     :[',@exp_is_result         ,']
exp_is_output     :[',@exp_is_output         ,']
exp_tst_ty        :[',@exp_tst_ty            ,']
exp_param_found   :[',@exp_param_found       ,']
exp_ex_num        :[',@exp_ex_num            ,']
exp_ex_msg        :[',@exp_ex_msg            ,']
display_table     :[',@display_table         ,']';
   -- SETUP
   SELECT
       @schema_nm = schema_nm
      ,@rtn_nm    = rtn_nm
   FROM test.fnSplitQualifiedName(@inp_qrn);
   EXEC sp_log 1, @fn, '005: setup: calling sp_get_rtn_details...';
   -- Partially populate the RtnDetails table (sp_pop_param_details precondition)
   -- ignore errors - they will be tested later
   EXEC test.sp_pop_rtn_details
       @qrn          = @inp_qrn
      ,@throw_if_err = 0
   ;
   EXEC sp_log 1, @fn, '010: ret frm sp_get_rtn_details';
   IF @exp_ex_num IS NULL
   BEGIN
      EXEC sp_log 1, @fn, '015: calling test.sp_get_rtn_parameters';
      EXEC test.sp_pop_param_details ;--@schema_nm, @rtn_nm;
      EXEC sp_log 1, @fn, '020: ret frm test.sp_get_rtn_parameters';
   END
   ELSE
   BEGIN
      BEGIN TRY
         -- Expect exception here
         EXEC sp_log 1, @fn, '025: calling test.sp_get_rtn_parameters: expect an exception to be thrown';
         EXEC test.sp_pop_param_details;-- @schema_nm, @rtn_nm;
         EXEC sp_log 4, @fn, '030: expected exception was NOT thrown';
      END TRY
      BEGIN CATCH
         DECLARE @act_ex_st INT
         SET @ex_thrown  = 1;
         SET @act_ex_num = ERROR_NUMBER();
         SET @act_ex_msg = ERROR_MESSAGE();
         SET @act_ex_st  = ERROR_STATE();
         EXEC sp_log 1, @fn, '035: caught exception: 
act_ex_num: [', @act_ex_num,'
act_ex_msg: [', @act_ex_msg,']
This is expected';
         -- Always test the exception num 
         EXEC sp_log 1, @fn, '040: checking the exception number';
         EXEC tSQLt.AssertEquals @exp_ex_num, @act_ex_num, 'ex_num mismatch';
         IF @exp_ex_msg IS NOT NULL
         BEGIN
            -- Test the exception msg if the expected value is supplied
            EXEC sp_log 1, @fn, '050: checking the exception message exp: [', @exp_ex_msg,'] act[', @act_ex_msg,']';
            DECLARE @pos INT
            SET @pos = CHARINDEX(@exp_ex_msg, @act_ex_msg);
            IF @pos = 0
            BEGIN
               SET @msg = CONCAT('
@test_num: ',@tst_num,'
exp/act_ex_msg mismatch: 
exp:[',@exp_ex_msg,']',NCHAR(13),'act:[',@act_ex_msg,']',NCHAR(13),'@exp_ex_msg should be contained in @act_ex_msg ');
               EXEC sp_log 4, @fn, '055: ', @msg;
               EXEC tSQLt.Fail @msg;
            END
         END
      END CATCH
      EXEC tSQLt.AssertEquals 1, @ex_thrown, '060: expected an exception to be thrown, but it was not';
      RETURN;
   END
      ----------------------------------------------------------------------------------------
   -- Test
      ----------------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '065: testing expected values...';
   IF @tst_ordinal IS NOT NULL
   BEGIN
      SELECT
          @act_param_nm       = param_nm
         ,@act_type_nm        = type_nm
         ,@act_parameter_mode = parameter_mode
         ,@act_is_chr_ty      = is_chr_ty
         ,@act_is_result      = is_result
         ,@act_is_output      = is_output
         ,@act_tst_ty         = tst_ty
      FROM test.ParamDetails
      WHERE ordinal = @tst_ordinal;
      -- Debug
      IF @display_table = 1
         SELECT * FROM ParamDetails WHERE ordinal = @tst_ordinal;
      -- Ordinal found chk
      EXEC sp_log 1, @fn, '070: ordinal found chk';
      IF @exp_param_found IS NOT NULL
      BEGIN
         IF @exp_param_found = 1
            EXEC tSQLt.AssertNotEquals NULL, @act_param_nm, 'ordinal should be found chk';
         ELSE
            EXEC tSQLt.AssertEquals    NULL, @act_param_nm, 'ordinal should not be found chk';
      END

      EXEC sp_log 1, @fn, '075: exp/act tests';
      IF @exp_param_nm         IS NOT NULL EXEC tSQLt.AssertEquals @exp_param_nm        , @act_param_nm        , 'param_nm';
      IF @exp_type_nm          IS NOT NULL EXEC tSQLt.AssertEquals @exp_type_nm         , @act_type_nm         , 'type_nm';
      IF @exp_parameter_mode   IS NOT NULL EXEC tSQLt.AssertEquals @exp_parameter_mode  , @act_parameter_mode  , 'parameter_mode';
      IF @exp_is_chr_ty        IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_chr_ty       , @act_is_chr_ty       , 'is_chr_ty';
      IF @exp_is_result        IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_result       , @act_is_result       , 'is_result';
      IF @exp_is_output        IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_output       , @act_is_output       , 'is_output';
      IF @exp_tst_ty           IS NOT NULL EXEC tSQLt.AssertEquals @exp_tst_ty          , @act_tst_ty          , 'tst_ty';

      EXEC sp_log 1, @fn, '55: completed param sub tests';
   END -- IF @ordinal IS NOT NULL
   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.Run 'test.test_034_sp_pop_param_details';
EXEC tSQLt.RunAll;
*/
GO

