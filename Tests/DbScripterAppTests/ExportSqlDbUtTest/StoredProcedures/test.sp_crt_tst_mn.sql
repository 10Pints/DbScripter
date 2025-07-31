SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================================================================
-- Author:      Terry Watts
-- Create date: 20-NOV-2023
-- Description: Creates the main test rtn in the database
--    first it creates the SQL script in the TestDef table
--    then uses that script to compile the stored procedure in the db
--
-- Preconditions
--    test.RtnDetails and Test.ParamDetails pop'd
--
-- Postconditions:                     EX 58100 'Failed to compile '
-- POST 01: script exists in databse - check delegated to sp_crt_tst_mn_compile
--
-- Algorithm:
-- Get the rtn details if necessary
-- Create  the script
-- Compile the script
--
-- Tests:
--    test_066_sp_crt_tst_mn
--    test_067_sp_crt_tst_mn
--
-- Changes:
-- 231121: @qrn must exist or exception 56472, '<@qrn> does not exist'
-- 231121: added a try catch handler to log errors
-- 240406: redesign see EA: ut/Model/Use Case Model/Test Automation
-- 240724: removed the compile ferature as have difficulty in getting this to work programmatically
--         now manually copy paste from the test.TstDef table
-- =====================================================================================================================
CREATE PROCEDURE [test].[sp_crt_tst_mn]
   @folder    NVARCHAR(500)
AS
BEGIN
   DECLARE 
    @fn                 NVARCHAR(35)   = 'sp_crt_tst_mn'
   ,@tst_rtn_nm         NVARCHAR(60)
   ,@script_file_path   NVARCHAR(500) 
   SET NOCOUNT ON;
   BEGIN TRY
      ----------------------------------------------------------------------------------------------------------------------------
      -- Init
      ----------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'000: starting';
      TRUNCATE TABLE Test.TstDef;
      SELECT
         @tst_rtn_nm = tst_rtn_nm
      FROM test.RtnDetails;
      SET @script_file_path = CONCAT(@folder, '\', @tst_rtn_nm, '.sql');
      ---------------------------------------------------------------------------------
      -- Create the main script in the TstDef table-
      ----------------------------------------------------------------------------------
      EXEC sp_log 2, @fn,'010: Creating the script in the TstDef table: calling sp_crt_tst_mn_script';
      EXEC test.sp_crt_tst_mn_script;
      ----------------------------------------------------------------------------------
      -- Save the script to file
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn,'020: Save the script to file';
      EXEC test.sp_crt_mn_script_file @script_file_path;
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
EXEC tSQLt.Run 'test.test_066_sp_crt_tst_mn';
EXEC tSQLt.Run 'test.test_067_sp_crt_tst_mn';
EXEC tSQLt.RunAll;
*/
GO

