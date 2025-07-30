SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================================================================
-- Author:      Terry Watts
-- Create date: 20-APR-2024
-- Description: Gets the routine details for the routine @q_rtn_nm
--    Populates
--       PopulatesTest.RtnDetails   with the rtn level details only, not the param specific data like max param length
--       ** Does not populate Test.ParamDetails table
--
-- Responsibilities:
-- Sole populator of the 2 rtn metadata tables: {Test.RtnDetails, Test.RtnParamDetails}
-- Parameters:
-- @q_tstd_rtn the qualified tested routine name <schema>.<routine> optionally wrapped in []
--
-- Preconditions: none
-- PRE 01: @qrn must be specified - not null, empty or just dot or whitespace
--
-- Postconditions:
-- Populates
--       Test.RtnDetails   with the rtn level details
--
------------------------------------------------------------------------------------------------------
-- RULES     Rule                       Ex num  ex msg
------------------------------------------------------------------------------------------------------
-- POST 01: if routine not found and @throw_if_err is true then throw exception 70003, 'Routine [[<@schema_nm>].[<@rtn_nm>]] not found'
-- POST 02: Test.RtnDetails      pop OR 70101,  Could not find the routine   details for <@q_tstd_rtn>
-- POST 03: Test.RtnParamDetails pop OR 70102,  Could not find the parameter details for <@q_tstd_rtn>
-- POST 04: qrn returned fully qualified with schema
-- POST 05: if routine not found and @throw_if_err is false then pop rtnDetails with the rtn name details only
-- POST 06: test.rtnDetails has 1 row or exception 70004, 'failed to populate Test.RtnDetails properly'
--
-- Algorithm:
-- 1. Removes square brackets
-- 2. Validate parameters
-- 2. Pop Test.RtnDetails   with the rtn level details
--
-- Called by: sp_set_rtn_details
--
-- Tests: test.hlpr_034_get_rtn_parameters
--
-- Changes:
-- 240415: redesign, added several fields to make the test rtn creation easier
-- 241111: if @trn not supplied look for the first unused trn
-- 241121: bugfix: qrn with leading space causes rtn not found error. FIX:  trim the qrn after de square bracket
-- 241227: @qrn must be specified - not null, empty or just dot or whitespace
-- ======================================================================================================================================
CREATE PROCEDURE [test].[sp_pop_rtn_details]
    @qrn             VARCHAR(150) OUT
   ,@trn             INT      = NULL
   ,@cora            NCHAR(1) = NULL
   ,@ad_stp          BIT      = NULL -- used in testing to identify a step with a unique name (not an incremental int id)
-- ,@tst_mode        BIT      = 1    -- for testing - copy tmp tables to permananent tables for teting
-- ,@stop_stage      INT      = 12   -- stage 12 for testing - display script
   ,@throw_if_err    BIT      = 1
   ,@display_tables  BIT      = 0
AS
BEGIN
   DECLARE
    @fn           VARCHAR(35)   = 'sp_pop_rtn_details'
   ,@schema_nm    VARCHAR(50)
   ,@rtn_nm       VARCHAR(100)
   ,@rtn_ty       VARCHAR(2)
   ,@ty_code      VARCHAR(2)
   ,@cnt          INT
   ,@tst_rtn_nm   VARCHAR(50)
   ,@hlpr_rtn_nm  VARCHAR(50)
   ,@is_clr       BIT
   ,@max_prm_len  INT
   ,@msg          VARCHAR(500)
   EXEC sp_log 2, @fn, '000: starting
@qrn           :[', @qrn           ,']
@trn           :[', @trn           ,']
@cora          :[', @cora          ,']
@ad_stp        :[', @ad_stp        ,']
@throw_if_err  :[', @throw_if_err  ,']
@display_tables:[', @display_tables,']
';
--@tst_mode      :[', @tst_mode      ,']
--@stop_stage    :[', @stop_stage    ,']
   BEGIN TRY
      DELETE FROM Test.RtnDetails;
      DELETE FROM Test.ParamDetails;
      --------------------------------------------------------------------------------------
      -- Validate parameters
         --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '005: Validating parameters: removing [] brackets';
      SET @qrn = TRIM(dbo.fnDeSquareBracket(@qrn)); -- 241121 bugfix: qrn with leading space causes rtn not found error. FIX:  trim the qrn after de square bracket
      -- PRE 01: @qrn must be specified - not null, empty or just dot or whitespace
      EXEC sp_assert_not_null_or_empty @qrn, ' @qrn not specified', @fn=@fn;
      IF @qrn LIKE '.%' OR @qrn LIKE '%.'
         EXEC sp_raise_exception @msg1='@qrn must be specified - not null, empty or just dot or whitespace';
      --------------------------------------------------------------------------------------
      -- ASSERTION: Validated parameters
         --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: ASSERTION: Validated parameters';
      --------------------------------------------------------------------------------------
      -- Process
         --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: Process';
      EXEC sp_log 1, @fn, '030: Calling fnGetRtnDetails(', @qrn, ')';
      -- 241227: When qrn is not qualified with a schemqa - we can get it if the routine name is unique accross schemas
      SELECT
          @qrn       = qrn
         ,@schema_nm = schema_nm
         ,@rtn_nm    = rtn_nm
         ,@rtn_ty    = rtn_ty
         ,@ty_code   = ty_code
         ,@is_clr    = is_clr
      FROM dbo.fnGetRtnDetails(@qrn);
      EXEC sp_log 1, @fn, '040: fnGetRtnDetails(',@qrn,') returned
             @qrn       = [@schema_nm = [', @schema_nm, ']
             @rtn_nm    = [', @rtn_nm   , ']
             @rtn_ty    = [', @rtn_ty   , ']
             @ty_code   = [', @ty_code  , ']
             @is_clr    = [', @is_clr   , ']'
      ;
      IF @schema_nm IS NULL
      BEGIN
         -- POST 01: if routine not found and @throw_if_err is true then throw exception 70003, 'Routine [[<@schema_nm>].[<@rtn_nm>]] not found'
         EXEC sp_log 4, @fn, '050: routine ',@qrn, ' does not exist';
         IF @throw_if_err = 1
         BEGIN
            SET @msg = CONCAT('routine [',@schema_nm,'.',@rtn_nm,'] was not found');
            EXEC sp_raise_exception 70003, @msg, @fn=@fn;
         END
         ELSE
            -- POST 05: if routine not found and @throw_if_err is false then pop rtnDetails with the rtn name details only
            EXEC sp_log 4, @fn, '060: routine ',@qrn, ' does not exist. @throw_if_err = 0 so pop table with rtn name details only';
            INSERT INTO test.RtnDetails(qrn, schema_nm, rtn_nm)
            VALUES (@qrn, @schema_nm, @rtn_nm);
      END
      EXEC sp_log 1, @fn, '070:';
      IF @cora IS NULL
         SET @cora = 'C';
      IF @cora NOT IN ('A','C')
      BEGIN
         EXEC sp_log 4, @fn, '080: @cora  NOT IN (''A'',''C''):[',cora, ']';
         IF @throw_if_err = 1
         BEGIN
            EXEC sp_log 4, @fn, '090 : unknown create mode [',@cora, ']';
            EXEC sp_raise_exception 70100, 'Create or alter param must be 1 of {NULL, ''A'' ''C''}', @cora;
         END
         ELSE
         BEGIN
            EXEC sp_log 4, @fn, '100 : unknown create mode [',@cora, ']';
            SET @cora = 'unknown create mode';
         END
      END
      -- Return this to client code
      IF @ad_stp     IS NULL SET @ad_stp     = 1;
      IF @trn        IS NULL SET @trn        = test.fnGetNxtTstRtnNum(); -- this is very slow
--      IF @tst_mode   IS NULL SET @tst_mode   = 1;
--      IF @stop_stage IS NULL SET @stop_stage = 12;
      EXEC sp_log 1, @fn, '110: modified params:
@qrn         :[', @qrn         ,']
@trn         :[', @trn         ,']
@cora        :[', @cora        ,']
@ad_stp      :[', @ad_stp      ,']
';
-- @tst_mode    :[', @tst_mode    ,']
-- @stop_stage  :[', @stop_stage  ,']
      --------------------------------------------------------------------------------------
      -- Validate parameters Complete
      --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '120: ASSERTION Validated set any defaults as needed';
      --------------------------------------------------------------------------------------
      -- Process
      --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '130: Process'
      EXEC sp_log 1, @fn, '140: populating the RtnDetails table   '
      SET @tst_rtn_nm   = test.fnCreateTestRtnName(@rtn_nm, @trn, 'M');
      SET @hlpr_rtn_nm  = test.fnCreateTestRtnName(@rtn_nm, @trn, 'H');
      -- 2. Pop Test.RtnDetails with the rtn level details
      INSERT INTO Test.RtnDetails
           ( schema_nm, rtn_nm, rtn_ty, rtn_ty_code, trn, qrn, cora, ad_stp, /*tst_mode,stop_stage, */ tst_rtn_nm, hlpr_rtn_nm, is_clr, display_tables)
      SELECT schema_nm, rtn_nm, rtn_ty, ty_code    ,@trn,@qrn,@cora,@ad_stp,/*@tst_mode,@stop_stage,*/ @tst_rtn_nm,@hlpr_rtn_nm, is_clr,@display_tables
      FROM SysRtns_vw
      WHERE schema_nm = @schema_nm
      AND   rtn_nm    = @rtn_nm;
      SET @cnt = @@ROWCOUNT;
      EXEC sp_log 1, @fn, '145: imported ', @cnt, ' rows';
      IF @display_tables = 1
      BEGIN
         EXEC sp_log 1, @fn, '147: displaying Test.RtnDetails rows';
         SELECT * FROM Test.RtnDetails;
      END
      --------------------------------------------------------------------------------------
      -- Check postconditions
      --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '150: Checking postconditions   ';
      -- POST 01: find the routine         OR 70100,  Could not find the routine <@q_tstd_rtn>               chd already
      -- POST 02: Test.RtnDetails      pop OR 70101,  Could not find the routine   details for <@q_tstd_rtn> chd already
      -- POST 03: Test.RtnParamDetails pop OR 70102,  Could not find the parameter details for <@q_tstd_rtn> chd already
      -- POST 04: qrn returned fully qualified with schema
      EXEC sp_log 1, @fn, '160: checking results in the RtnDetails table, @cnt:',@cnt, ''
      -- POST 02: Test.RtnDetails      pop OR 70101,  Could not find the routine   details for <@q_tstd_rtn>
      IF @cnt = 0
      BEGIN
         EXEC sp_log 4, @fn, '170: Could not find the routine details for [',@qrn,']';
         IF @throw_if_err = 1
         BEGIN
            EXEC sp_raise_exception 70100, '180: Could not find the routine details for ',@qrn;
         END
         ELSE
         BEGIN
            EXEC sp_log 4, @fn, '190 : continuing process since @throw_if_err = 0';
         END
      END
      EXEC sp_log 1, @fn, '200: checking  RtnDetails table row count = 1'
      EXEC sp_assert_equal 1, @cnt, '[',@cnt,']) rows were returned in the RtnDetails table, should be 1 row', @ex_num=70110;
      SET @cnt = CHARINDEX('.', @qrn);
      EXEC sp_log 1, @fn, '210 dot pos: ', @cnt, ' @qrn: [',@qrn,']';
      EXEC sp_assert_not_equal 0, @cnt ,'Failed: tested routine not qualified';
      EXEC sp_log 1, @fn, '220';
      -- POST 06: test.rtnDetails has 1 row or exception 70004, 'failed to populate Test.RtnDetails properly'
      EXEC sp_assert_tbl_pop 'test.rtnDetails', @exp_cnt =1, @ex_num=70004, @ex_msg='failed to populate Test.RtnDetails properly';
      EXEC sp_log 1, @fn, '230';
      --------------------------------------------------------------------------------------
      -- Process complete
      --------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '900: Process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '999: leaving';
END
/*
EXEC test.sp_pop_rtn_details 'test.sp_compile_rtn', @display_tables=1;
SELECT * frOM test.rtnDetails;
EXEC sp_set_log_level 0
PRINT DB_NAME()
EXEC tSQLt.Run 'test.test_090_sp_get_rtn_details';
EXEC tSQLt.Run 'test.test_034_sp_pop_param_details';
EXEC tSQLt.RunAll;
SELECT * FROM dbo.fnGetRtnDetails('test.sp_tst_hlpr_st');
*/
GO

