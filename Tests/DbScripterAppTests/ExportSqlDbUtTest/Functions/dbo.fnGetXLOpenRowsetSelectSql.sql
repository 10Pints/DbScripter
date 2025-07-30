SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 09-SEP-2019
-- Description: 
-- RETURNS: sql to select columns from an open rowset to and Excel range (or worksheet) 
--  or NULL if XL file not found
-- =============================================
CREATE FUNCTION [dbo].[fnGetXLOpenRowsetSelectSql]
(
          @workbook_path             NVARCHAR(260)
         ,@range                     NVARCHAR(50)            -- can be a range or a sheet
         ,@select_cols               NVARCHAR(2000)          -- select column names for the insert to the table: can apply functions to the columns at this point
         ,@xl_cols                   NVARCHAR(2000) = '*'    -- XL column names: can be *
         ,@extension                 NVARCHAR(50)   = ''     -- e.g. 'HDR=NO;IMEX=1'
         ,@where_clause              NVARCHAR(2000) =''      -- Where clause like "WHERE province <> ''"  or ""
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE
       @sql                       NVARCHAR(4000)
      ,@open_rowset_clause        NVARCHAR(MAX)
      ,@NL                        NVARCHAR(2)     = NCHAR(13)+NCHAR(10)
   -- Get the open rowset SQL 
   SET @open_rowset_clause = UT.dbo.fnGetOpenRowSetXL_SQL(@workbook_path, @range, @xl_cols, @extension)
   -- Return NULL if XL workbook file not found
   IF @open_rowset_clause IS NULL
      RETURN NULL
   -- Create the selct<cols> from the open rowset clause 
   SET @sql = CONCAT('SELECT ', @select_cols, CHAR(10), 'FROM ', @open_rowset_clause, ' ',@where_clause);       -- Where clause like "WHERE province <> ''
   -- return sql to select columns from an open rowset to and Excel range 
   RETURN @sql
END
GO

