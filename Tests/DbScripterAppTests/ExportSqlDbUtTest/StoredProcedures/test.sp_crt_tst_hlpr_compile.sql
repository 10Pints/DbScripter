SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================
-- Author:      Terry Watts
-- Create date: 15-APR-2024
-- Description: Creates the test helper rtn from a SQL script
--
-- PRECONDITIONS:
--    PRE01: @file_path contains the script to compile
--    PRE02: @tst_rtn_nm specified
--    PRE03: rtn does not exist in db initially
--
-- POSTCONDITIONS:
-- POST 01: helper procedure created or Exception 69000, 'Failed to create the helper routine from the script', 1
--
-- ALGORIHM:
-- Validate preconditions
-- Compile the script file
-- Validate postconditions
-- 
-- Changes:
-- ==================================================================
CREATE PROCEDURE [test].[sp_crt_tst_hlpr_compile]
    @script_file_path   NVARCHAR(500)
   ,@hlpr_rtn_nm        NVARCHAR(60)
AS
BEGIN
   DECLARE
     @fn          NVARCHAR(35)   = 'sp_crt_tst_hlpr_compile'
    ,@cmd         VARCHAR(8000)
    ,@qrn         NVARCHAR(100)
   SET NOCOUNT ON;
   BEGIN TRY
      EXEC sp_log 2, @fn,'000: starting, params:
file       :[',@script_file_path  ,']
hlpr_rtn_nm:[',@hlpr_rtn_nm,']'
;
 
      --------------------------------------------
      -- Validate preconditions
      --------------------------------------------
      EXEC sp_log 1, @fn,'020: Validating preconditions';
      --    PRE01: @file_path contains the script to compile
      EXEC sp_log 1, @fn,'030:chk script file exists...';
      EXEC sp_assert_file_exists @script_file_path, 'script file [', @script_file_path,'] does not exist';
      EXEC sp_log 1, @fn,'040:chk @hlpr_rtn_not null or empty...';
      EXEC sp_assert_not_null_or_empty @hlpr_rtn_nm;
      -- PRE03: rtn does not exist in db
      EXEC sp_log 1, @fn,'050:chk ',@hlpr_rtn_nm, ' does not exist initially...';
      EXEC sp_assert_rtn_exists @hlpr_rtn_nm, 0;
      SET @qrn = CONCAT('test', @hlpr_rtn_nm);
      --------------------------------------------
      -- Process: Compile the script file
      --------------------------------------------
      EXEC sp_log 1, @fn,'070: Compiling the script file';
      EXEC test.sp_compile_rtn  @qrn, @script_file_path;
      --------------------------------------------
      -- Validate postconditions
      --------------------------------------------
      EXEC sp_log 1, @fn,'080: Validating postconditions';
      EXEC sp_log 1, @fn,'080: chkling rtn exists';
      EXEC sp_assert_rtn_exists @hlpr_rtn_nm, 1, 'Failed to create the helper routine from the script';
      --------------------------------------------
      -- Processing complete
      --------------------------------------------
      EXEC sp_log 1, @fn,'900: Processing complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH
   EXEC sp_log 2, @fn, '999 leaving, OK';
END
/*
EXEC test.sp__crt_tst_rtns ''
EXEC tSQLt.Run 'test.test_081_sp_crt_tst_hlpr';
SELECT * FROM [test].[HlprDef]
EXEC tSQLt.RunAll;
*/
GO

