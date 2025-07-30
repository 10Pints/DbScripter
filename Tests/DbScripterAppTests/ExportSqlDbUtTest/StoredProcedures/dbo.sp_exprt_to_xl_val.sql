SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 27-DEC-2019
-- Description: validaes and corrects procedure sp_export_to_excel parameters
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
-- POSTCONDITIONS
-- returns  1 if OK
--            if error throw exception 50102with msg
-- =============================================
CREATE PROCEDURE [dbo].[sp_exprt_to_xl_val]
       @tbl_spec  NVARCHAR(50)
      ,@folder    NVARCHAR(260)
      ,@wrkbk_nm  NVARCHAR(260)  OUTPUT
      ,@sht_nm    NVARCHAR(50)   OUTPUT
      ,@vw_nm     NVARCHAR(50)   OUTPUT
AS
BEGIN
   DECLARE
       @fn        NVARCHAR(30)   =   'sp_exprt_to_xl_val'
      ,@err_msg   NVARCHAR(200)
   EXEC sp_log 2, @fn, 'starting';
   WHILE 1=1
   BEGIN
      -- Validation
      IF @tbl_spec IS NULL OR LEN(@tbl_spec)=0
      BEGIN
         SET @err_msg = 'table must be specified';
         BREAK;
      END
      IF ut.dbo.fnTableExists(@tbl_spec) = 0
      BEGIN
         SET @err_msg = 'unknown table';
         BREAK;
      END
      IF @folder IS NULL OR LEN(@folder)=0
      BEGIN
         SET @err_msg = 'folder must be specified';
         BREAK;
      END
      IF dbo.fnFolderExists(@folder) = 0
      BEGIN
         SET @err_msg = 'folder does not exist';
         BREAK;
      END
      -- set paramter defaults as needed
      -- file name = <table>.xlsx
      IF @wrkbk_nm IS NULL OR LEN(@wrkbk_nm)=0
         SET @wrkbk_nm = CONCAT(@tbl_spec, '.xlsx');
      -- view: = <table>View
      IF @vw_nm IS NULL OR LEN(@vw_nm)=0
         SET @vw_nm = CONCAT(@tbl_spec, 'View');
      IF ut.dbo.fnCheckViewExists(@vw_nm, 'dbo') = 0
      BEGIN
         SET @err_msg = CONCAT('unknown view: [', @vw_nm, ']')
         BREAK;
      END
      -- @sht_nm = <table>
      IF @sht_nm IS NULL OR LEN(@vw_nm)=0
         SET @sht_nm = @tbl_spec;
      BREAK;
   END -- WHILE 1=1
   -- If error throw exception 50102with msg
   IF @err_msg IS NOT NULL
   BEGIN
   EXEC sp_log 4, @fn, 'validation failed: throwing exception 50102, ', @err_msg;
      ;THROW 50102, @err_msg, 1
   END
   EXEC sp_log 2, @fn, '99: leaving OK';
   RETURN 1 -- OK
END
GO

