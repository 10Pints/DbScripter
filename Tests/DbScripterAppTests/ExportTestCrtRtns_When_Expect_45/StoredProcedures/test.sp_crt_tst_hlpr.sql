SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- ================================================================================================================================
-- Author:      Terry Watts
-- Create date: 09-Nov-2023
-- Description: creates a tSQLt test helper procedure from the data in test.RtnDetails and test.ParamDetails tables
--
-- Design: see EA ut/Use Case Model/Test Automation/Create Helper rotine Use case/Create the Helper routine_ActivityGraph
--
-- Algorithm:
-- Create the Helper script in the TstHlpr table
-- 
-- Create the helper procedure from the script 
--
-- OUTPUTS:
-- 1: populates table: test.tstActDefHlpr with the hlper creation sql script
--
-- Preconditions:
--    PRE01: test rtn details and param details tables populated
--
-- Algorithm:
-- Create the Helper script in a table
-- Create the Helper script file from the lines in teh tables
-- Compile the procedure from the script
--
-- Changes:
-- 231115: helper should have same defaults as the tstd rtn
-- 231121: @q_tstd_rtn must exist or exception 56472, '<@q_tstd_rtn> does not exist'
-- 231121: added a try catch handler to log errors
-- 231201: better tested exception handling
-- 231213: handle wonky []
-- 231216: add check for expected line for the given step id
-- 240402: refactor - split into subroutines
-- 240724: removed the compile feature as have difficulty in getting this to work programmatically
--         now manually copy paste from the test.TstHlpr table
-- ================================================================================================================================
CREATE PROCEDURE [test].[sp_crt_tst_hlpr]
   @folder    VARCHAR(500)
AS
BEGIN
   DECLARE 
    @fn                 VARCHAR(35)   = 'sp_crt_tst_hlpr'
   ,@hlpr_rtn_nm        VARCHAR(100)
   ,@script_file_path   VARCHAR(500) 
   ,@bckslsh            VARCHAR(1) = NCHAR(92)

   SET NOCOUNT ON;

   BEGIN TRY
      ----------------------------------------------------------------------------------------------------------------------------
      -- Init
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'000: starting';
      TRUNCATE TABLE Test.HlprDef;

      SELECT
         @hlpr_rtn_nm = hlpr_rtn_nm
      FROM test.RtnDetails;

      SET @script_file_path = CONCAT(@folder, @bckslsh, @hlpr_rtn_nm, '.sql');

      ---------------------------------------------------------------------------------
      -- Create the Helper script in the TstHlpr table
      ----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '010: Creating the script in the TstHlpr table: calling sp_crt_tst_hlpr_script';
      EXEC test.sp_crt_tst_hlpr_script;

      ----------------------------------------------------------------------------------
      -- Save the script to file
      ----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn, '020: Create the Helper script file';
      EXEC test.sp_crt_hlpr_script_file @script_file_path;

      ----------------------------------------------------------------------------------
      -- Processing complete 
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'800: Processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '999 leaving, OK';
END
/*
TRUNCATE TABLE APPLog
EXEC tSQLt.Run 'test.test_081_sp_crt_tst_hlpr';
EXEC tSQLt.RunAll;
*/



GO
