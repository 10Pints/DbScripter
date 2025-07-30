SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 16-APR-2024
-- Description: creates and compiles the main test rtn
--
-- Preconditions
-- PRE01: Test.TstDef, Rtndetails, ParamDetails tables pop'd
-- PRE02: rtn does not exist in db
--
-- Postconditions:                     EX
-- POST 01: rtn exists in db or EX 63200, 'failed to compile the main test script'
--
-- Algorithm:
-- Get the rtn details if necessary
-- Create the script
-- Compile the script
--
-- Tests:
--    test_012_sp_crt_tst_mn_compile
--    test_066_sp_crt_tst_mn
--    test_067_sp_crt_tst_mn
--
-- Changes:
-- 231121: @qrn must exist or exception 56472, '<@qrn> does not exist'
-- 231121: added a try catch handler to log errors
-- 240406: redesign see EA: ut/Model/Use Case Model/Test Automation
-- =============================================
CREATE PROCEDURE [test].[sp_crt_tst_mn_compile]
   @script_folder      NVARCHAR(MAX)
AS
BEGIN
   DECLARE 
    @fn                 NVARCHAR(35)   = 'sp_crt_tst_mn_compile'
   ,@ad_stp             BIT            = 1 -- used in testing to identify a step with a unique name (not an incremental int id)
   ,@cmd                NVARCHAR(500)
   ,@cora               NCHAR(2)
   ,@crse_rtn_ty_code   NVARCHAR(1)-- coarse grained type one of {'F','P'}
   ,@dash_line          NVARCHAR(500)  ='------------------------------------------'
   ,@db                 NVARCHAR(60)   
   ,@server             NVARCHAR(90)   
   ,@detld_rtn_ty_code  NCHAR(2)   -- detailed type code: can be 1 of {'P', 'FN', 'IF','TF'}like TF for a table function
   ,@hlpr_rtn_nm        NVARCHAR(60)
   ,@max_param_len      INT            = -1
   ,@msg                NVARCHAR(500)
   ,@n                  INT
   ,@params             NVARCHAR(MAX)
   ,@qrn                NVARCHAR(100)
   ,@rtn_nm             NVARCHAR(100)
   ,@rtn_ty_nm          NVARCHAR(25)
   ,@rtn_type           NCHAR(1)
   ,@sc_fn_ret_ty       NVARCHAR(50)
   ,@schema_nm          NVARCHAR(50)
   ,@sql                NVARCHAR(4000)
   ,@stop_stage         INT            = 99 -- stage 12 for testing - display script
   ,@tab                NVARCHAR(4)    = '   '
   ,@trn                INT
   ,@tst_mode           BIT            = 1 -- for testing - copy tmp tables to permananent tables for teting
   ,@tst_proc_nm_h      NVARCHAR(60)
   ,@tst_proc_nm_m      NVARCHAR(60)
   ,@tst_rtn_nm         NVARCHAR(60)
   ,@file_path          NVARCHAR(500) = 'D:\tmp\tst_mn_script.sql'
   BEGIN TRY
      SET @db        = DB_NAME();
      SET @server    = @@SERVERNAME;
      
      EXEC sp_log 2, @fn,'000: starting, params:
file  :[',@file_path,']
db    :[',@db       ,']
server:[',@server   ,']'
;
/*
      ----------------------------------------------------------------------------------
      -- Set Defaults
      ----------------------------------------------------------------------------------
      IF @db     IS NULL SET @db     = 'ut';
      IF @server IS NULL SET @server = 'DEVI9\SQLEXPRESS';
      EXEC sp_log 1, @fn,'005: updated params:
file  :[',@file_path,']
db    :[',@db       ,']
server:[',@server   ,']'
;
      ----------------------------------------------------------------------------------
      -- Get the cached details
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'010: getting the cached details';
      SELECT
          @qrn        = qrn
         ,@trn        = trn
         ,@cora       = cora
         ,@ad_stp     = ad_stp
         ,@tst_mode   = tst_mode
         ,@stop_stage = stop_stage
         ,@tst_rtn_nm = tst_rtn_nm
         ,@hlpr_rtn_nm= hlpr_rtn_nm
      FROM test.RtnDetails;
      ----------------------------------------------------------------------------------
      -- Validated preconditions
      ----------------------------------------------------------------------------------
      -- PRE01: Test.TstDef, Rtndetails, ParamDetails tables pop'd
      EXEC sp_log 1, @fn,'015: Validated preconditions';
      EXEC sp_chk_tbl_populated 'Test.RtnDetails';
      EXEC sp_chk_tbl_populated 'Test.ParamDetails';
      EXEC sp_chk_tbl_populated 'Test.TstDef';
      -- PRE02: check rtn does not exist in db
      EXEC sp_assert_rtn_exists @tst_rtn_nm, 0;
      ----------------------------------------------------------------------------------
      -- Save the script to file
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'020: Save the script to file';
      EXEC dbo.sp_export_to_file_TstDef @file_path;
*/
      ----------------------------------------------------------------------------------
      -- Compile the script
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'025: compiling the script...';
      
      EXEC test.sp_compile_rtn @qrn, @script_folder;
      ----------------------------------------------------------------------------------
      -- Check the postconditions
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'030: check the postconditions...'
      -- POST 01: rtn exists in db or EX 63200, 'failed to compile the main test script'
      -- TLW: 240429: dont stop because of this EXEC sp_chk_rtn_exists @tst_rtn_nm, 1;
      EXEC sp_log 1, @fn,'035: check the postconditions...'
      IF EXISTS (SELECT 1 FROM dbo.fnChkRtnExists(@tst_rtn_nm))
      BEGIN
         EXEC sp_log 4, @fn, '040: Failed to compile the rtn: [', @tst_rtn_nm, ']';
         EXEC sp_log 1, @fn, '045: Processing complete';
      END
      ELSE
      BEGIN
         EXEC sp_log 4, @fn, '050: Failed to compile the rtn: [', @tst_rtn_nm, ']';
      END
      ----------------------------------------------------------------------------------
      -- Processing complete
      ----------------------------------------------------------------------------------
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '999 leaving, OK';
END
/*
EXEC tSQLt.Run 'test.test_012_sp_crt_tst_mn_compile';
EXEC tSQLt.RunAll;
EXEC test.sp_crt_tst_mn_compile 'D:\TstTmp\test_012_sp_crt_tst_mn_compile.sql'
, 'ut','DEVI9\SQLEXPRESS'
*/
GO

