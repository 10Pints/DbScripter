SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:		 Terry Watts
-- Create date: 08-JUL-2023
-- Description: Generates the SQL for sp_list_occurence_counts
--
-- CHANGES: 231006:fixed issue with field name convention change:
--   Staging 1 id field nme is 'stg1_id' Staging 2 id is' stg2_id'
-- ===============================================================
ALTER FUNCTION [dbo].[fnCrtSqlForListOccurences]
(
    @table           NVARCHAR(100)
   ,@field           NVARCHAR(100)
   ,@where_clause    NVARCHAR(MAX)
   ,@len             INT
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   DECLARE 
      @nl            NVARCHAR(1) = NCHAR(0x0d)

   SET @len = @len + 5;  -- stop the ... on the column hiding the end of the value
   SET @where_clause = REPLACE(@where_clause, '#field#', @field);
	RETURN CONCAT( 
   'SELECT', @nl, 
'   S.[',@field,'] AS [',LEFT( @table + '.' + @field + Space(@len), @len),'.]
, Count(s.stg',iif(@table='staging1', '1','2'),'_id) AS [count]
FROM
(
   SELECT DISTINCT [', @field,']
   FROM [', @table,']
   WHERE ', @where_clause,'
) AS A
JOIN [', @table,'] as S on A.[', @field,'] = S.[', @field,']
GROUP BY S.[', @field,']
ORDER BY S.[', @field,'] ASC;'
);
END

/*
DECLARE @where_clause NVARCHAR(MAX)='([#field#] LIKE ''%(Direct-seeded) (Pre-germinated) rice%'' COLLATE Latin1_General_CI_AI )   AND crops like ''%onio%''';
PRINT dbo.fnCrtSqlForListOccurences('staging1', 'crops', @where_clause, 25);

GO
SELECT   S.[crops] AS [staging2.crops                .]
, Count(s.id) AS [count]
FROM
(
   SELECT DISTINCT [crops]
   FROM [staging2]
   WHERE ([crops] LIKE     '%(Direct-seeded) (Pre-germinated) rice%' COLLATE Latin1_General_CI_AI )   AND crops like '%onio%'
) AS A
JOIN [staging2] as S on A.[crops] = S.[crops]
GROUP BY S.[crops]
ORDER BY S.[crops] ASC;
*/

GO
