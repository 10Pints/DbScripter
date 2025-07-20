SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ============================================================
-- Author:      Terry Watts
-- Create date: 06-APR-2024
-- Description: creates the script for a test helper routine
--    populates test.HlprDef table
--
-- Design: see EA ut/Use Case Model/Test Automation/Create Helper rotine Use case/Create the Helper routine_ActivityGraph
--
-- Algorithm:
-- Create the text header
-- Create the Helper routine
-- Create the test helper signature
-- Create As-begin-decl-log-st bloc for the helper
-- Add the test setup and call tested routine comments
-- Create the if @exp_ex_num IS null bloc
-- Create the if @exp_ex_nm is NOT null bloc
-- Create the test bloc
-- Create the close bloc
--
-- OUTPUTS:
-- 1: populates table: test.tstActDefHlpr with the hlper creation sql script
--
-- Preconditions:
--    test.rtnDetails and test.ParamDetails populated

-- Algorithm:
--
-- Changes:
-- 231115: helper should have same defaults as the tstd rtn
-- 231121: @qrn must exist or exception 56472, '<@@qrn> does not exist'
-- 231121: added a try catch handler to log errors
-- 231201: better tested exception handling
-- 231213: handle wonky []
-- 231216: add check for expected line for the given step id
-- 240402: refactor - split into subroutines
-- ============================================================
CREATE PROCEDURE [test].[sp_crt_tst_hlpr_script]
AS
BEGIN
   DECLARE 
    @fn                 VARCHAR(35)   = 'sp_crt_tst_hlpr_script'
   ,@qrn                VARCHAR(100) -- including schema
   ,@trn                INT
   ,@ad_stp             BIT            = 0    -- used in testing to identify a step with a unique name (not an incremental int id)
   ,@cora               NCHAR(1)       = 'C'
   ,@crse_rtn_ty_code   VARCHAR(1)          -- coarse grained type one of {'F','P'}
   ,@detld_rtn_ty_code  NCHAR(2)       = '?' -- detailed type code: can be 1 of {'P', 'FN', 'IF','TF'}like TF for a table function
   ,@hlpr_rtn_nm        VARCHAR(120)        -- hlpr_<@trn 000>_
   ,@schema_nm          VARCHAR(50)
   ,@stop_stage         INT            = 12   -- stage 12 for testing - display script
   ,@tst_mode           BIT            = 1    -- for testing - copy tmp tables to permananent tables for teting
   ,@tst_proc_mn_nm     VARCHAR(120)
   ,@rtn_ty_code        VARCHAR(25)
   ,@rtn_ty_nm          VARCHAR(25)
   ,@rtn_nm             VARCHAR(100)
   ,@tstd_rtn_call      VARCHAR(250)
   ,@params             VARCHAR(MAX)  = '/*params: <TBD>*/'
   ,@hlpr_params        VARCHAR(MAX)  = '/*hlpr params: <TBD>*/'
   ,@max_param_len      INT            = -1
   ,@n                  INT
   ,@act_@qrn           VARCHAR(100)
   ,@row_cnt            INT
   ,@act_tst_rtn_num    INT
   ,@error_num          INT
   ,@error_msg          VARCHAR(500)
   ,@stage              INT = 1
   ,@msg                VARCHAR(500)
   ,@txt                VARCHAR(500)
   ,@tab                VARCHAR(4)    = '   '
   ;

   BEGIN TRY
--      EXEC sp_log 2, @fn, '';
--      EXEC sp_log 2, @fn, @line2;

      ----------------------------------------------------------------------------------------------------------------------------
      -- Log paramaters
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '000: starting';

      SELECT
          @qrn          = qrn
         ,@schema_nm    = schema_nm
         ,@rtn_nm       = rtn_nm
         ,@trn          = trn
         ,@cora         = cora
         ,@ad_stp       = ad_stp
--         ,@tst_mode     = tst_mode
--         ,@stop_stage   = stop_stage
         ,@hlpr_rtn_nm  = hlpr_rtn_nm
         ,@rtn_ty_nm    = rtn_ty
         ,@rtn_ty_code  = rtn_ty_code
      FROM test.RtnDetails;

      EXEC sp_log 1, @fn, '005: params
qrn        :[',@qrn         ,']
trn        :[',@trn         ,']
cora       :[',@cora        ,']
ad_stp     :[',@ad_stp      ,']
tst_mode   :[',@tst_mode    ,']
stop_stage :[',@stop_stage  ,']
hlpr_rtn_nm:[', @hlpr_rtn_nm,']
ty_code    :[', @rtn_ty_code,']
rtn_ty_nm  :[', @rtn_ty_nm     ,']'
;

      SET @stage = 1;
      EXEC sp_log 1, @fn, '010: truncate HlprDef';
      TRUNCATE TABLE test.HlprDef;

      if(@ad_stp=1) INSERT INTO HlprDef(line) VALUES(CONCAT('-- ', @fn));

      --------------------------------------------------------------------
      -- Create the text header
      --------------------------------------------------------------------
      EXEC sp_log 1, @fn, '015: creating the text header';
      INSERT INTO test.HlprDef (line)
      SELECT line FROM test.fnCrtCodeTstHdr(1);

      --------------------------------------------------------------------
      -- Create the test helper signature
      --------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: creating the helper signature';
      INSERT INTO test.HlprDef (line)
      SELECT line from test.fnCrtHlprCodeHlprSig();

      --------------------------------------------------------------------
      -- Create As-begin-decl-log-st bloc-test setup for the helper
      --------------------------------------------------------------------
      EXEC sp_log 1, @fn, '025: creating the as-begin-decl-log-st bloc-test setup';
      -- AS-BGN-ST, TF-DECL-ACTRTNDEF-TV,  BGN-TRY
      INSERT INTO test.HlprDef (line)
      SELECT line FROM test.fnCrtHlprCodeBegin();

      -------------------------------------------------------------------------------------------------
      --  Create the tested rtn call
      -------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: creating the call tested routine bloc';
      INSERT INTO test.HlprDef (line)
      SELECT line FROM test.fnCrtHlprCodeCallBloc();--@rtn_ty_code, @ad_stp);

      -------------------------------------------------------------------------------
      -- Create the test bloc dependant on rtn type
      ------------------------------------------------- ------------------------------
      --EXEC sp_log 1, @fn, '035: creating the test bloc dependant on rtn ty';
      --INSERT INTO test.HlprDef (line)
      --SELECT line FROM test.fnCrtHlprCodeTestBloc(@rtn_ty_code, @ad_stp);

      -------------------------------------------------------------------------------
      -- Create the close bloc
      -------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '045 creating the close bloc';
      INSERT INTO test.HlprDef (line)
      SELECT line FROM test.fnCrtHlprCodeCloseBloc()

      -------------------------------------------------------------------------------
      -- Script completed
      -------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '900 script completed';
      EXEC sp_log 2, @fn, '910 displaying hlpr script   ';
      SELECT * FROM test.HlprDef;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, '950: Stage: ', @stage;
      THROW;
   END CATCH

  
   EXEC sp_log 2, @fn, '999 leaving, OK';
END
/*
EXEC tSQLt.Run 'test.test_086_sp_crt_tst_hlpr_script';
*/



GO
