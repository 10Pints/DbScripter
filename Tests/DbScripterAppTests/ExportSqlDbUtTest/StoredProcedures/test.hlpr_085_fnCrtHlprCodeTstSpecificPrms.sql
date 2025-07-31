SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      05-Apr-2024
-- Description: Tests fnCrtHlprCodeTstSpecificPrms()
--
-- Tested rtn description:
-- Description: adds the routine output parameters if a table function
--  and
-- test specific parameters:
--  expected values  @exp_<>     optional
-- check step id:  @chk_step_id  optional
-- expected line: @exp_line      optional
-- expected exception info       optional (@exp_ex_num and @exp_ex_msg)
--
-- if qrn does not exist then return no rows then returned table has no rows
--
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
CREATE PROCEDURE [test].[hlpr_085_fnCrtHlprCodeTstSpecificPrms]
    @tst_num               NVARCHAR(50)
   ,@inp_qrn               NVARCHAR(120)
   ,@inp_ordinal           INT
   ,@tst_ordinal           INT            = NULL
   ,@exp_rtn_nm            NVARCHAR(50)   = NULL
   ,@exp_schema_nm         NVARCHAR(50)   = NULL
   ,@exp_param_nm          NVARCHAR(50)   = NULL
   ,@exp_param_ty_nm       NVARCHAR(50)   = NULL
   ,@exp_is_output         BIT            = NULL
   ,@exp_has_default_value BIT            = NULL
   ,@exp_is_nullable       BIT            = NULL
   ,@exp_has_rows          BIT            = NULL
   ,@exp_has_ex_cols       BIT            = NULL
   ,@exp_ex_num            INT            = NULL
   ,@exp_ex_msg            NVARCHAR(100)  = NULL
AS
BEGIN
   DECLARE
    @fn                    NVARCHAR(35)   = N'hlpr_085'
   ,@act_rtn_nm            NVARCHAR(50)
   ,@act_schema_nm         NVARCHAR(50)
   ,@act_param_nm          NVARCHAR(50)
   ,@act_ordinal  INT
   ,@act_param_ty_nm       NVARCHAR(50)
   ,@act_is_output         BIT
   ,@act_has_default_value BIT
   ,@act_is_nullable       BIT
   EXEC test.sp_tst_hlpr_st @fn, @tst_num;
   EXEC sp_log 1, @fn, '00: params:
tst_num              :[',@tst_num              ,']
inp_qrn              :[',@inp_qrn              ,']
inp_ordinal          :[',@inp_ordinal          ,']
tst_ordinal          :[',@tst_ordinal          ,']
exp_rtn_nm           :[',@exp_rtn_nm           ,']
exp_schema_nm        :[',@exp_schema_nm        ,']
exp_param_nm         :[',@exp_param_nm         ,']
exp_param_ty_nm      :[',@exp_param_ty_nm      ,']
exp_is_output        :[',@exp_is_output        ,']
exp_has_default_value:[',@exp_has_default_value,']
exp_is_nullable      :[',@exp_is_nullable      ,']
exp_has_rows         :[',@exp_has_rows         ,']
exp_has_ex_cols      :[',@exp_has_ex_cols      ,']'
;
   ----------------------------------------------------------------
      -- Setup
   ----------------------------------------------------------------
   DELETE FROM Test.RtnDetails;
   EXEC test.sp_get_rtn_details @inp_qrn, @throw_if_err = 0; -- do not throw if rtn not found
   EXEC sp_log 1, @fn, '05:';
   SELECT * FROM Test.RtnDetails;
   DROP table IF EXISTS Test.Results;
   ----------------------------------------------------------------
   -- Execute
   ----------------------------------------------------------------
   BEGIN TRY
      SELECT * into Test.Results
      FROM
      test.fnCrtHlprCodeTstSpecificPrms(@inp_qrn, @inp_ordinal);
      EXEC sp_log 1, @fn, '07:';
      SELECT * FROM Test.Results;
   ----------------------------------------------------------------
      -- Test
   ----------------------------------------------------------------
      IF @tst_ordinal IS NOT NULL
      BEGIN
         EXEC sp_log 1, @fn, '10:';
         SELECT 
             @act_rtn_nm            = rtn_nm 
            ,@act_schema_nm         = schema_nm
            ,@act_param_nm          = param_nm
            ,@act_ordinal           = ordinal_position
            ,@act_param_ty_nm       = param_ty_nm
            ,@act_is_output         = is_output
            ,@act_has_default_value = has_default_value
            ,@act_is_nullable       = is_nullable
         FROM  test.results
         WHERE ordinal_position = @tst_ordinal;
         EXEC sp_log 1, @fn, '15:';
   EXEC sp_log 1, @fn, '00: actuals:
act_ordinal          :[',@act_ordinal          ,']
act_rtn_nm           :[',@act_rtn_nm           ,']
act_schema_nm        :[',@act_schema_nm        ,']
act_param_nm         :[',@act_param_nm         ,']
act_param_ty_nm      :[',@act_param_ty_nm      ,']
act_is_output        :[',@act_is_output        ,']
act_has_default_value:[',@act_has_default_value,']
act_is_nullable      :[',@act_is_nullable      ,']'
;
         EXEC sp_assert_equal NULL, @exp_ex_num, '020 expected exception but none were thrown';
         IF @exp_has_rows IS NOT NULL
         BEGIN
            IF @exp_has_rows = 0
            BEGIN
               EXEC sp_log 1, @fn, '16: check results table is not populated';
               EXEC sp_chk_tbl_not_populated 'test.results';
            END
            ELSE
            BEGIN
               EXEC sp_log 1, @fn, '17: check results table is populated';
               EXEC sp_chk_tbl_populated 'test.results';
            END
         END
         EXEC sp_log 1, @fn, '20:';
         IF @exp_rtn_nm            IS NOT NULL EXEC tSQLt.AssertEquals @exp_rtn_nm           , @act_rtn_nm           , 'rtn_nm';
         EXEC sp_log 1, @fn, '25:';
         IF @exp_schema_nm         IS NOT NULL EXEC tSQLt.AssertEquals @exp_schema_nm        , @act_schema_nm        , 'schema_nm';
         EXEC sp_log 1, @fn, '30:';
         IF @exp_param_nm          IS NOT NULL EXEC tSQLt.AssertEquals @exp_param_nm         , @act_param_nm         , 'param_nm';
         EXEC sp_log 1, @fn, '40:';
         IF @exp_param_ty_nm       IS NOT NULL EXEC tSQLt.AssertEquals @exp_param_ty_nm      , @act_param_ty_nm      , 'param_ty_nm';
         EXEC sp_log 1, @fn, '45:';
         IF @exp_is_output         IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_output        , @act_is_output        , 'is_output';
         EXEC sp_log 1, @fn, '50:';
         IF @exp_has_default_value IS NOT NULL EXEC tSQLt.AssertEquals @exp_has_default_value, @act_has_default_value, 'has_default_value';
         EXEC sp_log 1, @fn, '55:';
         IF @exp_is_nullable       IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_nullable      , @act_is_nullable      , 'is_nullable';
         EXEC sp_log 1, @fn, '60:';
         IF @exp_has_ex_cols IS NOT NULL
         BEGIN
            EXEC sp_log 1, @fn, '65:';
            IF @exp_has_ex_cols = 0
            BEGIN
               EXEC sp_log 1, @fn, '70: chk @exp_ex_num and ';
               IF EXISTS (SELECT 1 FROM Test.Results WHERE param_nm LIKE '@exp_ex_%')
                  EXEC tSQLt.Fail 'unexpected @exp_ex_num and @exp_ex_msg parameters';
            END
            ELSE
            BEGIN
               EXEC sp_log 1, @fn, '75:';
               IF NOT EXISTS (SELECT 1 FROM Test.Results WHERE param_nm IN ('@exp_ex_num','@exp_ex_msg'))
                  EXEC tSQLt.Fail 'The expected @exp_ex_num and @exp_ex_msg parameters were not found in the output parameters';
            END
         END
      END
      END TRY
      BEGIN CATCH
         IF @exp_ex_num IS NULL
         BEGIN
            EXEC sp_log 4, @fn, '500: unexpected exception thrown';
            EXEC tSQLt.Fail '500: unexpected exception thrown';
            EXEC tSQLt.Fail '';
         END
      END CATCH
   EXEC sp_log 1, @fn, '99: leaving all subtests PASSED';
END
/*
EXEC tSQLt.Run 'test.test_085_fnCrtHlprCodeTstSpecificPrms';
EXEC tSQLt.RunAll;
*/
GO

