SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Terry Watts
-- Create date: 24-DEC-2019
-- Description:	produces a comma separated list of column names from a table or view
-- =============================================
CREATE FUNCTION [dbo].[fnGetColumnNames] 
(
   @table_or_view NVARCHAR(80)
)
RETURNS NVARCHAR(2000)
AS
BEGIN
   -- Declare the return variable here
   DECLARE @columns NVARCHAR(2000)
   
   -- Get the data from a view if supplied, else the raw table data
   SELECT @columns = CONCAT(@columns,',', column_name) -- + column_name
   FROM   INFORMATION_SCHEMA.COLUMNS
   WHERE  table_name = @table_or_view
   
   -- Remove the first comma
   RETURN SUBSTRING(@columns, 2, LEN(@columns)-1)
END
GO

