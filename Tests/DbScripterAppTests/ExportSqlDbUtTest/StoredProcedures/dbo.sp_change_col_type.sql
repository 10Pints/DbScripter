SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry watts
-- Create date: 27-APR-2020
-- Description: Changes a column type in a table if necessary
-- =============================================
CREATE PROCEDURE [dbo].[sp_change_col_type]
         @table_name        NVARCHAR(60)
      ,@col_nm            NVARCHAR(60)
      ,@col_ty            NVARCHAR(60)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
         @sql               NVARCHAR(MAX)
   SET @sql = CONCAT('IF EXISTS (Select 1 FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE TABLE_NAME = ''', @table_name,''' 
   AND COLUMN_NAME  = ''', @col_nm, '''
   AND DATA_TYPE <> ''',@col_ty,''')
   ALTER TABLE [', @table_name, '] ALTER COLUMN [',@col_nm,'] ',@col_ty,';');
   PRINT @sql;
   EXEC sp_executesql @sql;
END
GO

