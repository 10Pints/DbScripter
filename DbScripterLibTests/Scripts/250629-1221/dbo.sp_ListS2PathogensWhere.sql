SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- Author:      Terry Watts
-- Create date: 07-JUL-20223
-- Description: Lists the Pathogen sets for the given @where_clause 
--
-- use to look for variations in pathogen naming,
-- misspellings and errors
-- ================================================================
CREATE   PROC [dbo].[sp_ListS2PathogensWhere] @where_clause VARCHAR(500)
AS
BEGIN
DECLARE 
     @sql            VARCHAR(MAX)
    ,@nl             VARCHAR(2) = NCHAR(0x0a) + NCHAR(0x0d)

SET @sql = CONCAT(
   'SELECT S.pathogens AS [s1.pathogens                                                                  .]
 , Count(s.id) as [count]
FROM
(
   SELECT DISTINCT pathogens
   FROM staging1 
   WHERE ',   @where_clause, '
) AS A
JOIN STAGING1 as S on A.PATHOGENS = s.PATHOGENS
GROUP BY s.pathogens 
ORDER BY S.Pathogens ASC;'
);
   PRINT CONCAT('@sql:', @nl, @sql);
   EXEC sp_executesql @sql;
END
/*
    EXEC sp_ListS2PathogensWhere 'Pathogens LIKE ''%(%'' OR Pathogens LIKE ''%)%'''
SELECT * FROM s2vw  WHERE [pathogens] LIKE '%butt mold%' AND [pathogens] NOT LIKE '%Butt molds%' COLLATE Latin1_General_CS_AI;
UPDATE staging2 SET [pathogens] = Replace(pathogens, 'butt mold', 'Butt mold'   COLLATE Latin1_General_CS_AI)    WHERE [pathogens] LIKE '%butt mold%' AND [pathogens] NOT LIKE 'Butt molds' COLLATE Latin1_General_CS_AI;
*/


GO
