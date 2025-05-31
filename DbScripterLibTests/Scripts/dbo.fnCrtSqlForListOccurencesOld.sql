SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
ALTER FUNCTION [dbo].[fnCrtSqlForListOccurencesOld]
(
    @table           NVARCHAR(100)
   ,@field           NVARCHAR(100)
   ,@where_clause    NVARCHAR(MAX)
)
RETURNS  NVARCHAR(MAX)
AS
BEGIN
   DECLARE 
      @nl            NVARCHAR(1) = NCHAR(0x0d)
     ,@len1           INT
     ,@len2           INT
     ,@len            INT

   SELECT @len1 =MAX(ut.dbo.fnLen([Pathogens]))
   FROM
   (
   SELECT DISTINCT [Pathogens]
      FROM Staging1
      WHERE [Pathogens] LIKE     '%As surfactant%'
   ) R;

   SELECT @len2 = MAX(ut.dbo.fnLen([Pathogens]))
   FROM
   (
   SELECT DISTINCT [Pathogens]
      FROM Staging1
      WHERE [Pathogens] LIKE     '%As surfactant%'
   ) R;

   SET @len = iif(@len1>@len2, @len1, @len2);

   SET @where_clause = REPLACE(@where_clause, '#field#', @field);
	RETURN CONCAT( 
   'SELECT', @nl, 
'   S.pathogens
, Count(s.id) AS [count]
FROM
(
   SELECT DISTINCT [', @field,']
   FROM [', @table,']
   WHERE ', @where_clause,'
) AS A
JOIN [', @table,'] as S on A.[', @field,'] = S.[', @field,']
GROUP BY S.[', @field,']
ORDER BY S.[', @field,'] ASC;
-- @len1:',@len1,' @len2:',@len2, ' @len:', @len
);
END

GO
