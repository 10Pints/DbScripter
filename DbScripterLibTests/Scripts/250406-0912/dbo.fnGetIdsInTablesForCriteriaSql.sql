SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===================================================================
-- Author:      Terry Watts
-- Create date: 08-JUL-2023
-- Description: Creates the SQL to list the UNION all ids
--   matching the where clause in the 2 tables
--
-- CHANGES:
--   231006: fixed issue with field name convention change:
--   Staging 1 id field nme is 'id' Staging 2 id is' id'
-- ===================================================================
ALTER FUNCTION [dbo].[fnGetIdsInTablesForCriteriaSql]
(
    @table1       NVARCHAR(100)
   ,@field1       NVARCHAR(100)
   ,@table2       NVARCHAR(100)
   ,@field2       NVARCHAR(100)
   ,@where_clause NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
   RETURN CONCAT
   (
   N'SELECT @ids = STRING_AGG(CAST(id AS VARCHAR(MAX)), '','')
   FROM
(
   ', dbo.fnGetIdsInTableForCriteriaSql(@table1, @field1, @where_clause), N'
   UNION
   ', dbo.fnGetIdsInTableForCriteriaSql(@table2, @field2, @where_clause), N'
) X'
   )
END
/*
PRINT [dbo].[fnGetIdsInTablesForCriteriaSql]('Staging2', 'id','Staging1','id', 'crops like ''%Mung%''');
*/


GO
