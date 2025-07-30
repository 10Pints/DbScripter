SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================
-- Author:      Terry Watts
-- Create date: 17-DEC-2021
-- Description: Creates a table of arguments and their attributes
--
-- Responsibilities;
-- R01: fully populate the ParamDetails table
-- R02: update the RtnDetails table max_prm_len field with the max parameter name length
-- R03: update the RtnDetails table sc_fn_ret_ty field with the the scalar fn return type - if tstd rtn is a scalar function
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
--    Test.RtnDetails pop'd
--
-- POST CONDITIONS:
-- POST 01: if routine not found then exception 70003, 'Routine <@schema_nm.@rtn_nm> was not found'
-- POST 02: fully populates the ParamDetails table or exception <TBA> <TBA>
-- POST 03: updates the RtnDetails table max_prm_len field or exception <TBA> <TBA>
-- POST 04: updates the RtnDetails table scalar fn return type field or exception <TBA> <TBA>
--
-- NOTES:
-- 1. The MS routines and views to get default parameter values DONT WORK - no suprise there then
--
-- CALLED BY: test.sp_get_rtn_details
--
-- Tests: [test_034_sp_pop_param_details
--
-- Changes:
-- 240403: Changed to use INFORMATION_SCHEMA.PARAMETERS and dbo.paramsVw
--          not bother with comments
--          Table is now fixed as test.ParamTable
-- 240415: redesign, added several fields to make it eassier to use latter in the test rtn creation
-- 240503: added sc_fn_ret_ty to test.RtnParameters to hold the scalar fn return type - if tstd rtn is a scalar function
-- =============================================================================================================================
CREATE PROCEDURE [test].[sp_pop_param_details]
    @throw_if_err    BIT      = 1
   ,@display_tables  BIT      = 0
AS
BEGIN
   DECLARE
     @fn             NVARCHAR(35)   = 'sp_pop_param_details'
    ,@qrn            NVARCHAR(120)
    ,@schema_nm      NVARCHAR(25)
    ,@rtn_nm         NVARCHAR(50)
    ,@rtn_ty_code    NVARCHAR(2)
    ,@ndx            INT            = 1
    ,@row_cnt        INT
    ,@max_prm_len    INT
    ,@msg            NVARCHAR(500)
    ,@sc_fn_ret_ty   NVARCHAR(20)
   SELECT
       @schema_nm    = schema_nm
      ,@rtn_nm       = rtn_nm
      ,@rtn_ty_code  = rtn_ty_code
   FROM test.RtnDetails;
   EXEC sp_log 1, @fn, '000: starting
@schema_nm  :[',@schema_nm,']
@rtn_nm     :[',@rtn_nm,']
@rtn_ty_code:[',@rtn_ty_code,']';
   SET @qrn = CONCAT(@schema_nm, '.', @rtn_nm);
   -- Clear the test.Param TabIe
   EXEC sp_log 1, @fn, '005: clearing param details'
   TRUNCATE TABLE test.ParamDetails;
   -------------------------------------------------------------------------------
   -- Validate parameters
   -------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '010: Validating parameters...';
-- POST 01: if routine not found then exception 70003, 'Routine <@schema_nm.@rtn_nm> was not found'
   IF @rtn_nm IS NULL
   BEGIN
      SET @msg = CONCAT('Routine <', @schema_nm, '.',@rtn_nm,'> was not found');
      EXEC sp_log 4, @fn, '015: raising exception 70003, ', @msg;
      IF @throw_if_err = 1
         THROW 70003, @msg, 1;
      ELSE
         RETURN
   END
   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES
   WHERE SPECIFIC_SCHEMA = @schema_nm AND SPECIFIC_NAME = @rtn_nm)
   BEGIN
      SET @msg = CONCAT('routine <',@schema_nm,'>.<',@rtn_nm,'> was not found');
      IF @throw_if_err = 1
         THROW 70003, @msg, 1;
      ELSE
      BEGIN
         EXEC sp_log 4, @fn, '004: routine ',@schema_nm,'.',@rtn_nm,' not found';
      END
   END
   -------------------------------------------------------------------------------
   -- Validation complete
   -------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '005: Validation complete';
   -------------------------------------------------------------------------------
   -- Process
   -------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '010: starting process
@qrn:[',@qrn,']
@rtn_ty_code:[',@rtn_ty_code,']'
;
   -- Add the tst_num parameter setting type = SYS
   EXEC sp_log 1, @fn, '015: Populating ParamDetails, adding tst_num ';
   INSERT INTO test.ParamDetails(param_nm ,  type_nm      , parameter_mode, is_chr_ty, is_result, is_output, is_nullable, tst_ty)
   VALUES                       ('tst_num', 'NVARCHAR(50)', 'IN'           , 1        , 0        , 0        , 0          ,'TST');
   EXEC sp_log 1, @fn, '017:';
   IF @rtn_ty_code IN ('P','TF')
   BEGIN
      EXEC sp_log 1, @fn, '018:';
      SET @ndx = @ndx + 1;
      INSERT INTO test.ParamDetails(param_nm ,type_nm       , parameter_mode, is_chr_ty, is_result, is_output, is_nullable, tst_ty)
      VALUES                       ('tst_key', 'SQL_VARIANT', 'IN'           , 1        , 0        , 0        , 0          ,'TST');
   END
   --ELSE
      SET @ndx = @ndx + 1;
   -- Get the rtn parameters-- Add the rtn parameters as INP if a Scalar FN ignore the is_result parameter
   EXEC sp_log 1, @fn, '020: adding rtn parameters as INP';
   INSERT INTO test.ParamDetails
   (
    param_nm
   ,parameter_mode
   ,type_nm
   ,is_output
   ,is_chr_ty
   ,is_result
   ,is_nullable
   ,tst_ty
   )
   SELECT
       iif( is_result = 'YES', 'out_val', dbo.fnTrim2(pv.param_nm, '@')) as param_nm
      ,parameter_mode
      ,upper(ty_nm_full)
      ,is_output
      ,is_chr_ty
      ,iif(is_result='Yes', 1,0) as is_result
      ,is_nullable
      ,iif( is_result = 'YES','EXP','INP') as tst_ty
   FROM INFORMATION_SCHEMA.PARAMETERS isp
   JOIN dbo.paramsVw pv ON 
       isp.SPECIFIC_SCHEMA  = pv.schema_nm
   AND isp.SPECIFIC_NAME    = pv.rtn_nm
   AND isp.PARAMETER_NAME   = pv.param_nm
   WHERE schema_nm = @schema_nm
   AND   rtn_nm    = @rtn_nm
--   AND   is_result = 'No'
   ;
   SET @row_cnt = @@ROWCOUNT;
   SET @ndx = @ndx + @row_cnt;
   EXEC sp_log 1, @fn, '022: @ndx after geting rtn params: ', @ndx,'  @row_cnt: ',@row_cnt;
   ----------------------------------------------------------------------------------------------------------------------------------
   -- IF SP or TF: get the output cols and add EXP row_cnt param
   ----------------------------------------------------------------------------------------------------------------------------------
   IF @rtn_ty_code IN ('P','TF')
   BEGIN
      EXEC sp_log 1, @fn, '025: @rtn_ty_code:', @rtn_ty_code, ', adding exp_row_cnt';
      -- Add an exp_row_cnt INT setting type = TST
      INSERT INTO test.ParamDetails( param_nm    , type_nm, parameter_mode, is_chr_ty, is_result, is_output, is_nullable, tst_ty)
      VALUES                       ('row_cnt'    , 'INT'  , 'IN'          , 0        , 0        , 0        , 1          ,'EXP');
      SET @ndx = @ndx + 1;
      IF  @rtn_ty_code = 'TF'
      BEGIN
         -- Get the TF ouput table cols
         EXEC sp_log 1, @fn, '030: , adding the TF ouput table cols';
         INSERT INTO test.ParamDetails
               (param_nm, type_nm, parameter_mode, is_chr_ty, is_output, is_nullable, tst_ty)
         SELECT
             dbo.fnTrim2(name, '@')
            ,ty_nm
            ,'IN'
            ,dbo.fnIsCharType(ty_nm)
            ,0
            ,1
            ,'EXP'
         FROM dbo.fnGetFnOutputCols(@qrn)
      END
      IF @rtn_ty_code = 'P'
      BEGIN
         EXEC sp_log 1, @fn, '030: , getting the SP ouput table cols';
         BEGIN TRY
            DELETE FROM test.sp_first_result_col_info;
            DECLARE @obj_id INT
            SET @obj_id = OBJECT_ID(@qrn);
            EXEC sp_log 1, @fn, '031: , checking OBJECT_ID(',@qrn, ') = ', @obj_id, ' is > 0...';
            -------------------------------------------------------------------------------------------
            -- Make sure rtn was found
            -------------------------------------------------------------------------------------------
            EXEC sp_assert_gtr_than @obj_id, 0, '032: failed to get the object id for ', @qrn;
            INSERT INTO test.sp_first_result_col_info(name, column_ordinal, is_nullable, system_type_name, [error_message])
            SELECT name, column_ordinal, is_nullable, system_type_name, [error_message]
            FROM sys.dm_exec_describe_first_result_set_for_object(@obj_id, 0);
            INSERT INTO test.ParamDetails
                  (param_nm, type_nm, parameter_mode
                  ,is_chr_ty,is_result,is_output,is_nullable,tst_ty,is_out_col)
            SELECT
                dbo.fnTrim2(name, '@')                   -- raw_param_nm
               ,UPPER(system_type_name)                  -- type_nm
           --  ,column_ordinal + @ndx                    -- ordinal_position
               ,'IN'                                     -- parameter_mode
               ,dbo.fnIsCharType(system_type_name)       -- is_chr_ty
               ,1                                        -- is_result
               ,0                                        -- is_output
               ,1                                        -- is_nullable
               ,'EXP'                                    -- tst_ty
               ,1
            FROM test.sp_first_result_col_info
            WHERE name <> 'SP RTN COLS:';
            EXEC sp_log 1, @fn, '035: , getting the SP ouput table cols succeeded';
         END TRY
         BEGIN CATCH
            EXEC sp_log_exception @fn, 'sys.dm_exec_describe_first_result_set cannnot get output cols from SP - continuing without the output col exp/act params';
         END CATCH
      END -- IF @rtn_ty_code = 'P'
   END -- IF @rtn_ty_code IN ('P','TF')
   -------------------------------------------------------------------------------------------------------------------------------
   -- R02: add exception params
   -------------------------------------------------------------------------------------------------------------------------------
   SET @ndx = @ndx + 1;
   INSERT INTO test.ParamDetails(param_nm ,type_nm       , parameter_mode, is_chr_ty, is_result, is_output, is_nullable, tst_ty)
   VALUES                       
    ('ex_num', 'INT'          , 'IN'           , 1        , 0        , 0        , 1          ,'EXP')
   ,('ex_msg', 'NVARCHAR(500)', 'IN'           , 1        , 1        , 0        , 1          ,'EXP')
   ;
   -------------------------------------------------------------------------------------------------------------------------------
   -- R02: update the RtnDetails table max_prm_len field with the length of the longest parameter name including the @xxx_ prefix
   -------------------------------------------------------------------------------------------------------------------------------
   EXEC sp_log 1, @fn, '085: calculating max param len...'
   -- Set max param nm len make sure atleast size of our standard parameters like @act_ex_msg
   SELECT @max_prm_len = dbo.fnMax(14, MAX(dbo.fnLen(param_nm))) FROM ParamDetails;
   UPDATE test.RtnDetails
   SET max_prm_len = @max_prm_len;
   -------------------------------------------------------------------------------------------------------------------------------
   -- R03: if tstd rtn is a scalar function then update the RtnDetails table sc_fn_ret_ty field with the scalar fn return type
   -------------------------------------------------------------------------------------------------------------------------------
   IF @rtn_ty_code = 'FN'
   BEGIN
      EXEC sp_log 1, @fn, '090: getting sc fn ret type from parameters...'
      SELECT @sc_fn_ret_ty = type_nm
      FROM test.ParamDetails
      WHERE is_output=1;
      EXEC sp_log 1, @fn, '091: getting sc fn ret type from parameters ...@sc_fn_ret_ty:[', @sc_fn_ret_ty,']';
      EXEC sp_assert_not_null_or_empty @sc_fn_ret_ty, 'scalar fn return type was not found';
      EXEC sp_log 1, @fn, '092: ASSERTION @sc_fn_ret_ty found'
      UPDATE test.RtnDetails
      SET sc_fn_ret_ty = @sc_fn_ret_ty;
      EXEC sp_log 1, @fn, '098: ASSERTION @sc_fn_ret_ty found'
   END
   EXEC sp_log 1, @fn, '900: completed processing, @max_prm_len: ',@max_prm_len;
   EXEC sp_log 1, @fn, '999: leaving'
   -------------------------------------------------------------------------------
   -- Process complete
   -------------------------------------------------------------------------------
   if @display_tables = 1
      SELECT * FROM test.ParamDetails;
END
/*
EXEC tSQLt.Run 'test.test_034_sp_pop_param_details';
EXEC tSQLt.RunAll;
*/
GO

