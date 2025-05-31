SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ===============================================================
-- Author:      Terry Watts
-- Create date: 08-JUL-2023
-- Description: Generates the SQL for sp_list_occurence_counts
--
-- CHANGES: 231006:fixed issue with field name convention change:
--   Staging 1 id field nme is 'id' Staging 2 id is 'id'
-- ===============================================================
ALTER FUNCTION [dbo].[fnCrtSqlForListOccurences]
(
    @table           NVARCHAR(100)
   ,@field           NVARCHAR(100)
   ,@where_clause    NVARCHAR(MAX)
   ,@len             INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
   DECLARE
      @nl            NVARCHAR(2) = NCHAR(13)+NCHAR(10)

   SET @len = @len + 5;  -- stop the     on the column hiding the end of the value

   SET @len = dbo.fnMin(32, @len);
   SET @where_clause = REPLACE(@where_clause, '#field#', @field);
   RETURN CONCAT(   -- , Count(s.id',iif(@table=N'staging1', '1','2'),N'_id) AS [count]
   N'SELECT', @nl, 
N'   S.[',@field,N'] AS [',LEFT( @table + N'.' + @field + Space(@len), @len)
,N'.]', @nl
,', Count(s.id) AS [count]
FROM
(
   SELECT DISTINCT [', @field, N']
   FROM [', @table, N']
   WHERE ', @where_clause, N'
) AS A
JOIN [', @table, N'] as S on A.[', @field, N'] = S.[', @field, N']
GROUP BY S.[', @field, N']
ORDER BY S.[', @field, N'] ASC;'
);
END
/*
DECLARE @where_clause VARCHAR(MAX)='([#field#] LIKE ''%(Direct-seeded) (Pre-germinated) rice%'' COLLATE Latin1_General_CI_AI )
   AND crops like ''%onio%''';
PRINT dbo.fnCrtSqlForListOccurences('staging1', 'crops', @where_clause, 25);
*/

GO
