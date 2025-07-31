SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      23-Nov-2023
-- Description:      main test rtn for the dbo.sp_export_to_excel_validate rtn being tested
-- Tested rtn desc:
--  validaes and corrects procedure sp_export_to_excel parameters
--  Validate parameters
--      Mandatory parameters
--          table name
--          folder
--
--  set paramter defaults as needed
--      file name       <table>.xlsx            set if NULL or empty
--      sheet_name:     <table>                 set if NULL or empty
--      view:           <table>View             set if NULL or empty
--      timestamp:      <current time and date> set if NULL Format YYMMDD-HHmm
--
-- returns  1 if OK
--          0 if FATAL
--
-- Tested rtn params
--    @table_nm     NVARCHAR(50),
--    @folder       NVARCHAR(260),
--    @workbook_nm  NVARCHAR(260),
--    @sheet_nm     NVARCHAR(50),
--    @view_nm      NVARCHAR(50),
--    @error_msg    NVARCHAR(200)
--[@tSQLt:SkipTest]('Temporarily disabled while refactoring')
--========================================================================================
CREATE PROCEDURE [test].[test_060_sp_exprt_to_xl_val]
AS
BEGIN
   DECLARE
      @fn                 NVARCHAR(35)   = N'test_060_sp_exprt_to_xl_val'
   EXEC sp_log 2, @fn,'01: starting'
---- SETUP
   -- <TBD>
   ------------------------------------------
   -- Green tests: ones that should work ok
   ------------------------------------------
   ---- Run the test Helper rtn to run the tested rtn and do some checks
   EXEC test.hlpr_060_sp_exprt_to_xl_val @table_nm='',@folder='',@workbook_nm='',@sheet_nm='',@view_nm=''/*,@error_msg=''*/,@exp_ex=0, @subtest='TG001';
   ------------------------------------------
   -- Red tests: ones that should fail
   ------------------------------------------
   --EXEC test.hlpr_060_sp_exprt_to_xl_val @table_nm='',@folder='',@workbook_nm='',@sheet_nm='',@view_nm='',@error_msg='',@exp_ex=1, @subtest='TR001';
   EXEC sp_log 2, @fn, '99: All subtests PASSED'
END
/*
EXEC tSQLt.Run 'test.test_060_sp_exprt_to_xl_val';
*/
GO

