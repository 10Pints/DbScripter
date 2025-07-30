SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: creates the script for the main test routine
--    populates test.TstDef table
--
-- Design: see EA ut/Use Case Model/Test Automation/Create Helper rotine Use case/Create the Helper routine_ActivityGraph
--
-- Algorithm:
-- Create the ALTER PROCEDURE signature
-- Create the As begin declare bloc
-- Create a run test line with dummy parameters
-- Create the close bloc
--
-- Preconditions:
--    test.rtnDetails and test.ParamDetails populated
-- Algorithm:
--
-- Changes:
-- 231115: helper should have same defaults as the tstd rtn
-- 231121: @qrn must exist or exception 56472, '<@qrn> does not exist'
-- 231121: added a try catch handler to log errors
-- 231201: better tested exception handling
-- 231213: handle wonky []
-- 231216: add check for expected line for the given step id
-- 240402: refactor - split into subroutines
--
-- ============================================================
CREATE PROCEDURE [test].[sp_crt_tst_mn_script]
AS
BEGIN
   DECLARE 
    @fn                 VARCHAR(35)   = 'sp_crt_tst_mn_script'
   ,@qrn                VARCHAR(100) -- including schema
   ,@trn                INT
   ,@ad_stp             BIT            = 0    -- used in testing to identify a step with a unique name (not an incremental int id)
   ,@act_qrn            VARCHAR(100)
   ,@row_cnt            INT
   ,@act_tst_rtn_num    INT
   ,@error_num          INT
   ,@error_msg          VARCHAR(500)
   ,@cora               NCHAR(1)
   ,@crse_rtn_ty_code   VARCHAR(1)          -- coarse grained type one of {'F','P'}
   ,@detld_rtn_ty_code  NCHAR(2)       = '?' -- detailed type code: can be 1 of {'P', 'FN', 'IF','TF'}like TF for a table function
   ,@hlpr_params        VARCHAR(MAX)
   ,@hlpr_rtn_nm        VARCHAR(120)        -- hlpr_<@trn 000>_
   ,@line               VARCHAR(500)  ='-- ========================================================================================'
   ,@line2              VARCHAR(500)  ='-- ----------------------------------------------------------------------------------------'
   ,@max_param_len      INT = -1
   ,@msg                VARCHAR(500)
   ,@n                  INT
   ,@params             VARCHAR(MAX)
   ,@stage              INT = 1
   ,@rtn_nm             VARCHAR(100)
   ,@rtn_ty             NCHAR(1)
   ,@rtn_ty_code        VARCHAR(2)
   ,@schema_nm          VARCHAR(50)
   ,@stop_stage         INT            = 12   -- stage 12 for testing - display script
   ,@tab1               VARCHAR(3) = '   '
   ,@tst_mode           BIT            = 1    -- for testing - copy tmp tables to permananent tables for teting
   ,@tst_proc_mn_nm     VARCHAR(120)
   ,@tstd_rtn_call      VARCHAR(250)
   ,@ty_code            VARCHAR(2)
   ,@txt                VARCHAR(500)
   ;
   BEGIN TRY
      EXEC sp_log 2, @fn, '';
      EXEC sp_log 2, @fn, @line2;
      ----------------------------------------------------------------------------------------------------------------------------
      -- Log paramaters
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '000: starting, getting cached rtn details';
      SELECT
          @qrn             = qrn
         ,@schema_nm       = schema_nm
         ,@rtn_nm          = rtn_nm
         ,@trn             = trn
         ,@cora            = cora
         ,@ad_stp          = ad_stp
--         ,@tst_mode        = tst_mode
--         ,@stop_stage      = stop_stage
         ,@hlpr_rtn_nm     = hlpr_rtn_nm
         ,@rtn_ty          = rtn_ty
         ,@rtn_ty_code     = rtn_ty
         ,@tst_proc_mn_nm  = tst_rtn_nm
      FROM test.RtnDetails;
      EXEC sp_log 2, @fn, '005: rtn details:
qrn        :[',@qrn  ,']
trn        :[',@trn ,']
cora       :[',@cora,']
ad_stp     :[',@ad_stp,']
tst_mode   :[',@tst_mode,']
stop_stage :[',@stop_stage,']
hlpr_rtn_nm:[', @hlpr_rtn_nm, ']
ty_code    :[', @ty_code, ']
rtn_ty     :[', @rtn_ty, ']'
;
      SET @stage = 1;
      EXEC sp_log 1, @fn, '010: clearing HlprDeftable;';
      TRUNCATE TABLE Test.TstDef;
      if @ad_stp = 1 INSERT INTO test.TstDef (line) VALUES ('-- sp_crt_tst_mn_script');
      -------------------------------------------------------------------------------
      -- Create the text header
      -------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '015: creating the text header';
      INSERT INTO test.TstDef (line)
      SELECT line
      FROM test.fnCrtCodeTstHdr(0); -- 0 = main tst rtn, 1 = hlpr rtn
      -------------------------------------------------------------------------------
      -- Create the mn tst sig
      -------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: creating the mn tst sig';
      INSERT INTO test.TstDef (line)
      SELECT line
      FROM fnCrtCodeMnTstSig();
      -------------------------------------------------------------------------------
      -- Create the AS BEGIN DECLARE bloc
      -------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '025: creating the As begin declare bloc';
      INSERT INTO TstDef (line) VALUES
         ('AS')
        ,('BEGIN')
        ,('DECLARE')
        --,(CONCAT(@tab1, '@fn VARCHAR(35) = ''T', @trn, '_',UPPER(@rtn_nm), '''')) -- @tst_proc_mn_nm
        ,(CONCAT(@tab1, '@fn VARCHAR(35) = ''',@tst_proc_mn_nm, '''')) -- 
        ,('')
        ,(CONCAT (@tab1, 'EXEC test.sp_tst_mn_st @fn;'))
        ,('')
        ,(CONCAT (@tab1, '-- 1 off setup  ??'))
      ;
      -------------------------------------------------------------------------------
      -- Create 1 helper call with dummy parameters
      -------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: creating 1 helper with dummy parameters';
      INSERT INTO test.TstDef (line)
      SELECT line FROM test.fnCrtMnCodeCallHlpr();
      -------------------------------------------------------------------------------
      -- Create the close bloc
      -------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '035: creating the close bloc';
      INSERT INTO test.TstDef (line)
      SELECT line FROM test.fnCrtMnCodeClose();
      -------------------------------------------------------------------------------
      -- Script completed
      -------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '900 script completed';
      EXEC sp_log 2, @fn, '910 displaying mn test script   ';
      SELECT * FROM test.TstDef;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, '500 Stage: ', @stage;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '999 leaving, OK';
END
/*
SELECT * FROM test.Rtndetails;
EXEC tSQLt.Run 'test].[test_012_sp_crt_tst_mn_compile';
EXEC tSQLt.RunAll;
*/
GO

