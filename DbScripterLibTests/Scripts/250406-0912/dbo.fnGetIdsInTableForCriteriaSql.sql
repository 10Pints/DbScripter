SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================
-- Author:      Terry Watts
-- Create date: 08-JUL-2023
-- Description: Creates the SQL to
-- to list the rows in a table for the given id set
-- =================================================
ALTER   FUNCTION [dbo].[fnGetIdsInTableForCriteriaSql]( 
    @table           VARCHAR(100)
   ,@field           VARCHAR(100)
   ,@where_clause    VARCHAR(MAX)
   )
RETURNS VARCHAR(MAX)
AS
BEGIN
RETURN CONCAT('SELECT TOP 500 A.[',@field,'] AS id
   FROM
   (
      SELECT DISTINCT [', @field,']
      FROM  [',@table,']
      WHERE ',@where_clause,'
   ) AS A
   JOIN [',@table,'] S on A.[',@field,'] = S.[',@field,']
   ORDER BY A.[',@field,']'
);
END


GO
