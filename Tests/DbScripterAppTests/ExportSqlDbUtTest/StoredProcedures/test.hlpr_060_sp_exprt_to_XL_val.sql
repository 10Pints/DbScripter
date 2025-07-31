SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================================================
-- Author:           Terry Watts
-- Create date:      23-Nov-2023
-- Description:      test helper rtn for the sp_export_to_excel_validate rtn being tested
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
-- Tested rtn params: 
--    @table_nm     NVARCHAR(50),
--    @folder       NVARCHAR(260),
--    @workbook_nm  NVARCHAR(260),
--    @sheet_nm     NVARCHAR(50),
--    @view_nm      NVARCHAR(50),
--    @error_msg    NVARCHAR(200)
--========================================================================================
CREATE PROCEDURE [test].[hlpr_060_sp_exprt_to_XL_val]
   @table_nm     NVARCHAR(50),
   @folder       NVARCHAR(260),
   @workbook_nm  NVARCHAR(260),
   @sheet_nm     NVARCHAR(50),
   @view_nm      NVARCHAR(50),
--   @error_msg    NVARCHAR(200),
   @exp_ex       BIT = 0,
   @subtest      NVARCHAR(100)
AS
BEGIN
   DECLARE
       @fn                NVARCHAR(35)   = N'hlpr_060_sp_export_to_excel_validate'
--      ,@v                 
   EXEC sp_log 2, @fn, '01: starting, @subtest: ', @subtest;
---- SETUP:
   -- <TBD>
---- RUN tested rtn:
   EXEC sp_log 1, @fn, '04: running tested rtn: EXEC dbo.sp_export_to_excel_validate @table_nm,@folder,@workbook_nm,@sheet_nm,@view_nm,@error_msg;';
   IF @exp_ex = 1
   BEGIN
      BEGIN TRY
         -- Expect an exception here
         EXEC sp_log 2, @fn, '05: Expect an exception here';
         EXEC dbo.sp_exprt_to_XL_val @table_nm,@folder,@workbook_nm,@sheet_nm,@view_nm--,@error_msg;
         EXEC sp_log 4, @fn, '06: oops! Expected an exception here';
         THROW 51000, ' Expected an exception but none were thrown', 1;
      END TRY
      BEGIN CATCH
         EXEC sp_log 2, @fn, '07: caught expected exception';
      END CATCH
   END -- IF @exp_ex = 1
   ELSE
   BEGIN
      -- Do not expect an exception here
         EXEC sp_log 2, @fn, '08: Calling tested rtn: do not expect an exception now';
         EXEC dbo.sp_exprt_to_XL_val @table_nm,@folder,@workbook_nm,@sheet_nm,@view_nm--,@error_msg;
         EXEC sp_log 2, @fn, '09: Returned from tested rtn: no exception thrown';
   END -- ELSE -IF @exp_ex = 1
---- TEST:
      EXEC sp_log 2, @fn, '10: running tests...';
   -- <TBD>
      EXEC sp_log 2, @fn, '11: all tests ran OK';
---- CLEANUP:
   -- <TBD>
   EXEC sp_log 2, @fn, 'subtest ',@subtest, ': PASSED';
END
/*
   EXEC tSQLt.Run 'test.hlpr_060_sp_exprt_to_XL_validate';
*/
GO

