SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- =================================================
-- Author:		 Terry Watts
-- Create date: 08-JUL-2023
-- Description: Creates the SQL to
-- to list the rows in a table for the given id set
-- =================================================
ALTER FUNCTION [dbo].[fnGetIdsInTableForCriteriaSql]( 
    @table           NVARCHAR(100)
   ,@field           NVARCHAR(100)
   ,@where_clause    NVARCHAR(MAX)
   )
RETURNS NVARCHAR(MAX)
AS
BEGIN
RETURN CONCAT('SELECT TOP 500 A.[',@field,'] AS id   FROM
   (
      SELECT DISTINCT [', @field,']
      FROM  [',@table,']
      WHERE ',@where_clause,'
   ) AS A
   JOIN [',@table,'] S on A.[',@field,'] = S.[',@field,']
   ORDER BY A.[',@field,']'
);
END

/*
PRINT dbo.fnGetIdsInTableForCriteriaSql( 
    'Staging2'
   ,'stg2_id'
   ,'crops like ''%Mung%'''
   );

SELECT TOP 500 A.stg2_id AS id   FROM
   (
      SELECT DISTINCT [stg2_id]
      FROM  [Staging2]
      WHERE crops like '%Mung%'
   ) AS A
   JOIN [Staging2] S on A.[stg2_id] = S.[stg2_id]
   ORDER BY A.stg2_id

*/

GO
