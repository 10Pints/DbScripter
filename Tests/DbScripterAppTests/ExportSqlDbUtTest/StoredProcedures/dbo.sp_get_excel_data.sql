SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: <Create Date, ,>
-- Description: Returns SQL to execute to open an excel sheet
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_excel_data]
          @xls_workbook              NVARCHAR(260)
         ,@sheet                     NVARCHAR(50)    = 'Sheet1'
         ,@select_cols               NVARCHAR(2000)  = '*'       -- select column names for the insert to the table: can apply functions to the columns at this point
         ,@xl_cols                   NVARCHAR(2000)  = '*'       -- XL column names: can be *
         ,@whereClause               NVARCHAR(2000)  =''         -- Where clause like "WHERE province <> ''"  or ""
         ,@extension                 NVARCHAR(50)     -- e.g. HDR=NO;IMEX=1
         ,@sql                       NVARCHAR(4000)  = ''    OUTPUT -- the sql to execute
--         ,@SQL2 NVARCHAR(4000) OUTPUT
--         ,@SQL3 NVARCHAR(4000) OUTPUT -- IN/OUT
--         ,@SQL4 NVARCHAR(4000) -- not an output param
AS
BEGIN
   SET @sql = CONCAT('SELECT ', @select_cols, CHAR(10), 'FROM ', dbo.fnGetOpenRowSetXL_SQL(@xls_workbook, @sheet, @xl_cols, @extension));                                                    -- Where clause like "WHERE province <> ''
END
/*
exec tSQLt.RunAll;
EXEC sp_get_excel_data;
*/
GO

