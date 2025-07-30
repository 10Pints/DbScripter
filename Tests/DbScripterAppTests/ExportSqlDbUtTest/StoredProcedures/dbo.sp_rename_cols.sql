SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 27-APR-2020
-- Description: Renames a column in a table
-- =============================================
CREATE PROCEDURE [dbo].[sp_rename_cols]
         @table_name        NVARCHAR(60)
      ,@old_col_nm        NVARCHAR(60)
      ,@new_col_nm        NVARCHAR(60)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
         @sql               NVARCHAR(MAX)
   SET @sql = CONCAT('IF EXISTS (Select 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''',@table_name,'''  
   AND COLUMN_NAME = ''', @old_col_nm, ''')
   EXEC sp_rename ''',@table_name,'.',@old_col_nm,''', ''', @new_col_nm, ''',''COLUMN''');
   PRINT @sql;
   EXEC sp_executesql @sql;
END
GO

