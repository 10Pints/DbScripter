SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 26-OCT-2019
-- Description: Creates an Excel xls file as a TSV
-- N.B.: It needs to be loaded by Excel to actual make a .xls formatted file, however
-- Excel will open a CSV or TSV as an Excel file with a warning prompt
--
-- Process:
--  Validate parameters
--      Mandatory parameters
--          table name
--          folder
--
--  set paramter defaults as needed
--      file name       <table>.xlsx
--      sheet_name:     <table>
--      view:           <table>View
--      timestamp:      <current time and date> Fprmat YYMMDD-HHmm
-- =============================================
CREATE PROCEDURE [dbo].[sp_exprt_to_xl]
       @tbl_spec     NVARCHAR(50)
      ,@folder       NVARCHAR(260)
      ,@wrkbk_nm     NVARCHAR(260)  = NULL
      ,@sht_nm       NVARCHAR(50)   = NULL
      ,@vw_nm        NVARCHAR(50)   = NULL
      ,@filter       NVARCHAR(MAX)  = NULL
      ,@crt_tmstmp   BIT            = 1
      ,@max_rows     INT            = NULL
AS
BEGIN
   DECLARE
       @fn           NVARCHAR(30)   = 'EXPRT TO XL'
      ,@Line         NVARCHAR(102)  =  CONCAT(REPLICATE('-', 100), NCHAR(13), NCHAR(10))
      ,@sql          NVARCHAR(MAX)
      ,@backslash    NCHAR          = NCHAR(92)
      ,@columns      NVARCHAR(MAX)
      ,@err_msg      NVARCHAR(200)
      ,@ndx          INT
      ,@opnRwStSql   NVARCHAR(MAX)
      ,@rc           INT
      ,@srvr_nm      NVARCHAR(100)
      ,@tmstmp       NVARCHAR(30)
      ,@xl_fle_pth   NVARCHAR(260)
   EXEC sp_log 2, @fn,  '01: starting'
   -- Validate
   EXEC @rc = dbo.sp_exprt_to_xl_val 
          @tbl_spec   = @tbl_spec
         ,@folder     = @folder
         ,@wrkbk_nm   = @wrkbk_nm OUT
         ,@sht_nm     = @sht_nm   OUT
         ,@vw_nm      = @vw_nm  OUT
   IF @rc = 0
   BEGIN
      ;THROW 50306, @err_msg, 1
   END
   SET @ndx = CHARINDEX('.xls', @wrkbk_nm)
   IF @ndx > 0
      SET @wrkbk_nm = SUBSTRING(@wrkbk_nm, 1, @ndx-1)
   IF @crt_tmstmp = 1
   BEGIN
      -- timestamp= <current time and date> Format YYMMDD-HHmm
      SET @xl_fle_pth = CONCAT(@folder, @backslash, @wrkbk_nm, ' ', ut.dbo.fnGetTimestamp(NULL), '.xlsx')
   END
   ELSE
   BEGIN
      SET @xl_fle_pth = CONCAT(@folder, @backslash, @wrkbk_nm, '.xlsx')
   END
   -- Create an .xlsx file containing the column header
   SET @columns = ut.dbo.fnGetColumnNames(@vw_nm)
   PRINT @columns
   SET @sql = CONCAT('EXEC master..xp_cmdshell ''CreateExcelFile.exe  "', @xl_fle_pth, '" "', @sht_nm, '" "', @columns, '" ''');
   PRINT @sql
   EXEC (@sql)
   EXEC @opnRwStSql = ut.dbo.fnGetOpenRowSetXL_SQL @xl_fle_pth, @sht_nm
   -- Add in the TOP n rows clause if specified
   SET @sql = CASE 
               WHEN @max_rows IS NULL 
                  THEN CONCAT('INSERT INTO ', @opnRwStSql, ' SELECT ',                   @columns, ' FROM ', @vw_nm)
                  ELSE CONCAT('INSERT INTO ', @opnRwStSql, ' SELECT TOP ',@max_rows,' ', @columns, ' FROM ', @vw_nm)
               END
   -- Add in the filter and order by clause if specified
   IF @filter IS NOT NULL
      SET @sql = CONCAT(@sql,' ', @filter);
   PRINT @sql
   EXEC (@sql)
   EXEC sp_log 2, @fn,  '99: leaving OK'
END
GO

