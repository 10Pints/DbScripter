SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 12-JAN-2020
-- Description: wraps the openrowset for excel to make it easier to use
--
-- checks the file exists, exception if not throws exception 52587, 'invalid workbook file path', 1
--
-- returns a sql substring that can be used to open a rowset to an Excel range
-- LIKE OPENROWSET ( 'Micro' ... @extension,' Database=', @workbook_path SELECT ', @xl_cols 
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_get_open_rowset]
       @workbook_path   NVARCHAR(260)
      ,@sheet           NVARCHAR(50)   = 'Sheet1$'
      ,@xl_cols         NVARCHAR(2000) = '*'        -- select XL column names: can be *
      ,@extension       NVARCHAR(50)   = NULL       -- default: 'HDR=NO;IMEX=1'
      ,@open_clause     NVARCHAR(MAX)   OUT
AS
BEGIN
   -- check path exists
   SET @open_clause = dbo.fnGetOpenRowSetXL_SQL
   (
       @workbook_path
      ,@sheet
      ,@xl_cols
      ,@extension
   )
   IF @open_clause IS NULL
      THROW 52587, 'invalid workbook file path', 1
END
GO

