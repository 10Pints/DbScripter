SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 29-OCT-2019
-- Description: gets the range in an excel worksheet
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_xl_range]
       @workbook_path   NVARCHAR(260)
      ,@sheet           NVARCHAR(25)        =   'Sheet1'
      ,@num_rows        INT             OUTPUT
AS
BEGIN
   DECLARE
       @fn              NVARCHAR(30)    = 'GETXLRNG                     : '
      ,@error_msg       NVARCHAR(500)
      ,@sql             NVARCHAR(4000)
      ,@range           NVARCHAR(50)
      ,@openRowSetSql   NVARCHAR(2000)
   BEGIN TRY
      EXEC sp_log 1, @fn, 'starting';
      DROP TABLE IF EXISTS tmpTbl;
      SET @range = CONCAT(@sheet,'$', 'A1:AK3');
      SET @openRowSetSql = dbo.fnGetOpenRowSetXL_SQL(@workbook_path, @range, '*', 'HDR=NO;IMEX=1');
      SET @sql = CONCAT('SELECT * INTO tmpTbl FROM ', @openRowSetSql);
      EXEC sp_executesql @sql;
      SET @num_rows = (SELECT Top 1 F1 FROM tmpTbl);
   END TRY
   BEGIN CATCH
      SET @error_msg = dbo.fnGetErrorMsg();
      EXEC sp_log 4, @fn, 'Error: ', @error_msg;
      THROW;
   END CATCH
   EXEC sp_log 1, @fn, 'leaving OK';
END
/*
*/
GO

